import 'package:asset_tracker/domain/enums/currency_code.dart';
import 'package:asset_tracker/domain/enums/loan_type.dart';
import 'package:asset_tracker/domain/enums/market_code.dart';
import 'package:asset_tracker/domain/models/cash_account.dart';
import 'package:asset_tracker/domain/models/loan.dart';
import 'package:asset_tracker/domain/models/stock_holding.dart';
import 'package:asset_tracker/domain/usecases/calculate_net_worth.dart';
import 'package:asset_tracker/domain/usecases/capture_net_worth_snapshot.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter_test/flutter_test.dart';

import '_fakes.dart';

void main() {
  group('CaptureNetWorthSnapshot', () {
    late FakeStockRepository stockRepo;
    late FakeRealEstateRepository realEstateRepo;
    late FakeLoanRepository loanRepo;
    late FakeCashRepository cashRepo;
    late FakeExchangeRateRepository rateRepo;
    late FakeSnapshotRepository snapshotRepo;
    late CaptureNetWorthSnapshot useCase;

    setUp(() {
      stockRepo = FakeStockRepository();
      realEstateRepo = FakeRealEstateRepository();
      loanRepo = FakeLoanRepository();
      cashRepo = FakeCashRepository();
      rateRepo = FakeExchangeRateRepository();
      snapshotRepo = FakeSnapshotRepository();

      useCase = CaptureNetWorthSnapshot(
        calculate: CalculateNetWorth(
          stockRepo: stockRepo,
          realEstateRepo: realEstateRepo,
          loanRepo: loanRepo,
          cashRepo: cashRepo,
          exchangeRateRepo: rateRepo,
        ),
        snapshotRepo: snapshotRepo,
      );
    });

    test('captures snapshot normalised to midnight', () async {
      cashRepo.items.add(CashAccount(
        id: 'c1',
        name: 'Wallet',
        balance: Decimal.parse('1000'),
        currency: CurrencyCode.twd,
        createdAt: DateTime(2025, 1, 1),
        updatedAt: DateTime(2025, 1, 1),
      ));

      final at = DateTime(2025, 4, 18, 14, 30, 45);
      final snap = await useCase.execute(at: at);

      expect(snap.capturedAt, DateTime(2025, 4, 18));
      expect(snap.totalAssets, Decimal.parse('1000'));
      expect(snap.netWorth, Decimal.parse('1000'));
      expect(snap.displayCurrency, CurrencyCode.twd);
      expect(snapshotRepo.stored, hasLength(1));
    });

    test('breakdown contains all four categories with correct values',
        () async {
      stockRepo.items.add(_stock('s1', Decimal.parse('500'), 2));
      cashRepo.items.add(CashAccount(
        id: 'c1',
        name: 'Wallet',
        balance: Decimal.parse('300'),
        currency: CurrencyCode.twd,
        createdAt: DateTime(2025, 1, 1),
        updatedAt: DateTime(2025, 1, 1),
      ));
      loanRepo.items.add(_loan('l1', Decimal.parse('700')));

      final snap = await useCase.execute(at: DateTime(2025, 4, 18));

      expect(snap.breakdown['stock'], Decimal.parse('1000'));
      expect(snap.breakdown['cash'], Decimal.parse('300'));
      expect(snap.breakdown['real_estate'], Decimal.zero);
      expect(snap.breakdown['loan'], Decimal.parse('700'));
      expect(snap.totalLiabilities, Decimal.parse('700'));
      expect(snap.netWorth, Decimal.parse('600'));
    });

    test('upserts: re-running on same day overwrites prior snapshot',
        () async {
      cashRepo.items.add(CashAccount(
        id: 'c1',
        name: 'Wallet',
        balance: Decimal.parse('100'),
        currency: CurrencyCode.twd,
        createdAt: DateTime(2025, 1, 1),
        updatedAt: DateTime(2025, 1, 1),
      ));

      final at = DateTime(2025, 4, 18, 9);
      await useCase.execute(at: at);

      cashRepo.items[0] = cashRepo.items[0].copyWith(
        balance: Decimal.parse('250'),
      );
      await useCase.execute(at: at.add(const Duration(hours: 6)));

      expect(snapshotRepo.stored, hasLength(1));
      expect(snapshotRepo.stored.single.totalAssets, Decimal.parse('250'));
    });

    test('different days produce separate snapshots', () async {
      cashRepo.items.add(CashAccount(
        id: 'c1',
        name: 'Wallet',
        balance: Decimal.parse('100'),
        currency: CurrencyCode.twd,
        createdAt: DateTime(2025, 1, 1),
        updatedAt: DateTime(2025, 1, 1),
      ));

      await useCase.execute(at: DateTime(2025, 4, 17, 23, 59));
      await useCase.execute(at: DateTime(2025, 4, 18, 0, 1));

      expect(snapshotRepo.stored, hasLength(2));
    });
  });
}

StockHolding _stock(String id, Decimal price, int qty) => StockHolding(
      id: id,
      symbol: 'TEST',
      market: MarketCode.taiwan,
      name: 'Test',
      quantity: qty,
      avgCost: price,
      currency: CurrencyCode.twd,
      isMargin: false,
      latestPrice: price,
      createdAt: DateTime(2025, 1, 1),
      updatedAt: DateTime(2025, 1, 1),
    );

Loan _loan(String id, Decimal balance) => Loan(
      id: id,
      type: LoanType.personalLoan,
      name: 'Test loan',
      principal: balance,
      remainingBalance: balance,
      interestRate: Decimal.parse('0.05'),
      termMonths: 12,
      monthlyPayment: Decimal.parse('60'),
      currency: CurrencyCode.twd,
      hasGracePeriod: false,
      startDate: '2025-01-01',
      sourceType: 'personal',
      createdAt: DateTime(2025, 1, 1),
      updatedAt: DateTime(2025, 1, 1),
    );
