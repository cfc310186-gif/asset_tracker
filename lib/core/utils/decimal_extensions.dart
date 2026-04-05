import 'package:decimal/decimal.dart';

extension DecimalParsing on String {
  /// Parse string to Decimal, returns Decimal.zero on invalid input.
  Decimal toDecimal() {
    try {
      return Decimal.parse(this);
    } on FormatException {
      return Decimal.zero;
    }
  }

  /// Returns null if string is empty or unparseable.
  Decimal? toDecimalOrNull() {
    if (isEmpty) return null;
    try {
      return Decimal.parse(this);
    } on FormatException {
      return null;
    }
  }
}

extension DecimalFormatting on Decimal {
  /// Format to N decimal places as string.
  String toFixed(int decimalPlaces) {
    return toStringAsFixed(decimalPlaces);
  }

  /// Whether the value is positive (> 0).
  bool get isPositive => this > Decimal.zero;

  /// Whether the value is negative (< 0).
  bool get isNegative => this < Decimal.zero;

  /// Absolute value.
  Decimal get absValue => isNegative ? -this : this;

  /// Percentage string, e.g. "12.34%".
  String toPercentage({int decimalPlaces = 2}) =>
      '${toFixed(decimalPlaces)}%';
}
