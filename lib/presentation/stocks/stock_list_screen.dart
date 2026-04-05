import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/currency_formatter.dart';
import '../../domain/enums/market_code.dart';
import '../../domain/models/stock_holding.dart';
import '../../providers/repository_providers.dart';

class StockListScreen extends ConsumerWidget {
  const StockListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.watch(stockRepositoryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('股票'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: '重新整理',
            onPressed: () {
              // Price refresh wired in Phase 3
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('股價更新將於 Phase 3 實作')),
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/stocks/add'),
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder<List<StockHolding>>(
        stream: repo.watchAll(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('錯誤：${snapshot.error}'));
          }

          final holdings = snapshot.data ?? [];

          if (holdings.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.show_chart,
                    size: 64,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    '尚未新增股票',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => context.push('/stocks/add'),
                    icon: const Icon(Icons.add),
                    label: const Text('新增股票'),
                  ),
                ],
              ),
            );
          }

          // Group by market
          final grouped = <MarketCode, List<StockHolding>>{};
          for (final h in holdings) {
            grouped.putIfAbsent(h.market, () => []).add(h);
          }

          return ListView(
            padding: const EdgeInsets.symmetric(vertical: 8),
            children: [
              for (final market in MarketCode.values)
                if (grouped.containsKey(market)) ...[
                  _MarketGroupHeader(market: market),
                  ...grouped[market]!.map(
                    (h) => _StockTile(
                      holding: h,
                      onTap: () => context.push('/stocks/edit', extra: h),
                      onDelete: () => _confirmDelete(context, ref, h),
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
    StockHolding holding,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('刪除股票'),
        content: Text('確定要刪除「${holding.name}（${holding.symbol}）」嗎？'),
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
        await ref.read(stockRepositoryProvider).delete(holding.id);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('股票已刪除')),
          );
        }
      } on Exception catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('刪除失敗：$e')),
          );
        }
      }
    }
  }
}

class _MarketGroupHeader extends StatelessWidget {
  const _MarketGroupHeader({required this.market});

  final MarketCode market;

  @override
  Widget build(BuildContext context) {
    final color = _colorForMarket(market);
    return Container(
      color: color.withValues(alpha: 0.1),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Text(
        market.displayName,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: color,
          fontSize: 14,
        ),
      ),
    );
  }

  Color _colorForMarket(MarketCode m) => switch (m) {
        MarketCode.twse => Colors.blue,
        MarketCode.tpex => Colors.teal,
        MarketCode.emerging => Colors.cyan,
        MarketCode.nyse => Colors.purple,
        MarketCode.nasdaq => Colors.indigo,
        MarketCode.lse => Colors.deepOrange,
      };
}

class _StockTile extends StatelessWidget {
  const _StockTile({
    required this.holding,
    required this.onTap,
    required this.onDelete,
  });

  final StockHolding holding;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final unrealizedGain = holding.unrealizedGain;
    final hasPrice = holding.latestPrice != null;
    final gainColor = unrealizedGain.sign >= 0
        ? AppTheme.gainColor
        : AppTheme.lossColor;

    return Dismissible(
      key: Key(holding.id),
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
          backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.15),
          child: Text(
            holding.symbol.length > 4
                ? holding.symbol.substring(0, 4)
                : holding.symbol,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryColor,
            ),
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                '${holding.symbol}  ${holding.name}',
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (holding.isMargin)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 6,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  '融資',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.orange,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
        subtitle: Row(
          children: [
            Text(
              '${holding.quantity} 股  '
              '均價 ${CurrencyFormatter.format(holding.avgCost, holding.currency)}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            if (!hasPrice) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 4,
                  vertical: 1,
                ),
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  '需更新',
                  style: TextStyle(fontSize: 10, color: Colors.grey),
                ),
              ),
            ],
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              hasPrice
                  ? CurrencyFormatter.format(
                      holding.latestPrice!,
                      holding.currency,
                    )
                  : '—',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
            if (hasPrice)
              Text(
                CurrencyFormatter.formatWithSign(
                  unrealizedGain,
                  holding.currency,
                ),
                style: TextStyle(
                  fontSize: 12,
                  color: gainColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
