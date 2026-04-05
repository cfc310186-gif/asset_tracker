import '../models/cash_account.dart';

abstract interface class CashRepository {
  Stream<List<CashAccount>> watchAll();
  Future<List<CashAccount>> getAll();
  Future<CashAccount?> getById(String id);
  Future<void> save(CashAccount account);
  Future<void> delete(String id);
}
