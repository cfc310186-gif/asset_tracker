import 'package:decimal/decimal.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class ExchangeRateProvider {
  ExchangeRateProvider(this._dio);

  final Dio _dio;

  static const _baseUrl = 'https://api.frankfurter.app/latest';

  /// Returns a map with keys like "USD_TWD", "GBP_TWD", "USD_GBP".
  Future<Map<String, Decimal>> fetchRates() async {
    try {
      // Fetch USD → TWD and USD → GBP in one call.
      final usdResponse = await _dio.get<Map<String, dynamic>>(
        _baseUrl,
        queryParameters: {'from': 'USD', 'to': 'TWD,GBP'},
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

      // Derive GBP_TWD from USD_TWD / USD_GBP to avoid extra request.
      if (usdTwd != null && usdGbp != null && usdGbp != Decimal.zero) {
        final gbpTwd = (usdTwd / usdGbp).toDecimal(
          scaleOnInfinitePrecision: 6,
        );
        result['GBP_TWD'] = gbpTwd;
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
