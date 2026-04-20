import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/api/providers/alpha_vantage_provider.dart';
import '../data/api/providers/emerging_provider.dart';
import '../data/api/providers/exchange_rate_provider.dart';
import '../data/api/providers/foreign_waterfall_provider.dart';
import '../data/api/providers/stooq_provider.dart';
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
  (ref) => TwseProvider(
    ref.watch(dioProvider),
    corsProxyUrl: ref.watch(corsProxyUrlProvider).trim(),
  ),
);

final _tpexProviderP = Provider(
  (ref) => TpexProvider(
    ref.watch(dioProvider),
    corsProxyUrl: ref.watch(corsProxyUrlProvider).trim(),
  ),
);

final _emergingProviderP = Provider(
  (ref) => EmergingProvider(
    ref.watch(dioProvider),
    corsProxyUrl: ref.watch(corsProxyUrlProvider).trim(),
  ),
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
  final avKey = ref.watch(alphaVantageKeyProvider).trim();
  final corsProxy = ref.watch(corsProxyUrlProvider).trim();
  final dio = ref.watch(dioProvider);

  // Stooq is free and keyless — always available as the primary foreign source.
  final stooq = StooqProvider(dio, corsProxyUrl: corsProxy);
  final alphaVantage = avKey.isNotEmpty
      ? AlphaVantageProvider(dio, avKey, corsProxyUrl: corsProxy)
      : null;

  final foreignProvider = ForeignWaterfallProvider(
    stooq: stooq,
    alphaVantage: alphaVantage,
  );

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
