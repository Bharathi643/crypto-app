import 'package:flutter/material.dart';

import '../models/coin.dart';
import '../utils/formatters.dart';
import 'coin_avatar.dart';

class CoinCard extends StatelessWidget {
  final Coin coin;
  final int rank;
  final bool watched;
  final VoidCallback onTap;
  final VoidCallback onWatch;

  const CoinCard({
    super.key,
    required this.coin,
    required this.rank,
    required this.watched,
    required this.onTap,
    required this.onWatch,
  });

  @override
  Widget build(BuildContext context) {
    final positive = coin.priceChangePercent24h >= 0;
    final changeColor = positive ? const Color(0xFF2EE891) : const Color(0xFFFF5E6D);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          margin: const EdgeInsets.only(bottom: 7),
          padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 5),
          decoration: BoxDecoration(
            color: const Color(0xFF07131F),
            borderRadius: BorderRadius.circular(17),
            border: Border.all(color: Colors.white.withOpacity(.045)),
          ),
          child: Row(
            children: [
              SizedBox(
                width: 22,
                child: Text(
                  '$rank',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white38, fontSize: 11, fontWeight: FontWeight.w700),
                ),
              ),
              const SizedBox(width: 12),
              CoinAvatar(imageUrl: coin.imageUrl, symbol: coin.symbol, size: 40),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      coin.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      coin.symbol.replaceAll('USDT', '').toUpperCase(),
                      style: TextStyle(color: Colors.white.withOpacity(.42), fontSize: 10, fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(price(coin.price), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12)),
                  const SizedBox(height: 3),
                  Text(
                    '${positive ? '+' : ''}${coin.priceChangePercent24h.toStringAsFixed(2)}%',
                    style: TextStyle(color: changeColor, fontWeight: FontWeight.w900, fontSize: 10),
                  ),
                ],
              ),
              const SizedBox(width: 4),
              IconButton(
                visualDensity: VisualDensity.compact,
                onPressed: onWatch,
                icon: Icon(
                  watched ? Icons.star_rounded : Icons.star_border_rounded,
                  size: 21,
                  color: watched ? const Color(0xFFFFC83D) : Colors.white30,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
