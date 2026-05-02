import '../../domain/models/stock_holding.dart';
import '../../domain/repositories/stock_repository.dart';
import '../supabase/supabase_mappers.dart';
import '../supabase/supabase_repository_base.dart';

class SupabaseStockRepository extends SupabaseRepositoryBase
    implements StockRepository {
  const SupabaseStockRepository(super.client);

  static const _table = 'stock_holdings';

  @override
  Stream<List<StockHolding>> watchAll() {
    return watchByPolling(getAll);
  }

  @override
  Future<List<StockHolding>> getAll() async {
    final rows = await table(_table)
        .select()
        .isFilter('deleted_at', null)
        .order('updated_at', ascending: true);
    return _rowList(rows).map(stockHoldingFromSupabaseRow).toList();
  }

  @override
  Future<StockHolding?> getById(String id) async {
    final row = await table(_table)
        .select()
        .eq('id', id)
        .isFilter('deleted_at', null)
        .maybeSingle();
    return row == null ? null : stockHoldingFromSupabaseRow(row);
  }

  @override
  Future<void> save(StockHolding holding) async {
    await table(_table).upsert(
      stockHoldingToSupabaseRow(holding, userId: currentUserId),
    );
  }

  @override
  Future<void> delete(String id) async {
    await table(_table).update(softDeletePayload()).eq('id', id);
  }
}

List<SupabaseRow> _rowList(Object? rows) =>
    (rows as List).map((row) => Map<String, dynamic>.from(row as Map)).toList();
