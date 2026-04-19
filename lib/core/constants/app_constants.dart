class AppConstants {
  AppConstants._();

  /// Price cache duration before considered stale.
  static const priceStaleDuration = Duration(minutes: 15);

  /// Exchange rate cache duration.
  static const exchangeRateStaleDuration = Duration(hours: 1);

  /// Default display currency.
  static const defaultDisplayCurrency = 'twd';

  // Shared preferences keys.
  static const prefDisplayCurrency = 'display_currency';
  static const prefAlphaVantageApiKey = 'alpha_vantage_api_key';
  static const prefExchangeRateApiKey = 'exchange_rate_api_key';
  static const prefRefreshQueuePointer = 'refresh_queue_pointer';

  /// API rate limiting.
  static const maxRequestsPerMinute = 30;
}
