import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/utils/currency_formatter.dart';
import '../../domain/enums/loan_type.dart';
import '../../domain/models/loan.dart';
import '../../providers/repository_providers.dart';

class LoanListScreen extends ConsumerWidget {
  const LoanListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.watch(loanRepositoryProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('貸款')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/loans/add'),
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder<List<Loan>>(
        stream: repo.watchAll(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('錯誤：${snapshot.error}'));
          }

          final loans = snapshot.data ?? [];

          if (loans.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.credit_card_off_outlined,
                      size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text('尚未新增貸款',
                      style: TextStyle(fontSize: 18, color: Colors.grey)),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => context.push('/loans/add'),
                    icon: const Icon(Icons.add),
                    label: const Text('新增貸款'),
                  ),
                ],
              ),
            );
          }

          // Group by loan type
          final grouped = <LoanType, List<Loan>>{};
          for (final loan in loans) {
            grouped.putIfAbsent(loan.type, () => []).add(loan);
          }

          return ListView(
            children: [
              for (final type in LoanType.values)
                if (grouped.containsKey(type)) ...[
                  _GroupHeader(loanType: type),
                  ...grouped[type]!.map(
                    (loan) => _LoanTile(
                      loan: loan,
                      onTap: () =>
                          context.push('/loans/edit', extra: loan),
                      onDelete: () =>
                          _confirmDelete(context, ref, loan),
                    ),
                  ),
                ],
            ],
          );
        },
      ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    Loan loan,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('刪除貸款'),
        content: Text('確定要刪除「${loan.name}」嗎？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('刪除'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      try {
        await ref.read(loanRepositoryProvider).delete(loan.id);
        if (context.mounted) {
          ScaffoldMessenger.of(context)
              .showSnackBar(const SnackBar(content: Text('貸款已刪除')));
        }
      } on Exception catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text('刪除失敗：$e')));
        }
      }
    }
  }
}

class _GroupHeader extends StatelessWidget {
  const _GroupHeader({required this.loanType});

  final LoanType loanType;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: _colorForType(loanType).withValues(alpha: 0.1),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Text(
        loanType.displayName,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: _colorForType(loanType),
          fontSize: 14,
        ),
      ),
    );
  }

  Color _colorForType(LoanType type) => switch (type) {
        LoanType.mortgage => Colors.blue,
        LoanType.personalLoan => Colors.orange,
        LoanType.stockMarginLoan => Colors.purple,
      };
}

class _LoanTile extends StatelessWidget {
  const _LoanTile({
    required this.loan,
    required this.onTap,
    required this.onDelete,
  });

  final Loan loan;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final typeColor = _colorForType(loan.type);

    return Dismissible(
      key: Key(loan.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        color: Colors.red,
        padding: const EdgeInsets.only(right: 16),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      confirmDismiss: (_) async {
        onDelete();
        return false;
      },
      child: ListTile(
        onTap: onTap,
        onLongPress: onDelete,
        leading: CircleAvatar(
          backgroundColor: typeColor.withValues(alpha: 0.15),
          child: Icon(Icons.credit_card, color: typeColor),
        ),
        title: Row(
          children: [
            Expanded(child: Text(loan.name)),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: typeColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                loan.type.displayName,
                style: TextStyle(
                    fontSize: 11,
                    color: typeColor,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        subtitle: Text(
          '利率 ${CurrencyFormatter.formatRate(loan.interestRate)}  '
          '月付 ${CurrencyFormatter.format(loan.monthlyPayment, loan.currency)}',
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              CurrencyFormatter.format(
                  loan.remainingBalance, loan.currency),
              style: const TextStyle(
                  fontWeight: FontWeight.bold, fontSize: 15),
            ),
            Text('剩餘',
                style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }

  Color _colorForType(LoanType type) => switch (type) {
        LoanType.mortgage => Colors.blue,
        LoanType.personalLoan => Colors.orange,
        LoanType.stockMarginLoan => Colors.purple,
      };
}
