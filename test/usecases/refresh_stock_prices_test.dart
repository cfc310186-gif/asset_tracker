import 'package:asset_tracker/data/api/stock_price_provider.dart';
import 'package:asset_tracker/domain/enums/currency_code.dart';
import 'package:asset_tracker/domain/enums/market_code.dart';
import 'package:asset_tracker/domain/models/stock_holding.dart';
import 'package:asset_tracker/domain/repositories/price_repository.dart';
import 'package:asset_tracker/domain/usecases/refresh_stock_prices.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter_test/flutter_test.dart';

import '_fakes.dart';

class _FakePriceRepository implements PriceRepository {
  _FakePriceRepository(this._quotes);

  /// symbol(uppercase) -> quote, or null to simulate provider failure.
  final Map<String, StockQuote?> _quotes;

  final List<String> fetched = [];

  @override
  Future<StockQuote?> getQuote(String symbol, MarketCode market) async {
    fetched.add(symbol);
    return _quotes[symbol.toUpperCase()];
  }

  @override
  Future<String?> lookupName(String symbol, MarketCode market) async => null;

  @override
  Future<List<StockQuote>> refreshAll(
    List<({String symbol, MarketCode market})> holdings,
  ) async =>
      [];

  @override
  Future<void> cacheQuote(StockQuote quote, MarketCode market) async {}
}

StockHolding _holding(
  String symbol, {
  required DateTime createdAt,
  MarketCode market = MarketCode.taiwan,
  CurrencyCode currency = CurrencyCode.twd,
}) {
  return StockHolding(
    id: symbol,
    symbol: symbol,
    market: market,
    name: symbol,
    quantity: 10,
    avgCost: Decimal.parse('100'),
    currency: currency,
    isMargin: false,
    createdAt: createdAt,
    updatedAt: createdAt,
  );
}

StockQuote _quote(String symbol, String price) => StockQuote(
      symbol: symbol,
      price: Decimal.parse(price),
      fetchedAt: DateTime(2025, 4, 18, 9),
      name: symbol,
    );

void main() {
  group('RefreshStockPrices.executeAll', () {
    test('returns zero counts when queue is empty', () async {
      final stockRepo = FakeStockRepository();
      final priceRepo = _FakePriceRepository({});
      final useCase =
          RefreshStockPrices(stockRepo: stockRepo, priceRepo: priceRepo);

      final result = await useCase.executeAll();

      expect(result.updated, 0);
      expect(result.failed, 0);
      expect(result.queueSize, 0);
      expect(result.failedSymbols, isEmpty);
      expect(priceRepo.fetched, isEmpty);
    });

    test('fetches every holding in FIFO order (oldest createdAt first)',
        () async {
      final stockRepo = FakeStockRepository([
        _holding('BBB', createdAt: DateTime(2025, 3, 1)),
        _holding('AAA', createdAt: DateTime(2025, 1, 1)),
        _holding('CCC', createdAt: DateTime(2025, 4, 1)),
      ]);
      final priceRepo = _FakePriceRepository({
        'AAA': _quote('AAA', '10'),
        'BBB': _quote('BBB', '20'),
        'CCC': _quote('CCC', '30'),
      });
      final useCase =
          RefreshStockPrices(stockRepo: stockRepo, priceRepo: priceRepo);

      final result = await useCase.executeAll();

      expect(priceRepo.fetched, ['AAA', 'BBB', 'CCC']);
      expect(result.updated, 3);
      expect(result.failed, 0);
      expect(result.queueSize, 3);
      expect(result.failedSymbols, isEmpty);

      final saved = {for (final h in stockRepo.items) h.symbol: h.latestPrice};
      expect(saved['AAA'], Decimal.parse('10'));
      expect(saved['BBB'], Decimal.parse('20'));
      expect(saved['CCC'], Decimal.parse('30'));
    });

    test('reports partial failures without aborting the pass', () async {
      final stockRepo = FakeStockRepository([
        _holding('AAA', createdAt: DateTime(2025, 1, 1)),
        _holding('BAD', createdAt: DateTime(2025, 2, 1)),
        _holding('CCC', createdAt: DateTime(2025, 3, 1)),
      ]);
      final priceRepo = _FakePriceRepository({
        'AAA': _quote('AAA', '10'),
        'BAD': null, // simulate quote-not-found
        'CCC': _quote('CCC', '30'),
      });
      final useCase =
          RefreshStockPrices(stockRepo: stockRepo, priceRepo: priceRepo);

      final result = await useCase.executeAll();

      expect(result.updated, 2);
      expect(result.failed, 1);
      expect(result.queueSize, 3);
      expect(result.failedSymbols, ['BAD']);

      // The failing holding's latestPrice is not overwritten.
      final bad = stockRepo.items.firstWhere((h) => h.symbol == 'BAD');
      expect(bad.latestPrice, isNull);
    });

    test('failedSymbols is unmodifiable', () async {
      final stockRepo = FakeStockRepository([
        _holding('BAD', createdAt: DateTime(2025, 1, 1)),
      ]);
      final priceRepo = _FakePriceRepository({'BAD': null});
      final useCase =
          RefreshStockPrices(stockRepo: stockRepo, priceRepo: priceRepo);

      final result = await useCase.executeAll();

      expect(result.failedSymbols, ['BAD']);
      expect(() => result.failedSymbols.add('X'), throwsUnsupportedError);
    });
  });

  group('RefreshStockPrices.executeSingle', () {
    test('updates a single holding and reports success', () async {
      final holding = _holding('AAPL',
          market: MarketCode.us,
          currency: CurrencyCode.usd,
          createdAt: DateTime(2025, 1, 1));
      final stockRepo = FakeStockRepository([holding]);
      final priceRepo = _FakePriceRepository({
        'AAPL': _quote('AAPL', '211.7'),
      });
      final useCase =
          RefreshStockPrices(stockRepo: stockRepo, priceRepo: priceRepo);

      final result = await useCase.executeSingle(holding);

      expect(result.updated, 1);
      expect(result.failed, 0);
      expect(result.queueSize, 1);
      expect(result.failedSymbols, isEmpty);
      expect(stockRepo.items.single.latestPrice, Decimal.parse('211.7'));
    });

    test('reports failure when the provider returns null', () async {
      final holding = _holding('XYZ', createdAt: DateTime(2025, 1, 1));
      final stockRepo = FakeStockRepository([holding]);
      final priceRepo = _FakePriceRepository({'XYZ': null});
      final useCase =
          RefreshStockPrices(stockRepo: stockRepo, priceRepo: priceRepo);

      final result = await useCase.executeSingle(holding);

      expect(result.updated, 0);
      expect(result.failed, 1);
      expect(result.failedSymbols, ['XYZ']);
      expect(stockRepo.items.single.latestPrice, isNull);
    });
  });
}
