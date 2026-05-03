import 'package:asset_tracker/data/api/providers/exchange_rate_provider.dart';
import 'package:decimal/decimal.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';

void main() {
  test('ExchangeRateProvider reads TWD, GBP, and JPY rates from USD base',
      () async {
    final dio = Dio();
    final adapter = DioAdapter(dio: dio);
    adapter.onGet(
      'https://open.er-api.com/v6/latest/USD',
      (server) => server.reply(
        200,
        {
          'result': 'success',
          'rates': {'USD': 1, 'TWD': 32, 'GBP': 0.8, 'JPY': 160},
        },
        headers: {
          Headers.contentTypeHeader: [Headers.jsonContentType],
        },
      ),
    );

    final rates = await ExchangeRateProvider(dio).fetchRates();

    expect(rates['USD_TWD'], Decimal.parse('32'));
    expect(rates['GBP_TWD'], Decimal.parse('40'));
    expect(rates['JPY_TWD'], Decimal.parse('0.2'));
  });
}
