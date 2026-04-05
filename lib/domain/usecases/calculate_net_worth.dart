import 'package:decimal/decimal.dart';

import '../enums/currency_code.dart';
import '../models/cash_account.dart';
import '../models/loan.dart';
import '../models/net_worth_summary.dart';
import '../models/real_estate_asset.dart';
import '../models/stock_holding.dart';
import '../repositories/cash_repository.dart';
import '../repositories/exchange_rate_repository.dart';
import '../repositories/loan_repository.dart';
import '../repositories/real_estate_repository.dart';
import '../repositories/stock_repository.dart';

/// Calculates a multi-currency net worth summary converted to a single
/// [displayCurrency].
class CalculateNetWorth {
  const CalculateNetWorth({
    required StockRepository stockRepo,
    required RealEstateRepository realEstateRepo,
    required LoanRepository loanRepo,
    required CashRepository cashRepo,
    required ExchangeRateRepository exchangeRateRepo,
  })  : _stockRepo = stockRepo,
        _realEstateRepo = realEstateRepo,
        _loanRepo = loanRepo,
        _cashRepo = cashRepo,
        _exchangeRateRepo = exchangeRateRepo;

  final StockRepository _stockRepo;
  final RealEstateRepository _realEstateRepo;
  final LoanRepository _loanRepo;
  final CashRepository _cashRepo;
  final ExchangeRateRepository _exchangeRateRepo;

  /// Computes [NetWorthSummary] with all values converted to [displayCurrency].
  Future<NetWorthSummary> execute({
    CurrencyCode displayCurrency = CurrencyCode.twd,
  }) async {
    // Load all data in parallel with explicit typed futures.
    final stocksFuture = _stockRepo.getAll();
    final realEstateFuture = _realEstateRepo.getAll();
    final loansFuture = _loanRepo.getAll();
    final cashFuture = _cashRepo.getAll();

    final List<StockHolding> stocks = await stocksFuture;
    final List<RealEstateAsset> realEstate = await realEstateFuture;
    final List<Loan> loans = await loansFuture;
    final List<CashAccount> cash = await cashFuture;

    // Build exchange rate lookup map.
    final rates = await _loadRates();

    Decimal stockTotal = Decimal.zero;
    for (final s in stocks) {
      stockTotal += _convert(s.totalValue, s.currency, displayCurrency, rates);
    }

    Decimal realEstateTotal = Decimal.zero;
    for (final r in realEstate) {
      realEstateTotal +=
          _convert(r.estimatedValue, r.currency, displayCurrency, rates);
    }

    Decimal cashTotal = Decimal.zero;
    for (final c in cash) {
      cashTotal += _convert(c.balance, c.currency, displayCurrency, rates);
    }

    Decimal loanTotal = Decimal.zero;
    for (final l in loans) {
      loanTotal +=
          _convert(l.remainingBalance, l.currency, displayCurrency, rates);
    }

    return NetWorthSummary(
      totalStockValue: stockTotal,
      totalRealEstateValue: realEstateTotal,
      totalCashValue: cashTotal,
      totalLoanBalance: loanTotal,
      displayCurrency: displayCurrency,
      calculatedAt: DateTime.now(),
    );
  }

  /// Converts [amount] from [from] currency to [to] currency using [rates].
  ///
  /// Falls back to a 1:1 rate if the pair is not found in [rates].
  Decimal _convert(
    Decimal amount,
    CurrencyCode from,
    CurrencyCode to,
    Map<String, Decimal> rates,
  ) {
    if (from == to) return amount;
    final key = '${from.name.toUpperCase()}_${to.name.toUpperCase()}';
    final rate = rates[key] ?? Decimal.one;
    return (amount * rate).round(scale: 2);
  }

  /// Loads all exchange rates from the repository and returns them as a
  /// key→rate map where keys are formatted as "FROM_TO" (e.g. "USD_TWD").
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
