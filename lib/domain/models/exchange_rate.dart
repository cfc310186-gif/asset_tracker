import 'package:decimal/decimal.dart';
import 'package:flutter/foundation.dart';

import '../enums/currency_code.dart';

@immutable
class ExchangeRate {
  final String id;
  final CurrencyCode fromCurrency;
  final CurrencyCode toCurrency;
  final Decimal rate;
  final DateTime fetchedAt;

  const ExchangeRate({
    required this.id,
    required this.fromCurrency,
    required this.toCurrency,
    required this.rate,
    required this.fetchedAt,
  });

  /// Converts [amount] from [fromCurrency] to [toCurrency] using this rate.
  Decimal convert(Decimal amount) => amount * rate;

  ExchangeRate copyWith({
    String? id,
    CurrencyCode? fromCurrency,
    CurrencyCode? toCurrency,
    Decimal? rate,
    DateTime? fetchedAt,
  }) {
    return ExchangeRate(
      id: id ?? this.id,
      fromCurrency: fromCurrency ?? this.fromCurrency,
      toCurrency: toCurrency ?? this.toCurrency,
      rate: rate ?? this.rate,
      fetchedAt: fetchedAt ?? this.fetchedAt,
    );
  }
}
