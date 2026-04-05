import 'package:drift/drift.dart';

@DataClassName('CashAccountEntry')
class CashAccounts extends Table {
  @override
  String get tableName => 'cash_accounts';

  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get bankName => text().nullable()();
  TextColumn get balance => text()();
  TextColumn get currency => text()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
