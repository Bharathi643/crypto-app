import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/coin.dart';
import '../providers/crypto_provider.dart';
import '../utils/formatters.dart';
import '../widgets/coin_card.dart';
import 'coin_details_screen.dart';

class TopMoversScreen extends StatelessWidget {
  final bool gainers;

  const TopMoversScreen({super.key, required this.gainers});

  @override
  Widget build(BuildContext context) {
    final p = context.watch<CryptoProvider>();
    final coins = [...p.coins];

    coins.removeWhere((coin) => gainers
        ? coin.priceChangePercent24h <= 0
        : coin.priceChangePercent24h >= 0);

    coins.sort(
      (a, b) => gainers
          ? b.priceChangePercent24h.compareTo(a.priceChangePercent24h)
          : a.priceChangePercent24h.compareTo(b.priceChangePercent24h),
    );

    final accent = gainers ? const Color(0xFF2EE891) : const Color(0xFFFF5E6D);

    return Scaffold(
      backgroundColor: const Color(0xFF040C16),
      appBar: AppBar(
        title: Text(
          gainers ? 'Top Gainers' : 'Top Losers',
          style: const TextStyle(fontWeight: FontWeight.w900),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: p.refresh,
        color: accent,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 28),
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    accent.withOpacity(.16),
                    const Color(0xFF0B1927),
                  ],
                ),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: accent.withOpacity(.12)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: accent.withOpacity(.13),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      gainers ? Icons.trending_up_rounded : Icons.trending_down_rounded,
                      color: accent,
                    ),
                  ),
                  const SizedBox(width: 13),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          gainers ? 'Strongest 24h performers' : 'Weakest 24h performers',
                          style: const TextStyle(fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${coins.length} coins available',
                          style: const TextStyle(color: Colors.white54, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            if (coins.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 80),
                child: Center(
                  child: Text('No mover data available', style: TextStyle(color: Colors.white54)),
                ),
              )
            else
              ...coins.asMap().entries.map((entry) {
                final coin = entry.value;
                return CoinCard(
                  coin: coin,
                  rank: entry.key + 1,
                  watched: p.watched.contains(coin.symbol),
                  onWatch: () => p.toggleWatch(coin.symbol),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CoinDetailsScreen(coin: coin),
                    ),
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }
}
