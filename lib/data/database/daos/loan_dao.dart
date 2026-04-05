import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/loans_table.dart';

part 'loan_dao.g.dart';

@DriftAccessor(tables: [Loans])
class LoanDao extends DatabaseAccessor<AppDatabase> with _$LoanDaoMixin {
  LoanDao(super.db);

  Stream<List<LoanEntry>> watchAll() => select(loans).watch();

  Future<List<LoanEntry>> getAll() => select(loans).get();

  Future<LoanEntry?> getById(String id) =>
      (select(loans)..where((t) => t.id.equals(id))).getSingleOrNull();

  Future<int> insertOne(LoansCompanion entry) =>
      into(loans).insert(entry);

  Future<bool> updateOne(LoansCompanion entry) =>
      update(loans).replace(entry);

  Future<int> deleteById(String id) =>
      (delete(loans)..where((t) => t.id.equals(id))).go();
}
