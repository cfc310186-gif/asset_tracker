import 'dart:convert';

import 'package:decimal/decimal.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../../core/constants/app_constants.dart';
import '../../../domain/enums/market_code.dart';
import '../stock_price_provider.dart';

class TpexProvider implements StockPriceProvider {
  TpexProvider(this._dio, {this.corsProxyUrl = ''});

  final Dio _dio;

  /// Optional CORS proxy URL prefix. Required for browser builds because
  /// www.tpex.org.tw does not send permissive CORS headers.
  final String corsProxyUrl;

  static const _apiUrl =
      'https://www.tpex.org.tw/openapi/v1/tpex_mainboard_quotes';

  List<dynamic>? _cachedData;
  DateTime? _cacheTime;

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

    final allData = await _fetchAll();
    if (allData == null) return [];

    final now = DateTime.now();
    final symbolSet = symbols.toSet();
    final quotes = <StockQuote>[];

    for (final item in allData) {
      final map = item as Map<String, dynamic>;
      final code = map['SecuritiesCompanyCode'] as String?;
      if (code == null || !symbolSet.contains(code)) continue;

      final closeStr = map['Close'] as String?;
      if (closeStr == null || closeStr.isEmpty || closeStr == '-') continue;

      final nameStr = (map['CompanyName'] as String?)?.trim();
      final name =
          (nameStr != null && nameStr.isNotEmpty) ? nameStr : null;

      final price = Decimal.tryParse(closeStr);
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
  }

  Future<List<dynamic>?> _fetchAll() async {
    final now = DateTime.now();
    if (_cachedData != null &&
        _cacheTime != null &&
        now.difference(_cacheTime!) < AppConstants.priceStaleDuration) {
      return _cachedData;
    }

    try {
      final url =
          corsProxyUrl.isEmpty ? _apiUrl : '$corsProxyUrl$_apiUrl';
      final response = await _dio.get<dynamic>(url);
      final raw = response.data;
      final data = raw is List<dynamic>
          ? raw
          : raw is String
              ? _safeJsonDecodeList(raw)
              : null;
      if (data != null) {
        _cachedData = data;
        _cacheTime = now;
      }
      return data;
    } on DioException catch (e) {
      debugPrint('[TpexProvider] DioException: $e');
      return null;
    } on Exception catch (e) {
      debugPrint('[TpexProvider] Exception: $e');
      return null;
    }
  }

  List<dynamic>? _safeJsonDecodeList(String s) {
    try {
      final v = jsonDecode(s);
      return v is List<dynamic> ? v : null;
    } on FormatException {
      return null;
    }
  }
}
