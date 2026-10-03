import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/crypto_provider.dart';
import '../widgets/coin_card.dart';
import 'coin_details_screen.dart';

class WatchlistScreen extends StatelessWidget {
  const WatchlistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.watch<CryptoProvider>();
    final rows = p.watchlistCoins;

    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF071625), Color(0xFF040C16)],
        ),
      ),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 30),
          children: [
            RichText(
              text: const TextSpan(
                children: [
                  TextSpan(
                    text: 'Crypto',
                    style: TextStyle(color: Color(0xFFFFC83D), fontSize: 28, fontWeight: FontWeight.w900),
                  ),
                  TextSpan(
                    text: ' App',
                    style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w900),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 7),
            const Text('My Watchlist', style: TextStyle(fontSize: 21, fontWeight: FontWeight.w900)),
            const SizedBox(height: 4),
            const Text('Track the coins you want to research.', style: TextStyle(color: Colors.white54, fontSize: 12)),
            const SizedBox(height: 18),
            const SizedBox(height: 16),
            if (rows.isEmpty)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 70),
                decoration: BoxDecoration(color: const Color(0xFF081521), borderRadius: BorderRadius.circular(24), border: Border.all(color: Colors.white.withOpacity(.045))),
                child: Column(children: [
                  Container(width: 64, height: 64, decoration: BoxDecoration(color: const Color(0xFFFFC83D).withOpacity(.08), shape: BoxShape.circle), child: const Icon(Icons.bookmark_border_rounded, size: 34, color: Color(0xFFFFC83D))),
                  const SizedBox(height: 16),
                  const Text('Your watchlist is empty', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 7),
                  const Text('No coins have been added to your watchlist yet.', textAlign: TextAlign.center, style: TextStyle(color: Colors.white54, height: 1.4)),
                ]),
              )
            else
              ...rows.map((coin) => CoinCard(
                    coin: coin,
                    rank: rows.indexOf(coin) + 1,
                    watched: true,
                    onWatch: () => p.toggleWatch(coin.symbol),
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => CoinDetailsScreen(coin: coin))),
                  )),
          ],
        ),
      ),
    );
  }
}
