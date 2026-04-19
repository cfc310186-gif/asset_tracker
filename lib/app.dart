import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'presentation/shared/app_router.dart';
import 'providers/settings_providers.dart';
import 'providers/usecase_providers.dart';

class AssetTrackerApp extends ConsumerStatefulWidget {
  const AssetTrackerApp({super.key});

  @override
  ConsumerState<AssetTrackerApp> createState() => _AssetTrackerAppState();
}

class _AssetTrackerAppState extends ConsumerState<AssetTrackerApp> {
  @override
  void initState() {
    super.initState();
    // Capture today's net worth snapshot on app start. Upsert keyed by date
    // so re-launches the same day are no-ops.
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        final displayCurrency = ref.read(displayCurrencyProvider);
        await ref
            .read(captureNetWorthSnapshotProvider)
            .execute(displayCurrency: displayCurrency);
      } on Exception catch (e) {
        debugPrint('[AssetTrackerApp] Snapshot capture failed: $e');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeModeProvider);
    return MaterialApp.router(
      title: '資產管理',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      routerConfig: appRouter,
      debugShowCheckedModeBanner: false,
    );
  }
}
