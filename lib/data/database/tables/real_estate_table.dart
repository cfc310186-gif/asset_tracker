import 'package:drift/drift.dart';

@DataClassName('RealEstateEntry')
class RealEstate extends Table {
  @override
  String get tableName => 'real_estate';

  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get address => text()();
  TextColumn get estimatedValue => text()();
  TextColumn get purchasePrice => text()();
  TextColumn get purchaseDate => text()();
  TextColumn get currency => text()();
  BoolColumn get hasMortgage => boolean().withDefault(const Constant(false))();
  TextColumn get linkedLoanId => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
