import 'package:decimal/decimal.dart';
import 'package:flutter/foundation.dart';

import '../enums/currency_code.dart';

@immutable
class MonthlyCashFlowSummary {
  final Decimal positiveCashFlow;
  final Decimal negativeCashFlow;
  final CurrencyCode displayCurrency;
  final DateTime calculatedAt;

  const MonthlyCashFlowSummary({
    required this.positiveCashFlow,
    required this.negativeCashFlow,
    required this.displayCurrency,
    required this.calculatedAt,
  });

  Decimal get netCashFlow => positiveCashFlow - negativeCashFlow;
}
