import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../domain/models/time_series_point.dart';

/// Compact line chart used inside the Dashboard NetWorthCard. No axes.
class NetWorthSparkline extends StatelessWidget {
  const NetWorthSparkline({super.key, required this.points, this.height = 56});

  final List<TimeSeriesPoint> points;
  final double height;

  @override
  Widget build(BuildContext context) {
    if (points.length < 2) return SizedBox(height: height);

    final theme = Theme.of(context);
    final spots = <FlSpot>[];
    for (var i = 0; i < points.length; i++) {
      spots.add(FlSpot(i.toDouble(), points[i].value.toDouble()));
    }
    final ys = spots.map((s) => s.y).toList();
    final minY = ys.reduce((a, b) => a < b ? a : b);
    final maxY = ys.reduce((a, b) => a > b ? a : b);

    return SizedBox(
      height: height,
      child: LineChart(
        LineChartData(
          minY: minY,
          maxY: maxY == minY ? maxY + 1 : maxY,
          titlesData: const FlTitlesData(show: false),
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
          lineTouchData: const LineTouchData(enabled: false),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              color: theme.colorScheme.primary,
              barWidth: 2,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                color:
                    theme.colorScheme.primary.withValues(alpha: 0.18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
