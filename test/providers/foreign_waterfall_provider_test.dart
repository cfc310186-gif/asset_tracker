import 'package:asset_tracker/data/api/providers/foreign_waterfall_provider.dart';
import 'package:asset_tracker/data/api/stock_price_provider.dart';
import 'package:asset_tracker/domain/enums/market_code.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeProvider implements StockPriceProvider {
  _FakeProvider({this.quote, this.shouldThrow = false});
  final StockQuote? quote;
  final bool shouldThrow;
  int callCount = 0;

  @override
  bool supportsMarket(MarketCode market) => true;

  @override
  Future<StockQuote?> getQuote(String symbol, MarketCode market) async {
    callCount++;
    if (shouldThrow) throw Exception('boom');
    return quote;
  }

  @override
  Future<List<StockQuote>> getBatchQuotes(
      List<String> symbols, MarketCode market) async {
    return [for (final s in symbols) if (await getQuote(s, market) != null) quote!];
  }
}

void main() {
  StockQuote q(String symbol, String price) => StockQuote(
        symbol: symbol,
        price: Decimal.parse(price),
        fetchedAt: DateTime.now(),
      );

  group('ForeignWaterfallProvider', () {
    test('returns Stooq quote when Stooq succeeds — does not call AV',
        () async {
      final stooq = _FakeProvider(quote: q('AAPL', '100'));
      final av = _FakeProvider(quote: q('AAPL', '999'));
      final waterfall =
          ForeignWaterfallProvider(stooq: stooq, alphaVantage: av);

      final result = await waterfall.getQuote('AAPL', MarketCode.us);
      expect(result?.price, Decimal.parse('100'));
      expect(stooq.callCount, 1);
      expect(av.callCount, 0);
    });

    test('falls back to Alpha Vantage when Stooq returns null', () async {
      final stooq = _FakeProvider(quote: null);
      final av = _FakeProvider(quote: q('AAPL', '50'));
      final waterfall =
          ForeignWaterfallProvider(stooq: stooq, alphaVantage: av);

      final result = await waterfall.getQuote('AAPL', MarketCode.us);
      expect(result?.price, Decimal.parse('50'));
      expect(stooq.callCount, 1);
      expect(av.callCount, 1);
    });

    test('returns null when Stooq fails and AV is not provided', () async {
      final stooq = _FakeProvider(quote: null);
      final waterfall =
          ForeignWaterfallProvider(stooq: stooq, alphaVantage: null);

      final result = await waterfall.getQuote('AAPL', MarketCode.us);
      expect(result, isNull);
      expect(stooq.callCount, 1);
    });

    test('returns null when Stooq and AV both fail', () async {
      final stooq = _FakeProvider(quote: null);
      final av = _FakeProvider(quote: null);
      final waterfall =
          ForeignWaterfallProvider(stooq: stooq, alphaVantage: av);

      final result = await waterfall.getQuote('AAPL', MarketCode.us);
      expect(result, isNull);
      expect(stooq.callCount, 1);
      expect(av.callCount, 1);
    });

    test('supportsMarket only US and UK', () {
      final waterfall = ForeignWaterfallProvider(
        stooq: _FakeProvider(),
        alphaVantage: null,
      );
      expect(waterfall.supportsMarket(MarketCode.us), isTrue);
      expect(waterfall.supportsMarket(MarketCode.uk), isTrue);
      expect(waterfall.supportsMarket(MarketCode.taiwan), isFalse);
    });
  });
}
