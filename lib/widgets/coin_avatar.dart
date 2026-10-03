import 'package:flutter/material.dart';

class CoinAvatar extends StatelessWidget {
  final String? imageUrl;
  final String symbol;
  final double size;
  const CoinAvatar({super.key, required this.imageUrl, required this.symbol, this.size = 46});

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: Container(
        width: size,
        height: size,
        color: const Color(0xFF1D2A3D),
        alignment: Alignment.center,
        child: imageUrl == null || imageUrl!.isEmpty
            ? Text(symbol.isEmpty ? '?' : symbol[0], style: const TextStyle(fontWeight: FontWeight.w900))
            : Image.network(imageUrl!, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Text(symbol.isEmpty ? '?' : symbol[0])),
      ),
    );
  }
}
