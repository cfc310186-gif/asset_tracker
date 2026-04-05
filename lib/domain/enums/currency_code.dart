enum CurrencyCode {
  twd, // 新台幣
  usd, // 美元
  gbp; // 英鎊

  String get displayName => switch (this) {
        CurrencyCode.twd => 'TWD 新台幣',
        CurrencyCode.usd => 'USD 美元',
        CurrencyCode.gbp => 'GBP 英鎊',
      };

  String get symbol => switch (this) {
        CurrencyCode.twd => r'NT$',
        CurrencyCode.usd => r'$',
        CurrencyCode.gbp => '£',
      };
}
