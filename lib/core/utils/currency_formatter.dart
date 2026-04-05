import 'package:decimal/decimal.dart';
import 'package:intl/intl.dart';

import '../../domain/enums/currency_code.dart';
class CurrencyFormatter {
  CurrencyFormatter._();

  static final _formatters = <CurrencyCode, NumberFormat>{
    CurrencyCode.twd: NumberFormat('#,##0', 'zh_TW'), // TWD: no decimals
    CurrencyCode.usd: NumberFormat('#,##0.00', 'en_US'), // USD: 2 decimals
    CurrencyCode.gbp: NumberFormat('#,##0.00', 'en_GB'), // GBP: 2 decimals
  };

  /// Format amount with currency symbol, e.g. "NT$1,234,567" or "$1,234.56".
  static String format(Decimal amount, CurrencyCode currency) {
    final formatter = _formatters[currency] ?? NumberFormat('#,##0.00');
    final symbol = currency.symbol;
    // Note: toDouble() used for display formatting only. For TWD integer amounts
    // this is exact. For USD/GBP, rounding to 2 decimal places via NumberFormat
    // absorbs any float noise at the display layer.
    return '$symbol${formatter.format(amount.toDouble())}';
  }

  /// Format with explicit sign for gains/losses, e.g. "+$123.45" or "-$67.89".
  static String formatWithSign(Decimal amount, CurrencyCode currency) {
    final formatted = format(amount.abs(), currency);
    return amount < Decimal.zero ? '-$formatted' : '+$formatted';
  }

  /// Format a rate as percentage, e.g. 0.035 -> "3.50%".
  static String formatRate(Decimal rate) {
    final percentage = rate * Decimal.fromInt(100);
    return '${percentage.toStringAsFixed(2)}%';
  }
}
