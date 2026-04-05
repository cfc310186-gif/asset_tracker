import 'package:decimal/decimal.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../../domain/enums/market_code.dart';
import '../stock_price_provider.dart';

class YahooProvider implements StockPriceProvider {
  YahooProvider(this._dio);

  final Dio _dio;

  static const _baseUrl = 'https://query1.finance.yahoo.com/v8/finance/chart';

  @override
  bool supportsMarket(MarketCode market) =>
      market == MarketCode.nyse ||
      market == MarketCode.nasdaq ||
      market == MarketCode.lse;

  @override
  Future<StockQuote?> getQuote(String symbol, MarketCode market) async {
    final formattedSymbol = _formatSymbol(symbol, market);
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '$_baseUrl/$formattedSymbol',
        queryParameters: {'interval': '1d', 'range': '1d'},
      );

      final data = response.data;
      if (data == null) return null;

      final chart = data['chart'] as Map<String, dynamic>?;
      if (chart == null) return null;

      final results = chart['result'] as List<dynamic>?;
      if (results == null || results.isEmpty) return null;

      final meta = (results.first as Map<String, dynamic>)['meta']
          as Map<String, dynamic>?;
      if (meta == null) return null;

      final rawPrice = meta['regularMarketPrice'];
      if (rawPrice == null) return null;

      final price = Decimal.tryParse(rawPrice.toString());
      if (price == null) return null;

      return StockQuote(symbol: symbol, price: price, fetchedAt: DateTime.now());
    } on DioException catch (e) {
      // Yahoo Finance blocks CORS from browsers; return null gracefully.
      debugPrint('[YahooProvider] DioException for $formattedSymbol: $e');
      return null;
    } on Exception catch (e) {
      debugPrint('[YahooProvider] Exception for $formattedSymbol: $e');
      return null;
    }
  }

  @override
  Future<List<StockQuote>> getBatchQuotes(
    List<String> symbols,
    MarketCode market,
  ) async {
    // Yahoo Finance v8 does not support batch in a single call without
    // the premium API. Fetch individually and collect results.
    final futures = symbols.map((s) => getQuote(s, market));
    final results = await Future.wait(futures);
    return results.whereType<StockQuote>().toList();
  }

  String _formatSymbol(String symbol, MarketCode market) {
    if (market == MarketCode.lse && !symbol.endsWith('.L')) {
      return '$symbol.L';
    }
    return symbol;
  }
}
