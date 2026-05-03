import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/usecases/build_category_comparison.dart';
import '../domain/usecases/build_net_worth_series.dart';
import '../domain/usecases/calculate_monthly_cash_flow.dart';
import '../domain/usecases/calculate_net_worth.dart';
import '../domain/usecases/capture_net_worth_snapshot.dart';
import '../domain/usecases/create_margin_loan.dart';
import '../domain/usecases/create_mortgage.dart';
import '../domain/usecases/record_transaction.dart';
import '../domain/usecases/sync_linked_loans.dart';
import 'repository_providers.dart';
import 'settings_providers.dart';

final portfolioRevisionProvider = StateProvider<int>((ref) => 0);

Future<void> notifyPortfolioChanged(WidgetRef ref) async {
  ref.read(portfolioRevisionProvider.notifier).update((value) => value + 1);

  try {
    final displayCurrency = ref.read(displayCurrencyProvider);
    await ref
        .read(captureNetWorthSnapshotProvider)
        .execute(displayCurrency: displayCurrency);
  } on Exception catch (e) {
    debugPrint('[Portfolio] Snapshot refresh failed: $e');
  }
}

final createMarginLoanProvider = Provider<CreateMarginLoan>((ref) {
  return CreateMarginLoan(
    stockRepo: ref.watch(stockRepositoryProvider),
    loanRepo: ref.watch(loanRepositoryProvider),
  );
});

final createMortgageProvider = Provider<CreateMortgage>((ref) {
  return CreateMortgage(
    realEstateRepo: ref.watch(realEstateRepositoryProvider),
    loanRepo: ref.watch(loanRepositoryProvider),
  );
});

final syncLinkedLoansProvider = Provider<SyncLinkedLoans>((ref) {
  return SyncLinkedLoans(
    loanRepo: ref.watch(loanRepositoryProvider),
  );
});

final calculateNetWorthProvider = Provider<CalculateNetWorth>((ref) {
  ref.watch(portfolioRevisionProvider);
  return CalculateNetWorth(
    stockRepo: ref.watch(stockRepositoryProvider),
    realEstateRepo: ref.watch(realEstateRepositoryProvider),
    loanRepo: ref.watch(loanRepositoryProvider),
    cashRepo: ref.watch(cashRepositoryProvider),
    exchangeRateRepo: ref.watch(exchangeRateRepositoryProvider),
  );
});

final calculateMonthlyCashFlowProvider =
    Provider<CalculateMonthlyCashFlow>((ref) {
  ref.watch(portfolioRevisionProvider);
  return CalculateMonthlyCashFlow(
    cashRepo: ref.watch(cashRepositoryProvider),
    loanRepo: ref.watch(loanRepositoryProvider),
    exchangeRateRepo: ref.watch(exchangeRateRepositoryProvider),
  );
});

final recordTransactionProvider = Provider<RecordTransaction>((ref) {
  return RecordTransaction(ref.watch(transactionRepositoryProvider));
});

final captureNetWorthSnapshotProvider =
    Provider<CaptureNetWorthSnapshot>((ref) {
  return CaptureNetWorthSnapshot(
    calculate: ref.watch(calculateNetWorthProvider),
    snapshotRepo: ref.watch(netWorthSnapshotRepositoryProvider),
  );
});

final buildNetWorthSeriesProvider = Provider<BuildNetWorthSeries>((ref) {
  return BuildNetWorthSeries(ref.watch(netWorthSnapshotRepositoryProvider));
});

final buildCategoryComparisonProvider =
    Provider<BuildCategoryComparison>((ref) {
  return BuildCategoryComparison(ref.watch(netWorthSnapshotRepositoryProvider));
});
