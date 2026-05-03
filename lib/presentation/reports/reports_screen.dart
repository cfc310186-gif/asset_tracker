import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/models/time_series_point.dart';
import '../../domain/models/transaction.dart';
import '../../domain/models/net_worth_summary.dart';
import '../../domain/usecases/build_category_comparison.dart';
import '../../providers/repository_providers.dart';
import '../../providers/settings_providers.dart';
import '../../providers/usecase_providers.dart';
import 'widgets/category_comparison_chart.dart';
import 'widgets/net_worth_trend_chart.dart';
import 'widgets/transactions_list.dart';

/// Look-back periods for the trend chart.
enum ReportPeriod { m1, m3, m6, y1, all }

extension on ReportPeriod {
  String get label => switch (this) {
        ReportPeriod.m1 => '1M',
        ReportPeriod.m3 => '3M',
        ReportPeriod.m6 => '6M',
        ReportPeriod.y1 => '1Y',
        ReportPeriod.all => 'ALL',
      };

  Duration? get window => switch (this) {
        ReportPeriod.m1 => const Duration(days: 30),
        ReportPeriod.m3 => const Duration(days: 90),
        ReportPeriod.m6 => const Duration(days: 180),
        ReportPeriod.y1 => const Duration(days: 365),
        ReportPeriod.all => null,
      };
}

final _periodProvider = StateProvider<ReportPeriod>((_) => ReportPeriod.m3);

final _trendProvider = FutureProvider.autoDispose<List<TimeSeriesPoint>>((
  ref,
) async {
  final currency = ref.watch(displayCurrencyProvider);
  final period = ref.watch(_periodProvider);
  ref.watch(portfolioRevisionProvider);
  final from =
      period.window == null ? null : DateTime.now().subtract(period.window!);
  final points = await ref
      .watch(buildNetWorthSeriesProvider)
      .build(displayCurrency: currency, from: from);
  if (points.isNotEmpty) {
    return points;
  }

  final summary = await ref
      .watch(calculateNetWorthProvider)
      .execute(displayCurrency: currency);
  return [
    TimeSeriesPoint(at: summary.calculatedAt, value: summary.netWorth),
  ];
});

final _comparisonProvider =
    FutureProvider.autoDispose<List<CategoryComparisonRow>>((ref) async {
  final currency = ref.watch(displayCurrencyProvider);
  ref.watch(portfolioRevisionProvider);
  final rows = await ref
      .watch(buildCategoryComparisonProvider)
      .buildMonthly(displayCurrency: currency);
  if (rows.isNotEmpty) {
    return rows;
  }

  final summary = await ref
      .watch(calculateNetWorthProvider)
      .execute(displayCurrency: currency);
  return [_comparisonRowFromSummary(summary)];
});

final _transactionsProvider =
    FutureProvider.autoDispose<List<Transaction>>((ref) {
  ref.watch(portfolioRevisionProvider);
  return ref.watch(transactionRepositoryProvider).getAll();
});

CategoryComparisonRow _comparisonRowFromSummary(NetWorthSummary summary) {
  return CategoryComparisonRow(
    period: DateTime(
      summary.calculatedAt.year,
      summary.calculatedAt.month,
      1,
    ),
    values: {
      'stock': summary.totalStockValue,
      'cash': summary.totalCashValue,
      'real_estate': summary.totalRealEstateValue,
      'loan': summary.totalLoanBalance,
    },
  );
}

class ReportsScreen extends ConsumerWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('報表'),
          bottom: TabBar(
            tabs: [
              Tab(
                child: Semantics(
                  identifier: 'tab-trend',
                  child: const Text('淨資產走勢'),
                ),
              ),
              Tab(
                child: Semantics(
                  identifier: 'tab-comparison',
                  child: const Text('類別比較'),
                ),
              ),
              Tab(
                child: Semantics(
                  identifier: 'tab-transactions',
                  child: const Text('交易明細'),
                ),
              ),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _TrendTab(),
            _ComparisonTab(),
            _TransactionsTab(),
          ],
        ),
      ),
    );
  }
}

class _TrendTab extends ConsumerWidget {
  const _TrendTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trendAsync = ref.watch(_trendProvider);
    final period = ref.watch(_periodProvider);
    final currency = ref.watch(displayCurrencyProvider);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SegmentedButton<ReportPeriod>(
            segments: ReportPeriod.values
                .map((p) => ButtonSegment(
                      value: p,
                      label: Semantics(
                        identifier: 'period-${p.label}',
                        child: Text(p.label),
                      ),
                    ))
                .toList(),
            selected: {period},
            onSelectionChanged: (set) =>
                ref.read(_periodProvider.notifier).state = set.first,
          ),
          const SizedBox(height: 16),
          Expanded(
            child: trendAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('載入失敗：$e')),
              data: (points) => Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: NetWorthTrendChart(
                    points: points,
                    currency: currency,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ComparisonTab extends ConsumerWidget {
  const _ComparisonTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final compAsync = ref.watch(_comparisonProvider);
    final currency = ref.watch(displayCurrencyProvider);
    return Padding(
      padding: const EdgeInsets.all(16),
      child: compAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('載入失敗：$e')),
        data: (rows) => Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: SingleChildScrollView(
              child: CategoryComparisonChart(
                rows: rows,
                currency: currency,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TransactionsTab extends ConsumerStatefulWidget {
  const _TransactionsTab();

  @override
  ConsumerState<_TransactionsTab> createState() => _TransactionsTabState();
}

class _TransactionsTabState extends ConsumerState<_TransactionsTab> {
  TransactionAssetType? _filter;

  @override
  Widget build(BuildContext context) {
    final txAsync = ref.watch(_transactionsProvider);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Wrap(
            spacing: 8,
            children: [
              FilterChip(
                label: const Text('全部'),
                selected: _filter == null,
                onSelected: (_) => setState(() => _filter = null),
              ),
              ...TransactionAssetType.values.map(
                (t) => FilterChip(
                  label: Text(t.displayName),
                  selected: _filter == t,
                  onSelected: (selected) =>
                      setState(() => _filter = selected ? t : null),
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: txAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('載入失敗：$e')),
            data: (txs) {
              final filtered = _filter == null
                  ? txs
                  : txs.where((t) => t.assetType == _filter).toList();
              return TransactionsList(transactions: filtered);
            },
          ),
        ),
      ],
    );
  }
}
