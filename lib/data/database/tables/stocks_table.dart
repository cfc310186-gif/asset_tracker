import 'package:drift/drift.dart';

@DataClassName('StockEntry')
class Stocks extends Table {
  @override
  String get tableName => 'stocks';

  TextColumn get id => text()();
  TextColumn get symbol => text()();
  TextColumn get market => text()();
  TextColumn get name => text()();
  IntColumn get quantity => integer()();
  TextColumn get avgCost => text()();
  TextColumn get currency => text()();
  BoolColumn get isMargin => boolean().withDefault(const Constant(false))();
  TextColumn get marginAmount => text().nullable()();
  TextColumn get linkedLoanId => text().nullable()();
  TextColumn get latestPrice => text().nullable()();
  DateTimeColumn get priceUpdatedAt => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
