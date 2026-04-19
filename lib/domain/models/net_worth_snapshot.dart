import 'package:decimal/decimal.dart';
import 'package:flutter/foundation.dart';

import '../enums/currency_code.dart';

@immutable
class NetWorthSnapshot {
  final String id;
  final DateTime capturedAt;
  final CurrencyCode displayCurrency;
  final Decimal totalAssets;
  final Decimal totalLiabilities;
  final Decimal netWorth;

  /// Map of asset-type key → value in [displayCurrency].
  /// Keys: "stock", "cash", "real_estate", "loan" (loan = positive magnitude).
  final Map<String, Decimal> breakdown;

  final DateTime createdAt;

  const NetWorthSnapshot({
    required this.id,
    required this.capturedAt,
    required this.displayCurrency,
    required this.totalAssets,
    required this.totalLiabilities,
    required this.netWorth,
    required this.breakdown,
    required this.createdAt,
  });
}
