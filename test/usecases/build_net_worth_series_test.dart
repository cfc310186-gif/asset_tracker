import 'package:asset_tracker/domain/enums/currency_code.dart';
import 'package:asset_tracker/domain/models/net_worth_snapshot.dart';
import 'package:asset_tracker/domain/usecases/build_net_worth_series.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter_test/flutter_test.dart';

import '_fakes.dart';

void main() {
  test('build filters currency/window and sorts points by date', () async {
    final repo = FakeSnapshotRepository()
      ..stored.addAll([
        _snapshot(
          id: 'late',
          at: DateTime(2026, 5, 3),
          currency: CurrencyCode.twd,
          netWorth: 300,
        ),
        _snapshot(
          id: 'usd',
          at: DateTime(2026, 5, 2),
          currency: CurrencyCode.usd,
          netWorth: 999,
        ),
        _snapshot(
          id: 'early',
          at: DateTime(2026, 5, 1),
          currency: CurrencyCode.twd,
          netWorth: 100,
        ),
        _snapshot(
          id: 'old',
          at: DateTime(2026, 4, 1),
          currency: CurrencyCode.twd,
          netWorth: 50,
        ),
      ]);

    final points = await BuildNetWorthSeries(repo).build(
      displayCurrency: CurrencyCode.twd,
      from: DateTime(2026, 5),
    );

    expect(points.map((p) => p.value.toString()), ['100', '300']);
    expect(points.map((p) => p.at), [
      DateTime(2026, 5, 1),
      DateTime(2026, 5, 3),
    ]);
  });
}

NetWorthSnapshot _snapshot({
  required String id,
  required DateTime at,
  required CurrencyCode currency,
  required int netWorth,
}) {
  return NetWorthSnapshot(
    id: id,
    capturedAt: at,
    displayCurrency: currency,
    totalAssets: Decimal.fromInt(netWorth),
    totalLiabilities: Decimal.zero,
    netWorth: Decimal.fromInt(netWorth),
    breakdown: const {},
    createdAt: at,
  );
}
