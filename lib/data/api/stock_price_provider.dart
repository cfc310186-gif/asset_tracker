import 'package:decimal/decimal.dart';

import '../../domain/enums/market_code.dart';

class StockQuote {
  final String symbol;
  final Decimal price;
  final DateTime fetchedAt;

  const StockQuote({
    required this.symbol,
    required this.price,
    required this.fetchedAt,
  });
}

abstract class StockPriceProvider {
  bool supportsMarket(MarketCode market);

  Future<StockQuote?> getQuote(String symbol, MarketCode market);

  Future<List<StockQuote>> getBatchQuotes(
    List<String> symbols,
    MarketCode market,
  );
}
