import 'package:decimal/decimal.dart';

import '../enums/currency_code.dart';
import '../models/net_worth_snapshot.dart';
import '../repositories/net_worth_snapshot_repository.dart';

class CategoryComparisonRow {
  final DateTime period;
  final Map<String, Decimal> values;
  const CategoryComparisonRow({required this.period, required this.values});
}

/// Groups snapshots by month and surfaces per-category totals so the report
/// view can render a comparison bar chart.
class BuildCategoryComparison {
  const BuildCategoryComparison(this._repo);

  final NetWorthSnapshotRepository _repo;

  Stream<List<CategoryComparisonRow>> watchMonthly({
    required CurrencyCode displayCurrency,
    int monthsBack = 12,
  }) {
    return _repo.watchByCurrency(displayCurrency).map((snapshots) {
      final cutoff = _monthStart(DateTime.now()).subtract(
        Duration(days: 31 * monthsBack),
      );
      final inWindow =
          snapshots.where((s) => !s.capturedAt.isBefore(cutoff)).toList();

      // Group by first day of month, keep the latest snapshot per month.
      final byMonth = <DateTime, NetWorthSnapshot>{};
      for (final s in inWindow) {
        final monthKey = _monthStart(s.capturedAt);
        final existing = byMonth[monthKey];
        if (existing == null || s.capturedAt.isAfter(existing.capturedAt)) {
          byMonth[monthKey] = s;
        }
      }

      final sortedKeys = byMonth.keys.toList()..sort();
      return sortedKeys
          .map((k) => CategoryComparisonRow(
                period: k,
                values: byMonth[k]!.breakdown,
              ))
          .toList();
    });
  }

  DateTime _monthStart(DateTime ts) => DateTime(ts.year, ts.month, 1);
}
