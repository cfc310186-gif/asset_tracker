import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import 'daos/cash_dao.dart';
import 'daos/exchange_rate_dao.dart';
import 'daos/loan_dao.dart';
import 'daos/net_worth_snapshot_dao.dart';
import 'daos/real_estate_dao.dart';
import 'daos/stock_dao.dart';
import 'daos/transaction_dao.dart';
import 'tables/cash_accounts_table.dart';
import 'tables/exchange_rates_table.dart';
import 'tables/loans_table.dart';
import 'tables/net_worth_snapshots_table.dart';
import 'tables/real_estate_table.dart';
import 'tables/stocks_table.dart';
import 'tables/transactions_table.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    Stocks,
    RealEstate,
    Loans,
    CashAccounts,
    ExchangeRates,
    Transactions,
    NetWorthSnapshots,
  ],
  daos: [
    StockDao,
    RealEstateDao,
    LoanDao,
    CashDao,
    ExchangeRateDao,
    TransactionDao,
    NetWorthSnapshotDao,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) => m.createAll(),
        onUpgrade: (m, from, to) async {
          if (from < 2) {
            await m.createTable(transactions);
            await m.createTable(netWorthSnapshots);
          }
          if (from < 3) {
            await m.addColumn(cashAccounts, cashAccounts.annualRate);
          }
        },
      );

  static QueryExecutor _openConnection() {
    if (kIsWeb) {
      return driftDatabase(
        name: 'asset_tracker_db',
        web: DriftWebOptions(
          sqlite3Wasm: Uri.parse('sqlite3.wasm'),
          driftWorker: Uri.parse('drift_worker.js'),
        ),
      );
    }
    return driftDatabase(name: 'asset_tracker_db');
  }
}
