import 'package:asset_tracker/data/api/providers/twse_provider.dart';
import 'package:asset_tracker/domain/enums/market_code.dart';
import 'package:decimal/decimal.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';

const _jsonHeaders = {
  Headers.contentTypeHeader: ['application/json'],
};

void main() {
  late Dio dio;
  late DioAdapter adapter;
  late TwseProvider provider;

  setUp(() {
    dio = Dio();
    adapter = DioAdapter(dio: dio);
    provider = TwseProvider(dio);
  });

  group('TwseProvider', () {
    test('parses code, current price, and Chinese name from msgArray',
        () async {
      adapter.onGet(
        'https://mis.twse.com.tw/stock/api/getStockInfo.jsp?ex_ch=tse_2330.tw&json=1&delay=0',
        (server) => server.reply(
          200,
          {
            'msgArray': [
              {'c': '2330', 'n': '台積電', 'z': '900.50', 'y': '895.00'},
            ],
          },
          headers: _jsonHeaders,
        ),
      );

      final quote = await provider.getQuote('2330', MarketCode.taiwan);
      expect(quote, isNotNull);
      expect(quote!.symbol, '2330');
      expect(quote.price, Decimal.parse('900.50'));
      expect(quote.name, '台積電');
    });

    test('falls back to previous close when current price is "-"', () async {
      adapter.onGet(
        'https://mis.twse.com.tw/stock/api/getStockInfo.jsp?ex_ch=tse_2330.tw&json=1&delay=0',
        (server) => server.reply(
          200,
          {
            'msgArray': [
              {'c': '2330', 'n': '台積電', 'z': '-', 'y': '895.00'},
            ],
          },
          headers: _jsonHeaders,
        ),
      );

      final quote = await provider.getQuote('2330', MarketCode.taiwan);
      expect(quote, isNotNull);
      expect(quote!.price, Decimal.parse('895.00'));
      expect(quote.name, '台積電');
    });

    test('returns null when msgArray is empty', () async {
      adapter.onGet(
        'https://mis.twse.com.tw/stock/api/getStockInfo.jsp?ex_ch=tse_9999.tw&json=1&delay=0',
        (server) => server.reply(200, {'msgArray': []}, headers: _jsonHeaders),
      );

      final quote = await provider.getQuote('9999', MarketCode.taiwan);
      expect(quote, isNull);
    });

    test('returns null on 5xx error', () async {
      adapter.onGet(
        'https://mis.twse.com.tw/stock/api/getStockInfo.jsp?ex_ch=tse_2330.tw&json=1&delay=0',
        (server) => server.reply(503, 'oops'),
      );

      final quote = await provider.getQuote('2330', MarketCode.taiwan);
      expect(quote, isNull);
    });

    test('prepends a non-empty cors proxy URL verbatim', () async {
      final proxied = TwseProvider(
        dio,
        corsProxyUrl: 'https://corsproxy.io/?',
      );
      adapter.onGet(
        'https://corsproxy.io/?https://mis.twse.com.tw/stock/api/getStockInfo.jsp?ex_ch=tse_2330.tw&json=1&delay=0',
        (server) => server.reply(
          200,
          {
            'msgArray': [
              {'c': '2330', 'n': '台積電', 'z': '900.50'},
            ],
          },
          headers: _jsonHeaders,
        ),
      );

      final quote = await proxied.getQuote('2330', MarketCode.taiwan);
      expect(quote, isNotNull);
      expect(quote!.name, '台積電');
    });

    test('parses a String JSON body when proxy returns text/plain', () async {
      // Some CORS proxies forward upstream JSON as a quoted text/plain blob.
      // The provider must still cope by JSON-decoding the raw String.
      adapter.onGet(
        'https://mis.twse.com.tw/stock/api/getStockInfo.jsp?ex_ch=tse_2330.tw&json=1&delay=0',
        (server) => server.reply(
          200,
          '{"msgArray":[{"c":"2330","n":"台積電","z":"900.50"}]}',
          headers: {
            Headers.contentTypeHeader: ['text/plain'],
          },
        ),
      );

      final quote = await provider.getQuote('2330', MarketCode.taiwan);
      expect(quote, isNotNull);
      expect(quote!.name, '台積電');
      expect(quote.price, Decimal.parse('900.50'));
    });
  });
}
