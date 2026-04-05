import 'package:decimal/decimal.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../../core/constants/app_constants.dart';
import '../../../domain/enums/market_code.dart';
import '../stock_price_provider.dart';

class EmergingProvider implements StockPriceProvider {
  EmergingProvider(this._dio);

  final Dio _dio;

  static const _apiUrl =
      'https://www.tpex.org.tw/openapi/v1/tpex_esb_latest_statistics';

  List<dynamic>? _cachedData;
  DateTime? _cacheTime;

  @override
  bool supportsMarket(MarketCode market) => market == MarketCode.emerging;

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

      final priceStr = map['LatestPrice'] as String?;
      if (priceStr == null || priceStr.isEmpty || priceStr == '-') continue;

      final price = Decimal.tryParse(priceStr);
      if (price != null) {
        quotes.add(StockQuote(symbol: code, price: price, fetchedAt: now));
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
      final response = await _dio.get<List<dynamic>>(_apiUrl);
      final data = response.data;
      if (data != null) {
        _cachedData = data;
        _cacheTime = now;
      }
      return data;
    } on DioException catch (e) {
      debugPrint('[EmergingProvider] DioException: $e');
      return null;
    } on Exception catch (e) {
      debugPrint('[EmergingProvider] Exception: $e');
      return null;
    }
  }
}
