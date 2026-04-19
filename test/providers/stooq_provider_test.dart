import 'package:asset_tracker/data/api/providers/stooq_provider.dart';
import 'package:asset_tracker/domain/enums/market_code.dart';
import 'package:decimal/decimal.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';

const _csvHeaders = {
  Headers.contentTypeHeader: ['text/csv'],
};

void main() {
  late Dio dio;
  late DioAdapter adapter;
  late StooqProvider provider;

  setUp(() {
    dio = Dio();
    adapter = DioAdapter(dio: dio);
    provider = StooqProvider(dio);
  });

  group('StooqProvider', () {
    test('parses a valid US CSV row', () async {
      adapter.onGet(
        'https://stooq.com/q/l/?s=aapl.us&f=sd2t2ohlcv&h&e=csv',
        (server) => server.reply(
          200,
          'Symbol,Date,Time,Open,High,Low,Close,Volume\n'
          'AAPL.US,2025-04-18,22:00:00,210.0,212.1,209.5,211.7,45123456',
          headers: _csvHeaders,
        ),
      );

      final quote = await provider.getQuote('AAPL', MarketCode.us);
      expect(quote, isNotNull);
      expect(quote!.symbol, 'AAPL');
      expect(quote.price, Decimal.parse('211.7'));
    });

    test('returns null for N/D no-data response', () async {
      adapter.onGet(
        'https://stooq.com/q/l/?s=xyz.us&f=sd2t2ohlcv&h&e=csv',
        (server) => server.reply(
          200,
          'Symbol,Date,Time,Open,High,Low,Close,Volume\n'
          'XYZ.US,N/D,N/D,N/D,N/D,N/D,N/D,N/D',
          headers: _csvHeaders,
        ),
      );

      final quote = await provider.getQuote('XYZ', MarketCode.us);
      expect(quote, isNull);
    });

    test('returns null on HTTP 500', () async {
      adapter.onGet(
        'https://stooq.com/q/l/?s=aapl.us&f=sd2t2ohlcv&h&e=csv',
        (server) => server.reply(500, 'oops', headers: _csvHeaders),
      );

      final quote = await provider.getQuote('AAPL', MarketCode.us);
      expect(quote, isNull);
    });

    test('formats UK symbol with .uk suffix', () async {
      adapter.onGet(
        'https://stooq.com/q/l/?s=vwra.uk&f=sd2t2ohlcv&h&e=csv',
        (server) => server.reply(
          200,
          'Symbol,Date,Time,Open,High,Low,Close,Volume\n'
          'VWRA.UK,2025-04-18,22:00:00,100,101,99,100.5,1000',
          headers: _csvHeaders,
        ),
      );

      final quote = await provider.getQuote('VWRA', MarketCode.uk);
      expect(quote, isNotNull);
      expect(quote!.price, Decimal.parse('100.5'));
    });

    test('does not support taiwan market', () {
      expect(provider.supportsMarket(MarketCode.taiwan), isFalse);
      expect(provider.supportsMarket(MarketCode.us), isTrue);
      expect(provider.supportsMarket(MarketCode.uk), isTrue);
    });

    test('getBatchQuotes returns only successful quotes', () async {
      adapter.onGet(
        'https://stooq.com/q/l/?s=aapl.us&f=sd2t2ohlcv&h&e=csv',
        (server) => server.reply(
          200,
          'Symbol,Date,Time,Open,High,Low,Close,Volume\n'
          'AAPL.US,2025-04-18,22:00:00,210,212,209,211.7,1',
          headers: _csvHeaders,
        ),
      );
      adapter.onGet(
        'https://stooq.com/q/l/?s=xyz.us&f=sd2t2ohlcv&h&e=csv',
        (server) => server.reply(
          200,
          'Symbol,Date,Time,Open,High,Low,Close,Volume\n'
          'XYZ.US,N/D,N/D,N/D,N/D,N/D,N/D,N/D',
          headers: _csvHeaders,
        ),
      );

      final quotes = await provider
          .getBatchQuotes(['AAPL', 'XYZ'], MarketCode.us);
      expect(quotes, hasLength(1));
      expect(quotes.first.symbol, 'AAPL');
    });
  });
}
