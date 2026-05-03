import '../../domain/enums/currency_code.dart';
import '../../domain/models/net_worth_snapshot.dart';
import '../../domain/repositories/net_worth_snapshot_repository.dart';
import '../supabase/supabase_mappers.dart';
import '../supabase/supabase_repository_base.dart';

class SupabaseNetWorthSnapshotRepository extends SupabaseRepositoryBase
    implements NetWorthSnapshotRepository {
  const SupabaseNetWorthSnapshotRepository(super.client);

  static const _table = 'net_worth_snapshots';

  @override
  Future<void> upsert(NetWorthSnapshot snapshot) async {
    await table(_table).upsert(
      netWorthSnapshotToSupabaseRow(snapshot, userId: currentUserId),
      onConflict: 'user_id,captured_at,display_currency',
    );
  }

  @override
  Future<List<NetWorthSnapshot>> getAll() async {
    final rows = await table(_table)
        .select()
        .isFilter('deleted_at', null)
        .order('captured_at', ascending: true);
    return _rowList(rows).map(netWorthSnapshotFromSupabaseRow).toList();
  }

  @override
  Stream<List<NetWorthSnapshot>> watchAll() {
    return watchByPolling(getAll);
  }

  @override
  Stream<List<NetWorthSnapshot>> watchByCurrency(CurrencyCode currency) {
    return watchAll().map(
      (snapshots) => snapshots
          .where((snapshot) => snapshot.displayCurrency == currency)
          .toList(),
    );
  }
}

List<SupabaseRow> _rowList(Object? rows) =>
    (rows as List).map((row) => Map<String, dynamic>.from(row as Map)).toList();
