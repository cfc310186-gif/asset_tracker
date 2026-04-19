import 'package:flutter/foundation.dart';

import '../../../domain/enums/market_code.dart';
import '../stock_price_provider.dart';
import 'emerging_provider.dart';
import 'tpex_provider.dart';
import 'twse_provider.dart';

/// Queries Taiwan stock price by trying TWSE → TPEx → Emerging in order.
/// Returns the first successful result, or null if all sources fail.
class TaiwanWaterfallProvider implements StockPriceProvider {
  TaiwanWaterfallProvider({
    required TwseProvider twse,
    required TpexProvider tpex,
    required EmergingProvider emerging,
  })  : _twse = twse,
        _tpex = tpex,
        _emerging = emerging;

  final TwseProvider _twse;
  final TpexProvider _tpex;
  final EmergingProvider _emerging;

  @override
  bool supportsMarket(MarketCode market) => market == MarketCode.taiwan;

  @override
  Future<StockQuote?> getQuote(String symbol, MarketCode market) async {
    for (final source in [_twse, _tpex, _emerging]) {
      final quote = await source.getQuote(symbol, market);
      if (quote != null) return quote;
    }
    debugPrint('[TaiwanWaterfall] No quote found for $symbol');
    return null;
  }

  @override
  Future<List<StockQuote>> getBatchQuotes(
    List<String> symbols,
    MarketCode market,
  ) async {
    if (symbols.isEmpty) return [];

    // Fetch all symbols concurrently; each symbol waterfalls independently.
    final futures = symbols.map((s) => getQuote(s, market));
    final results = await Future.wait(futures);
    return results.whereType<StockQuote>().toList();
  }
}
