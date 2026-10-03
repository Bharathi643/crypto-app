import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/crypto_provider.dart';
import '../utils/formatters.dart';
import '../widgets/coin_card.dart';
import '../widgets/metric_card.dart';
import 'coin_details_screen.dart';
import 'market_screen.dart';
import 'watchlist_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int tab = 0;

  static const _pages = <Widget>[
    _CoinsTab(),
    MarketScreen(),
    WatchlistScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: tab, children: _pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: tab,
        onDestinationSelected: (value) => setState(() => tab = value),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.currency_bitcoin_outlined),
            selectedIcon: Icon(Icons.currency_bitcoin_rounded),
            label: 'Coins',
          ),
          NavigationDestination(
            icon: Icon(Icons.bar_chart_rounded),
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

class _CoinsTab extends StatelessWidget {
  const _CoinsTab();

  @override
  Widget build(BuildContext context) {
    final p = context.watch<CryptoProvider>();
    final stats = p.stats;

    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF071625), Color(0xFF040C16)],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          onRefresh: p.refresh,
          color: const Color(0xFF19A9FF),
          backgroundColor: const Color(0xFF102234),
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverAppBar(
                pinned: true,
                automaticallyImplyLeading: false,
                backgroundColor: const Color(0xFF071625),
                surfaceTintColor: Colors.transparent,
                elevation: 0,
                toolbarHeight: 70,
                titleSpacing: 20,
                title: Row(
                  children: [
                    const Expanded(
                      child: _CryptoBrand(),
                    ),
                    _LiveIndicator(connected: p.socketConnected),
                    const SizedBox(width: 4),
                    IconButton(
                      tooltip: 'Refresh market data',
                      onPressed: p.refresh,
                      icon: const Icon(Icons.refresh_rounded),
                    ),
                  ],
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
                sliver: SliverToBoxAdapter(
                  child: Text(
                    'Track prices, compare market moves and research your coins.',
                    style: TextStyle(
                      color: Colors.white.withOpacity(.58),
                      fontSize: 12,
                      height: 1.35,
                    ),
                  ),
                ),
              ),
              if (stats != null)
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 2, 20, 14),
                  sliver: SliverToBoxAdapter(
                    child: SizedBox(
                      height: 116,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          MetricCard(
                            title: 'Total Market Cap',
                            value: money(stats.totalMarketCap),
                            icon: Icons.pie_chart_rounded,
                            color: const Color(0xFFFFC83D),
                          ),
                          const SizedBox(width: 10),
                          MetricCard(
                            title: '24h Volume',
                            value: money(stats.totalVolume),
                            icon: Icons.swap_vert_rounded,
                            color: const Color(0xFF2EE891),
                          ),
                          const SizedBox(width: 10),
                          MetricCard(
                            title: 'BTC Dominance',
                            value: '${stats.btcDominance.toStringAsFixed(1)}%',
                            icon: Icons.currency_bitcoin_rounded,
                            color: const Color(0xFF19A9FF),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverToBoxAdapter(
                  child: TextField(
                    onChanged: p.setSearch,
                    textInputAction: TextInputAction.search,
                    decoration: const InputDecoration(
                      hintText: 'Search coins...',
                      prefixIcon: Icon(Icons.search_rounded),
                    ),
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
                sliver: SliverToBoxAdapter(
                  child: Row(
                    children: [
                      _FilterPill(
                        label: 'All',
                        selected: p.filter == CoinFilter.all,
                        onTap: () => p.setFilter(CoinFilter.all),
                      ),
                      const SizedBox(width: 7),
                      _FilterPill(
                        label: 'Gainers',
                        selected: p.filter == CoinFilter.gainers,
                        onTap: () => p.setFilter(CoinFilter.gainers),
                      ),
                      const SizedBox(width: 7),
                      _FilterPill(
                        label: 'Losers',
                        selected: p.filter == CoinFilter.losers,
                        onTap: () => p.setFilter(CoinFilter.losers),
                      ),
                      const Spacer(),
                      PopupMenuButton<SortBy>(
                        onSelected: p.setSort,
                        itemBuilder: (_) => const [
                          PopupMenuItem(value: SortBy.marketCap, child: Text('Market Cap')),
                          PopupMenuItem(value: SortBy.price, child: Text('Price')),
                          PopupMenuItem(value: SortBy.change, child: Text('24h Change')),
                          PopupMenuItem(value: SortBy.volume, child: Text('Volume')),
                        ],
                        child: const Row(
                          children: [
                            Icon(Icons.sort_rounded, size: 18),
                            SizedBox(width: 4),
                            Text('Sort', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
                  child: Row(
                    children: [
                      Text('#', style: _columnStyle),
                      const SizedBox(width: 20),
                      Expanded(child: Text('Coin', style: _columnStyle)),
                      const Text('Price', style: _columnStyle),
                      const SizedBox(width: 48),
                      const Text('24h %', style: _columnStyle),
                    ],
                  ),
                ),
              ),
              if (p.loading && p.coins.isEmpty)
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (p.error != null && p.coins.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: _ErrorState(message: p.error!, retry: p.refresh),
                )
              else if (p.filtered.isEmpty)
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Text('No coins found', style: TextStyle(color: Colors.white54)),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                  sliver: SliverList.builder(
                    itemCount: p.filtered.length,
                    itemBuilder: (_, index) {
                      final coin = p.filtered[index];
                      return CoinCard(
                        coin: coin,
                        rank: index + 1,
                        watched: p.watched.contains(coin.symbol),
                        onWatch: () => p.toggleWatch(coin.symbol),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => CoinDetailsScreen(coin: coin),
                          ),
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  static const _columnStyle = TextStyle(
    color: Colors.white38,
    fontSize: 10,
    fontWeight: FontWeight.w700,
  );
}

class _CryptoBrand extends StatelessWidget {
  const _CryptoBrand();

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: const TextSpan(
        children: [
          TextSpan(
            text: 'Crypto',
            style: TextStyle(
              color: Color(0xFFFFC83D),
              fontSize: 27,
              fontWeight: FontWeight.w900,
              letterSpacing: -.7,
            ),
          ),
          TextSpan(
            text: ' App',
            style: TextStyle(
              color: Colors.white,
              fontSize: 27,
              fontWeight: FontWeight.w900,
              letterSpacing: -.7,
            ),
          ),
        ],
      ),
    );
  }
}

class _LiveIndicator extends StatelessWidget {
  final bool connected;
  const _LiveIndicator({required this.connected});

  @override
  Widget build(BuildContext context) {
    final color = connected ? const Color(0xFF2EE891) : Colors.orangeAccent;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(.10),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(.15)),
      ),
      child: Row(
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            connected ? 'LIVE' : 'CONNECTING',
            style: TextStyle(color: color, fontSize: 9, fontWeight: FontWeight.w900),
          ),
        ],
      ),
    );
  }
}

class _FilterPill extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _FilterPill({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        decoration: BoxDecoration(
          gradient: selected
              ? const LinearGradient(colors: [Color(0xFF1EA7FF), Color(0xFF1184DD)])
              : null,
          color: selected ? null : const Color(0xFF0C1B2A),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: selected ? Colors.transparent : Colors.white.withOpacity(.06)),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : Colors.white60,
            fontSize: 11,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final Future<void> Function() retry;
  const _ErrorState({required this.message, required this.retry});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: const Color(0xFF19A9FF).withOpacity(.08),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.cloud_off_rounded, size: 40, color: Colors.white54),
          ),
          const SizedBox(height: 16),
          const Text('Market data unavailable', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
          const SizedBox(height: 8),
          Text(message, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white54, height: 1.4)),
          const SizedBox(height: 18),
          FilledButton.icon(onPressed: retry, icon: const Icon(Icons.refresh_rounded), label: const Text('Try again')),
        ],
      ),
    );
  }
}
