import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/currency_formatter.dart';
import '../../domain/models/net_worth_summary.dart';
import '../../providers/settings_providers.dart';
import '../../providers/usecase_providers.dart';
import 'widgets/asset_breakdown_chart.dart';
import 'widgets/category_summary_tile.dart';
import 'widgets/net_worth_card.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryAsync = ref.watch(_netWorthProvider);

    return summaryAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 48,
                  color: AppTheme.lossColor,
                ),
                const SizedBox(height: 16),
                Text(
                  '載入資料時發生錯誤',
                  style: Theme.of(context).textTheme.titleLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                SelectableText(
                  'ERROR: ${error.runtimeType}\n${error.toString()}',
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(fontFamily: 'monospace'),
                  textAlign: TextAlign.left,
                ),
                const SizedBox(height: 8),
                SelectableText(
                  stack.toString().substring(
                        0,
                        stack.toString().length > 800
                            ? 800
                            : stack.toString().length,
                      ),
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(fontSize: 10, fontFamily: 'monospace'),
                  textAlign: TextAlign.left,
                ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: () => ref.invalidate(_netWorthProvider),
                icon: const Icon(Icons.refresh),
                label: const Text('重試'),
              ),
            ],
          ),
        ),
      ),
      ),
      data: (summary) => _DashboardBody(summary: summary),
    );
  }
}

class _DashboardBody extends StatelessWidget {
  const _DashboardBody({required this.summary});
  final NetWorthSummary summary;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          NetWorthCard(summary: summary),
          const SizedBox(height: 16),
          AssetBreakdownChart(summary: summary),
          const SizedBox(height: 16),
          Text('資產類別', style: theme.textTheme.titleLarge),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.4,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              CategorySummaryTile(
                icon: Icons.show_chart,
                title: '股票',
                amount: CurrencyFormatter.format(
                  summary.totalStockValue,
                  summary.displayCurrency,
                ),
                color: const Color(0xFF3B82F6),
                onTap: () => context.go('/stocks'),
              ),
              CategorySummaryTile(
                icon: Icons.home_work,
                title: '不動產',
                amount: CurrencyFormatter.format(
                  summary.totalRealEstateValue,
                  summary.displayCurrency,
                ),
                color: const Color(0xFF10B981),
                onTap: () => context.go('/real-estate'),
              ),
              CategorySummaryTile(
                icon: Icons.savings,
                title: '現金',
                amount: CurrencyFormatter.format(
                  summary.totalCashValue,
                  summary.displayCurrency,
                ),
                color: const Color(0xFFF59E0B),
                onTap: () => context.go('/cash'),
              ),
              CategorySummaryTile(
                icon: Icons.account_balance,
                title: '貸款',
                amount: CurrencyFormatter.format(
                  summary.totalLoanBalance,
                  summary.displayCurrency,
                ),
                color: const Color(0xFFEF4444),
                onTap: () => context.go('/loans'),
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// FutureProvider backed by CalculateNetWorth use case
// ---------------------------------------------------------------------------

final _netWorthProvider = FutureProvider<NetWorthSummary>((ref) {
  final currency = ref.watch(displayCurrencyProvider);
  return ref.watch(calculateNetWorthProvider).execute(
        displayCurrency: currency,
      );
});
