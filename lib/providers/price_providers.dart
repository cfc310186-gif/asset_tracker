import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/api/providers/alpha_vantage_provider.dart';
import '../data/api/providers/emerging_provider.dart';
import '../data/api/providers/exchange_rate_provider.dart';
import '../data/api/providers/noop_foreign_provider.dart';
import '../data/api/providers/taiwan_waterfall_provider.dart';
import '../data/api/providers/tpex_provider.dart';
import '../data/api/providers/twse_provider.dart';

import '../data/repositories/price_repository_impl.dart';
import '../domain/repositories/price_repository.dart';
import '../domain/usecases/refresh_exchange_rates.dart';
import '../domain/usecases/refresh_stock_prices.dart';
import 'database_provider.dart';
import 'repository_providers.dart';
import 'settings_providers.dart';

final dioProvider = Provider<Dio>((ref) => Dio());

final _twseProviderP = Provider(
  (ref) => TwseProvider(ref.watch(dioProvider)),
);

final _tpexProviderP = Provider(
  (ref) => TpexProvider(ref.watch(dioProvider)),
);

final _emergingProviderP = Provider(
  (ref) => EmergingProvider(ref.watch(dioProvider)),
);

/// Taiwan waterfall: TWSE → TPEx → Emerging.
final taiwanProviderP = Provider(
  (ref) => TaiwanWaterfallProvider(
    twse: ref.watch(_twseProviderP),
    tpex: ref.watch(_tpexProviderP),
    emerging: ref.watch(_emergingProviderP),
  ),
);

final exchangeRateProviderP = Provider(
  (ref) => ExchangeRateProvider(ref.watch(dioProvider)),
);

final priceRepositoryProvider = Provider<PriceRepository>((ref) {
  final db = ref.watch(databaseProvider);
  final avKey = ref.watch(alphaVantageKeyProvider);

  // Use Alpha Vantage when a key is configured; otherwise no-op (prices stay null).
  final foreignProvider = avKey.trim().isNotEmpty
      ? AlphaVantageProvider(ref.watch(dioProvider), avKey.trim())
      : const NoOpForeignProvider();

  return PriceRepositoryImpl(
    taiwanProvider: ref.watch(taiwanProviderP),
    foreignProvider: foreignProvider,
    stockDao: db.stockDao,
  );
});

final refreshStockPricesProvider = Provider<RefreshStockPrices>((ref) {
  return RefreshStockPrices(
    stockRepo: ref.watch(stockRepositoryProvider),
    priceRepo: ref.watch(priceRepositoryProvider),
  );
});

final refreshExchangeRatesProvider = Provider<RefreshExchangeRates>(
  (ref) => RefreshExchangeRates(
    exchangeRateProvider: ref.watch(exchangeRateProviderP),
    exchangeRateRepo: ref.watch(exchangeRateRepositoryProvider),
  ),
);
