import 'package:drift/drift.dart';

@DataClassName('LoanEntry')
class Loans extends Table {
  @override
  String get tableName => 'loans';

  TextColumn get id => text()();
  TextColumn get type => text()();
  TextColumn get name => text()();
  TextColumn get principal => text()();
  TextColumn get remainingBalance => text()();
  TextColumn get interestRate => text()();
  IntColumn get termMonths => integer()();
  TextColumn get monthlyPayment => text()();
  TextColumn get currency => text()();
  BoolColumn get hasGracePeriod =>
      boolean().withDefault(const Constant(false))();
  IntColumn get gracePeriodMonths => integer().nullable()();
  TextColumn get gracePeriodEndDate => text().nullable()();
  TextColumn get startDate => text()();
  TextColumn get sourceType => text()();
  TextColumn get sourceId => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
