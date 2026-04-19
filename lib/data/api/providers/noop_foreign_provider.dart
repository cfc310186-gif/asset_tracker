import '../../../domain/enums/market_code.dart';
import '../stock_price_provider.dart';

/// Placeholder provider used when no Alpha Vantage API key is configured.
/// Always returns null / empty so the UI can detect the missing-key state.
class NoOpForeignProvider implements StockPriceProvider {
  const NoOpForeignProvider();

  @override
  bool supportsMarket(MarketCode market) =>
      market == MarketCode.us || market == MarketCode.uk;

  @override
  Future<StockQuote?> getQuote(String symbol, MarketCode market) async =>
      null;

  @override
  Future<List<StockQuote>> getBatchQuotes(
    List<String> symbols,
    MarketCode market,
  ) async =>
      [];
}
