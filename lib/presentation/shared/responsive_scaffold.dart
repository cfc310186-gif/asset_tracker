import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';


class ResponsiveScaffold extends StatelessWidget {
  final Widget child;
  const ResponsiveScaffold({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width >= 768) {
      return _DesktopScaffold(child: child);
    }
    return _MobileScaffold(child: child);
  }
}

// Navigation destination data
const _navDestinations = [
  _NavDest(icon: Icons.dashboard, label: '總覽', route: '/'),
  _NavDest(icon: Icons.show_chart, label: '股票', route: '/stocks'),
  _NavDest(icon: Icons.home_work, label: '不動產', route: '/real-estate'),
  _NavDest(icon: Icons.account_balance, label: '貸款', route: '/loans'),
  _NavDest(icon: Icons.savings, label: '現金', route: '/cash'),
  _NavDest(icon: Icons.bar_chart, label: '報表', route: '/reports'),
];

class _NavDest {
  final IconData icon;
  final String label;
  final String route;
  const _NavDest({required this.icon, required this.label, required this.route});
}

int _selectedIndex(BuildContext context) {
  final location = GoRouterState.of(context).uri.path;
  final idx = _navDestinations.indexWhere((d) => d.route == location);
  return idx < 0 ? 0 : idx;
}

class _DesktopScaffold extends StatelessWidget {
  final Widget child;
  const _DesktopScaffold({required this.child});

  @override
  Widget build(BuildContext context) {
    final selectedIdx = _selectedIndex(context);
    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: selectedIdx,
            extended: true,
            minExtendedWidth: 200,
            leading: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Column(
                children: [
                  Text(
                    '資產管理',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Semantics(
                    identifier: 'nav-/settings',
                    button: true,
                    child: IconButton(
                      icon: const Icon(Icons.settings_outlined),
                      tooltip: '設定',
                      onPressed: () => context.go('/settings'),
                    ),
                  ),
                ],
              ),
            ),
            destinations: _navDestinations
                .map(
                  (d) => NavigationRailDestination(
                    icon: Icon(d.icon),
                    label: Semantics(
                      identifier: 'nav-${d.route}',
                      child: Text(d.label),
                    ),
                  ),
                )
                .toList(),
            onDestinationSelected: (idx) {
              context.go(_navDestinations[idx].route);
            },
          ),
          const VerticalDivider(thickness: 1, width: 1),
          Expanded(child: child),
        ],
      ),
    );
  }
}

class _MobileScaffold extends StatelessWidget {
  final Widget child;
  const _MobileScaffold({required this.child});

  @override
  Widget build(BuildContext context) {
    final selectedIdx = _selectedIndex(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('資產管理'),
        actions: [
          Semantics(
            identifier: 'nav-/settings',
            button: true,
            child: IconButton(
              icon: const Icon(Icons.settings_outlined),
              tooltip: '設定',
              onPressed: () => context.go('/settings'),
            ),
          ),
        ],
      ),
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedIdx,
        type: BottomNavigationBarType.fixed,
        items: _navDestinations
            .map(
              (d) => BottomNavigationBarItem(
                icon: Semantics(
                  identifier: 'nav-${d.route}',
                  child: Icon(d.icon),
                ),
                label: d.label,
              ),
            )
            .toList(),
        onTap: (idx) {
          context.go(_navDestinations[idx].route);
        },
      ),
    );
  }
}
