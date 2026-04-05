import '../enums/currency_code.dart';
import '../models/exchange_rate.dart';

abstract interface class ExchangeRateRepository {
  Stream<List<ExchangeRate>> watchAll();
  Future<List<ExchangeRate>> getAll();
  Future<ExchangeRate?> getById(String id);
  Future<ExchangeRate?> getByPair(CurrencyCode from, CurrencyCode to);
  Future<void> save(ExchangeRate rate);
  Future<void> delete(String id);
}
