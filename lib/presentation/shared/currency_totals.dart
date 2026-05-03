import 'package:decimal/decimal.dart';

import '../../core/utils/currency_formatter.dart';
import '../../domain/enums/currency_code.dart';

Map<CurrencyCode, Decimal> sumByCurrency<T>(
  Iterable<T> items, {
  required CurrencyCode Function(T item) currencyOf,
  required Decimal Function(T item) amountOf,
}) {
  final totals = <CurrencyCode, Decimal>{};
  for (final item in items) {
    final currency = currencyOf(item);
    totals[currency] = (totals[currency] ?? Decimal.zero) + amountOf(item);
  }
  return totals;
}

List<MapEntry<CurrencyCode, Decimal>> orderedCurrencyTotals(
  Map<CurrencyCode, Decimal> totals,
) {
  return CurrencyCode.values
      .where((currency) => totals[currency] != null)
      .map((currency) => MapEntry(currency, totals[currency]!))
      .where((entry) => entry.value != Decimal.zero)
      .toList();
}

String formatCurrencyTotals(Map<CurrencyCode, Decimal> totals) {
  return orderedCurrencyTotals(totals)
      .map(
        (entry) => '${entry.key.name.toUpperCase()} '
            '${CurrencyFormatter.format(entry.value, entry.key)}',
      )
      .join(' · ');
}
