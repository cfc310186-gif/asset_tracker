import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/currency_formatter.dart';
import '../../domain/enums/market_code.dart';
import '../../domain/models/stock_holding.dart';
import '../../providers/price_providers.dart';
import '../../providers/repository_providers.dart';
import '../../providers/settings_providers.dart';
import '../../providers/usecase_providers.dart';

class StockListScreen extends ConsumerStatefulWidget {
  const StockListScreen({super.key});

  @override
  ConsumerState<StockListScreen> createState() => _StockListScreenState();
}

class _StockListScreenState extends ConsumerState<StockListScreen> {
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    _loadQueuePointer();
  }

  Future<void> _loadQueuePointer() async {
    final prefsAsync = ref.read(sharedPrefsProvider);
    prefsAsync.whenData((prefs) {
      final saved = prefs.getInt(AppConstants.prefRefreshQueuePointer) ?? 0;
      ref.read(refreshQueuePointerProvider.notifier).state = saved;
    });
  }

  Future<void> _saveQueuePointer(int pointer) async {
    ref.read(refreshQueuePointerProvider.notifier).state = pointer;
    final prefsAsync = ref.read(sharedPrefsProvider);
    prefsAsync.whenData(
      (prefs) => prefs.setInt(AppConstants.prefRefreshQueuePointer, pointer),
    );
  }

  Future<void> _refreshPrices() async {
    if (_isRefreshing) return;
    setState(() => _isRefreshing = true);
    try {
      final pointer = ref.read(refreshQueuePointerProvider);
      final result = await ref
          .read(refreshStockPricesProvider)
          .execute(pointer: pointer);

      await _saveQueuePointer(result.nextPointer);

      if (mounted) {
        final symbol = result.updatedSymbol ?? '—';
        final pos = result.nextPointer == 0
            ? result.queueSize
            : result.nextPointer; // current (1-based)
        final msg = result.updated > 0
            ? '$symbol 已更新（$pos/${result.queueSize}）→ 下次：${_nextSymbolLabel(result.nextPointer)}'
            : '$symbol 更新失敗（$pos/${result.queueSize}）';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(msg)),
        );
      }
    } on Exception catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('更新失敗：$e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isRefreshing = false);
    }
  }

  /// Returns the symbol at [nextPointer] from the current holdings stream,
  /// or '?' if unavailable.
  String _nextSymbolLabel(int nextPointer) {
    // We can't easily access stream data synchronously here;
    // the pointer indicator in the subtitle handles the display.
    return '#${nextPointer + 1}';
  }

  @override
  Widget build(BuildContext context) {
    final repo = ref.watch(stockRepositoryProvider);
    final avKey = ref.watch(alphaVantageKeyProvider);
    final queuePointer = ref.watch(refreshQueuePointerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('股票'),
        actions: [
          if (_isRefreshing)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else
            Semantics(
              identifier: 'btn-refresh-prices',
              button: true,
              child: IconButton(
                icon: const Icon(Icons.refresh),
                tooltip: '更新股價',
                onPressed: _refreshPrices,
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/stocks/add'),
        tooltip: '新增股票',
        child: Semantics(
          identifier: 'fab-add-stock',
          child: const Icon(Icons.add),
        ),
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
          final hasForeignHoldings = holdings.any(
            (h) => h.market == MarketCode.us || h.market == MarketCode.uk,
          );
          final showNoKeyBanner = avKey.trim().isEmpty && hasForeignHoldings;

          if (holdings.isEmpty) {
            return Semantics(
              identifier: 'stocks-empty-state',
              label: '尚未新增股票',
              container: true,
              child: Center(
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
              ),
            );
          }

          // Stable queue order: sorted by createdAt.
          final sorted = [...holdings]
            ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
          final queueSize = sorted.length;
          final nextIdx = queuePointer % queueSize;
          final nextSymbol = sorted[nextIdx].symbol;

          // Group by market for display.
          final grouped = <MarketCode, List<StockHolding>>{};
          for (final h in holdings) {
            grouped.putIfAbsent(h.market, () => []).add(h);
          }

          return ListView(
            padding: const EdgeInsets.symmetric(vertical: 8),
            children: [
              if (showNoKeyBanner)
                _NoApiKeyBanner(onTapSettings: () => context.push('/settings')),
              _QueueIndicator(nextSymbol: nextSymbol, pointer: nextIdx, total: queueSize),
              for (final market in MarketCode.values)
                if (grouped.containsKey(market)) ...[
                  _MarketGroupHeader(market: market),
                  ...grouped[market]!.map(
                    (h) => _StockTile(
                      holding: h,
                      isNextInQueue: h.symbol == nextSymbol,
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
        await ref
            .read(syncLinkedLoansProvider)
            .onStockDeleted(holding);
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

class _QueueIndicator extends StatelessWidget {
  const _QueueIndicator({
    required this.nextSymbol,
    required this.pointer,
    required this.total,
  });

  final String nextSymbol;
  final int pointer;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 4),
      child: Row(
        children: [
          Icon(Icons.queue, size: 14, color: Colors.grey.shade500),
          const SizedBox(width: 4),
          Text(
            '下次更新：$nextSymbol（${pointer + 1}/$total）',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }
}

class _NoApiKeyBanner extends StatelessWidget {
  const _NoApiKeyBanner({required this.onTapSettings});
  final VoidCallback onTapSettings;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      identifier: 'banner-no-api-key',
      label: '免費來源已啟用',
      container: true,
      child: Container(
        margin: const EdgeInsets.fromLTRB(12, 8, 12, 0),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.amber.shade50,
          border: Border.all(color: Colors.amber.shade400),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(Icons.warning_amber_rounded,
                color: Colors.amber.shade700, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '免費來源 (Stooq) 已啟用；若遇網路限制或需更準確資料，可在設定補上 Alpha Vantage API Key。',
                style: TextStyle(fontSize: 13, color: Colors.amber.shade900),
              ),
            ),
            TextButton(
              onPressed: onTapSettings,
              child: const Text('前往設定'),
            ),
          ],
        ),
      ),
    );
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
        MarketCode.taiwan => Colors.blue,
        MarketCode.us => Colors.purple,
        MarketCode.uk => Colors.deepOrange,
      };
}

class _StockTile extends StatelessWidget {
  const _StockTile({
    required this.holding,
    required this.onTap,
    required this.onDelete,
    this.isNextInQueue = false,
  });

  final StockHolding holding;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final bool isNextInQueue;

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
            if (isNextInQueue) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  '▶ 下次',
                  style: TextStyle(fontSize: 10, color: Colors.green),
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
