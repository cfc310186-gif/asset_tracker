import 'package:asset_tracker/presentation/stocks/add_edit_stock_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// Regression test: the add-new path used to throw LateInitializationError
/// because _detectMarket() read the uninitialised `_market` field during
/// initState. On mobile web that manifested as a blank gray screen.
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
      // Title should read "新增股票" (add), not "編輯股票" (edit).
      expect(find.text('新增股票'), findsOneWidget);
      // Core form fields should be present.
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
        // Foreign market selector is shown because symbol is empty and
        // _detectMarket() defaults to US.
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
        // Taiwan read-only tile replaces the dropdown.
        expect(find.textContaining('自動識別'), findsOneWidget);
      },
    );
  });
}
