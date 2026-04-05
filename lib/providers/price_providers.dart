import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/api/providers/emerging_provider.dart';
import '../data/api/providers/exchange_rate_provider.dart';
import '../data/api/providers/tpex_provider.dart';
import '../data/api/providers/twse_provider.dart';
import '../data/api/providers/yahoo_provider.dart';
import '../data/repositories/price_repository_impl.dart';
import '../domain/repositories/price_repository.dart';
import '../domain/usecases/refresh_exchange_rates.dart';
import '../domain/usecases/refresh_stock_prices.dart';
import 'database_provider.dart';
import 'repository_providers.dart';

final dioProvider = Provider<Dio>((ref) => Dio());

final twseProviderP = Provider(
  (ref) => TwseProvider(ref.watch(dioProvider)),
);

final tpexProviderP = Provider(
  (ref) => TpexProvider(ref.watch(dioProvider)),
);

final emergingProviderP = Provider(
  (ref) => EmergingProvider(ref.watch(dioProvider)),
);

final yahooProviderP = Provider(
  (ref) => YahooProvider(ref.watch(dioProvider)),
);

final exchangeRateProviderP = Provider(
  (ref) => ExchangeRateProvider(ref.watch(dioProvider)),
);

final priceRepositoryProvider = Provider<PriceRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return PriceRepositoryImpl(
    providers: [
      ref.watch(twseProviderP),
      ref.watch(tpexProviderP),
      ref.watch(emergingProviderP),
      ref.watch(yahooProviderP),
    ],
    stockDao: db.stockDao,
  );
});

final refreshStockPricesProvider = Provider<RefreshStockPrices>((ref) {
  return RefreshStockPrices(
    stockRepo: ref.watch(stockRepositoryProvider),
    priceRepo: ref.watch(priceRepositoryProvider),
  );
});

// Exchange rate refresh use case — fetches rates and stores in DB
final refreshExchangeRatesProvider = Provider<RefreshExchangeRates>(
  (ref) => RefreshExchangeRates(
    exchangeRateProvider: ref.watch(exchangeRateProviderP),
    exchangeRateRepo: ref.watch(exchangeRateRepositoryProvider),
  ),
);
