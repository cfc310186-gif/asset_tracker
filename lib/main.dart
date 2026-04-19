import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app.dart';
import 'core/constants/app_constants.dart';
import 'providers/settings_providers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Preload SharedPreferences so the app picks up the saved theme / keys
  // on the very first frame instead of after the user opens Settings.
  final prefs = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [
        sharedPrefsProvider.overrideWith((ref) => prefs),
        themeModeProvider.overrideWith((ref) => loadThemeMode(prefs)),
        displayCurrencyProvider
            .overrideWith((ref) => loadDisplayCurrency(prefs)),
        alphaVantageKeyProvider.overrideWith(
          (ref) => prefs.getString(AppConstants.prefAlphaVantageApiKey) ?? '',
        ),
        corsProxyUrlProvider
            .overrideWith((ref) => loadCorsProxyUrl(prefs)),
      ],
      child: const AssetTrackerApp(),
    ),
  );
}
