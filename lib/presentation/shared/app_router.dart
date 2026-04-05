import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'responsive_scaffold.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    ShellRoute(
      builder: (context, state, child) => ResponsiveScaffold(child: child),
      routes: [
        GoRoute(path: '/', builder: (c, s) => const DashboardPlaceholder()),
        GoRoute(path: '/stocks', builder: (c, s) => const StocksPlaceholder()),
        GoRoute(
          path: '/real-estate',
          builder: (c, s) => const RealEstatePlaceholder(),
        ),
        GoRoute(path: '/loans', builder: (c, s) => const LoansPlaceholder()),
        GoRoute(path: '/cash', builder: (c, s) => const CashPlaceholder()),
      ],
    ),
  ],
);

// Placeholder screens — to be replaced in later tasks

class DashboardPlaceholder extends StatelessWidget {
  const DashboardPlaceholder({super.key});
  @override
  Widget build(BuildContext context) =>
      const Center(child: Text('Dashboard'));
}

class StocksPlaceholder extends StatelessWidget {
  const StocksPlaceholder({super.key});
  @override
  Widget build(BuildContext context) => const Center(child: Text('Stocks'));
}

class RealEstatePlaceholder extends StatelessWidget {
  const RealEstatePlaceholder({super.key});
  @override
  Widget build(BuildContext context) =>
      const Center(child: Text('Real Estate'));
}

class LoansPlaceholder extends StatelessWidget {
  const LoansPlaceholder({super.key});
  @override
  Widget build(BuildContext context) => const Center(child: Text('Loans'));
}

class CashPlaceholder extends StatelessWidget {
  const CashPlaceholder({super.key});
  @override
  Widget build(BuildContext context) => const Center(child: Text('Cash'));
}
