import 'package:asset_tracker/domain/enums/currency_code.dart';
import 'package:asset_tracker/domain/models/time_series_point.dart';
import 'package:asset_tracker/presentation/reports/widgets/net_worth_trend_chart.dart';
import 'package:decimal/decimal.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('trend chart renders a single snapshot as chart content',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: NetWorthTrendChart(
            currency: CurrencyCode.twd,
            points: [
              TimeSeriesPoint(
                at: DateTime(2026, 5, 3),
                value: Decimal.fromInt(1200000),
              ),
            ],
          ),
        ),
      ),
    );

    expect(find.byType(LineChart), findsOneWidget);
    expect(find.textContaining('尚無歷史資料'), findsNothing);
  });
}
