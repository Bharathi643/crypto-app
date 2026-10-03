import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/crypto_provider.dart';
import '../utils/formatters.dart';
import '../widgets/coin_card.dart';
import '../widgets/metric_card.dart';
import 'coin_details_screen.dart';

class CoinListScreen extends StatelessWidget {
  const CoinListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CryptoProvider>();
    final stats = provider.stats;

    return SafeArea(
      child: RefreshIndicator(
        onRefresh: provider.refresh,
        color: const Color(0xFF5B55E8),
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 8),
              sliver: SliverToBoxAdapter(
                child: Row(
                  children: [
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Crypto Research',
                            style: TextStyle(
                              color: Color(0xFF797C88),
                              fontSize: 13,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Market overview',
                            style: TextStyle(
                              color: Color(0xFF171822),
                              fontSize: 27,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: const Color(0xFFEAEAF1),
                        ),
                      ),
                      child: IconButton(
                        onPressed: provider.refresh,
                        icon: const Icon(Icons.refresh_rounded),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              sliver: SliverToBoxAdapter(
                child: SizedBox(
                  height: 112,
                  child: stats == null
                      ? const SizedBox.shrink()
                      : ListView(
                          scrollDirection: Axis.horizontal,
                          children: [
                            MetricCard(
                              title: 'Market Cap',
                              value: money(stats.marketCap),
                              icon: Icons.pie_chart_rounded,
                              color: const Color(0xFF5B55E8),
                            ),
                            const SizedBox(width: 10),
                            MetricCard(
                              title: '24h Volume',
                              value: money(stats.volume),
                              icon: Icons.swap_vert_rounded,
                              color: const Color(0xFF16A66C),
                            ),
                            const SizedBox(width: 10),
                            MetricCard(
                              title: 'BTC Dominance',
                              value:
                                  '${stats.btcDominance.toStringAsFixed(1)}%',
                              icon: Icons.currency_bitcoin_rounded,
                              color: const Color(0xFFE2A529),
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
                  onChanged: provider.setSearch,
                  decoration: const InputDecoration(
                    hintText: 'Search coin or symbol',
                    prefixIcon: Icon(Icons.search_rounded),
                  ),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
              sliver: SliverToBoxAdapter(
                child: Row(
                  children: [
                    _FilterChip(
                      label: 'All',
                      selected: provider.filter == 0,
                      onTap: () => provider.setFilter(0),
                    ),
                    const SizedBox(width: 8),
                    _FilterChip(
                      label: 'Gainers',
                      selected: provider.filter == 1,
                      onTap: () => provider.setFilter(1),
                    ),
                    const SizedBox(width: 8),
                    _FilterChip(
                      label: 'Losers',
                      selected: provider.filter == 2,
                      onTap: () => provider.setFilter(2),
                    ),
                    const Spacer(),
                    PopupMenuButton<SortBy>(
                      onSelected: provider.setSort,
                      itemBuilder: (context) {
                        return const [
                          PopupMenuItem(
                            value: SortBy.marketCap,
                            child: Text('Market Cap'),
                          ),
                          PopupMenuItem(
                            value: SortBy.price,
                            child: Text('Price'),
                          ),
                          PopupMenuItem(
                            value: SortBy.change,
                            child: Text('24h Change'),
                          ),
                          PopupMenuItem(
                            value: SortBy.volume,
                            child: Text('Volume'),
                          ),
                        ];
                      },
                      child: const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 4),
                        child: Row(
                          children: [
                            Icon(Icons.sort_rounded, size: 19),
                            SizedBox(width: 4),
                            Text(
                              'Sort',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (provider.loading && provider.coins.isEmpty)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              )
            else if (provider.error != null && provider.coins.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: _ErrorState(
                  message: provider.error!,
                  onRetry: provider.refresh,
                ),
              )
            else if (provider.filtered.isEmpty)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: Text(
                    'No coins match your search.',
                    style: TextStyle(color: Color(0xFF797C88)),
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 25),
                sliver: SliverList.builder(
                  itemCount: provider.filtered.length,
                  itemBuilder: (context, index) {
                    final coin = provider.filtered[index];

                    return CoinCard(
                      coin: coin,
                      watched: provider.isWatched(coin.id),
                      onWatch: () => provider.toggle(coin.id),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                CoinDetailsScreen(coin: coin),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(
          horizontal: 13,
          vertical: 9,
        ),
        decoration: BoxDecoration(
          color: selected
              ? const Color(0xFF5B55E8)
              : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected
                ? const Color(0xFF5B55E8)
                : const Color(0xFFEAEAF1),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected
                ? Colors.white
                : const Color(0xFF616571),
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorState({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(30),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.cloud_off_rounded,
            size: 54,
            color: Color(0xFFACAFBB),
          ),
          const SizedBox(height: 16),
          const Text(
            'Something went wrong',
            style: TextStyle(
              color: Color(0xFF171822),
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF6F7280),
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 18),
          FilledButton(
            onPressed: onRetry,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}
