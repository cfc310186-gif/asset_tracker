import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/usecases/calculate_net_worth.dart';
import '../domain/usecases/create_margin_loan.dart';
import '../domain/usecases/create_mortgage.dart';
import '../domain/usecases/sync_linked_loans.dart';
import 'repository_providers.dart';

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
  return CalculateNetWorth(
    stockRepo: ref.watch(stockRepositoryProvider),
    realEstateRepo: ref.watch(realEstateRepositoryProvider),
    loanRepo: ref.watch(loanRepositoryProvider),
    cashRepo: ref.watch(cashRepositoryProvider),
    exchangeRateRepo: ref.watch(exchangeRateRepositoryProvider),
  );
});
