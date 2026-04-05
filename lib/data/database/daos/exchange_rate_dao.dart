import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/exchange_rates_table.dart';

part 'exchange_rate_dao.g.dart';

@DriftAccessor(tables: [ExchangeRates])
class ExchangeRateDao extends DatabaseAccessor<AppDatabase>
    with _$ExchangeRateDaoMixin {
  ExchangeRateDao(super.db);

  Stream<List<ExchangeRateEntry>> watchAll() => select(exchangeRates).watch();

  Future<List<ExchangeRateEntry>> getAll() => select(exchangeRates).get();

  Future<ExchangeRateEntry?> getById(String id) =>
      (select(exchangeRates)..where((t) => t.id.equals(id)))
          .getSingleOrNull();

  Future<ExchangeRateEntry?> getByPair(
    String fromCurrency,
    String toCurrency,
  ) =>
      (select(exchangeRates)
            ..where(
              (t) =>
                  t.fromCurrency.equals(fromCurrency) &
                  t.toCurrency.equals(toCurrency),
            ))
          .getSingleOrNull();

  Future<int> insertOne(ExchangeRatesCompanion entry) =>
      into(exchangeRates).insert(entry);

  Future<bool> updateOne(ExchangeRatesCompanion entry) =>
      update(exchangeRates).replace(entry);

  Future<int> deleteById(String id) =>
      (delete(exchangeRates)..where((t) => t.id.equals(id))).go();
}
