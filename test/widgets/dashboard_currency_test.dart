import 'package:asset_tracker/domain/enums/currency_code.dart';
import 'package:asset_tracker/domain/models/cash_account.dart';
import 'package:asset_tracker/domain/models/exchange_rate.dart';
import 'package:asset_tracker/domain/models/stock_holding.dart';
import 'package:asset_tracker/domain/enums/market_code.dart';
import 'package:asset_tracker/presentation/dashboard/dashboard_screen.dart';
import 'package:asset_tracker/providers/repository_providers.dart';
import 'package:asset_tracker/providers/settings_providers.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../usecases/_fakes.dart';

void main() {
  testWidgets('dashboard always summarizes assets in TWD using exchange rates',
      (tester) async {
    final now = DateTime(2026, 5, 4);
    final cashRepo = FakeCashRepository([
      CashAccount(
        id: 'jpy-cash',
        name: 'JPY cash',
        balance: Decimal.fromInt(10000),
        currency: CurrencyCode.jpy,
        createdAt: now,
        updatedAt: now,
      ),
    ]);
    final rateRepo = FakeExchangeRateRepository([
      ExchangeRate(
        id: 'jpy-twd',
        fromCurrency: CurrencyCode.jpy,
        toCurrency: CurrencyCode.twd,
        rate: Decimal.parse('0.21'),
        fetchedAt: now,
      ),
    ]);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          displayCurrencyProvider.overrideWith((ref) => CurrencyCode.usd),
          stockRepositoryProvider.overrideWithValue(FakeStockRepository()),
          realEstateRepositoryProvider.overrideWithValue(
            FakeRealEstateRepository(),
          ),
          loanRepositoryProvider.overrideWithValue(FakeLoanRepository()),
          cashRepositoryProvider.overrideWithValue(cashRepo),
          exchangeRateRepositoryProvider.overrideWithValue(rateRepo),
          netWorthSnapshotRepositoryProvider.overrideWithValue(
            FakeSnapshotRepository(),
          ),
        ],
        child: const MaterialApp(home: DashboardScreen()),
      ),
    );
    await tester.pump();

    expect(find.text('NT\$2,100'), findsWidgets);
    expect(find.textContaining(r'$65.63'), findsNothing);
  });

  testWidgets('dashboard converts mixed-currency assets before summing TWD',
      (tester) async {
    final now = DateTime(2026, 5, 4);
    final stockRepo = FakeStockRepository([
      StockHolding(
        id: 'usd-stock',
        symbol: 'VOD',
        market: MarketCode.uk,
        name: 'Vodafone',
        quantity: 10,
        avgCost: Decimal.fromInt(100),
        currency: CurrencyCode.usd,
        isMargin: false,
        latestPrice: Decimal.fromInt(100),
        createdAt: now,
        updatedAt: now,
      ),
    ]);
    final cashRepo = FakeCashRepository([
      CashAccount(
        id: 'jpy-cash',
        name: 'JPY cash',
        balance: Decimal.fromInt(10000),
        currency: CurrencyCode.jpy,
        createdAt: now,
        updatedAt: now,
      ),
    ]);
    final rateRepo = FakeExchangeRateRepository([
      ExchangeRate(
        id: 'usd-twd',
        fromCurrency: CurrencyCode.usd,
        toCurrency: CurrencyCode.twd,
        rate: Decimal.fromInt(32),
        fetchedAt: now,
      ),
      ExchangeRate(
        id: 'jpy-twd',
        fromCurrency: CurrencyCode.jpy,
        toCurrency: CurrencyCode.twd,
        rate: Decimal.parse('0.21'),
        fetchedAt: now,
      ),
    ]);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          displayCurrencyProvider.overrideWith((ref) => CurrencyCode.usd),
          stockRepositoryProvider.overrideWithValue(stockRepo),
          realEstateRepositoryProvider.overrideWithValue(
            FakeRealEstateRepository(),
          ),
          loanRepositoryProvider.overrideWithValue(FakeLoanRepository()),
          cashRepositoryProvider.overrideWithValue(cashRepo),
          exchangeRateRepositoryProvider.overrideWithValue(rateRepo),
          netWorthSnapshotRepositoryProvider.overrideWithValue(
            FakeSnapshotRepository(),
          ),
        ],
        child: const MaterialApp(home: DashboardScreen()),
      ),
    );
    await tester.pump();

    expect(find.text('NT\$34,100'), findsWidgets);
    expect(find.text('NT\$11,000'), findsNothing);
  });
}
