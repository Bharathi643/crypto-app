import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../models/coin.dart';
import '../models/market_stats.dart';

class ApiService {
  late final Dio _dio;

  ApiService() {
    _dio = Dio(BaseOptions(
      baseUrl: dotenv.env['API_BASE_URL'] ?? 'http://localhost:5000/api',
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 25),
      headers: {'accept': 'application/json'},
    ));
  }

  List<dynamic> _extractList(dynamic body, String field) {
    if (body is List) return body;
    if (body is Map && body[field] is List) return List<dynamic>.from(body[field] as List);
    if (body is Map && body['data'] is List) return List<dynamic>.from(body['data'] as List);
    throw Exception('Invalid $field response from backend');
  }

  Map<String, dynamic> _extractObject(dynamic body) {
    if (body is Map && body['data'] is Map) return Map<String, dynamic>.from(body['data'] as Map);
    if (body is Map) return Map<String, dynamic>.from(body);
    throw Exception('Invalid object response from backend');
  }

  Future<List<Coin>> getCoins() async {
    final response = await _dio.get('/coins');
    final list = _extractList(response.data, 'coins');
    return list.map((e) => Coin.fromJson(Map<String, dynamic>.from(e as Map))).toList();
  }

  Future<MarketStats> getMarket() async {
    final response = await _dio.get('/market');
    return MarketStats.fromJson(_extractObject(response.data));
  }

  Future<Coin> getCoin(String symbol) async {
    final response = await _dio.get('/coins/${symbol.toUpperCase()}');
    return Coin.fromJson(_extractObject(response.data));
  }

  Future<List<Candle>> getHistory(String symbol, {String interval = '1h', int limit = 168}) async {
    final response = await _dio.get('/coins/${symbol.toUpperCase()}/history', queryParameters: {
      'interval': interval,
      'limit': limit,
    });
    final list = _extractList(response.data, 'candles');
    return list.map((e) => Candle.fromJson(Map<String, dynamic>.from(e as Map))).toList();
  }

  Future<Set<String>> getWatchlist(String deviceId) async {
    final response = await _dio.get('/watchlist', queryParameters: {'deviceId': deviceId});
    final list = _extractList(response.data, 'symbols');
    return list.map((e) => '$e').toSet();
  }

  Future<void> addWatch(String deviceId, String symbol) async {
    await _dio.post('/watchlist', data: {'deviceId': deviceId, 'symbol': symbol});
  }

  Future<void> removeWatch(String deviceId, String symbol) async {
    await _dio.delete('/watchlist/${symbol.toUpperCase()}', queryParameters: {'deviceId': deviceId});
  }
}
