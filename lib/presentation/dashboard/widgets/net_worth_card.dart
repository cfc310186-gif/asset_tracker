import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../domain/models/net_worth_summary.dart';

class NetWorthCard extends StatelessWidget {
  const NetWorthCard({super.key, required this.summary});

  final NetWorthSummary summary;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final netWorth = summary.netWorth;
    final netWorthColor =
        netWorth < Decimal.zero ? AppTheme.lossColor : AppTheme.gainColor;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '總淨資產',
              style: theme.textTheme.labelLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              CurrencyFormatter.format(netWorth, summary.displayCurrency),
              style: theme.textTheme.displaySmall?.copyWith(
                color: netWorthColor,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 16),
            const Divider(height: 1),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _SummaryItem(
                    label: '總資產',
                    amount: CurrencyFormatter.format(
                      summary.totalAssets,
                      summary.displayCurrency,
                    ),
                    color: AppTheme.gainColor,
                  ),
                ),
                Container(width: 1, height: 32, color: Colors.grey.shade200),
                Expanded(
                  child: _SummaryItem(
                    label: '總負債',
                    amount: CurrencyFormatter.format(
                      summary.totalLoanBalance,
                      summary.displayCurrency,
                    ),
                    color: AppTheme.lossColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  const _SummaryItem({
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            amount,
            style: theme.textTheme.titleLarge?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
