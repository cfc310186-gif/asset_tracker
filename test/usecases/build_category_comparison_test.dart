import 'package:asset_tracker/domain/enums/currency_code.dart';
import 'package:asset_tracker/domain/models/net_worth_snapshot.dart';
import 'package:asset_tracker/domain/usecases/build_category_comparison.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter_test/flutter_test.dart';

import '_fakes.dart';

void main() {
  test('buildMonthly filters currency and keeps latest snapshot per month',
      () async {
    final thisMonth = DateTime(DateTime.now().year, DateTime.now().month, 1);
    final lastMonth = DateTime(thisMonth.year, thisMonth.month - 1, 1);
    final repo = FakeSnapshotRepository()
      ..stored.addAll([
        _snapshot(
          id: 'last',
          at: lastMonth.add(const Duration(hours: 9)),
          currency: CurrencyCode.twd,
          stock: 100,
        ),
        _snapshot(
          id: 'older-this-month',
          at: thisMonth.add(const Duration(hours: 9)),
          currency: CurrencyCode.twd,
          stock: 200,
        ),
        _snapshot(
          id: 'latest-this-month',
          at: thisMonth.add(const Duration(days: 1)),
          currency: CurrencyCode.twd,
          stock: 300,
        ),
        _snapshot(
          id: 'usd',
          at: thisMonth.add(const Duration(days: 2)),
          currency: CurrencyCode.usd,
          stock: 999,
        ),
      ]);

    final rows = await BuildCategoryComparison(repo).buildMonthly(
      displayCurrency: CurrencyCode.twd,
      monthsBack: 12,
    );

    expect(rows.map((r) => r.period), [lastMonth, thisMonth]);
    expect(rows.map((r) => r.values['stock'].toString()), ['100', '300']);
  });
}

NetWorthSnapshot _snapshot({
  required String id,
  required DateTime at,
  required CurrencyCode currency,
  required int stock,
}) {
  return NetWorthSnapshot(
    id: id,
    capturedAt: at,
    displayCurrency: currency,
    totalAssets: Decimal.fromInt(stock),
    totalLiabilities: Decimal.zero,
    netWorth: Decimal.fromInt(stock),
    breakdown: {'stock': Decimal.fromInt(stock)},
    createdAt: at,
  );
}
