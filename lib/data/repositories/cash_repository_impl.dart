import 'package:decimal/decimal.dart';
import 'package:drift/drift.dart';

import '../../domain/enums/currency_code.dart';
import '../../domain/models/cash_account.dart';
import '../../domain/repositories/cash_repository.dart';
import '../database/app_database.dart';
import '../database/daos/cash_dao.dart';

class CashRepositoryImpl implements CashRepository {
  const CashRepositoryImpl(this._dao);

  final CashDao _dao;

  @override
  Stream<List<CashAccount>> watchAll() => _dao
      .watchAll()
      .map((entries) => entries.map<CashAccount>(_fromEntry).toList());

  @override
  Future<List<CashAccount>> getAll() async {
    final entries = await _dao.getAll();
    return entries.map<CashAccount>(_fromEntry).toList();
  }

  @override
  Future<CashAccount?> getById(String id) async {
    final entry = await _dao.getById(id);
    return entry != null ? _fromEntry(entry) : null;
  }

  @override
  Future<void> save(CashAccount account) async {
    final companion = _toCompanion(account);
    final updated = await _dao.updateOne(companion);
    if (!updated) {
      await _dao.insertOne(companion);
    }
  }

  @override
  Future<void> delete(String id) => _dao.deleteById(id);

  CashAccount _fromEntry(CashAccountEntry e) => CashAccount(
        id: e.id,
        name: e.name,
        bankName: e.bankName,
        balance: Decimal.parse(e.balance),
        currency: CurrencyCode.values.byName(e.currency),
        createdAt: e.createdAt,
        updatedAt: e.updatedAt,
      );

  CashAccountsCompanion _toCompanion(CashAccount a) => CashAccountsCompanion(
        id: Value(a.id),
        name: Value(a.name),
        bankName: Value(a.bankName),
        balance: Value(a.balance.toString()),
        currency: Value(a.currency.name),
        createdAt: Value(a.createdAt),
        updatedAt: Value(a.updatedAt),
      );
}
