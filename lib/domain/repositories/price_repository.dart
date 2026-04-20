import '../../data/api/stock_price_provider.dart';
import '../enums/market_code.dart';

abstract interface class PriceRepository {
  Future<StockQuote?> getQuote(String symbol, MarketCode market);

  Future<List<StockQuote>> refreshAll(
    List<({String symbol, MarketCode market})> holdings,
  );

  Future<void> cacheQuote(StockQuote quote, MarketCode market);

  /// Look up the official display name for [symbol] in [market]. Returns null
  /// when the symbol is not found, the source has no name field, or all
  /// providers fail. Used by the add/edit form to auto-populate the name.
  Future<String?> lookupName(String symbol, MarketCode market);
}
