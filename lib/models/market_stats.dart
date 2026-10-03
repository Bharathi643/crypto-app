import 'coin.dart';

class MarketStats {
  final double totalMarketCap;
  final double totalVolume;
  final double btcDominance;
  final int activeCoins;
  final int markets;
  final List<CoinTicker> topGainers;
  final List<CoinTicker> topLosers;

  const MarketStats({
    required this.totalMarketCap,
    required this.totalVolume,
    required this.btcDominance,
    required this.activeCoins,
    required this.markets,
    required this.topGainers,
    required this.topLosers,
  });

  factory MarketStats.fromJson(Map<String, dynamic> j) {
    double n(dynamic v) => v is num ? v.toDouble() : double.tryParse('${v ?? ''}') ?? 0;
    final gain = (j['topGainers'] as List? ?? const []).map((e) => CoinTicker.fromJson(Map<String, dynamic>.from(e))).toList();
    final loss = (j['topLosers'] as List? ?? const []).map((e) => CoinTicker.fromJson(Map<String, dynamic>.from(e))).toList();

    return MarketStats(
      totalMarketCap: n(j['totalMarketCap']),
      totalVolume: n(j['totalVolume']),
      btcDominance: n(j['btcDominance']),
      activeCoins: (j['activeCoins'] as num?)?.toInt() ?? 0,
      markets: (j['markets'] as num?)?.toInt() ?? 0,
      topGainers: gain,
      topLosers: loss,
    );
  }
}

class CoinTicker {
  final String symbol;
  final double price;
  final double priceChangePercent24h;

  const CoinTicker({
    required this.symbol,
    required this.price,
    required this.priceChangePercent24h,
  });

  factory CoinTicker.fromJson(Map<String, dynamic> j) => CoinTicker(
        symbol: '${j['symbol'] ?? ''}',
        price: (j['price'] as num?)?.toDouble() ?? 0,
        priceChangePercent24h: (j['priceChangePercent24h'] as num?)?.toDouble() ?? 0,
      );
}

class Candle {
  final DateTime time;
  final double open;
  final double high;
  final double low;
  final double close;
  final double volume;

  const Candle({
    required this.time,
    required this.open,
    required this.high,
    required this.low,
    required this.close,
    required this.volume,
  });

  factory Candle.fromJson(Map<String, dynamic> j) {
    double n(dynamic v) => v is num ? v.toDouble() : double.tryParse('${v ?? ''}') ?? 0;
    final openTime = j['openTime'] ?? j['open_time'] ?? 0;
    final milliseconds = openTime is num
        ? openTime.toInt()
        : int.tryParse('$openTime') ?? 0;
    return Candle(
      time: DateTime.fromMillisecondsSinceEpoch(milliseconds),
      open: n(j['open']),
      high: n(j['high']),
      low: n(j['low']),
      close: n(j['close']),
      volume: n(j['volume']),
    );
  }
}
