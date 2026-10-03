import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/coin.dart';
import '../models/market_stats.dart';
import '../providers/crypto_provider.dart';
import '../utils/formatters.dart';
import 'top_movers_screen.dart';

class MarketScreen extends StatelessWidget {
  const MarketScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.watch<CryptoProvider>();
    final stats = p.stats;

    final gainers = [...p.coins]
      ..removeWhere((coin) => coin.priceChangePercent24h <= 0)
      ..sort((a, b) => b.priceChangePercent24h.compareTo(a.priceChangePercent24h));
    final losers = [...p.coins]
      ..removeWhere((coin) => coin.priceChangePercent24h >= 0)
      ..sort((a, b) => a.priceChangePercent24h.compareTo(b.priceChangePercent24h));

    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF071625), Color(0xFF040C16)],
        ),
      ),
      child: SafeArea(
        child: RefreshIndicator(
          onRefresh: p.refresh,
          color: const Color(0xFF19A9FF),
          backgroundColor: const Color(0xFF102234),
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
            children: [
              Row(
                children: [
                  const Expanded(child: _CryptoBrand()),
                  _LiveDot(connected: p.socketConnected),
                  IconButton(
                    onPressed: p.refresh,
                    icon: const Icon(Icons.refresh_rounded),
                  ),
                ],
              ),
              const SizedBox(height: 3),
              const Text('Global Market Stats', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
              const SizedBox(height: 14),
              if (stats == null && p.loading)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 80),
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (stats == null)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 80),
                  child: Center(child: Text('Market statistics unavailable', style: TextStyle(color: Colors.white54))),
                )
              else ...[
                _HeroStat(label: 'Total Market Cap', value: money(stats.totalMarketCap), accent: const Color(0xFFFFC83D)),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(child: _SmallStat(title: '24h Volume', value: money(stats.totalVolume), accent: const Color(0xFF2EE891))),
                    const SizedBox(width: 10),
                    Expanded(child: _SmallStat(title: 'BTC Dominance', value: '${stats.btcDominance.toStringAsFixed(2)}%', accent: const Color(0xFF19A9FF))),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(child: _SmallStat(title: 'Active Coins', value: stats.activeCoins.toString(), accent: const Color(0xFFB37CFF))),
                    const SizedBox(width: 10),
                    Expanded(child: _SmallStat(title: 'Markets', value: stats.markets.toString(), accent: const Color(0xFFFF8E5E))),
                  ],
                ),
                const SizedBox(height: 24),
                _SectionHeader(
                  title: 'Top Gainers',
                  subtitle: '${gainers.length} available',
                  accent: const Color(0xFF2EE891),
                  showSeeAll: gainers.length > 4,
                  onSeeAll: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const TopMoversScreen(gainers: true)),
                  ),
                ),
                const SizedBox(height: 9),
                _MoverCard(rows: gainers, positive: true),
                const SizedBox(height: 16),
                _SectionHeader(
                  title: 'Top Losers',
                  subtitle: '${losers.length} available',
                  accent: const Color(0xFFFF5E6D),
                  showSeeAll: losers.length > 4,
                  onSeeAll: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const TopMoversScreen(gainers: false)),
                  ),
                ),
                const SizedBox(height: 9),
                _MoverCard(rows: losers, positive: false),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _CryptoBrand extends StatelessWidget {
  const _CryptoBrand();
  @override
  Widget build(BuildContext context) {
    return RichText(
      text: const TextSpan(
        children: [
          TextSpan(text: 'Crypto', style: TextStyle(color: Color(0xFFFFC83D), fontSize: 28, fontWeight: FontWeight.w900)),
          TextSpan(text: ' App', style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }
}

class _LiveDot extends StatelessWidget {
  final bool connected;
  const _LiveDot({required this.connected});
  @override
  Widget build(BuildContext context) {
    final color = connected ? const Color(0xFF2EE891) : Colors.orangeAccent;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(.10),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(.14)),
      ),
      child: Row(
        children: [
          Container(width: 6, height: 6, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 5),
          Text(connected ? 'LIVE' : 'CONNECTING', style: TextStyle(color: color, fontSize: 8, fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final Color accent;
  final bool showSeeAll;
  final VoidCallback onSeeAll;

  const _SectionHeader({
    required this.title,
    required this.subtitle,
    required this.accent,
    required this.showSeeAll,
    required this.onSeeAll,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Row(
            children: [
              Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
              const SizedBox(width: 8),
              Text(subtitle, style: const TextStyle(color: Colors.white38, fontSize: 10)),
            ],
          ),
        ),
        if (showSeeAll)
          TextButton(
            onPressed: onSeeAll,
            style: TextButton.styleFrom(
              foregroundColor: accent,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: const Row(
              children: [
                Text('See All', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 11)),
                SizedBox(width: 3),
                Icon(Icons.arrow_forward_rounded, size: 14),
              ],
            ),
          ),
      ],
    );
  }
}

class _HeroStat extends StatelessWidget {
  final String label;
  final String value;
  final Color accent;
  const _HeroStat({required this.label, required this.value, required this.accent});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF15233A), Color(0xFF0A1726)]),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: accent.withOpacity(.13)),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(color: accent.withOpacity(.12), borderRadius: BorderRadius.circular(15)),
            child: Icon(Icons.pie_chart_rounded, color: accent),
          ),
          const SizedBox(width: 14),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(label, style: const TextStyle(color: Colors.white54, fontSize: 11)),
            const SizedBox(height: 4),
            Text(value, style: const TextStyle(fontSize: 25, fontWeight: FontWeight.w900)),
          ]),
        ],
      ),
    );
  }
}

