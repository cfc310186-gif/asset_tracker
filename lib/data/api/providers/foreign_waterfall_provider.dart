import 'package:flutter/foundation.dart';

import '../../../domain/enums/market_code.dart';
import '../stock_price_provider.dart';

/// Queries US/UK stock prices by trying Stooq (free) first, then optionally
/// Alpha Vantage (if a key-backed provider is supplied). Returns null if all
/// sources fail — callers must keep any previously cached price untouched.
class ForeignWaterfallProvider implements StockPriceProvider {
  ForeignWaterfallProvider({
    required StockPriceProvider stooq,
    StockPriceProvider? alphaVantage,
  })  : _stooq = stooq,
        _alphaVantage = alphaVantage;

  final StockPriceProvider _stooq;
  final StockPriceProvider? _alphaVantage;

  @override
  bool supportsMarket(MarketCode market) =>
      market == MarketCode.us || market == MarketCode.uk;

  @override
  Future<StockQuote?> getQuote(String symbol, MarketCode market) async {
    final stooqQuote = await _stooq.getQuote(symbol, market);
    if (stooqQuote != null) return stooqQuote;

    if (_alphaVantage != null) {
      final avQuote = await _alphaVantage.getQuote(symbol, market);
      if (avQuote != null) return avQuote;
    }

    debugPrint('[ForeignWaterfall] No quote for $symbol ($market)');
    return null;
  }

  @override
  Future<List<StockQuote>> getBatchQuotes(
    List<String> symbols,
    MarketCode market,
  ) async {
    if (symbols.isEmpty) return [];
    final futures = symbols.map((s) => getQuote(s, market));
    final results = await Future.wait(futures);
    return results.whereType<StockQuote>().toList();
  }
}
