import '../../domain/models/transaction.dart';
import '../../domain/repositories/transaction_repository.dart';
import '../supabase/supabase_mappers.dart';
import '../supabase/supabase_repository_base.dart';

class SupabaseTransactionRepository extends SupabaseRepositoryBase
    implements TransactionRepository {
  const SupabaseTransactionRepository(super.client);

  static const _table = 'transactions';

  @override
  Future<void> add(Transaction tx) async {
    await table(_table).upsert(
      transactionToSupabaseRow(tx, userId: currentUserId),
    );
  }

  @override
  Future<List<Transaction>> getAll() async {
    final rows = await table(_table)
        .select()
        .isFilter('deleted_at', null)
        .order('occurred_at', ascending: false);
    return _rowList(rows).map(transactionFromSupabaseRow).toList();
  }

  @override
  Stream<List<Transaction>> watchAll() {
    return watchByPolling(getAll);
  }

  @override
  Stream<List<Transaction>> watchByRange(DateTime from, DateTime to) {
    return watchAll().map(
      (transactions) => transactions
          .where(
            (tx) => !tx.occurredAt.isBefore(from) && tx.occurredAt.isBefore(to),
          )
          .toList(),
    );
  }

  @override
  Stream<List<Transaction>> watchByAssetType(TransactionAssetType type) {
    return watchAll().map(
      (transactions) =>
          transactions.where((tx) => tx.assetType == type).toList(),
    );
  }

  @override
  Future<void> deleteByAsset(TransactionAssetType type, String assetId) async {
    await table(_table)
        .update(softDeletePayload())
        .eq('asset_type', type.storageKey)
        .eq('asset_id', assetId);
  }
}

List<SupabaseRow> _rowList(Object? rows) =>
    (rows as List).map((row) => Map<String, dynamic>.from(row as Map)).toList();
