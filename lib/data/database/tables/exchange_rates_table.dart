import 'package:drift/drift.dart';

@DataClassName('ExchangeRateEntry')
class ExchangeRates extends Table {
  @override
  String get tableName => 'exchange_rates';

  TextColumn get id => text()();
  TextColumn get fromCurrency => text()();
  TextColumn get toCurrency => text()();
  TextColumn get rate => text()();
  DateTimeColumn get fetchedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
