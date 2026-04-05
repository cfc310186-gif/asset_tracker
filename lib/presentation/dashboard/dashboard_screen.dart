import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/currency_formatter.dart';
import '../../domain/enums/currency_code.dart';
import '../../domain/models/net_worth_summary.dart';
import '../../providers/repository_providers.dart';
import 'widgets/asset_breakdown_chart.dart';
import 'widgets/category_summary_tile.dart';
import 'widgets/net_worth_card.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stocksAsync = ref.watch(
      _stocksProvider,
    );
    final realEstateAsync = ref.watch(
      _realEstateProvider,
    );
    final loansAsync = ref.watch(
      _loansProvider,
    );
    final cashAsync = ref.watch(
      _cashProvider,
    );

    // Show loading while any source is loading
    if (stocksAsync.isLoading ||
        realEstateAsync.isLoading ||
        loansAsync.isLoading ||
        cashAsync.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // Show error if any source failed
    final stocksError = stocksAsync.error;
    final realEstateError = realEstateAsync.error;
    final loansError = loansAsync.error;
    final cashError = cashAsync.error;

    if (stocksError != null ||
        realEstateError != null ||
        loansError != null ||
        cashError != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: AppTheme.lossColor),
            const SizedBox(height: 16),
            Text(
              '載入資料時發生錯誤',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () {
                ref.invalidate(_stocksProvider);
                ref.invalidate(_realEstateProvider);
                ref.invalidate(_loansProvider);
                ref.invalidate(_cashProvider);
              },
              child: const Text('重試'),
            ),
          ],
        ),
      );
    }

    final stocks = stocksAsync.value ?? [];
    final realEstateList = realEstateAsync.value ?? [];
    final loans = loansAsync.value ?? [];
    final cashAccounts = cashAsync.value ?? [];

    // Compute net worth inline (no currency conversion in Phase 2)
    final totalStockValue = stocks.fold(
      Decimal.zero,
      (sum, s) => sum + s.totalValue,
    );
    final totalRealEstateValue = realEstateList.fold(
      Decimal.zero,
      (sum, r) => sum + r.estimatedValue,
    );
    final totalCashValue = cashAccounts.fold(
      Decimal.zero,
      (sum, c) => sum + c.balance,
    );
    final totalLoanBalance = loans.fold(
      Decimal.zero,
      (sum, l) => sum + l.remainingBalance,
    );

    final summary = NetWorthSummary(
      totalStockValue: totalStockValue,
      totalRealEstateValue: totalRealEstateValue,
      totalCashValue: totalCashValue,
      totalLoanBalance: totalLoanBalance,
      displayCurrency: CurrencyCode.twd,
      calculatedAt: DateTime.now(),
    );

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
                  totalStockValue,
                  CurrencyCode.twd,
                ),
                color: const Color(0xFF3B82F6),
                onTap: () => context.go('/stocks'),
              ),
              CategorySummaryTile(
                icon: Icons.home_work,
                title: '不動產',
                amount: CurrencyFormatter.format(
                  totalRealEstateValue,
                  CurrencyCode.twd,
                ),
                color: const Color(0xFF10B981),
                onTap: () => context.go('/real-estate'),
              ),
              CategorySummaryTile(
                icon: Icons.savings,
                title: '現金',
                amount: CurrencyFormatter.format(
                  totalCashValue,
                  CurrencyCode.twd,
                ),
                color: const Color(0xFFF59E0B),
                onTap: () => context.go('/cash'),
              ),
              CategorySummaryTile(
                icon: Icons.account_balance,
                title: '貸款',
                amount: CurrencyFormatter.format(
                  totalLoanBalance,
                  CurrencyCode.twd,
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
// Stream-based providers that watch live data from repositories
// ---------------------------------------------------------------------------

final _stocksProvider = StreamProvider((ref) {
  return ref.watch(stockRepositoryProvider).watchAll();
});

final _realEstateProvider = StreamProvider((ref) {
  return ref.watch(realEstateRepositoryProvider).watchAll();
});

final _loansProvider = StreamProvider((ref) {
  return ref.watch(loanRepositoryProvider).watchAll();
});

final _cashProvider = StreamProvider((ref) {
  return ref.watch(cashRepositoryProvider).watchAll();
});
