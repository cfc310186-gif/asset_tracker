import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/currency_formatter.dart';
import '../../domain/models/net_worth_summary.dart';
import '../../domain/models/time_series_point.dart';
import '../../providers/settings_providers.dart';
import '../../providers/usecase_providers.dart';
import 'widgets/asset_breakdown_chart.dart';
import 'widgets/category_summary_tile.dart';
import 'widgets/net_worth_card.dart';
import 'widgets/net_worth_sparkline.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryAsync = ref.watch(_netWorthProvider);

    return summaryAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => _ErrorView(error: error, stack: stack, ref: ref),
      data: (summary) => _DashboardBody(summary: summary),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.error, required this.stack, required this.ref});
  final Object error;
  final StackTrace stack;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    final stackStr = stack.toString();
    return Center(
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
                stackStr.substring(
                    0, stackStr.length > 800 ? 800 : stackStr.length),
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
    );
  }
}

class _DashboardBody extends ConsumerWidget {
  const _DashboardBody({required this.summary});
  final NetWorthSummary summary;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final width = MediaQuery.of(context).size.width;
    final wide = width >= 1024;

    final netWorthCard = _NetWorthBlock(summary: summary);
    final categories = _CategoryGrid(summary: summary, columns: wide ? 2 : 2);
    final breakdown = AssetBreakdownChart(summary: summary);

    if (wide) {
      return SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 5,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  netWorthCard,
                  const SizedBox(height: 16),
                  breakdown,
                ],
              ),
            ),
            const SizedBox(width: 24),
            Expanded(
              flex: 5,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('資產類別',
                      style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 12),
                  categories,
                ],
              ),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          netWorthCard,
          const SizedBox(height: 16),
          breakdown,
          const SizedBox(height: 16),
          Text('資產類別', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          categories,
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _NetWorthBlock extends ConsumerWidget {
  const _NetWorthBlock({required this.summary});
  final NetWorthSummary summary;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sparkAsync = ref.watch(_sparklineProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        NetWorthCard(summary: summary),
        const SizedBox(height: 8),
        sparkAsync.maybeWhen(
          data: (points) => InkWell(
            onTap: () => context.go('/reports'),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        '近 30 日走勢',
                        style: Theme.of(context).textTheme.labelMedium,
                      ),
                      const Spacer(),
                      Icon(
                        Icons.arrow_forward,
                        size: 14,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  NetWorthSparkline(points: points),
                ],
              ),
            ),
          ),
          orElse: () => const SizedBox.shrink(),
        ),
      ],
    );
  }
}

class _CategoryGrid extends StatelessWidget {
  const _CategoryGrid({required this.summary, required this.columns});
  final NetWorthSummary summary;
  final int columns;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: columns,
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
              summary.totalStockValue, summary.displayCurrency),
          color: const Color(0xFF3B82F6),
          onTap: () => context.go('/stocks'),
        ),
        CategorySummaryTile(
          icon: Icons.home_work,
          title: '不動產',
          amount: CurrencyFormatter.format(
              summary.totalRealEstateValue, summary.displayCurrency),
          color: const Color(0xFF10B981),
          onTap: () => context.go('/real-estate'),
        ),
        CategorySummaryTile(
          icon: Icons.savings,
          title: '現金',
          amount: CurrencyFormatter.format(
              summary.totalCashValue, summary.displayCurrency),
          color: const Color(0xFFF59E0B),
          onTap: () => context.go('/cash'),
        ),
        CategorySummaryTile(
          icon: Icons.account_balance,
          title: '貸款',
          amount: CurrencyFormatter.format(
              summary.totalLoanBalance, summary.displayCurrency),
          color: const Color(0xFFEF4444),
          onTap: () => context.go('/loans'),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Providers
// ---------------------------------------------------------------------------

final _netWorthProvider = FutureProvider<NetWorthSummary>((ref) {
  final currency = ref.watch(displayCurrencyProvider);
  return ref.watch(calculateNetWorthProvider).execute(
        displayCurrency: currency,
      );
});

final _sparklineProvider =
    StreamProvider.autoDispose<List<TimeSeriesPoint>>((ref) {
  final currency = ref.watch(displayCurrencyProvider);
  final from = DateTime.now().subtract(const Duration(days: 30));
  return ref
      .watch(buildNetWorthSeriesProvider)
      .watch(displayCurrency: currency, from: from);
});
