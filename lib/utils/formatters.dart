/// Formats a price as pesos, e.g. 1299.0 → "₱1,299", 12.5 → "₱12.50".
String formatPeso(double value) {
  final isWhole = value == value.roundToDouble();
  final fixed = value.toStringAsFixed(isWhole ? 0 : 2);
  final parts = fixed.split('.');
  final digits = parts[0];
  final buffer = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) buffer.write(',');
    buffer.write(digits[i]);
  }
  return '₱$buffer${parts.length > 1 ? '.${parts[1]}' : ''}';
}
