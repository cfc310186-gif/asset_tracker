import '../enums/currency_code.dart';

enum MarketCode {
  taiwan, // 台股（上市 / 上櫃 / 興櫃）
  us, // 美股
  uk; // 英股（LSE，USD 計價）

  String get displayName => switch (this) {
        MarketCode.taiwan => '台股',
        MarketCode.us => '美股',
        MarketCode.uk => '英股',
      };

  CurrencyCode get defaultCurrency => switch (this) {
        MarketCode.taiwan => CurrencyCode.twd,
        MarketCode.us => CurrencyCode.usd,
        MarketCode.uk => CurrencyCode.usd,
      };

  bool get isTaiwanMarket => this == taiwan;
}
