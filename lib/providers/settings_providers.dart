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

/// Circular FIFO pointer for stock price refresh queue.
/// Populated from SharedPreferences by StockListScreen on load.
final refreshQueuePointerProvider = StateProvider<int>((ref) => 0);

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
