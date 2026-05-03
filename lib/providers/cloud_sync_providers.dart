import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/repositories/cash_repository_impl.dart';
import '../data/repositories/exchange_rate_repository_impl.dart';
import '../data/repositories/loan_repository_impl.dart';
import '../data/repositories/net_worth_snapshot_repository_impl.dart';
import '../data/repositories/real_estate_repository_impl.dart';
import '../data/repositories/stock_repository_impl.dart';
import '../data/repositories/supabase_cash_repository.dart';
import '../data/repositories/supabase_exchange_rate_repository.dart';
import '../data/repositories/supabase_loan_repository.dart';
import '../data/repositories/supabase_net_worth_snapshot_repository.dart';
import '../data/repositories/supabase_real_estate_repository.dart';
import '../data/repositories/supabase_stock_repository.dart';
import '../data/repositories/supabase_transaction_repository.dart';
import '../data/repositories/transaction_repository_impl.dart';
import '../domain/usecases/export_cloud_data.dart';
import '../domain/usecases/import_local_data_to_cloud.dart';
import 'auth_providers.dart';
import 'database_provider.dart';

final importLocalDataToCloudProvider = Provider<ImportLocalDataToCloud>((ref) {
  final db = ref.watch(databaseProvider);
  final client = ref.watch(supabaseClientProvider);

  return ImportLocalDataToCloud(
    localStockRepo: StockRepositoryImpl(db.stockDao),
    cloudStockRepo: SupabaseStockRepository(client),
    localCashRepo: CashRepositoryImpl(db.cashDao),
    cloudCashRepo: SupabaseCashRepository(client),
    localRealEstateRepo: RealEstateRepositoryImpl(db.realEstateDao),
    cloudRealEstateRepo: SupabaseRealEstateRepository(client),
    localLoanRepo: LoanRepositoryImpl(db.loanDao),
    cloudLoanRepo: SupabaseLoanRepository(client),
    localTransactionRepo: TransactionRepositoryImpl(db.transactionDao),
    cloudTransactionRepo: SupabaseTransactionRepository(client),
    localSnapshotRepo: NetWorthSnapshotRepositoryImpl(db.netWorthSnapshotDao),
    cloudSnapshotRepo: SupabaseNetWorthSnapshotRepository(client),
    localExchangeRateRepo: ExchangeRateRepositoryImpl(db.exchangeRateDao),
    cloudExchangeRateRepo: SupabaseExchangeRateRepository(client),
  );
});

final exportCloudDataProvider = Provider<ExportCloudData>((ref) {
  final client = ref.watch(supabaseClientProvider);

  return ExportCloudData(
    stockRepo: SupabaseStockRepository(client),
    cashRepo: SupabaseCashRepository(client),
    realEstateRepo: SupabaseRealEstateRepository(client),
    loanRepo: SupabaseLoanRepository(client),
    transactionRepo: SupabaseTransactionRepository(client),
    snapshotRepo: SupabaseNetWorthSnapshotRepository(client),
    exchangeRateRepo: SupabaseExchangeRateRepository(client),
  );
});
