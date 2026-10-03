import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/crypto_provider.dart';
import 'coin_list_screen.dart';
import 'market_screen.dart';
import 'watchlist_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int index = 0;

  @override
  Widget build(BuildContext context) {
    final pages = const [
      CoinListScreen(),
      MarketScreen(),
      WatchlistScreen(),
    ];

    return Scaffold(
      body: SafeArea(child: pages[index]),
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (value) => setState(() => index = value),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.currency_bitcoin), label: 'Coins'),
          NavigationDestination(icon: Icon(Icons.analytics_outlined), label: 'Market'),
          NavigationDestination(icon: Icon(Icons.star_outline), label: 'Watchlist'),
        ],
      ),
    );
  }
}
