import 'package:asset_tracker/data/api/stock_price_provider.dart';
import 'package:asset_tracker/domain/enums/market_code.dart';
import 'package:asset_tracker/domain/repositories/price_repository.dart';
import 'package:asset_tracker/presentation/stocks/add_edit_stock_screen.dart';
import 'package:asset_tracker/providers/price_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakePriceRepository implements PriceRepository {
  _FakePriceRepository(this._names);
  final Map<String, String> _names; // symbol(uppercase) → display name

  int lookupCalls = 0;

  @override
  Future<String?> lookupName(String symbol, MarketCode market) async {
    lookupCalls++;
    return _names[symbol.toUpperCase()];
  }

  @override
  Future<StockQuote?> getQuote(String symbol, MarketCode market) async => null;

  @override
  Future<List<StockQuote>> refreshAll(
    List<({String symbol, MarketCode market})> holdings,
  ) async =>
      [];

  @override
  Future<void> cacheQuote(StockQuote quote, MarketCode market) async {}
}

/// Regression tests for two reported mobile bugs:
///   1. typing a symbol like "2330" or "AAPL" does NOT auto-fill the name,
///   2. price refresh shows a generic failure with no actionable hint.
void main() {
  group('AddEditStockScreen', () {
    testWidgets('builds without exception when opened for a new stock',
        (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: AddEditStockScreen(),
          ),
        ),
      );

      expect(tester.takeException(), isNull);
      expect(find.text('新增股票'), findsOneWidget);
      expect(find.text('股票代號 *'), findsOneWidget);
      expect(find.text('股票名稱 *'), findsOneWidget);
      expect(find.text('股數 *'), findsOneWidget);
    });

    testWidgets(
      'renders the US market dropdown by default (non-taiwan symbol empty)',
      (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: AddEditStockScreen(),
            ),
          ),
        );

        expect(tester.takeException(), isNull);
        expect(find.text('市場 *'), findsOneWidget);
      },
    );

    testWidgets(
      'typing a Taiwan symbol switches to the read-only Taiwan tile',
      (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: AddEditStockScreen(),
            ),
          ),
        );

        final symbolField = find.widgetWithText(TextField, '').first;
        await tester.enterText(symbolField, '2330');
        await tester.pump();

        expect(tester.takeException(), isNull);
        expect(find.textContaining('自動識別'), findsOneWidget);
      },
    );

    testWidgets(
      'typing a Taiwan symbol auto-populates the name from PriceRepository',
      (tester) async {
        final repo = _FakePriceRepository({'2330': '台積電'});
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              priceRepositoryProvider.overrideWithValue(repo),
            ],
            child: const MaterialApp(
              home: AddEditStockScreen(),
            ),
          ),
        );

        final symbolField = find.widgetWithText(TextField, '').first;
        await tester.enterText(symbolField, '2330');
        // Past the 600ms debounce.
        await tester.pump(const Duration(milliseconds: 700));
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
        expect(repo.lookupCalls, greaterThanOrEqualTo(1));
        expect(find.text('台積電'), findsOneWidget);
      },
    );

    testWidgets(
      'typing a US symbol auto-populates the name from PriceRepository',
      (tester) async {
        final repo = _FakePriceRepository({'AAPL': 'APPLE'});
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              priceRepositoryProvider.overrideWithValue(repo),
            ],
            child: const MaterialApp(
              home: AddEditStockScreen(),
            ),
          ),
        );

        final symbolField = find.widgetWithText(TextField, '').first;
        await tester.enterText(symbolField, 'AAPL');
        await tester.pump(const Duration(milliseconds: 700));
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
        expect(repo.lookupCalls, greaterThanOrEqualTo(1));
        expect(find.text('APPLE'), findsOneWidget);
      },
    );

    testWidgets(
      'does not overwrite a name the user typed manually',
      (tester) async {
        final repo = _FakePriceRepository({'AAPL': 'APPLE'});
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              priceRepositoryProvider.overrideWithValue(repo),
            ],
            child: const MaterialApp(
              home: AddEditStockScreen(),
            ),
          ),
        );

        // Enter a manual name first, then a symbol.
        final fields = find.byType(TextField);
        await tester.enterText(fields.at(1), '我的蘋果');
        await tester.enterText(fields.first, 'AAPL');
        await tester.pump(const Duration(milliseconds: 700));
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
        expect(find.text('我的蘋果'), findsOneWidget);
        expect(find.text('APPLE'), findsNothing);
      },
    );
  });
}
