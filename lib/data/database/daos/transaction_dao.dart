import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/transactions_table.dart';

part 'transaction_dao.g.dart';

@DriftAccessor(tables: [Transactions])
class TransactionDao extends DatabaseAccessor<AppDatabase>
    with _$TransactionDaoMixin {
  TransactionDao(super.db);

  Future<int> insertOne(TransactionsCompanion entry) =>
      into(transactions).insert(entry);

  Future<List<TransactionEntry>> getAll() =>
      (select(transactions)..orderBy([(t) => OrderingTerm.desc(t.occurredAt)]))
          .get();

  Stream<List<TransactionEntry>> watchAll() =>
      (select(transactions)..orderBy([(t) => OrderingTerm.desc(t.occurredAt)]))
          .watch();

  Future<List<TransactionEntry>> getByRange(DateTime from, DateTime to) =>
      (select(transactions)
            ..where((t) =>
                t.occurredAt.isBiggerOrEqualValue(from) &
                t.occurredAt.isSmallerThanValue(to))
            ..orderBy([(t) => OrderingTerm.desc(t.occurredAt)]))
          .get();

  Stream<List<TransactionEntry>> watchByRange(DateTime from, DateTime to) =>
      (select(transactions)
            ..where((t) =>
                t.occurredAt.isBiggerOrEqualValue(from) &
                t.occurredAt.isSmallerThanValue(to))
            ..orderBy([(t) => OrderingTerm.desc(t.occurredAt)]))
          .watch();

  Stream<List<TransactionEntry>> watchByAssetType(String assetType) =>
      (select(transactions)
            ..where((t) => t.assetType.equals(assetType))
            ..orderBy([(t) => OrderingTerm.desc(t.occurredAt)]))
          .watch();

  Future<int> deleteByAsset(String assetType, String assetId) =>
      (delete(transactions)
            ..where((t) =>
                t.assetType.equals(assetType) & t.assetId.equals(assetId)))
          .go();
}
