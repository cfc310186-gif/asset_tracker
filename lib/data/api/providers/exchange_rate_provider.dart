import 'package:decimal/decimal.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class ExchangeRateProvider {
  ExchangeRateProvider(this._dio);

  final Dio _dio;

  static const _baseUrl = 'https://open.er-api.com/v6/latest/USD';

  /// Returns a map with keys like "USD_TWD", "GBP_TWD", and "JPY_TWD".
  Future<Map<String, Decimal>> fetchRates() async {
    try {
      final usdResponse = await _dio.get<Map<String, dynamic>>(
        _baseUrl,
      );

      final usdData = usdResponse.data;
      if (usdData == null) return {};

      final usdRates = usdData['rates'] as Map<String, dynamic>?;
      if (usdRates == null) return {};

      final result = <String, Decimal>{};

      final usdTwd = Decimal.tryParse(usdRates['TWD']?.toString() ?? '');
      if (usdTwd != null) result['USD_TWD'] = usdTwd;

      final usdGbp = Decimal.tryParse(usdRates['GBP']?.toString() ?? '');
      if (usdGbp != null) result['USD_GBP'] = usdGbp;

      if (usdTwd != null && usdGbp != null && usdGbp != Decimal.zero) {
        final gbpTwd = (usdTwd / usdGbp).toDecimal(
          scaleOnInfinitePrecision: 6,
        );
        result['GBP_TWD'] = gbpTwd;
      }

      final usdJpy = Decimal.tryParse(usdRates['JPY']?.toString() ?? '');
      if (usdJpy != null) result['USD_JPY'] = usdJpy;

      if (usdTwd != null && usdJpy != null && usdJpy != Decimal.zero) {
        final jpyTwd = (usdTwd / usdJpy).toDecimal(
          scaleOnInfinitePrecision: 6,
        );
        result['JPY_TWD'] = jpyTwd;
      }

      return result;
    } on DioException catch (e) {
      debugPrint('[ExchangeRateProvider] DioException: $e');
      return {};
    } on Exception catch (e) {
      debugPrint('[ExchangeRateProvider] Exception: $e');
      return {};
    }
  }
}
