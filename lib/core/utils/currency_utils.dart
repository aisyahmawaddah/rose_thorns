// lib/core/utils/currency_utils.dart
class CurrencyUtils {
  static String formatMYR(double amount) {
    return 'RM ${amount.toStringAsFixed(2)}';
  }

  static String formatMYRCompact(double amount) {
    if (amount >= 1000) {
      return 'RM ${(amount / 1000).toStringAsFixed(1)}k';
    }
    return formatMYR(amount);
  }
}
