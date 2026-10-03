import 'package:flutter/material.dart';

import 'coin_list_screen.dart';
import 'market_screen.dart';
import 'watchlist_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int index = 0;

  static const pages = <Widget>[
    CoinListScreen(),
    MarketScreen(),
    WatchlistScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: index,
        children: pages,
      ),
      bottomNavigationBar: NavigationBar(
        height: 72,
        selectedIndex: index,
        onDestinationSelected: (value) {
          setState(() {
            index = value;
          });
        },
        backgroundColor: Colors.white,
        indicatorColor: const Color(0xFFE7E4FF),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.currency_bitcoin_outlined),
            selectedIcon: Icon(Icons.currency_bitcoin_rounded),
            label: 'Coins',
          ),
          NavigationDestination(
            icon: Icon(Icons.bar_chart_outlined),
            selectedIcon: Icon(Icons.bar_chart_rounded),
            label: 'Market',
          ),
          NavigationDestination(
            icon: Icon(Icons.star_border_rounded),
            selectedIcon: Icon(Icons.star_rounded),
            label: 'Watchlist',
          ),
        ],
      ),
    );
  }
}
