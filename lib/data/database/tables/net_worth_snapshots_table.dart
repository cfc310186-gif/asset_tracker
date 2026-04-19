import 'package:drift/drift.dart';

/// One row per calendar day storing the user's net worth snapshot.
/// `capturedAt` is normalised to midnight (local) to enforce uniqueness.
@DataClassName('NetWorthSnapshotEntry')
class NetWorthSnapshots extends Table {
  @override
  String get tableName => 'net_worth_snapshots';

  TextColumn get id => text()();

  /// Midnight of the snapshot day (local timezone).
  DateTimeColumn get capturedAt => dateTime()();

  TextColumn get displayCurrency => text()();

  /// All amounts stored as text Decimal in [displayCurrency].
  TextColumn get totalAssets => text()();
  TextColumn get totalLiabilities => text()();
  TextColumn get netWorth => text()();

  /// JSON map: { "stock": "1234.5", "cash": "...", "real_estate": "...", "loan": "..." }
  /// Loan value is positive (the magnitude of liabilities).
  TextColumn get breakdownJson => text()();

  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<Set<Column>> get uniqueKeys => [
        {capturedAt, displayCurrency},
      ];
}
