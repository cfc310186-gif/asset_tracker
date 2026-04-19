import 'package:decimal/decimal.dart';
import 'package:flutter/foundation.dart';

import '../enums/currency_code.dart';

@immutable
class CashAccount {
  final String id;
  final String name;
  final String? bankName;
  final Decimal balance;
  final CurrencyCode currency;
  /// Annual interest rate as a plain decimal (e.g. 0.015 for 1.5%).
  /// Null means no rate configured; UI should skip interest calculations.
  final Decimal? annualRate;
  final DateTime createdAt;
  final DateTime updatedAt;

  const CashAccount({
    required this.id,
    required this.name,
    this.bankName,
    required this.balance,
    required this.currency,
    this.annualRate,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Monthly interest estimate: `balance × annualRate / 12`.
  /// Returns null when no rate is configured.
  Decimal? get estimatedMonthlyInterest {
    final rate = annualRate;
    if (rate == null) return null;
    return (balance * rate / Decimal.fromInt(12))
        .toDecimal(scaleOnInfinitePrecision: 10);
  }

  CashAccount copyWith({
    String? id,
    String? name,
    Object? bankName = _sentinel,
    Decimal? balance,
    CurrencyCode? currency,
    Object? annualRate = _sentinel,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CashAccount(
      id: id ?? this.id,
      name: name ?? this.name,
      bankName:
          bankName == _sentinel ? this.bankName : bankName as String?,
      balance: balance ?? this.balance,
      currency: currency ?? this.currency,
      annualRate:
          annualRate == _sentinel ? this.annualRate : annualRate as Decimal?,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

const Object _sentinel = Object();
