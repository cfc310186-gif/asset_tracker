enum MarketCode {
  twse, // 台股上市 TWSE
  tpex, // 台股上櫃 TPEx/OTC
  emerging, // 台股興櫃 Emerging
  nyse, // 美股 NYSE
  nasdaq, // 美股 NASDAQ
  lse; // 英股 LSE

  String get displayName => switch (this) {
        MarketCode.twse => '台股上市',
        MarketCode.tpex => '台股上櫃',
        MarketCode.emerging => '台股興櫃',
        MarketCode.nyse => '美股 NYSE',
        MarketCode.nasdaq => '美股 NASDAQ',
        MarketCode.lse => '英股 LSE',
      };

  bool get isTaiwanMarket =>
      this == twse || this == tpex || this == emerging;
}
