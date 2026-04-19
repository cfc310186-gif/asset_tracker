import 'package:asset_tracker/domain/enums/currency_code.dart';
import 'package:asset_tracker/domain/enums/loan_type.dart';
import 'package:asset_tracker/domain/enums/market_code.dart';
import 'package:asset_tracker/domain/models/cash_account.dart';
import 'package:asset_tracker/domain/models/exchange_rate.dart';
import 'package:asset_tracker/domain/models/loan.dart';
import 'package:asset_tracker/domain/models/real_estate_asset.dart';
import 'package:asset_tracker/domain/models/stock_holding.dart';
import 'package:asset_tracker/domain/usecases/calculate_net_worth.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter_test/flutter_test.dart';

import '_fakes.dart';

void main() {
  group('CalculateNetWorth', () {
    late FakeStockRepository stockRepo;
    late FakeRealEstateRepository realEstateRepo;
    late FakeLoanRepository loanRepo;
    late FakeCashRepository cashRepo;
    late FakeExchangeRateRepository rateRepo;
    late CalculateNetWorth useCase;

    setUp(() {
      stockRepo = FakeStockRepository();
      realEstateRepo = FakeRealEstateRepository();
      loanRepo = FakeLoanRepository();
      cashRepo = FakeCashRepository();
      rateRepo = FakeExchangeRateRepository();
      useCase = CalculateNetWorth(
        stockRepo: stockRepo,
        realEstateRepo: realEstateRepo,
        loanRepo: loanRepo,
        cashRepo: cashRepo,
        exchangeRateRepo: rateRepo,
      );
    });

    test('returns all zeros when no data', () async {
      final summary = await useCase.execute();
      expect(summary.totalAssets, Decimal.zero);
      expect(summary.totalLoanBalance, Decimal.zero);
      expect(summary.netWorth, Decimal.zero);
      expect(summary.displayCurrency, CurrencyCode.twd);
    });

    test('sums same-currency assets directly', () async {
      stockRepo.items.add(_stock(
          'AAPL', MarketCode.us, CurrencyCode.usd, Decimal.parse('200'), 5));
      cashRepo.items.add(_cash('c', CurrencyCode.usd, Decimal.parse('500')));

      final summary = await useCase.execute(displayCurrency: CurrencyCode.usd);
      expect(summary.totalStockValue, Decimal.parse('1000'));
      expect(summary.totalCashValue, Decimal.parse('500'));
      expect(summary.netWorth, Decimal.parse('1500'));
    });

    test('converts via exchange rate when currencies differ', () async {
      cashRepo.items.add(_cash('c', CurrencyCode.usd, Decimal.parse('100')));
      rateRepo.items.add(ExchangeRate(
        id: 'r1',
        fromCurrency: CurrencyCode.usd,
        toCurrency: CurrencyCode.twd,
        rate: Decimal.parse('32'),
        fetchedAt: DateTime.now(),
      ));

      final summary = await useCase.execute(displayCurrency: CurrencyCode.twd);
      expect(summary.totalCashValue, Decimal.parse('3200'));
    });

    test('falls back to 1:1 rate when pair missing', () async {
      cashRepo.items.add(_cash('c', CurrencyCode.usd, Decimal.parse('100')));

      final summary = await useCase.execute(displayCurrency: CurrencyCode.twd);
      expect(summary.totalCashValue, Decimal.parse('100'));
    });

    test('liabilities subtract from net worth', () async {
      cashRepo.items.add(_cash('c', CurrencyCode.twd, Decimal.parse('1000')));
      loanRepo.items.add(_loan('l', CurrencyCode.twd, Decimal.parse('400')));

      final summary = await useCase.execute(displayCurrency: CurrencyCode.twd);
      expect(summary.totalLoanBalance, Decimal.parse('400'));
      expect(summary.netWorth, Decimal.parse('600'));
    });

    test('real estate value uses estimatedValue, not purchasePrice',
        () async {
      realEstateRepo.items.add(RealEstateAsset(
        id: 're1',
        name: 'Apt',
        address: 'X',
        purchasePrice: Decimal.parse('5000000'),
        estimatedValue: Decimal.parse('6000000'),
        purchaseDate: '2020-01-01',
        currency: CurrencyCode.twd,
        hasMortgage: false,
        createdAt: DateTime(2025, 1, 1),
        updatedAt: DateTime(2025, 1, 1),
      ));

      final summary = await useCase.execute(displayCurrency: CurrencyCode.twd);
      expect(summary.totalRealEstateValue, Decimal.parse('6000000'));
    });
  });
}

StockHolding _stock(String symbol, MarketCode market, CurrencyCode ccy,
        Decimal price, int qty) =>
    StockHolding(
      id: symbol,
      symbol: symbol,
      market: market,
      name: symbol,
      quantity: qty,
      avgCost: price,
      currency: ccy,
      isMargin: false,
      latestPrice: price,
      createdAt: DateTime(2025, 1, 1),
      updatedAt: DateTime(2025, 1, 1),
    );

CashAccount _cash(String id, CurrencyCode ccy, Decimal balance) => CashAccount(
      id: id,
      name: id,
      balance: balance,
      currency: ccy,
      createdAt: DateTime(2025, 1, 1),
      updatedAt: DateTime(2025, 1, 1),
    );

Loan _loan(String id, CurrencyCode ccy, Decimal balance) => Loan(
      id: id,
      type: LoanType.personalLoan,
      name: id,
      principal: balance,
      remainingBalance: balance,
      interestRate: Decimal.parse('0.05'),
      termMonths: 12,
      monthlyPayment: Decimal.parse('60'),
      currency: ccy,
      hasGracePeriod: false,
      startDate: '2025-01-01',
      sourceType: 'personal',
      createdAt: DateTime(2025, 1, 1),
      updatedAt: DateTime(2025, 1, 1),
    );
