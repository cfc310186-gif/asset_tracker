import 'package:asset_tracker/domain/enums/currency_code.dart';
import 'package:asset_tracker/domain/enums/loan_type.dart';
import 'package:asset_tracker/domain/models/cash_account.dart';
import 'package:asset_tracker/domain/models/loan.dart';
import 'package:asset_tracker/domain/models/real_estate_asset.dart';
import 'package:asset_tracker/presentation/cash/cash_list_screen.dart';
import 'package:asset_tracker/presentation/loans/loan_list_screen.dart';
import 'package:asset_tracker/presentation/real_estate/real_estate_list_screen.dart';
import 'package:asset_tracker/providers/repository_providers.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../usecases/_fakes.dart';

void main() {
  testWidgets('cash list shows totals for each currency including JPY',
      (tester) async {
    final now = DateTime(2026, 5, 4);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          cashRepositoryProvider.overrideWithValue(
            FakeCashRepository([
              _cash('twd', 'TWD cash', CurrencyCode.twd, '1000', now),
              _cash('jpy', 'JPY cash', CurrencyCode.jpy, '10000', now),
            ]),
          ),
        ],
        child: const MaterialApp(home: CashListScreen()),
      ),
    );
    await tester.pump();

    expect(find.text('TWD 新台幣：NT\$1,000'), findsOneWidget);
    expect(find.text('JPY 日圓：¥10,000'), findsOneWidget);
  });

  testWidgets('loan list summarizes remaining balance and payment by type',
      (tester) async {
    final now = DateTime(2026, 5, 4);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          loanRepositoryProvider.overrideWithValue(
            FakeLoanRepository([
              _loan(
                'loan-1',
                LoanType.personalLoan,
                CurrencyCode.twd,
                remainingBalance: '100000',
                monthlyPayment: '3000',
                now: now,
              ),
              _loan(
                'loan-2',
                LoanType.personalLoan,
                CurrencyCode.twd,
                remainingBalance: '50000',
                monthlyPayment: '2000',
                now: now,
              ),
            ]),
          ),
        ],
        child: const MaterialApp(home: LoanListScreen()),
      ),
    );
    await tester.pump();

    expect(find.textContaining('TWD NT\$150,000'), findsOneWidget);
    expect(find.textContaining('TWD NT\$5,000'), findsOneWidget);
  });

  testWidgets('real estate list shows estimated value totals by currency',
      (tester) async {
    final now = DateTime(2026, 5, 4);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          realEstateRepositoryProvider.overrideWithValue(
            FakeRealEstateRepository([
              _asset('home-1', CurrencyCode.twd, '10000000', now),
              _asset('home-2', CurrencyCode.twd, '5000000', now),
              _asset('home-us', CurrencyCode.usd, '300000', now),
            ]),
          ),
        ],
        child: const MaterialApp(home: RealEstateListScreen()),
      ),
    );
    await tester.pump();

    expect(find.textContaining('TWD NT\$15,000,000'), findsOneWidget);
    expect(find.textContaining(r'USD $300,000.00'), findsOneWidget);
  });
}

CashAccount _cash(
  String id,
  String name,
  CurrencyCode currency,
  String balance,
  DateTime now,
) {
  return CashAccount(
    id: id,
    name: name,
    balance: Decimal.parse(balance),
    currency: currency,
    createdAt: now,
    updatedAt: now,
  );
}

Loan _loan(
  String id,
  LoanType type,
  CurrencyCode currency, {
  required String remainingBalance,
  required String monthlyPayment,
  required DateTime now,
}) {
  return Loan(
    id: id,
    type: type,
    name: id,
    principal: Decimal.parse(remainingBalance),
    remainingBalance: Decimal.parse(remainingBalance),
    interestRate: Decimal.parse('0.02'),
    termMonths: 60,
    monthlyPayment: Decimal.parse(monthlyPayment),
    currency: currency,
    hasGracePeriod: false,
    startDate: '2026-05-04',
    sourceType: 'personal',
    createdAt: now,
    updatedAt: now,
  );
}

RealEstateAsset _asset(
  String id,
  CurrencyCode currency,
  String estimatedValue,
  DateTime now,
) {
  return RealEstateAsset(
    id: id,
    name: id,
    address: 'address',
    estimatedValue: Decimal.parse(estimatedValue),
    purchasePrice: Decimal.parse(estimatedValue),
    purchaseDate: '2026-05-04',
    currency: currency,
    hasMortgage: false,
    createdAt: now,
    updatedAt: now,
  );
}
