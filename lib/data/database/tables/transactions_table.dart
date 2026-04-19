import 'package:drift/drift.dart';

/// Records every asset mutation (buy/sell/deposit/withdraw/dividend/etc.)
/// so the report screen can render history and totals over time.
@DataClassName('TransactionEntry')
class Transactions extends Table {
  @override
  String get tableName => 'transactions';

  TextColumn get id => text()();

  /// One of: stock | cash | real_estate | loan
  TextColumn get assetType => text()();

  /// FK-ish reference to the source table's id. Not enforced because
  /// rows are kept after the source asset is deleted (audit trail).
  TextColumn get assetId => text()();

  /// One of: buy | sell | deposit | withdraw | dividend | adjust
  TextColumn get kind => text()();

  /// Optional quantity (e.g. shares). Stored as text Decimal.
  TextColumn get quantity => text().nullable()();

  /// Optional unit price. Stored as text Decimal.
  TextColumn get price => text().nullable()();

  /// Total amount in [currency] (signed: positive = inflow, negative = outflow).
  TextColumn get amount => text()();

  TextColumn get currency => text()();

  DateTimeColumn get occurredAt => dateTime()();

  TextColumn get note => text().nullable()();

  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
