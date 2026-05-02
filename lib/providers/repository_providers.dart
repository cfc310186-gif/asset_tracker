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
import '../core/config/supabase_config.dart';
import '../domain/repositories/cash_repository.dart';
import '../domain/repositories/exchange_rate_repository.dart';
import '../domain/repositories/loan_repository.dart';
import '../domain/repositories/net_worth_snapshot_repository.dart';
import '../domain/repositories/real_estate_repository.dart';
import '../domain/repositories/stock_repository.dart';
import '../domain/repositories/transaction_repository.dart';
import 'auth_providers.dart';
import 'database_provider.dart';

final stockRepositoryProvider = Provider<StockRepository>((ref) {
  if (_useCloudRepositories(ref)) {
    return SupabaseStockRepository(ref.watch(supabaseClientProvider));
  }
  final db = ref.watch(databaseProvider);
  return StockRepositoryImpl(db.stockDao);
});

final realEstateRepositoryProvider = Provider<RealEstateRepository>((ref) {
  if (_useCloudRepositories(ref)) {
    return SupabaseRealEstateRepository(ref.watch(supabaseClientProvider));
  }
  final db = ref.watch(databaseProvider);
  return RealEstateRepositoryImpl(db.realEstateDao);
});

final loanRepositoryProvider = Provider<LoanRepository>((ref) {
  if (_useCloudRepositories(ref)) {
    return SupabaseLoanRepository(ref.watch(supabaseClientProvider));
  }
  final db = ref.watch(databaseProvider);
  return LoanRepositoryImpl(db.loanDao);
});

final cashRepositoryProvider = Provider<CashRepository>((ref) {
  if (_useCloudRepositories(ref)) {
    return SupabaseCashRepository(ref.watch(supabaseClientProvider));
  }
  final db = ref.watch(databaseProvider);
  return CashRepositoryImpl(db.cashDao);
});

final exchangeRateRepositoryProvider = Provider<ExchangeRateRepository>((ref) {
  if (_useCloudRepositories(ref)) {
    return SupabaseExchangeRateRepository(ref.watch(supabaseClientProvider));
  }
  final db = ref.watch(databaseProvider);
  return ExchangeRateRepositoryImpl(db.exchangeRateDao);
});

final transactionRepositoryProvider = Provider<TransactionRepository>((ref) {
  if (_useCloudRepositories(ref)) {
    return SupabaseTransactionRepository(ref.watch(supabaseClientProvider));
  }
  final db = ref.watch(databaseProvider);
  return TransactionRepositoryImpl(db.transactionDao);
});

final netWorthSnapshotRepositoryProvider =
    Provider<NetWorthSnapshotRepository>((ref) {
  if (_useCloudRepositories(ref)) {
    return SupabaseNetWorthSnapshotRepository(
      ref.watch(supabaseClientProvider),
    );
  }
  final db = ref.watch(databaseProvider);
  return NetWorthSnapshotRepositoryImpl(db.netWorthSnapshotDao);
});

bool _useCloudRepositories(Ref ref) {
  if (!SupabaseConfig.isConfigured) return false;

  final authState = ref.watch(authStateProvider);
  final hasSession = authState.valueOrNull?.session != null;
  final hasCurrentUser =
      ref.watch(supabaseClientProvider).auth.currentUser != null;
  return hasSession || hasCurrentUser;
}
