import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../domain/models/monthly_cash_flow_summary.dart';

class MonthlyCashFlowCard extends StatelessWidget {
  const MonthlyCashFlowCard({
    super.key,
    required this.summary,
    required this.onRetry,
  });

  final AsyncValue<MonthlyCashFlowSummary> summary;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Semantics(
      identifier: 'monthly-cash-flow-card',
      label: summary.maybeWhen(
        data: (value) {
          final positive = CurrencyFormatter.format(
            value.positiveCashFlow,
            value.displayCurrency,
          );
          final negative = CurrencyFormatter.formatWithSign(
            Decimal.zero - value.negativeCashFlow,
            value.displayCurrency,
          );
          final net = CurrencyFormatter.formatWithSign(
            value.netCashFlow,
            value.displayCurrency,
          );
          return '每月現金流 正現金流 $positive 負現金流 $negative 淨現金流 $net';
        },
        orElse: () => '每月現金流',
      ),
      container: true,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '每月現金流',
                style: theme.textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              summary.when(
                data: (value) => _CashFlowValues(summary: value),
                loading: () => const _CashFlowLoading(),
                error: (error, stackTrace) => _CashFlowError(onRetry: onRetry),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

enum _CashFlowLayout {
  row,
  wrap,
  stacked,
}

_CashFlowLayout _layoutFor(double width, double textScaleFactor) {
  if (width >= 520 && textScaleFactor <= 1.2) {
    return _CashFlowLayout.row;
  }
  if (width >= 360 && textScaleFactor <= 1.4) {
    return _CashFlowLayout.wrap;
  }
  return _CashFlowLayout.stacked;
}

class _AdaptiveMetricLayout extends StatelessWidget {
  const _AdaptiveMetricLayout({
    required this.children,
    required this.stackedSpacing,
  });

  final List<Widget> children;
  final double stackedSpacing;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final layout = _layoutFor(
          constraints.maxWidth,
          MediaQuery.textScalerOf(context).scale(1),
        );

        switch (layout) {
          case _CashFlowLayout.row:
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final child in children)
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: child,
                    ),
                  ),
              ],
            );
          case _CashFlowLayout.wrap:
            final itemWidth = (constraints.maxWidth - 12) / 2;
            return Wrap(
              spacing: 12,
              runSpacing: stackedSpacing,
              children: [
                SizedBox(width: itemWidth, child: children[0]),
                SizedBox(width: itemWidth, child: children[1]),
                SizedBox(width: constraints.maxWidth, child: children[2]),
              ],
            );
          case _CashFlowLayout.stacked:
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (var i = 0; i < children.length; i++) ...[
                  children[i],
                  if (i != children.length - 1)
                    SizedBox(height: stackedSpacing),
                ],
              ],
            );
        }
      },
    );
  }
}

class _CashFlowValues extends StatelessWidget {
  const _CashFlowValues({required this.summary});

  final MonthlyCashFlowSummary summary;

  @override
  Widget build(BuildContext context) {
    final netColor = summary.netCashFlow.sign > 0
        ? AppTheme.gainColor
        : summary.netCashFlow.sign < 0
            ? AppTheme.lossColor
            : AppTheme.neutralColor;

    return _AdaptiveMetricLayout(
      stackedSpacing: 10,
      children: [
        _CashFlowMetric(
          label: '正現金流',
          amount: CurrencyFormatter.format(
            summary.positiveCashFlow,
            summary.displayCurrency,
          ),
          color: AppTheme.gainColor,
        ),
        _CashFlowMetric(
          label: '負現金流',
          amount: CurrencyFormatter.formatWithSign(
            Decimal.zero - summary.negativeCashFlow,
            summary.displayCurrency,
          ),
          color: AppTheme.lossColor,
        ),
        _CashFlowMetric(
          label: '淨現金流',
          amount: CurrencyFormatter.formatWithSign(
            summary.netCashFlow,
            summary.displayCurrency,
          ),
          color: netColor,
        ),
      ],
    );
  }
}

class _CashFlowMetric extends StatelessWidget {
  const _CashFlowMetric({
    required this.label,
    required this.amount,
    required this.color,
  });

  final String label;
  final String amount;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        Align(
          alignment: Alignment.centerLeft,
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              amount,
              style: theme.textTheme.titleLarge?.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _CashFlowLoading extends StatelessWidget {
  const _CashFlowLoading();

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.surfaceContainerHighest;

    return _AdaptiveMetricLayout(
      stackedSpacing: 12,
      children: List.generate(
        3,
        (index) => _LoadingMetric(color: color),
      ),
    );
  }
}

class _LoadingMetric extends StatelessWidget {
  const _LoadingMetric({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 12,
          width: 64,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 20,
          width: 88,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ],
    );
  }
}

class _CashFlowError extends StatelessWidget {
  const _CashFlowError({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        const Icon(
          Icons.error_outline,
          size: 18,
          color: AppTheme.lossColor,
        ),
        Text(
          '現金流載入失敗',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        TextButton.icon(
          onPressed: onRetry,
          icon: const Icon(Icons.refresh, size: 16),
          label: const Text('重試'),
        ),
      ],
    );
  }
}
