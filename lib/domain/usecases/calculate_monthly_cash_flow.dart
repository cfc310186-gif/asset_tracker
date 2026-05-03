import 'package:decimal/decimal.dart';

import '../enums/currency_code.dart';
import '../models/cash_account.dart';
import '../models/loan.dart';
import '../models/monthly_cash_flow_summary.dart';
import '../repositories/cash_repository.dart';
import '../repositories/exchange_rate_repository.dart';
import '../repositories/loan_repository.dart';

class CalculateMonthlyCashFlow {
  const CalculateMonthlyCashFlow({
    required CashRepository cashRepo,
    required LoanRepository loanRepo,
    required ExchangeRateRepository exchangeRateRepo,
  })  : _cashRepo = cashRepo,
        _loanRepo = loanRepo,
        _exchangeRateRepo = exchangeRateRepo;

  final CashRepository _cashRepo;
  final LoanRepository _loanRepo;
  final ExchangeRateRepository _exchangeRateRepo;

  Future<MonthlyCashFlowSummary> execute({
    required CurrencyCode displayCurrency,
  }) async {
    final cashFuture = _cashRepo.getAll();
    final loansFuture = _loanRepo.getAll();

    final List<CashAccount> cashAccounts = await cashFuture;
    final List<Loan> loans = await loansFuture;
    final rates = await _loadRates();

    Decimal positiveCashFlow = Decimal.zero;
    for (final account in cashAccounts) {
      final monthlyInterest = account.estimatedMonthlyInterest;
      if (monthlyInterest == null) continue;
      positiveCashFlow += _convert(
        monthlyInterest,
        account.currency,
        displayCurrency,
        rates,
      );
    }

    Decimal negativeCashFlow = Decimal.zero;
    for (final loan in loans) {
      negativeCashFlow += _convert(
        loan.monthlyPayment,
        loan.currency,
        displayCurrency,
        rates,
      );
    }

    return MonthlyCashFlowSummary(
      positiveCashFlow: positiveCashFlow.round(scale: 2),
      negativeCashFlow: negativeCashFlow.round(scale: 2),
      displayCurrency: displayCurrency,
      calculatedAt: DateTime.now(),
    );
  }

  Decimal _convert(
    Decimal amount,
    CurrencyCode from,
    CurrencyCode to,
    Map<String, Decimal> rates,
  ) {
    if (from == to) return amount;
    final key = '${from.name.toUpperCase()}_${to.name.toUpperCase()}';
    final directRate = rates[key];
    if (directRate != null) return amount * directRate;

    final reverseKey = '${to.name.toUpperCase()}_${from.name.toUpperCase()}';
    final reverseRate = rates[reverseKey];
    if (reverseRate != null && reverseRate != Decimal.zero) {
      return (amount / reverseRate).toDecimal(scaleOnInfinitePrecision: 10);
    }

    return amount;
  }

  Future<Map<String, Decimal>> _loadRates() async {
    final allRates = await _exchangeRateRepo.getAll();
    final rateMap = <String, Decimal>{};
    for (final r in allRates) {
      final key =
          '${r.fromCurrency.name.toUpperCase()}_${r.toCurrency.name.toUpperCase()}';
      rateMap[key] = r.rate;
    }
    return rateMap;
  }
}
