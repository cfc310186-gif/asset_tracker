import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/constants/app_constants.dart';
import '../domain/enums/currency_code.dart';

final sharedPrefsProvider = FutureProvider<SharedPreferences>(
  (ref) => SharedPreferences.getInstance(),
);

final displayCurrencyProvider = StateProvider<CurrencyCode>((ref) {
  // Default to TWD; actual loading from SharedPreferences happens in SettingsScreen.
  return CurrencyCode.twd;
});

/// Alpha Vantage API key. Populated by SettingsScreen on load.
/// Empty string means no key — prices stay null for foreign stocks.
final alphaVantageKeyProvider = StateProvider<String>((ref) => '');

/// Theme mode. Defaults to system; persisted in SharedPreferences.
final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.system);

/// Optional CORS proxy URL prepended to all stock-quote HTTP requests.
/// Required on Flutter Web because TWSE / TPEx / Stooq do not send CORS
/// headers. Empty string = direct call (works on native; works on web only
/// when the API origin happens to be permissive).
///
/// Default value: see [defaultCorsProxyUrl] — `https://corsproxy.io/?` on web,
/// empty on native. Users can override in Settings.
final corsProxyUrlProvider =
    StateProvider<String>((ref) => defaultCorsProxyUrl);

/// Public default for the CORS proxy. On Flutter Web the app cannot reach
/// TWSE / TPEx / Stooq without one, so we ship a reasonable free default
/// that the user can replace from the Settings screen.
const String defaultCorsProxyUrl =
    kIsWeb ? 'https://corsproxy.io/?' : '';

Future<void> saveThemeMode(SharedPreferences prefs, ThemeMode mode) async {
  await prefs.setString(AppConstants.prefThemeMode, mode.name);
}

ThemeMode loadThemeMode(SharedPreferences prefs) {
  final raw = prefs.getString(AppConstants.prefThemeMode);
  if (raw == null) return ThemeMode.system;
  return ThemeMode.values.firstWhere(
    (m) => m.name == raw,
    orElse: () => ThemeMode.system,
  );
}

Future<void> saveCorsProxyUrl(SharedPreferences prefs, String url) async {
  await prefs.setString(AppConstants.prefCorsProxy, url);
}

String loadCorsProxyUrl(SharedPreferences prefs) {
  return prefs.getString(AppConstants.prefCorsProxy) ?? defaultCorsProxyUrl;
}

/// Persists the selected [CurrencyCode] to SharedPreferences.
Future<void> saveDisplayCurrency(
  SharedPreferences prefs,
  CurrencyCode code,
) async {
  await prefs.setString(AppConstants.prefDisplayCurrency, code.name);
}

/// Loads the persisted [CurrencyCode] from SharedPreferences.
/// Returns [CurrencyCode.twd] if not set.
CurrencyCode loadDisplayCurrency(SharedPreferences prefs) {
  final raw = prefs.getString(AppConstants.prefDisplayCurrency);
  if (raw == null) return CurrencyCode.twd;
  return CurrencyCode.values.firstWhere(
    (c) => c.name == raw,
    orElse: () => CurrencyCode.twd,
  );
}
