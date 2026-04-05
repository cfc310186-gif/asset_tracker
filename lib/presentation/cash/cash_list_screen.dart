import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/utils/currency_formatter.dart';
import '../../domain/enums/currency_code.dart';
import '../../domain/models/cash_account.dart';
import '../../providers/repository_providers.dart';

class CashListScreen extends ConsumerWidget {
  const CashListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.watch(cashRepositoryProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('現金帳戶')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/cash/add'),
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder<List<CashAccount>>(
        stream: repo.watchAll(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('錯誤：${snapshot.error}'));
          }

          final accounts = snapshot.data ?? [];

          if (accounts.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.account_balance_wallet_outlined,
                      size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text('尚未新增現金帳戶',
                      style: TextStyle(fontSize: 18, color: Colors.grey)),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => context.push('/cash/add'),
                    icon: const Icon(Icons.add),
                    label: const Text('新增帳戶'),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              _TotalBalanceHeader(accounts: accounts),
              Expanded(
                child: ListView.builder(
                  itemCount: accounts.length,
                  itemBuilder: (context, index) {
                    final account = accounts[index];
                    return _CashAccountTile(
                      account: account,
                      onTap: () =>
                          context.push('/cash/edit', extra: account),
                      onDelete: () => _confirmDelete(context, ref, account),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    CashAccount account,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('刪除帳戶'),
        content: Text('確定要刪除「${account.name}」嗎？'),
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
        await ref.read(cashRepositoryProvider).delete(account.id);
        if (context.mounted) {
          ScaffoldMessenger.of(context)
              .showSnackBar(const SnackBar(content: Text('帳戶已刪除')));
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

class _TotalBalanceHeader extends StatelessWidget {
  const _TotalBalanceHeader({required this.accounts});

  final List<CashAccount> accounts;

  @override
  Widget build(BuildContext context) {
    // Group balances by currency
    final totals = <CurrencyCode, double>{};
    for (final a in accounts) {
      totals[a.currency] =
          (totals[a.currency] ?? 0) + a.balance.toDouble();
    }

    return Container(
      width: double.infinity,
      color: Theme.of(context).colorScheme.primaryContainer,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '帳戶總覽',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
          ),
          const SizedBox(height: 4),
          ...totals.entries.map(
            (e) => Text(
              '${e.key.displayName}：${e.key.symbol}${_formatAmount(e.value, e.key)}',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatAmount(double amount, CurrencyCode currency) {
    if (currency == CurrencyCode.twd) {
      return amount.toStringAsFixed(0).replaceAllMapped(
            RegExp(r'\B(?=(\d{3})+(?!\d))'),
            (m) => ',',
          );
    }
    return amount.toStringAsFixed(2).replaceAllMapped(
          RegExp(r'\B(?=(\d{3})+(?!\d))'),
          (m) => ',',
        );
  }
}

class _CashAccountTile extends StatelessWidget {
  const _CashAccountTile({
    required this.account,
    required this.onTap,
    required this.onDelete,
  });

  final CashAccount account;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(account.id),
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
        leading: const CircleAvatar(child: Icon(Icons.account_balance_wallet)),
        title: Text(account.name),
        subtitle: account.bankName != null ? Text(account.bankName!) : null,
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              CurrencyFormatter.format(account.balance, account.currency),
              style: const TextStyle(
                  fontWeight: FontWeight.bold, fontSize: 16),
            ),
            Text(
              account.currency.displayName,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
