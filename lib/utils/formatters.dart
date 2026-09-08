String formatPeso(double amount) {
  final parts = amount.toStringAsFixed(2).split('.');
  final regexp = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
  final formattedInteger =
      parts[0].replaceAllMapped(regexp, (Match m) => '${m[1]},');
  return '₱$formattedInteger.${parts[1]}';
}
