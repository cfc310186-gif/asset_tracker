import 'dart:convert';

import 'package:decimal/decimal.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../../domain/enums/market_code.dart';
import '../stock_price_provider.dart';

/// Fetches US and UK stock prices via Alpha Vantage GLOBAL_QUOTE endpoint.
///
/// Requires a free API key from https://www.alphavantage.co/support/#api-key
/// Free tier: 25 requests/day.
///
/// Symbol suffixes:
///   US stocks: pass symbol as-is (e.g. AAPL)
///   UK stocks: append .LON  (e.g. VWRA → VWRA.LON)
class AlphaVantageProvider implements StockPriceProvider {
  AlphaVantageProvider(this._dio, this._apiKey, {this.corsProxyUrl = ''});

  final Dio _dio;
  final String _apiKey;

  /// Optional CORS proxy URL prefix. AlphaVantage does send CORS headers,
  /// but we accept the parameter for symmetry with sibling providers.
  final String corsProxyUrl;

  static const _baseUrl = 'https://www.alphavantage.co/query';

  @override
  bool supportsMarket(MarketCode market) =>
      market == MarketCode.us || market == MarketCode.uk;

  @override
  Future<StockQuote?> getQuote(String symbol, MarketCode market) async {
    final avSymbol = _formatSymbol(symbol, market);
    try {
      final qs =
          'function=GLOBAL_QUOTE&symbol=${Uri.encodeQueryComponent(avSymbol)}&apikey=${Uri.encodeQueryComponent(_apiKey)}';
      final target = '$_baseUrl?$qs';
      final url = corsProxyUrl.isEmpty ? target : '$corsProxyUrl$target';
      final response = await _dio.get<dynamic>(url);
      final raw = response.data;
      final Map<String, dynamic>? data = raw is Map<String, dynamic>
          ? raw
          : raw is String
              ? _safeJsonDecode(raw)
              : null;
      if (data == null) return null;

      // Rate-limit notice: {"Note": "Thank you for using Alpha Vantage!..."}
      if (data.containsKey('Note') || data.containsKey('Information')) {
        debugPrint('[AlphaVantage] Rate limited for $avSymbol');
        return null;
      }

      final quote = data['Global Quote'] as Map<String, dynamic>?;
      if (quote == null || quote.isEmpty) return null;

      final priceStr = quote['05. price'] as String?;
      if (priceStr == null || priceStr.isEmpty) return null;

      final price = Decimal.tryParse(priceStr);
      if (price == null) return null;

      return StockQuote(symbol: symbol, price: price, fetchedAt: DateTime.now());
    } on DioException catch (e) {
      debugPrint('[AlphaVantage] DioException for $avSymbol: $e');
      return null;
    } on Exception catch (e) {
      debugPrint('[AlphaVantage] Exception for $avSymbol: $e');
      return null;
    }
  }

  @override
  Future<List<StockQuote>> getBatchQuotes(
    List<String> symbols,
    MarketCode market,
  ) async {
    // Alpha Vantage free tier is 25 req/day — fetch sequentially to be safe.
    final quotes = <StockQuote>[];
    for (final symbol in symbols) {
      final quote = await getQuote(symbol, market);
      if (quote != null) quotes.add(quote);
    }
    return quotes;
  }

  String _formatSymbol(String symbol, MarketCode market) {
    if (market == MarketCode.uk) {
      return symbol.contains('.') ? symbol : '$symbol.LON';
    }
    return symbol;
  }

  Map<String, dynamic>? _safeJsonDecode(String s) {
    try {
      final v = jsonDecode(s);
      return v is Map<String, dynamic> ? v : null;
    } on FormatException {
      return null;
    }
  }
}
