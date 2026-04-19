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
  /// Annual interest rate as a plain decimal string (e.g. "0.015" = 1.5%).
  /// Nullable: accounts added before the rate feature keep null.
  TextColumn get annualRate => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
