import 'package:asset_tracker/core/utils/loan_calculator.dart';
import 'package:asset_tracker/core/utils/currency_formatter.dart';
import 'package:asset_tracker/domain/enums/currency_code.dart';
import 'package:asset_tracker/domain/enums/loan_type.dart';
import 'package:asset_tracker/domain/models/loan.dart';
import 'package:asset_tracker/presentation/loans/add_edit_loan_screen.dart';
import 'package:asset_tracker/providers/repository_providers.dart';
import 'package:asset_tracker/providers/usecase_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:decimal/decimal.dart';

import '../usecases/_fakes.dart';

void main() {
  testWidgets('mortgage grace period updates monthly payment to interest only',
      (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: AddEditLoanScreen(),
        ),
      ),
    );

    await tester.enterText(find.widgetWithText(TextField, '貸款名稱 *'), '房貸');
    await tester.enterText(find.widgetWithText(TextField, '本金 *'), '1200000');
    await tester.enterText(find.widgetWithText(TextField, '剩餘餘額 *'), '1200000');
    await tester.enterText(find.widgetWithText(TextField, '年利率 (%) *'), '1.2');
    await tester.enterText(find.widgetWithText(TextField, '貸款期限（月）*'), '240');
    await tester.pump();

    final principal = Decimal.parse('1200000');
    final annualRate = Decimal.parse('0.012');
    final normalPayment = LoanCalculator.calculateMonthlyPayment(
      principal: principal,
      annualRate: annualRate,
      termMonths: 240,
    );
    final gracePayment = LoanCalculator.calculateInterestOnlyPayment(
      principal: principal,
      annualRate: annualRate,
    );

    expect(
      find.text(CurrencyFormatter.format(normalPayment, CurrencyCode.twd)),
      findsOneWidget,
    );

    await tester.ensureVisible(find.byType(Switch).first);
    await tester.tap(find.byType(Switch).first);
    await tester.pump();

    expect(
      find.text(CurrencyFormatter.format(gracePayment, CurrencyCode.twd)),
      findsOneWidget,
    );
    expect(
      find.text(CurrencyFormatter.format(normalPayment, CurrencyCode.twd)),
      findsNothing,
    );
  });

  testWidgets('personal loan rate changes update monthly payment immediately',
      (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: AddEditLoanScreen(),
        ),
      ),
    );

    await tester.tap(find.text('房貸'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('信貸').last);
    await tester.pumpAndSettle();

    await tester.enterText(find.widgetWithText(TextField, '貸款名稱 *'), '信貸');
    await tester.enterText(find.widgetWithText(TextField, '本金 *'), '120000');
    await tester.enterText(find.widgetWithText(TextField, '剩餘餘額 *'), '120000');
    await tester.enterText(find.widgetWithText(TextField, '年利率 (%) *'), '1.2');
    await tester.enterText(find.widgetWithText(TextField, '貸款期限（月）*'), '24');
    await tester.pump();

    final principal = Decimal.parse('120000');
    final firstPayment = LoanCalculator.calculateMonthlyPayment(
      principal: principal,
      annualRate: Decimal.parse('0.012'),
      termMonths: 24,
    );
    final updatedPayment = LoanCalculator.calculateMonthlyPayment(
      principal: principal,
      annualRate: Decimal.parse('0.024'),
      termMonths: 24,
    );

    expect(
      find.text(CurrencyFormatter.format(firstPayment, CurrencyCode.twd)),
      findsOneWidget,
    );

    await tester.enterText(find.widgetWithText(TextField, '年利率 (%) *'), '2.4');
    await tester.pump();

    expect(
      find.text(CurrencyFormatter.format(updatedPayment, CurrencyCode.twd)),
      findsOneWidget,
    );
    expect(
      find.text(CurrencyFormatter.format(firstPayment, CurrencyCode.twd)),
      findsNothing,
    );
  });

  testWidgets('saving a personal loan recalculates payment from current rate',
      (tester) async {
    final now = DateTime(2026, 5, 4);
    final loanRepo = FakeLoanRepository([
      Loan(
        id: 'loan-1',
        type: LoanType.personalLoan,
        name: '信貸',
        principal: Decimal.parse('120000'),
        remainingBalance: Decimal.parse('120000'),
        interestRate: Decimal.parse('0.012'),
        termMonths: 24,
        monthlyPayment: LoanCalculator.calculateMonthlyPayment(
          principal: Decimal.parse('120000'),
          annualRate: Decimal.parse('0.012'),
          termMonths: 24,
        ),
        currency: CurrencyCode.twd,
        hasGracePeriod: false,
        startDate: '2026-05-04',
        sourceType: 'manual',
        createdAt: now,
        updatedAt: now,
      ),
    ]);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          stockRepositoryProvider.overrideWithValue(FakeStockRepository()),
          realEstateRepositoryProvider.overrideWithValue(
            FakeRealEstateRepository(),
          ),
          loanRepositoryProvider.overrideWithValue(loanRepo),
          cashRepositoryProvider.overrideWithValue(FakeCashRepository()),
          exchangeRateRepositoryProvider.overrideWithValue(
            FakeExchangeRateRepository(),
          ),
          netWorthSnapshotRepositoryProvider.overrideWithValue(
            FakeSnapshotRepository(),
          ),
          portfolioRevisionProvider.overrideWith((ref) => 0),
        ],
        child: MaterialApp(
          home: AddEditLoanScreen(loan: loanRepo.items.single),
        ),
      ),
    );

    await tester.enterText(find.widgetWithText(TextField, '年利率 (%) *'), '2.4');
    await tester.pump();
    await tester.ensureVisible(find.text('儲存'));
    await tester.tap(find.text('儲存'));
    await tester.pump(const Duration(milliseconds: 500));

    final saved = loanRepo.items.single;
    expect(saved.interestRate.toString(), '0.024');
    expect(
      saved.monthlyPayment,
      LoanCalculator.calculateMonthlyPayment(
        principal: Decimal.parse('120000'),
        annualRate: Decimal.parse('0.024'),
        termMonths: 24,
      ),
    );
  });
}
