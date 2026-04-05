import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/currency_formatter.dart';
import '../../domain/enums/currency_code.dart';
import '../../domain/models/net_worth_summary.dart';
import '../../providers/usecase_providers.dart';
import 'widgets/asset_breakdown_chart.dart';
import 'widgets/category_summary_tile.dart';
import 'widgets/net_worth_card.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryAsync = ref.watch(_netWorthProvider);

    if (summaryAsync.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (summaryAsync.hasError) {
      return Center(
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
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => ref.invalidate(_netWorthProvider),
              child: const Text('重試'),
            ),
          ],
        ),
      );
    }

    final summary = summaryAsync.value!;
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
  return ref.watch(calculateNetWorthProvider).execute(
        displayCurrency: CurrencyCode.twd,
      );
});
