import 'package:go_router/go_router.dart';

import '../cash/add_edit_cash_screen.dart';
import '../cash/cash_list_screen.dart';
import '../dashboard/dashboard_screen.dart';
import '../loans/add_edit_loan_screen.dart';
import '../loans/loan_list_screen.dart';
import '../real_estate/add_edit_real_estate_screen.dart';
import '../real_estate/real_estate_list_screen.dart';
import '../reports/reports_screen.dart';
import '../settings/settings_screen.dart';
import '../stocks/add_edit_stock_screen.dart';
import '../stocks/stock_list_screen.dart';
import '../../domain/models/cash_account.dart';
import '../../domain/models/loan.dart';
import '../../domain/models/real_estate_asset.dart';
import '../../domain/models/stock_holding.dart';
import 'responsive_scaffold.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    ShellRoute(
      builder: (context, state, child) => ResponsiveScaffold(child: child),
      routes: [
        GoRoute(path: '/', builder: (c, s) => const DashboardScreen()),
        GoRoute(
          path: '/stocks',
          builder: (c, s) => const StockListScreen(),
          routes: [
            GoRoute(
              path: 'add',
              builder: (c, s) => const AddEditStockScreen(),
            ),
            GoRoute(
              path: 'edit',
              builder: (c, s) {
                final holding = s.extra as StockHolding?;
                return AddEditStockScreen(holding: holding);
              },
            ),
          ],
        ),
        GoRoute(
          path: '/real-estate',
          builder: (c, s) => const RealEstateListScreen(),
          routes: [
            GoRoute(
              path: 'add',
              builder: (c, s) => const AddEditRealEstateScreen(),
            ),
            GoRoute(
              path: 'edit',
              builder: (c, s) {
                final asset = s.extra as RealEstateAsset?;
                return AddEditRealEstateScreen(asset: asset);
              },
            ),
          ],
        ),
        GoRoute(
          path: '/loans',
          builder: (c, s) => const LoanListScreen(),
          routes: [
            GoRoute(
              path: 'add',
              builder: (c, s) => const AddEditLoanScreen(),
            ),
            GoRoute(
              path: 'edit',
              builder: (c, s) {
                final loan = s.extra as Loan?;
                return AddEditLoanScreen(loan: loan);
              },
            ),
          ],
        ),
        GoRoute(
          path: '/cash',
          builder: (c, s) => const CashListScreen(),
          routes: [
            GoRoute(
              path: 'add',
              builder: (c, s) => const AddEditCashScreen(),
            ),
            GoRoute(
              path: 'edit',
              builder: (c, s) {
                final account = s.extra as CashAccount?;
                return AddEditCashScreen(account: account);
              },
            ),
          ],
        ),
        GoRoute(
          path: '/reports',
          builder: (c, s) => const ReportsScreen(),
        ),
        GoRoute(
          path: '/settings',
          builder: (c, s) => const SettingsScreen(),
        ),
      ],
    ),
  ],
);

