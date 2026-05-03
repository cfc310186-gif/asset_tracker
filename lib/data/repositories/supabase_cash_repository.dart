import '../../domain/models/cash_account.dart';
import '../../domain/repositories/cash_repository.dart';
import '../supabase/supabase_mappers.dart';
import '../supabase/supabase_repository_base.dart';

class SupabaseCashRepository extends SupabaseRepositoryBase
    implements CashRepository {
  const SupabaseCashRepository(super.client);

  static const _table = 'cash_accounts';

  @override
  Stream<List<CashAccount>> watchAll() {
    return watchByPolling(getAll);
  }

  @override
  Future<List<CashAccount>> getAll() async {
    final rows = await table(_table)
        .select()
        .isFilter('deleted_at', null)
        .order('updated_at', ascending: true);
    return _rowList(rows).map(cashAccountFromSupabaseRow).toList();
  }

  @override
  Future<CashAccount?> getById(String id) async {
    final row = await table(_table)
        .select()
        .eq('id', id)
        .isFilter('deleted_at', null)
        .maybeSingle();
    return row == null ? null : cashAccountFromSupabaseRow(row);
  }

  @override
  Future<void> save(CashAccount account) async {
    await table(_table).upsert(
      cashAccountToSupabaseRow(account, userId: currentUserId),
    );
  }

  @override
  Future<void> delete(String id) async {
    await table(_table).update(softDeletePayload()).eq('id', id);
  }
}

List<SupabaseRow> _rowList(Object? rows) =>
    (rows as List).map((row) => Map<String, dynamic>.from(row as Map)).toList();
