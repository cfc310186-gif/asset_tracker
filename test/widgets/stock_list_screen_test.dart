import 'package:asset_tracker/domain/enums/currency_code.dart';
import 'package:asset_tracker/domain/enums/market_code.dart';
import 'package:asset_tracker/domain/models/exchange_rate.dart';
import 'package:asset_tracker/domain/models/stock_holding.dart';
import 'package:asset_tracker/presentation/stocks/stock_list_screen.dart';
import 'package:asset_tracker/providers/repository_providers.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../usecases/_fakes.dart';

void main() {
  testWidgets('stock list can collapse market groups independently',
      (tester) async {
    tester.view.physicalSize = const Size(1200, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final now = DateTime(2026, 5, 3);
    final repo = FakeStockRepository([
      _holding(
        id: 'tw',
        symbol: '2330',
        market: MarketCode.taiwan,
        name: '台積電',
        currency: CurrencyCode.twd,
        now: now,
      ),
      _holding(
        id: 'us',
        symbol: 'AAPL',
        market: MarketCode.us,
        name: 'Apple',
        currency: CurrencyCode.usd,
        now: now,
      ),
      _holding(
        id: 'uk',
        symbol: 'VOD',
        market: MarketCode.uk,
        name: 'Vodafone',
        currency: CurrencyCode.gbp,
        now: now,
      ),
    ]);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          stockRepositoryProvider.overrideWithValue(repo),
          exchangeRateRepositoryProvider.overrideWithValue(
            FakeExchangeRateRepository(),
          ),
        ],
        child: const MaterialApp(home: StockListScreen()),
      ),
    );
    await tester.pump();

    expect(find.text('台股'), findsOneWidget);
    expect(find.text('美股'), findsOneWidget);
    expect(find.text('英股'), findsOneWidget);
    expect(find.text('2330  台積電'), findsOneWidget);
    expect(find.text('AAPL  Apple'), findsOneWidget);
    expect(find.text('VOD  Vodafone'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('stock-market-toggle-us')));
    await tester.pump();

    expect(find.text('AAPL  Apple'), findsNothing);
  });

  testWidgets('stock market totals use the holdings actual currencies',
      (tester) async {
    final now = DateTime(2026, 5, 3);
    final repo = FakeStockRepository([
      _holding(
        id: 'tw',
        symbol: '2330',
        market: MarketCode.taiwan,
        name: 'TSMC',
        currency: CurrencyCode.twd,
        now: now,
      ),
      _holding(
        id: 'uk-usd',
        symbol: 'VOD',
        market: MarketCode.uk,
        name: 'Vodafone',
        currency: CurrencyCode.usd,
        now: now,
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
    ]);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          stockRepositoryProvider.overrideWithValue(repo),
          exchangeRateRepositoryProvider.overrideWithValue(rateRepo),
        ],
        child: const MaterialApp(home: StockListScreen()),
      ),
    );
    await tester.pump();
    await tester.pump();

    expect(find.textContaining('TWD NT\$1,100'), findsOneWidget);
    expect(find.textContaining(r'USD $1,100.00'), findsOneWidget);
    expect(find.textContaining('≈ NT\$35,200'), findsOneWidget);
    expect(find.textContaining('GBP'), findsNothing);
  });

  testWidgets('stock page shows market allocation chart converted to TWD',
      (tester) async {
    final now = DateTime(2026, 5, 3);
    final repo = FakeStockRepository([
      _holding(
        id: 'tw',
        symbol: '2330',
        market: MarketCode.taiwan,
        name: 'TSMC',
        currency: CurrencyCode.twd,
        now: now,
      ),
      _holding(
        id: 'us',
        symbol: 'AAPL',
        market: MarketCode.us,
        name: 'Apple',
        currency: CurrencyCode.usd,
        now: now,
      ),
      _holding(
        id: 'uk-usd',
        symbol: 'VOD',
        market: MarketCode.uk,
        name: 'Vodafone',
        currency: CurrencyCode.usd,
        now: now,
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
    ]);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          stockRepositoryProvider.overrideWithValue(repo),
          exchangeRateRepositoryProvider.overrideWithValue(rateRepo),
        ],
        child: const MaterialApp(home: StockListScreen()),
      ),
    );
    await tester.pump();
    await tester.pump();

    expect(find.byKey(const ValueKey('stock-market-allocation-chart')),
        findsOneWidget);
    expect(
      find.textContaining('≈ NT\$35,200', skipOffstage: false),
      findsNWidgets(2),
    );
    expect(
      find.textContaining('VOD  Vodafone', skipOffstage: false),
      findsOneWidget,
    );
  });
}

StockHolding _holding({
  required String id,
  required String symbol,
  required MarketCode market,
  required String name,
  required CurrencyCode currency,
  required DateTime now,
}) {
  return StockHolding(
    id: id,
    symbol: symbol,
    market: market,
    name: name,
    quantity: 10,
    avgCost: Decimal.fromInt(100),
    currency: currency,
    isMargin: false,
    latestPrice: Decimal.fromInt(110),
    createdAt: now,
    updatedAt: now,
  );
}
