import 'package:asset_tracker/core/utils/loan_calculator.dart';
import 'package:asset_tracker/core/utils/currency_formatter.dart';
import 'package:asset_tracker/domain/enums/currency_code.dart';
import 'package:asset_tracker/presentation/loans/add_edit_loan_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:decimal/decimal.dart';

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
}
