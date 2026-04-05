import 'package:decimal/decimal.dart';
import 'package:drift/drift.dart';

import '../../domain/enums/currency_code.dart';
import '../../domain/enums/loan_type.dart';
import '../../domain/models/loan.dart';
import '../../domain/repositories/loan_repository.dart';
import '../database/app_database.dart';
import '../database/daos/loan_dao.dart';

class LoanRepositoryImpl implements LoanRepository {
  const LoanRepositoryImpl(this._dao);

  final LoanDao _dao;

  @override
  Stream<List<Loan>> watchAll() => _dao
      .watchAll()
      .map((entries) => entries.map<Loan>(_fromEntry).toList());

  @override
  Future<List<Loan>> getAll() async {
    final entries = await _dao.getAll();
    return entries.map<Loan>(_fromEntry).toList();
  }

  @override
  Future<Loan?> getById(String id) async {
    final entry = await _dao.getById(id);
    return entry != null ? _fromEntry(entry) : null;
  }

  @override
  Future<void> save(Loan loan) async {
    final companion = _toCompanion(loan);
    final updated = await _dao.updateOne(companion);
    if (!updated) {
      await _dao.insertOne(companion);
    }
  }

  @override
  Future<void> delete(String id) => _dao.deleteById(id);

  Loan _fromEntry(LoanEntry e) => Loan(
        id: e.id,
        type: LoanType.values.byName(e.type),
        name: e.name,
        principal: Decimal.parse(e.principal),
        remainingBalance: Decimal.parse(e.remainingBalance),
        interestRate: Decimal.parse(e.interestRate),
        termMonths: e.termMonths,
        monthlyPayment: Decimal.parse(e.monthlyPayment),
        currency: CurrencyCode.values.byName(e.currency),
        hasGracePeriod: e.hasGracePeriod,
        gracePeriodMonths: e.gracePeriodMonths,
        gracePeriodEndDate: e.gracePeriodEndDate,
        startDate: e.startDate,
        sourceType: e.sourceType,
        sourceId: e.sourceId,
        createdAt: e.createdAt,
        updatedAt: e.updatedAt,
      );

  LoansCompanion _toCompanion(Loan l) => LoansCompanion(
        id: Value(l.id),
        type: Value(l.type.name),
        name: Value(l.name),
        principal: Value(l.principal.toString()),
        remainingBalance: Value(l.remainingBalance.toString()),
        interestRate: Value(l.interestRate.toString()),
        termMonths: Value(l.termMonths),
        monthlyPayment: Value(l.monthlyPayment.toString()),
        currency: Value(l.currency.name),
        hasGracePeriod: Value(l.hasGracePeriod),
        gracePeriodMonths: Value(l.gracePeriodMonths),
        gracePeriodEndDate: Value(l.gracePeriodEndDate),
        startDate: Value(l.startDate),
        sourceType: Value(l.sourceType),
        sourceId: Value(l.sourceId),
        createdAt: Value(l.createdAt),
        updatedAt: Value(l.updatedAt),
      );
}
