// lib/presentation/owner/payments/currency_utils.dart

/// Small self-contained helpers so this feature doesn't need to add the
/// `intl` package as a new dependency. If your project already uses
/// `intl` / `NumberFormat`, feel free to swap this out.
class CurrencyUtils {
  CurrencyUtils._();

  /// Formats a number using Indian digit grouping (e.g. 1,23,456) with a
  /// ₹ prefix, no decimals if the value is a whole number.
  static String formatInr(double amount) {
    final bool isWhole = amount == amount.roundToDouble();
    final String fixed =
    isWhole ? amount.toStringAsFixed(0) : amount.toStringAsFixed(2);

    final parts = fixed.split('.');
    final wholePart = parts[0];
    final decimalPart = parts.length > 1 ? '.${parts[1]}' : '';

    final isNegative = wholePart.startsWith('-');
    final digits = isNegative ? wholePart.substring(1) : wholePart;

    String grouped;
    if (digits.length <= 3) {
      grouped = digits;
    } else {
      final lastThree = digits.substring(digits.length - 3);
      final rest = digits.substring(0, digits.length - 3);
      final buffer = StringBuffer();
      for (int i = 0; i < rest.length; i++) {
        final posFromEnd = rest.length - i;
        buffer.write(rest[i]);
        if (posFromEnd > 1 && posFromEnd % 2 == 1) {
          buffer.write(',');
        }
      }
      grouped = '${buffer.toString()},$lastThree';
    }

    return '${isNegative ? '-' : ''}\u20B9$grouped$decimalPart';
  }
}