class Coin {
  final String symbol;
  final String coingeckoId;
  final String name;
  final String? imageUrl;
  final String? description;
  final String? websiteUrl;
  final double marketCap;
  final double circulatingSupply;
  final double? totalSupply;
  final double? maxSupply;
  final double price;
  final double priceChange24h;
  final double priceChangePercent24h;
  final double high24h;
  final double low24h;
  final double volume;
  final double quoteVolume;
  final int eventTime;
  final int rank;

  const Coin({
    required this.symbol,
    required this.coingeckoId,
    required this.name,
    required this.imageUrl,
    required this.description,
    required this.websiteUrl,
    required this.marketCap,
    required this.circulatingSupply,
    required this.totalSupply,
    required this.maxSupply,
    required this.price,
    required this.priceChange24h,
    required this.priceChangePercent24h,
    required this.high24h,
    required this.low24h,
    required this.volume,
    required this.quoteVolume,
    required this.eventTime,
    required this.rank,
  });

  factory Coin.fromJson(Map<String, dynamic> j) {
    double n(dynamic v) => v is num ? v.toDouble() : double.tryParse('${v ?? ''}') ?? 0;
    double? nullable(dynamic v) => v == null ? null : n(v);

    return Coin(
      symbol: '${j['symbol'] ?? ''}',
      coingeckoId: '${j['coingeckoId'] ?? ''}',
      name: '${j['name'] ?? j['symbol'] ?? 'Unknown'}',
      imageUrl: j['imageUrl']?.toString(),
      description: j['description']?.toString(),
      websiteUrl: j['websiteUrl']?.toString(),
      marketCap: n(j['marketCap']),
      circulatingSupply: n(j['circulatingSupply']),
      totalSupply: nullable(j['totalSupply']),
      maxSupply: nullable(j['maxSupply']),
      price: n(j['price']),
      priceChange24h: n(j['priceChange24h']),
      priceChangePercent24h: n(j['priceChangePercent24h']),
      high24h: n(j['high24h']),
      low24h: n(j['low24h']),
      volume: n(j['volume']),
      quoteVolume: n(j['quoteVolume']),
      eventTime: (j['eventTime'] as num?)?.toInt() ?? 0,
      rank: (j['rank'] as num?)?.toInt() ?? 0,
    );
  }

  Coin withLive(Map<String, dynamic> update) => Coin(
        symbol: symbol,
        coingeckoId: coingeckoId,
        name: name,
        imageUrl: imageUrl,
        description: description,
        websiteUrl: websiteUrl,
        marketCap: marketCap,
        circulatingSupply: circulatingSupply,
        totalSupply: totalSupply,
        maxSupply: maxSupply,
        price: update['price'] is num ? (update['price'] as num).toDouble() : price,
        priceChange24h: update['priceChange24h'] is num ? (update['priceChange24h'] as num).toDouble() : priceChange24h,
        priceChangePercent24h: update['priceChangePercent24h'] is num ? (update['priceChangePercent24h'] as num).toDouble() : priceChangePercent24h,
        high24h: update['high24h'] is num ? (update['high24h'] as num).toDouble() : high24h,
        low24h: update['low24h'] is num ? (update['low24h'] as num).toDouble() : low24h,
        volume: update['volume'] is num ? (update['volume'] as num).toDouble() : volume,
        quoteVolume: update['quoteVolume'] is num ? (update['quoteVolume'] as num).toDouble() : quoteVolume,
        eventTime: update['eventTime'] is num ? (update['eventTime'] as num).toInt() : eventTime,
        rank: rank,
      );
}
