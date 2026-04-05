import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/cash_accounts_table.dart';

part 'cash_dao.g.dart';

@DriftAccessor(tables: [CashAccounts])
class CashDao extends DatabaseAccessor<AppDatabase> with _$CashDaoMixin {
  CashDao(super.db);

  Stream<List<CashAccountEntry>> watchAll() => select(cashAccounts).watch();

  Future<List<CashAccountEntry>> getAll() => select(cashAccounts).get();

  Future<CashAccountEntry?> getById(String id) =>
      (select(cashAccounts)..where((t) => t.id.equals(id))).getSingleOrNull();

  Future<int> insertOne(CashAccountsCompanion entry) =>
      into(cashAccounts).insert(entry);

  Future<bool> updateOne(CashAccountsCompanion entry) =>
      update(cashAccounts).replace(entry);

  Future<int> deleteById(String id) =>
      (delete(cashAccounts)..where((t) => t.id.equals(id))).go();
}
