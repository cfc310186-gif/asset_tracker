import 'package:uuid/uuid.dart';

import '../enums/currency_code.dart';
import '../models/net_worth_snapshot.dart';
import '../repositories/net_worth_snapshot_repository.dart';
import 'calculate_net_worth.dart';

/// Captures a daily net-worth snapshot, upserting the row keyed by
/// (capturedAt midnight, displayCurrency).
class CaptureNetWorthSnapshot {
  CaptureNetWorthSnapshot({
    required CalculateNetWorth calculate,
    required NetWorthSnapshotRepository snapshotRepo,
    Uuid? uuid,
  })  : _calculate = calculate,
        _snapshotRepo = snapshotRepo,
        _uuid = uuid ?? const Uuid();

  final CalculateNetWorth _calculate;
  final NetWorthSnapshotRepository _snapshotRepo;
  final Uuid _uuid;

  Future<NetWorthSnapshot> execute({
    CurrencyCode displayCurrency = CurrencyCode.twd,
    DateTime? at,
  }) async {
    final summary = await _calculate.execute(displayCurrency: displayCurrency);
    final day = _normalizeDay(at ?? DateTime.now());

    final snapshot = NetWorthSnapshot(
      id: _uuid.v4(),
      capturedAt: day,
      displayCurrency: displayCurrency,
      totalAssets: summary.totalAssets,
      totalLiabilities: summary.totalLoanBalance,
      netWorth: summary.netWorth,
      breakdown: {
        'stock': summary.totalStockValue,
        'cash': summary.totalCashValue,
        'real_estate': summary.totalRealEstateValue,
        'loan': summary.totalLoanBalance,
      },
      createdAt: DateTime.now(),
    );

    await _snapshotRepo.upsert(snapshot);
    return snapshot;
  }

  DateTime _normalizeDay(DateTime ts) =>
      DateTime(ts.year, ts.month, ts.day);
}
