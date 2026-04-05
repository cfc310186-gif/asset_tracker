import 'package:decimal/decimal.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../domain/models/net_worth_summary.dart';

const _stockColor = Color(0xFF3B82F6);
const _realEstateColor = Color(0xFF10B981);
const _cashColor = Color(0xFFF59E0B);
const _loanColor = Color(0xFFEF4444);

class AssetBreakdownChart extends StatefulWidget {
  const AssetBreakdownChart({super.key, required this.summary});

  final NetWorthSummary summary;

  @override
  State<AssetBreakdownChart> createState() => _AssetBreakdownChartState();
}

class _AssetBreakdownChartState extends State<AssetBreakdownChart> {
  int _touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    final segments = _buildSegments();

    if (segments.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Center(child: Text('尚無資產資料')),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '資產配置',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  sections: _buildSections(segments),
                  centerSpaceRadius: 40,
                  sectionsSpace: 2,
                  pieTouchData: PieTouchData(
                    touchCallback: (event, response) {
                      setState(() {
                        if (!event.isInterestedForInteractions ||
                            response == null ||
                            response.touchedSection == null) {
                          _touchedIndex = -1;
                          return;
                        }
                        _touchedIndex =
                            response.touchedSection!.touchedSectionIndex;
                      });
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            _Legend(segments: segments),
          ],
        ),
      ),
    );
  }

  List<_ChartSegment> _buildSegments() {
    final summary = widget.summary;
    final segments = <_ChartSegment>[];

    if (summary.totalStockValue > Decimal.zero) {
      segments.add(_ChartSegment(
        label: '股票',
        value: summary.totalStockValue,
        color: _stockColor,
      ));
    }
    if (summary.totalRealEstateValue > Decimal.zero) {
      segments.add(_ChartSegment(
        label: '不動產',
        value: summary.totalRealEstateValue,
        color: _realEstateColor,
      ));
    }
    if (summary.totalCashValue > Decimal.zero) {
      segments.add(_ChartSegment(
        label: '現金',
        value: summary.totalCashValue,
        color: _cashColor,
      ));
    }
    if (summary.totalLoanBalance > Decimal.zero) {
      segments.add(_ChartSegment(
        label: '貸款',
        value: summary.totalLoanBalance,
        color: _loanColor,
      ));
    }

    return segments;
  }

  List<PieChartSectionData> _buildSections(List<_ChartSegment> segments) {
    final total = segments.fold(
      Decimal.zero,
      (sum, s) => sum + s.value,
    );
    if (total == Decimal.zero) return [];

    return List.generate(segments.length, (i) {
      final segment = segments[i];
      final isTouched = i == _touchedIndex;
      final totalDouble = total.toDouble();
      final percentage = totalDouble > 0
          ? (segment.value.toDouble() / totalDouble) * 100.0
          : 0.0;

      return PieChartSectionData(
        color: segment.color,
        value: segment.value.toDouble(),
        title: '${percentage.toStringAsFixed(1)}%',
        radius: isTouched ? 70 : 55,
        titleStyle: TextStyle(
          fontSize: isTouched ? 14 : 12,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      );
    });
  }
}

class _ChartSegment {
  const _ChartSegment({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final Decimal value;
  final Color color;
}

class _Legend extends StatelessWidget {
  const _Legend({required this.segments});

  final List<_ChartSegment> segments;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Determine display currency — pick TWD as default for now
    // The segments already hold raw values; we display formatted amounts
    // using CurrencyFormatter with each segment's own currency assumption
    // (all values are already normalized to the display currency)
    return Wrap(
      spacing: 16,
      runSpacing: 8,
      children: segments.map((segment) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: segment.color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              segment.label,
              style: theme.textTheme.bodyMedium,
            ),
          ],
        );
      }).toList(),
    );
  }
}
