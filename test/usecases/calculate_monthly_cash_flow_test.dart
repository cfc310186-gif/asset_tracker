import 'package:asset_tracker/domain/enums/currency_code.dart';
import 'package:asset_tracker/domain/enums/loan_type.dart';
import 'package:asset_tracker/domain/models/cash_account.dart';
import 'package:asset_tracker/domain/models/exchange_rate.dart';
import 'package:asset_tracker/domain/models/loan.dart';
import 'package:asset_tracker/domain/usecases/calculate_monthly_cash_flow.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter_test/flutter_test.dart';

import '_fakes.dart';

void main() {
  group('CalculateMonthlyCashFlow', () {
    late FakeCashRepository cashRepo;
    late FakeLoanRepository loanRepo;
    late FakeExchangeRateRepository rateRepo;
    late CalculateMonthlyCashFlow useCase;

    setUp(() {
      cashRepo = FakeCashRepository();
      loanRepo = FakeLoanRepository();
      rateRepo = FakeExchangeRateRepository();
      useCase = CalculateMonthlyCashFlow(
        cashRepo: cashRepo,
        loanRepo: loanRepo,
        exchangeRateRepo: rateRepo,
      );
    });

    test('returns zeros when no data', () async {
      final summary = await useCase.execute(displayCurrency: CurrencyCode.twd);

      expect(summary.positiveCashFlow, Decimal.zero);
      expect(summary.negativeCashFlow, Decimal.zero);
      expect(summary.netCashFlow, Decimal.zero);
      expect(summary.displayCurrency, CurrencyCode.twd);
    });

    test('uses cash estimated monthly interest for positive flow', () async {
      cashRepo.items.add(_cash(
        'savings',
        CurrencyCode.twd,
        Decimal.parse('120000'),
        annualRate: Decimal.parse('0.012'),
      ));

      final summary = await useCase.execute(displayCurrency: CurrencyCode.twd);

      expect(summary.positiveCashFlow, Decimal.parse('120'));
      expect(summary.negativeCashFlow, Decimal.zero);
      expect(summary.netCashFlow, Decimal.parse('120'));
    });

    test('sums multiple loan payments for negative flow', () async {
      loanRepo.items.addAll([
        _loan('mortgage', CurrencyCode.twd, Decimal.parse('28000')),
        _loan('personal', CurrencyCode.twd, Decimal.parse('6500')),
      ]);

      final summary = await useCase.execute(displayCurrency: CurrencyCode.twd);

      expect(summary.negativeCashFlow, Decimal.parse('34500'));
      expect(summary.netCashFlow, Decimal.parse('-34500'));
    });

    test('cash account without annual rate contributes zero', () async {
      cashRepo.items.add(_cash(
        'checking',
        CurrencyCode.twd,
        Decimal.parse('100000'),
      ));

      final summary = await useCase.execute(displayCurrency: CurrencyCode.twd);

      expect(summary.positiveCashFlow, Decimal.zero);
    });

    test('converts positive and negative flows from USD to TWD', () async {
      cashRepo.items.add(_cash(
        'usd-savings',
        CurrencyCode.usd,
        Decimal.parse('1200'),
        annualRate: Decimal.parse('0.12'),
      ));
      loanRepo.items.add(_loan(
        'usd-loan',
        CurrencyCode.usd,
        Decimal.parse('25'),
      ));
      rateRepo.items.add(ExchangeRate(
        id: 'usd-twd',
        fromCurrency: CurrencyCode.usd,
        toCurrency: CurrencyCode.twd,
        rate: Decimal.parse('31.25'),
        fetchedAt: DateTime(2025, 1, 1),
      ));

      final summary = await useCase.execute(displayCurrency: CurrencyCode.twd);

      expect(summary.positiveCashFlow, Decimal.parse('375'));
      expect(summary.negativeCashFlow, Decimal.parse('781.25'));
      expect(summary.netCashFlow, Decimal.parse('-406.25'));
    });

    test('uses reverse exchange rate when direct pair is missing', () async {
      cashRepo.items.add(_cash(
        'twd-savings',
        CurrencyCode.twd,
        Decimal.parse('1200'),
        annualRate: Decimal.parse('0.12'),
      ));
      loanRepo.items.add(_loan(
        'twd-loan',
        CurrencyCode.twd,
        Decimal.parse('90'),
      ));
      rateRepo.items.add(ExchangeRate(
        id: 'usd-twd',
        fromCurrency: CurrencyCode.usd,
        toCurrency: CurrencyCode.twd,
        rate: Decimal.parse('30'),
        fetchedAt: DateTime(2025, 1, 1),
      ));

      final summary = await useCase.execute(displayCurrency: CurrencyCode.usd);

      expect(summary.positiveCashFlow, Decimal.parse('0.4'));
      expect(summary.negativeCashFlow, Decimal.parse('3'));
      expect(summary.netCashFlow, Decimal.parse('-2.6'));
    });

    test('rounds converted subtotal after aggregation', () async {
      cashRepo.items.addAll([
        _cash(
          'usd-savings-1',
          CurrencyCode.usd,
          Decimal.parse('0.04'),
          annualRate: Decimal.parse('1.2'),
        ),
        _cash(
          'usd-savings-2',
          CurrencyCode.usd,
          Decimal.parse('0.04'),
          annualRate: Decimal.parse('1.2'),
        ),
      ]);
      rateRepo.items.add(ExchangeRate(
        id: 'usd-twd',
        fromCurrency: CurrencyCode.usd,
        toCurrency: CurrencyCode.twd,
        rate: Decimal.one,
        fetchedAt: DateTime(2025, 1, 1),
      ));

      final summary = await useCase.execute(displayCurrency: CurrencyCode.twd);

      expect(summary.positiveCashFlow, Decimal.parse('0.01'));
    });
  });
}

CashAccount _cash(
  String id,
  CurrencyCode ccy,
  Decimal balance, {
  Decimal? annualRate,
}) =>
    CashAccount(
      id: id,
      name: id,
      balance: balance,
      currency: ccy,
      annualRate: annualRate,
      createdAt: DateTime(2025, 1, 1),
      updatedAt: DateTime(2025, 1, 1),
    );

Loan _loan(String id, CurrencyCode ccy, Decimal monthlyPayment) => Loan(
      id: id,
      type: LoanType.personalLoan,
      name: id,
      principal: Decimal.parse('100000'),
      remainingBalance: Decimal.parse('100000'),
      interestRate: Decimal.parse('0.05'),
      termMonths: 12,
      monthlyPayment: monthlyPayment,
      currency: ccy,
      hasGracePeriod: true,
      gracePeriodMonths: 6,
      gracePeriodEndDate: '2026-12-31',
      startDate: '2025-01-01',
      sourceType: 'personal',
      createdAt: DateTime(2025, 1, 1),
      updatedAt: DateTime(2025, 1, 1),
    );
