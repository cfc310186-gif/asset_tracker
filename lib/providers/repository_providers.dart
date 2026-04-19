import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/repositories/cash_repository_impl.dart';
import '../data/repositories/exchange_rate_repository_impl.dart';
import '../data/repositories/loan_repository_impl.dart';
import '../data/repositories/net_worth_snapshot_repository_impl.dart';
import '../data/repositories/real_estate_repository_impl.dart';
import '../data/repositories/stock_repository_impl.dart';
import '../data/repositories/transaction_repository_impl.dart';
import '../domain/repositories/cash_repository.dart';
import '../domain/repositories/exchange_rate_repository.dart';
import '../domain/repositories/loan_repository.dart';
import '../domain/repositories/net_worth_snapshot_repository.dart';
import '../domain/repositories/real_estate_repository.dart';
import '../domain/repositories/stock_repository.dart';
import '../domain/repositories/transaction_repository.dart';
import 'database_provider.dart';

final stockRepositoryProvider = Provider<StockRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return StockRepositoryImpl(db.stockDao);
});

final realEstateRepositoryProvider = Provider<RealEstateRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return RealEstateRepositoryImpl(db.realEstateDao);
});

final loanRepositoryProvider = Provider<LoanRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return LoanRepositoryImpl(db.loanDao);
});

final cashRepositoryProvider = Provider<CashRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return CashRepositoryImpl(db.cashDao);
});

final exchangeRateRepositoryProvider = Provider<ExchangeRateRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return ExchangeRateRepositoryImpl(db.exchangeRateDao);
});

final transactionRepositoryProvider = Provider<TransactionRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return TransactionRepositoryImpl(db.transactionDao);
});

final netWorthSnapshotRepositoryProvider =
    Provider<NetWorthSnapshotRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return NetWorthSnapshotRepositoryImpl(db.netWorthSnapshotDao);
});
