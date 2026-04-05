import 'package:decimal/decimal.dart';
import 'package:drift/drift.dart';

import '../../domain/enums/currency_code.dart';
import '../../domain/models/exchange_rate.dart';
import '../../domain/repositories/exchange_rate_repository.dart';
import '../database/app_database.dart';
import '../database/daos/exchange_rate_dao.dart';

class ExchangeRateRepositoryImpl implements ExchangeRateRepository {
  const ExchangeRateRepositoryImpl(this._dao);

  final ExchangeRateDao _dao;

  @override
  Stream<List<ExchangeRate>> watchAll() => _dao
      .watchAll()
      .map((entries) => entries.map<ExchangeRate>(_fromEntry).toList());

  @override
  Future<List<ExchangeRate>> getAll() async {
    final entries = await _dao.getAll();
    return entries.map<ExchangeRate>(_fromEntry).toList();
  }

  @override
  Future<ExchangeRate?> getById(String id) async {
    final entry = await _dao.getById(id);
    return entry != null ? _fromEntry(entry) : null;
  }

  @override
  Future<ExchangeRate?> getByPair(CurrencyCode from, CurrencyCode to) async {
    final entry = await _dao.getByPair(from.name, to.name);
    return entry != null ? _fromEntry(entry) : null;
  }

  @override
  Future<void> save(ExchangeRate rate) async {
    final companion = _toCompanion(rate);
    final updated = await _dao.updateOne(companion);
    if (!updated) {
      await _dao.insertOne(companion);
    }
  }

  @override
  Future<void> delete(String id) => _dao.deleteById(id);

  ExchangeRate _fromEntry(ExchangeRateEntry e) => ExchangeRate(
        id: e.id,
        fromCurrency: CurrencyCode.values.byName(e.fromCurrency),
        toCurrency: CurrencyCode.values.byName(e.toCurrency),
        rate: Decimal.parse(e.rate),
        fetchedAt: e.fetchedAt,
      );

  ExchangeRatesCompanion _toCompanion(ExchangeRate r) =>
      ExchangeRatesCompanion(
        id: Value(r.id),
        fromCurrency: Value(r.fromCurrency.name),
        toCurrency: Value(r.toCurrency.name),
        rate: Value(r.rate.toString()),
        fetchedAt: Value(r.fetchedAt),
      );
}
