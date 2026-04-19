import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import 'daos/cash_dao.dart';
import 'daos/exchange_rate_dao.dart';
import 'daos/loan_dao.dart';
import 'daos/real_estate_dao.dart';
import 'daos/stock_dao.dart';
import 'tables/cash_accounts_table.dart';
import 'tables/exchange_rates_table.dart';
import 'tables/loans_table.dart';
import 'tables/real_estate_table.dart';
import 'tables/stocks_table.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    Stocks,
    RealEstate,
    Loans,
    CashAccounts,
    ExchangeRates,
  ],
  daos: [
    StockDao,
    RealEstateDao,
    LoanDao,
    CashDao,
    ExchangeRateDao,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

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
