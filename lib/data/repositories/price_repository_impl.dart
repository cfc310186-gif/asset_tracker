import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';

import '../../domain/enums/market_code.dart';
import '../../domain/repositories/price_repository.dart';
import '../api/stock_price_provider.dart';
import '../database/app_database.dart';
import '../database/daos/stock_dao.dart';

class PriceRepositoryImpl implements PriceRepository {
  PriceRepositoryImpl({
    required List<StockPriceProvider> providers,
    required StockDao stockDao,
  })  : _providers = providers,
        _stockDao = stockDao;

  final List<StockPriceProvider> _providers;
  final StockDao _stockDao;

  StockPriceProvider? _providerFor(MarketCode market) {
    for (final p in _providers) {
      if (p.supportsMarket(market)) return p;
    }
    return null;
  }

  @override
  Future<StockQuote?> getQuote(String symbol, MarketCode market) async {
    final provider = _providerFor(market);
    if (provider == null) {
      debugPrint('[PriceRepository] No provider for market: $market');
      return null;
    }
    return provider.getQuote(symbol, market);
  }

  @override
  Future<List<StockQuote>> refreshAll(
    List<({String symbol, MarketCode market})> holdings,
  ) async {
    if (holdings.isEmpty) return [];

    // Group holdings by market for batch fetching.
    final byMarket = <MarketCode, List<String>>{};
    for (final h in holdings) {
      byMarket.putIfAbsent(h.market, () => []).add(h.symbol);
    }

    final allQuotes = <StockQuote>[];

    await Future.wait(
      byMarket.entries.map((entry) async {
        final market = entry.key;
        final symbols = entry.value;
        final provider = _providerFor(market);
        if (provider == null) {
          debugPrint('[PriceRepository] No provider for market: $market');
          return;
        }
        try {
          final quotes = await provider.getBatchQuotes(symbols, market);
          allQuotes.addAll(quotes);
        } on Exception catch (e) {
          debugPrint(
            '[PriceRepository] Error fetching $market quotes: $e',
          );
        }
      }),
    );

    return allQuotes;
  }

  @override
  Future<void> cacheQuote(StockQuote quote, MarketCode market) async {
    final entry =
        await _stockDao.findBySymbolAndMarket(quote.symbol, market.name);
    if (entry == null) return; // symbol not in portfolio, nothing to cache

    await _stockDao.updateOne(StocksCompanion(
      id: Value(entry.id),
      symbol: Value(entry.symbol),
      market: Value(entry.market),
      name: Value(entry.name),
      quantity: Value(entry.quantity),
      avgCost: Value(entry.avgCost),
      currency: Value(entry.currency),
      isMargin: Value(entry.isMargin),
      marginAmount: Value(entry.marginAmount),
      linkedLoanId: Value(entry.linkedLoanId),
      latestPrice: Value(quote.price.toString()),
      priceUpdatedAt: Value(quote.fetchedAt),
      createdAt: Value(entry.createdAt),
      updatedAt: Value(entry.updatedAt),
    ));
  }
}
