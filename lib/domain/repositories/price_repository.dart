import '../../data/api/stock_price_provider.dart';
import '../enums/market_code.dart';

abstract interface class PriceRepository {
  Future<StockQuote?> getQuote(String symbol, MarketCode market);

  Future<List<StockQuote>> refreshAll(
    List<({String symbol, MarketCode market})> holdings,
  );

  Future<void> cacheQuote(StockQuote quote, MarketCode market);
}
