String money(double value) {
  final abs = value.abs();
  final sign = value < 0 ? '-' : '';
  if (abs >= 1e12) return '$sign\$${(abs / 1e12).toStringAsFixed(2)}T';
  if (abs >= 1e9) return '$sign\$${(abs / 1e9).toStringAsFixed(2)}B';
  if (abs >= 1e6) return '$sign\$${(abs / 1e6).toStringAsFixed(2)}M';
  if (abs >= 1e3) return '$sign\$${(abs / 1e3).toStringAsFixed(2)}K';
  return '$sign\$${abs.toStringAsFixed(2)}';
}

String price(double value) {
  if (value >= 10000) return '\$${value.toStringAsFixed(0)}';
  if (value >= 1000) return '\$${value.toStringAsFixed(2)}';
  if (value >= 1) return '\$${value.toStringAsFixed(2)}';
  if (value >= .01) return '\$${value.toStringAsFixed(4)}';
  return '\$${value.toStringAsFixed(6)}';
}

String supply(double value) {
  if (value >= 1e9) return '${(value/1e9).toStringAsFixed(2)}B';
  if (value >= 1e6) return '${(value/1e6).toStringAsFixed(2)}M';
  if (value >= 1e3) return '${(value/1e3).toStringAsFixed(2)}K';
  return value.toStringAsFixed(2);
}
