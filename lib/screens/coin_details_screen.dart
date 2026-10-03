import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/coin.dart';
import '../models/market_stats.dart';
import '../providers/crypto_provider.dart';
import '../utils/formatters.dart';
import '../widgets/coin_avatar.dart';

class CoinDetailsScreen extends StatefulWidget {
  final Coin coin;

  const CoinDetailsScreen({super.key, required this.coin});

  @override
  State<CoinDetailsScreen> createState() => _CoinDetailsScreenState();
}

class _CoinDetailsScreenState extends State<CoinDetailsScreen> {
  String interval = '1h';
  int limit = 168;
  late Future<List<Candle>> future;
  late Future<Coin> detailsFuture;
  bool descriptionExpanded = false;

  @override
  void initState() {
    super.initState();
    final p = context.read<CryptoProvider>();
    future = p.history(widget.coin.symbol, interval, limit);
    detailsFuture = p.refreshCoin(widget.coin.symbol);
  }

  void loadChart(String nextInterval, int nextLimit) {
    setState(() {
      interval = nextInterval;
      limit = nextLimit;
      future = context.read<CryptoProvider>().history(
            widget.coin.symbol,
            interval,
            limit,
          );
    });
  }

  Future<void> _openWebsite(String rawUrl) async {
    var value = rawUrl.trim();
    if (value.isEmpty) return;
    if (!value.startsWith('http://') && !value.startsWith('https://')) {
      value = 'https://$value';
    }

    final uri = Uri.tryParse(value);
    if (uri == null || !uri.hasScheme) return;

    try {
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      if (!launched && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open the official website')),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open the official website')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<CryptoProvider>();
    final liveCoin = p.coins.firstWhere(
      (c) => c.symbol == widget.coin.symbol,
      orElse: () => widget.coin,
    );
    final positive = liveCoin.priceChangePercent24h >= 0;
    final accent = positive
        ? const Color(0xFF2EE891)
        : const Color(0xFFFF5E6D);

    return Scaffold(
      backgroundColor: const Color(0xFF040C16),
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        title: Row(
          children: [
            CoinAvatar(
              imageUrl: liveCoin.imageUrl,
              symbol: liveCoin.symbol,
              size: 34,
            ),
            const SizedBox(width: 9),
            Flexible(
              child: Text(
                '${liveCoin.name} (${liveCoin.symbol.replaceAll('USDT', '')})',
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () => p.toggleWatch(liveCoin.symbol),
            icon: Icon(
              p.watched.contains(liveCoin.symbol)
                  ? Icons.star_rounded
                  : Icons.star_border_rounded,
              color: p.watched.contains(liveCoin.symbol)
                  ? const Color(0xFFFFC83D)
                  : Colors.white,
            ),
          ),
        ],
      ),
      body: FutureBuilder<Coin>(
        future: detailsFuture,
        builder: (context, snapshot) {
          final coin = snapshot.data ?? liveCoin;
          final description = _cleanDescription(coin.description);
          final showReadMore = description.length > 360;
          final visibleDescription = descriptionExpanded || !showReadMore
              ? description
              : '${description.substring(0, 360).trim()}...';

          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 6, 20, 32),
            children: [
              Row(
                children: [
                  Text(
                    coin.symbol.replaceAll('USDT', '').toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white54,
                      fontWeight: FontWeight.w800,
                      fontSize: 11,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 9,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: (p.socketConnected
                              ? const Color(0xFF2EE891)
                              : Colors.orangeAccent)
                          .withOpacity(.10),
                      borderRadius: BorderRadius.circular(9),
                      border: Border.all(
                        color: (p.socketConnected
                                ? const Color(0xFF2EE891)
                                : Colors.orangeAccent)
                            .withOpacity(.14),
                      ),
                    ),
                    child: Text(
                      p.socketConnected ? 'LIVE' : 'RECONNECTING',
                      style: TextStyle(
                        color: p.socketConnected
                            ? const Color(0xFF2EE891)
                            : Colors.orangeAccent,
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                price(coin.price),
                style: const TextStyle(
                  fontSize: 39,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -1.2,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(
                    positive
                        ? Icons.arrow_upward_rounded
                        : Icons.arrow_downward_rounded,
                    color: accent,
                    size: 15,
                  ),
                  const SizedBox(width: 3),
                  Text(
                    '${positive ? '+' : ''}${coin.priceChangePercent24h.toStringAsFixed(2)}% (24h)',
                    style: TextStyle(
                      color: accent,
                      fontWeight: FontWeight.w900,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 17),
              _ChartPanel(
                future: future,
                positive: positive,
                accent: accent,
                onRetry: () => loadChart(interval, limit),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  _Period(label: '1H', active: interval == '1m', onTap: () => loadChart('1m', 240)),
                  _Period(label: '1D', active: interval == '5m', onTap: () => loadChart('5m', 288)),
                  _Period(label: '7D', active: interval == '1h', onTap: () => loadChart('1h', 168)),
                  _Period(label: '30D', active: interval == '4h', onTap: () => loadChart('4h', 180)),
                ],
              ),
              const SizedBox(height: 9),
              const Text(
                'Historical price • Binance REST + PostgreSQL',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white30, fontSize: 9),
              ),
              const SizedBox(height: 22),
              const Text(
                'Market Information',
                style: TextStyle(fontSize: 19, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 10),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 9,
                mainAxisSpacing: 9,
                childAspectRatio: 1.85,
                children: [
                  _InfoCard(label: 'Market Cap', value: money(coin.marketCap)),
                  _InfoCard(label: '24h Volume', value: money(coin.quoteVolume)),
                  _InfoCard(label: '24h High', value: price(coin.high24h)),
                  _InfoCard(label: '24h Low', value: price(coin.low24h)),
                  _InfoCard(label: 'Circulating Supply', value: supply(coin.circulatingSupply)),
                  _InfoCard(
                    label: 'Max Supply',
                    value: coin.maxSupply == null ? 'N/A' : supply(coin.maxSupply!),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Text(
                'About this coin',
                style: TextStyle(fontSize: 19, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 8),
              if (description.isEmpty)
                Text(
                  coin.description == null
                      ? 'Coin description is still syncing from CoinGecko.'
                      : 'Description is not currently available for this coin.',
                  style: const TextStyle(color: Colors.white54, height: 1.45),
                )
              else
                Text(
                  visibleDescription,
                  style: const TextStyle(
                    color: Colors.white70,
                    height: 1.5,
                    fontSize: 12,
                  ),
                ),
              if (showReadMore) ...[
                const SizedBox(height: 6),
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton(
                    onPressed: () => setState(() {
                      descriptionExpanded = !descriptionExpanded;
                    }),
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      foregroundColor: const Color(0xFF19A9FF),
                    ),
                    child: Text(
                      descriptionExpanded ? 'Read less' : 'Read more',
                      style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12),
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 14),
              if (coin.websiteUrl != null && coin.websiteUrl!.trim().isNotEmpty)
                OutlinedButton.icon(
                  onPressed: () => _openWebsite(coin.websiteUrl!),
                  icon: const Icon(Icons.language_rounded),
                  label: const Expanded(
                    child: Text(
                      'Open official website',
                      textAlign: TextAlign.center,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(54),
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Color(0xFF19A9FF), width: 1.3),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(17),
                    ),
                  ),
                )
              else
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0B1927),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Text(
                    'Official website is not available from CoinGecko for this coin.',
                    style: TextStyle(color: Colors.white54, fontSize: 12),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  String _cleanDescription(String? value) {
    if (value == null) return '';
    return value
        .replaceAll(RegExp(r'<[^>]*>'), ' ')
        .replaceAll('&amp;', '&')
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&quot;', '"')
        .replaceAll('&#39;', "'")
        .replaceAll('&#x27;', "'")
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }
}

class _ChartPanel extends StatelessWidget {
  final Future<List<Candle>> future;
  final bool positive;
  final Color accent;
  final VoidCallback onRetry;

  const _ChartPanel({
    required this.future,
    required this.positive,
    required this.accent,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 286,
      padding: const EdgeInsets.fromLTRB(10, 18, 14, 10),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF0D2132), Color(0xFF07131F)],
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withOpacity(.05)),
      ),
      child: FutureBuilder<List<Candle>>(
        future: future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return _ChartError(
              message: snapshot.error.toString().replaceFirst('Exception: ', ''),
              onRetry: onRetry,
            );
          }

          final data = snapshot.data ?? const <Candle>[];
          if (data.length < 2) {
            return _ChartError(
              message: 'No historical candles available yet.',
              onRetry: onRetry,
            );
          }

          final spots = data
              .asMap()
              .entries
              .map((e) => FlSpot(e.key.toDouble(), e.value.close))
              .toList();
          final minY = spots.map((e) => e.y).reduce((a, b) => a < b ? a : b);
          final maxY = spots.map((e) => e.y).reduce((a, b) => a > b ? a : b);
          final range = (maxY - minY).abs();
          final pad = range == 0 ? maxY.abs() * .01 + 0.000001 : range * .12;

          return LineChart(
            LineChartData(
              minY: minY - pad,
              maxY: maxY + pad,
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval: (range / 4).clamp(.000001, double.infinity),
                getDrawingHorizontalLine: (_) => FlLine(
                  color: Colors.white.withOpacity(.045),
                  strokeWidth: 1,
                ),
              ),
              titlesData: const FlTitlesData(show: false),
              borderData: FlBorderData(show: false),
              lineTouchData: LineTouchData(
                enabled: true,
                touchTooltipData: LineTouchTooltipData(
                  getTooltipItems: (spots) => spots
                      .map(
                        (spot) => LineTooltipItem(
                          price(spot.y),
                          const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
              lineBarsData: [
                LineChartBarData(
                  spots: spots,
                  isCurved: true,
                  curveSmoothness: .16,
                  barWidth: 2.4,
                  color: accent,
                  dotData: const FlDotData(show: false),
                  belowBarData: BarAreaData(
                    show: true,
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        accent.withOpacity(.18),
                        accent.withOpacity(.01),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _ChartError extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ChartError({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.show_chart_rounded, color: Colors.white38, size: 38),
          const SizedBox(height: 9),
          const Text(
            'Chart data unavailable',
            style: TextStyle(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 5),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              message,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white38, fontSize: 10),
            ),
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded, size: 16),
            label: const Text('Retry'),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF19A9FF),
              side: const BorderSide(color: Color(0xFF19A9FF)),
              visualDensity: VisualDensity.compact,
            ),
          ),
        ],
      ),
    );
  }
}

class _Period extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _Period({required this.label, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 3),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            padding: const EdgeInsets.symmetric(vertical: 11),
            decoration: BoxDecoration(
              gradient: active
                  ? const LinearGradient(
                      colors: [Color(0xFF19A9FF), Color(0xFF0D82D8)],
                    )
                  : null,
              color: active ? null : const Color(0xFF0B1927),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                label,
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String label;
  final String value;

  const _InfoCard({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: const Color(0xFF091825),
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: Colors.white.withOpacity(.045)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(label, style: const TextStyle(color: Colors.white54, fontSize: 10)),
          const SizedBox(height: 7),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14),
          ),
        ],
      ),
    );
  }
}
