import 'dart:convert';

import 'package:decimal/decimal.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../../domain/enums/market_code.dart';
import '../stock_price_provider.dart';

class TwseProvider implements StockPriceProvider {
  TwseProvider(this._dio, {this.corsProxyUrl = ''});

  final Dio _dio;

  /// Optional CORS proxy URL prefix (e.g. 'https://corsproxy.io/?').
  /// Required for browser builds because TWSE does not send CORS headers.
  /// Empty string = direct call (works on native / when origin is allowed).
  final String corsProxyUrl;

  static const _baseUrl =
      'https://mis.twse.com.tw/stock/api/getStockInfo.jsp';

  @override
  bool supportsMarket(MarketCode market) => market == MarketCode.taiwan;

  @override
  Future<StockQuote?> getQuote(String symbol, MarketCode market) async {
    final quotes = await getBatchQuotes([symbol], market);
    return quotes.isEmpty ? null : quotes.first;
  }

  @override
  Future<List<StockQuote>> getBatchQuotes(
    List<String> symbols,
    MarketCode market,
  ) async {
    if (symbols.isEmpty) return [];

    final exCh = symbols.map((s) => 'tse_$s.tw').join('|');
    try {
      final qs =
          'ex_ch=${Uri.encodeQueryComponent(exCh)}&json=1&delay=0';
      final target = '$_baseUrl?$qs';
      final url = corsProxyUrl.isEmpty ? target : '$corsProxyUrl$target';
      final response = await _dio.get<dynamic>(url);
      final raw = response.data;
      final Map<String, dynamic>? data = raw is Map<String, dynamic>
          ? raw
          : raw is String
              ? _safeJsonDecode(raw)
              : null;
      if (data == null) return [];

      final msgArray = data['msgArray'] as List<dynamic>?;
      if (msgArray == null || msgArray.isEmpty) return [];

      final now = DateTime.now();
      final quotes = <StockQuote>[];

      for (final item in msgArray) {
        final map = item as Map<String, dynamic>;
        final code = map['c'] as String?;
        if (code == null) continue;

        final currentPriceStr = map['z'] as String?;
        final prevCloseStr = map['y'] as String?;
        final nameStr = (map['n'] as String?)?.trim();
        final name =
            (nameStr != null && nameStr.isNotEmpty) ? nameStr : null;

        Decimal? price;
        if (currentPriceStr != null &&
            currentPriceStr.isNotEmpty &&
            currentPriceStr != '-') {
          price = Decimal.tryParse(currentPriceStr);
        }
        if (price == null &&
            prevCloseStr != null &&
            prevCloseStr.isNotEmpty &&
            prevCloseStr != '-') {
          price = Decimal.tryParse(prevCloseStr);
        }

        if (price != null) {
          quotes.add(StockQuote(
            symbol: code,
            price: price,
            fetchedAt: now,
            name: name,
          ));
        }
      }

      return quotes;
    } on DioException catch (e) {
      debugPrint('[TwseProvider] DioException: $e');
      return [];
    } on Exception catch (e) {
      debugPrint('[TwseProvider] Exception: $e');
      return [];
    }
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
