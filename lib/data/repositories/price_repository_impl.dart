import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';

import '../../domain/enums/market_code.dart';
import '../../domain/repositories/price_repository.dart';
import '../api/stock_price_provider.dart';
import '../database/app_database.dart';
import '../database/daos/stock_dao.dart';

class PriceRepositoryImpl implements PriceRepository {
  PriceRepositoryImpl({
    required StockPriceProvider taiwanProvider,
    required StockPriceProvider foreignProvider,
    required StockDao stockDao,
  })  : _taiwanProvider = taiwanProvider,
        _foreignProvider = foreignProvider,
        _stockDao = stockDao;

  final StockPriceProvider _taiwanProvider; // TaiwanWaterfallProvider
  final StockPriceProvider _foreignProvider; // AlphaVantageProvider or StooqProvider
  final StockDao _stockDao;

  StockPriceProvider _providerFor(MarketCode market) =>
      market == MarketCode.taiwan ? _taiwanProvider : _foreignProvider;

  @override
  Future<StockQuote?> getQuote(String symbol, MarketCode market) {
    return _providerFor(market).getQuote(symbol, market);
  }

  @override
  Future<List<StockQuote>> refreshAll(
    List<({String symbol, MarketCode market})> holdings,
  ) async {
    if (holdings.isEmpty) return [];

    final byMarket = <MarketCode, List<String>>{};
    for (final h in holdings) {
      byMarket.putIfAbsent(h.market, () => []).add(h.symbol);
    }

    final allQuotes = <StockQuote>[];

    await Future.wait(
      byMarket.entries.map((entry) async {
        final market = entry.key;
        final symbols = entry.value;
        try {
          final quotes = await _providerFor(market).getBatchQuotes(symbols, market);
          allQuotes.addAll(quotes);
        } on Exception catch (e) {
          debugPrint('[PriceRepository] Error fetching $market quotes: $e');
        }
      }),
    );

    return allQuotes;
  }

  @override
  Future<String?> lookupName(String symbol, MarketCode market) async {
    final trimmed = symbol.trim();
    if (trimmed.isEmpty) return null;
    try {
      final quote = await _providerFor(market).getQuote(trimmed, market);
      final raw = quote?.name?.trim();
      return (raw == null || raw.isEmpty) ? null : raw;
    } on Exception catch (e) {
      debugPrint('[PriceRepository] lookupName($trimmed, $market) failed: $e');
      return null;
    }
  }

  @override
  Future<void> cacheQuote(StockQuote quote, MarketCode market) async {
    final entry =
        await _stockDao.findBySymbolAndMarket(quote.symbol, market.name);
    if (entry == null) return;

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