class _SmallStat extends StatelessWidget {
  final String title;
  final String value;
  final Color accent;
  const _SmallStat({required this.title, required this.value, required this.accent});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFF0B1927),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(.05)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: const TextStyle(color: Colors.white54, fontSize: 10)),
        const SizedBox(height: 6),
        Text(value, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 17)),
        const SizedBox(height: 4),
        Row(children: [
          Container(width: 6, height: 6, decoration: BoxDecoration(color: accent, shape: BoxShape.circle)),
          const SizedBox(width: 5),
          Text('Live market data', style: TextStyle(color: accent, fontSize: 9, fontWeight: FontWeight.w700)),
        ]),
      ]),
    );
  }
}

class _MoverCard extends StatelessWidget {
  final List<Coin> rows;
  final bool positive;
  const _MoverCard({required this.rows, required this.positive});

  @override
  Widget build(BuildContext context) {
    final accent = positive ? const Color(0xFF2EE891) : const Color(0xFFFF5E6D);
    final list = rows.take(4).toList();

    return Container(
      padding: const EdgeInsets.fromLTRB(15, 14, 15, 12),
      decoration: BoxDecoration(
        color: const Color(0xFF081521),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(.045)),
      ),
      child: Column(
        children: [
          if (list.isEmpty)
            const Padding(
              padding: EdgeInsets.all(14),
              child: Text('No mover data available', style: TextStyle(color: Colors.white54)),
            )
          else
            ...list.asMap().entries.map((entry) {
              final coin = entry.value;
              final symbol = coin.symbol.replaceAll('USDT', '');
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    SizedBox(width: 20, child: Text('${entry.key + 1}', style: const TextStyle(color: Colors.white38, fontSize: 10))),
                    Expanded(
                      child: Text(
                        coin.name.isEmpty ? symbol : coin.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
                      ),
                    ),
                    Text(price(coin.price), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800)),
                    const SizedBox(width: 14),
                    Text(
                      '${positive ? '+' : ''}${coin.priceChangePercent24h.toStringAsFixed(2)}%',
                      style: TextStyle(color: accent, fontSize: 10, fontWeight: FontWeight.w900),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }
}
