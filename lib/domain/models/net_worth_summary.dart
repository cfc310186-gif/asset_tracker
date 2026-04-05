import 'package:decimal/decimal.dart';
import 'package:flutter/foundation.dart';

import '../enums/currency_code.dart';

@immutable
class NetWorthSummary {
  /// Sum of all stock holdings at market value (in [displayCurrency]).
  final Decimal totalStockValue;

  /// Sum of all real estate estimated values (in [displayCurrency]).
  final Decimal totalRealEstateValue;

  /// Sum of all cash account balances (in [displayCurrency]).
  final Decimal totalCashValue;

  /// Sum of all loan remaining balances — a liability (in [displayCurrency]).
  final Decimal totalLoanBalance;

  final CurrencyCode displayCurrency;
  final DateTime calculatedAt;

  const NetWorthSummary({
    required this.totalStockValue,
    required this.totalRealEstateValue,
    required this.totalCashValue,
    required this.totalLoanBalance,
    required this.displayCurrency,
    required this.calculatedAt,
  });

  Decimal get totalAssets =>
      totalStockValue + totalRealEstateValue + totalCashValue;

  Decimal get netWorth => totalAssets - totalLoanBalance;

  NetWorthSummary copyWith({
    Decimal? totalStockValue,
    Decimal? totalRealEstateValue,
    Decimal? totalCashValue,
    Decimal? totalLoanBalance,
    CurrencyCode? displayCurrency,
    DateTime? calculatedAt,
  }) {
    return NetWorthSummary(
      totalStockValue: totalStockValue ?? this.totalStockValue,
      totalRealEstateValue: totalRealEstateValue ?? this.totalRealEstateValue,
      totalCashValue: totalCashValue ?? this.totalCashValue,
      totalLoanBalance: totalLoanBalance ?? this.totalLoanBalance,
      displayCurrency: displayCurrency ?? this.displayCurrency,
      calculatedAt: calculatedAt ?? this.calculatedAt,
    );
  }
}
