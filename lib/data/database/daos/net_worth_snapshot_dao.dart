import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/net_worth_snapshots_table.dart';

part 'net_worth_snapshot_dao.g.dart';

@DriftAccessor(tables: [NetWorthSnapshots])
class NetWorthSnapshotDao extends DatabaseAccessor<AppDatabase>
    with _$NetWorthSnapshotDaoMixin {
  NetWorthSnapshotDao(super.db);

  Future<List<NetWorthSnapshotEntry>> getAll() =>
      (select(netWorthSnapshots)
            ..orderBy([(t) => OrderingTerm.asc(t.capturedAt)]))
          .get();

  Stream<List<NetWorthSnapshotEntry>> watchAll() =>
      (select(netWorthSnapshots)
            ..orderBy([(t) => OrderingTerm.asc(t.capturedAt)]))
          .watch();

  Stream<List<NetWorthSnapshotEntry>> watchByCurrency(String currency) =>
      (select(netWorthSnapshots)
            ..where((t) => t.displayCurrency.equals(currency))
            ..orderBy([(t) => OrderingTerm.asc(t.capturedAt)]))
          .watch();

  Future<NetWorthSnapshotEntry?> findByDayAndCurrency(
    DateTime day,
    String currency,
  ) =>
      (select(netWorthSnapshots)
            ..where((t) =>
                t.capturedAt.equals(day) & t.displayCurrency.equals(currency)))
          .getSingleOrNull();

  /// Upsert by (capturedAt, displayCurrency).
  Future<void> upsert(NetWorthSnapshotsCompanion entry) async {
    await into(netWorthSnapshots).insertOnConflictUpdate(entry);
  }

  Future<int> deleteAll() => delete(netWorthSnapshots).go();
}
