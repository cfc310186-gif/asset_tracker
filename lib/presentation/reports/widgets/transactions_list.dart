import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/utils/currency_formatter.dart';
import '../../../domain/models/transaction.dart';

class TransactionsList extends StatelessWidget {
  const TransactionsList({super.key, required this.transactions});

  final List<Transaction> transactions;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (transactions.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Text(
            '尚無交易紀錄\n新增或編輯資產時會自動記錄',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      );
    }

    return ListView.separated(
      itemCount: transactions.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final tx = transactions[index];
        final positive = tx.amount.sign >= 0;
        return ListTile(
          leading: CircleAvatar(
            backgroundColor:
                _kindColor(tx.kind).withValues(alpha: 0.15),
            child: Icon(
              _kindIcon(tx.kind),
              color: _kindColor(tx.kind),
              size: 20,
            ),
          ),
          title: Row(
            children: [
              Text(tx.kind.displayName),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  tx.assetType.displayName,
                  style: theme.textTheme.labelSmall,
                ),
              ),
            ],
          ),
          subtitle: Text(
            DateFormat('yyyy/MM/dd HH:mm').format(tx.occurredAt),
            style: theme.textTheme.bodySmall,
          ),
          trailing: Text(
            CurrencyFormatter.formatWithSign(tx.amount, tx.currency),
            style: theme.textTheme.titleSmall?.copyWith(
              color: positive
                  ? theme.colorScheme.primary
                  : theme.colorScheme.error,
              fontWeight: FontWeight.w600,
            ),
          ),
        );
      },
    );
  }

  IconData _kindIcon(TransactionKind kind) => switch (kind) {
        TransactionKind.buy => Icons.add_shopping_cart,
        TransactionKind.sell => Icons.shopping_cart_checkout,
        TransactionKind.deposit => Icons.south_west,
        TransactionKind.withdraw => Icons.north_east,
        TransactionKind.dividend => Icons.payments,
        TransactionKind.adjust => Icons.tune,
      };

  Color _kindColor(TransactionKind kind) => switch (kind) {
        TransactionKind.buy ||
        TransactionKind.deposit ||
        TransactionKind.dividend =>
          const Color(0xFF22C55E),
        TransactionKind.sell || TransactionKind.withdraw =>
          const Color(0xFFEF4444),
        TransactionKind.adjust => const Color(0xFF6B7280),
      };
}
