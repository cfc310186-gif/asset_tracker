import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../domain/usecases/build_category_comparison.dart';

class CategoryComparisonChart extends StatelessWidget {
  const CategoryComparisonChart({super.key, required this.rows});

  final List<CategoryComparisonRow> rows;

  static const _categoryKeys = ['stock', 'real_estate', 'cash', 'loan'];
  static const _categoryLabels = {
    'stock': '股票',
    'real_estate': '不動產',
    'cash': '現金',
    'loan': '貸款',
  };
  static const _categoryColors = {
    'stock': Color(0xFF3B82F6),
    'real_estate': Color(0xFF10B981),
    'cash': Color(0xFFF59E0B),
    'loan': Color(0xFFEF4444),
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (rows.isEmpty) {
      return SizedBox(
        height: 240,
        child: Center(
          child: Text(
            '尚無月度資料',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      );
    }

    final maxValue = rows
        .expand((r) => _categoryKeys.map((k) => r.values[k]?.toDouble() ?? 0))
        .fold<double>(0, (a, b) => b > a ? b : a);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 280,
          child: BarChart(
            BarChartData(
              maxY: (maxValue * 1.15).clamp(1, double.infinity),
              alignment: BarChartAlignment.spaceAround,
              barTouchData: BarTouchData(enabled: true),
              titlesData: FlTitlesData(
                rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 32,
                    getTitlesWidget: (value, meta) {
                      final idx = value.toInt();
                      if (idx < 0 || idx >= rows.length) {
                        return const SizedBox.shrink();
                      }
                      return Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          DateFormat('yy/MM').format(rows[idx].period),
                          style: theme.textTheme.labelSmall,
                        ),
                      );
                    },
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 56,
                    getTitlesWidget: (value, meta) => Padding(
                      padding: const EdgeInsets.only(right: 4),
                      child: Text(
                        _short(value),
                        style: theme.textTheme.labelSmall,
                      ),
                    ),
                  ),
                ),
              ),
              gridData: const FlGridData(show: true, drawVerticalLine: false),
              borderData: FlBorderData(show: false),
              barGroups: [
                for (var i = 0; i < rows.length; i++) _buildGroup(i, rows[i]),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 16,
          runSpacing: 8,
          children: _categoryKeys
              .map(
                (k) => _LegendDot(
                  color: _categoryColors[k]!,
                  label: _categoryLabels[k]!,
                ),
              )
              .toList(),
        ),
      ],
    );
  }

  BarChartGroupData _buildGroup(int x, CategoryComparisonRow row) {
    return BarChartGroupData(
      x: x,
      barsSpace: 2,
      barRods: _categoryKeys.map((k) {
        final v = row.values[k]?.toDouble() ?? 0;
        return BarChartRodData(
          toY: v,
          color: _categoryColors[k],
          width: 8,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(2)),
        );
      }).toList(),
    );
  }

  String _short(double v) {
    final abs = v.abs();
    if (abs >= 1000000) return '${(v / 1000000).toStringAsFixed(1)}M';
    if (abs >= 1000) return '${(v / 1000).toStringAsFixed(0)}K';
    return v.toStringAsFixed(0);
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color, required this.label});
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(label, style: Theme.of(context).textTheme.labelSmall),
      ],
    );
  }
}
