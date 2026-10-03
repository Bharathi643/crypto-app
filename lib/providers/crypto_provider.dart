import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/coin.dart';
import '../models/market_stats.dart';
import '../services/api_service.dart';
import '../services/realtime_service.dart';

enum SortBy { marketCap, price, change, volume }
enum CoinFilter { all, gainers, losers }

class CryptoProvider extends ChangeNotifier {
  final ApiService api;
  final RealtimeService realtime;
  final String deviceId;

  CryptoProvider({required this.api, required this.realtime, required this.deviceId});

  List<Coin> coins = [];
  MarketStats? stats;
  Set<String> watched = {};
  bool loading = false;
  String? error;
  bool socketConnected = false;
  String search = '';
  CoinFilter filter = CoinFilter.all;
  SortBy sortBy = SortBy.marketCap;
  StreamSubscription? _socketSub;

  Future<void> initialize() async {
    _socketSub = realtime.stream.listen(_handleSocket);
    realtime.connect();
    await refresh();
    try { watched = await api.getWatchlist(deviceId); } catch (_) {}
    notifyListeners();
  }

  Future<void> refresh() async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      final results = await Future.wait([api.getCoins(), api.getMarket()]);
      coins = results[0] as List<Coin>;
      stats = results[1] as MarketStats;
    } catch (e) {
      error = e.toString().replaceFirst('Exception: ', '');
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  void _handleSocket(Map<String, dynamic> m) {
    if (m['type'] == 'connection' || m['type'] == 'source_status') {
      socketConnected = m['status'] == 'connected';
      notifyListeners();
      return;
    }
    if (m['type'] != 'ticker') return;
    final symbol = '${m['symbol'] ?? ''}'.toUpperCase();
    final index = coins.indexWhere((c) => c.symbol == symbol);
    if (index == -1) return;
    coins[index] = coins[index].withLive(m);
    notifyListeners();
  }

  List<Coin> get filtered {
    final q = search.trim().toLowerCase();
    final list = coins.where((coin) {
      final matches = q.isEmpty || coin.name.toLowerCase().contains(q) || coin.symbol.toLowerCase().contains(q);
      final filterMatch = switch (filter) {
        CoinFilter.all => true,
        CoinFilter.gainers => coin.priceChangePercent24h > 0,
        CoinFilter.losers => coin.priceChangePercent24h < 0,
      };
      return matches && filterMatch;
    }).toList();

    list.sort((a, b) {
      switch (sortBy) {
        case SortBy.marketCap: return b.marketCap.compareTo(a.marketCap);
        case SortBy.price: return b.price.compareTo(a.price);
        case SortBy.change: return b.priceChangePercent24h.compareTo(a.priceChangePercent24h);
        case SortBy.volume: return b.volume.compareTo(a.volume);
      }
    });
    return list;
  }

  List<Coin> get watchlistCoins => coins.where((c) => watched.contains(c.symbol)).toList();

  void setSearch(String value) { search = value; notifyListeners(); }
  void setFilter(CoinFilter value) { filter = value; notifyListeners(); }
  void setSort(SortBy value) { sortBy = value; notifyListeners(); }

  Future<void> toggleWatch(String symbol) async {
    final exists = watched.contains(symbol);
    try {
      if (exists) {
        await api.removeWatch(deviceId, symbol);
        watched.remove(symbol);
      } else {
        await api.addWatch(deviceId, symbol);
        watched.add(symbol);
      }
      notifyListeners();
    } catch (e) {
      error = 'Watchlist update failed';
      notifyListeners();
    }
  }

  Future<List<Candle>> history(String symbol, String interval, int limit) => api.getHistory(symbol, interval: interval, limit: limit);

  Future<Coin> refreshCoin(String symbol) => api.getCoin(symbol);

  @override
  void dispose() {
    _socketSub?.cancel();
    realtime.dispose();
    super.dispose();
  }
}
