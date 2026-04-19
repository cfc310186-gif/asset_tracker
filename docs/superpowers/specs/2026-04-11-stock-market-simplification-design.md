# Stock Market Simplification & Price API Fix

**Date:** 2026-04-11  
**Status:** Approved

## Problem

1. Yahoo Finance API fails silently in Flutter web due to CORS — US/UK stocks never update.
2. Market selection has 6 options (twse/tpex/emerging/nyse/nasdaq/lse), exposing internal API details to the user.

## Goals

- Fix US (AAPL) and UK (VWRA) stock price queries from Flutter web.
- Simplify market selection to 3 user-facing choices: 台股 / 美股 / 英股.
- Taiwan stocks auto-route across TWSE/TPEx/Emerging with no user action.
- No required API keys — fallback works out of the box.

## Data Model

### MarketCode enum (3 values)

```dart
enum MarketCode { taiwan, us, uk }
```

Stored as text in DB (`"taiwan"` / `"us"` / `"uk"`).  
Existing records are incompatible with old 6-value enum. Acceptable: web DB resets on reload.

### Currency defaults

| Market | Default Currency |
|--------|-----------------|
| taiwan | TWD |
| us | USD |
| uk | USD |

UK stocks: user enters USD-priced symbols directly (e.g., USD share class on LSE). No GBP→USD conversion in the app.

## API Architecture

### Taiwan (waterfall)

```
TaiwanWaterfallProvider
  1. TwseProvider.getQuote(symbol)   → if null:
  2. TpexProvider.getQuote(symbol)   → if null:
  3. EmergingProvider.getQuote(symbol)
```

Returns first non-null result. All three existing providers are kept unchanged.

### US & UK (dual provider)

```
AlphaVantageProvider   (when API key is set in Settings)
  US:  GET /query?function=GLOBAL_QUOTE&symbol=AAPL&apikey=KEY
  UK:  GET /query?function=GLOBAL_QUOTE&symbol=VWRA.LON&apikey=KEY
  Response: data["Global Quote"]["05. price"]

StooqProvider          (fallback, no key required)
  US:  GET /q/l/?s=AAPL.US&f=sd2t2ohlcv  (CSV)
  UK:  GET /q/l/?s=VWRA.L&f=sd2t2ohlcv   (CSV)
  Response: CSV row, column index 4 = close price
```

Provider selection at runtime in `PriceRepositoryImpl`:
- If Alpha Vantage key is present in SharedPreferences → use `AlphaVantageProvider`
- Otherwise → use `StooqProvider`

## Files Changed

| Action | File | Change |
|--------|------|--------|
| Modify | `domain/enums/market_code.dart` | 6→3 values, update `displayName`, add `defaultCurrency` |
| New | `data/api/providers/taiwan_waterfall_provider.dart` | Wraps TWSE/TPEx/Emerging in waterfall |
| New | `data/api/providers/alpha_vantage_provider.dart` | Alpha Vantage GLOBAL_QUOTE, US + UK suffix |
| New | `data/api/providers/stooq_provider.dart` | Stooq CSV parser, US + UK suffix |
| Modify | `data/repositories/price_repository_impl.dart` | Route taiwan→waterfall, us/uk→AV or Stooq |
| Modify | `providers/price_providers.dart` | Wire new providers, read AV key from settings |
| Modify | `providers/settings_providers.dart` | Expose `alphaVantageKeyProvider` |
| Modify | `presentation/stocks/add_edit_stock_screen.dart` | 3-item market dropdown, remove MarketCode.nyse/nasdaq/lse/twse/tpex/emerging |
| Modify | `presentation/stocks/stock_list_screen.dart` | Update `_colorForMarket` for 3 values |
| Modify | `presentation/settings/settings_screen.dart` | Update helper text: "用於美股 / 英股查詢" |

## Provider Interface (unchanged)

```dart
abstract interface class StockPriceProvider {
  bool supportsMarket(MarketCode market);
  Future<StockQuote?> getQuote(String symbol, MarketCode market);
  Future<List<StockQuote>> getBatchQuotes(List<String> symbols, MarketCode market);
}
```

## Symbol Formatting

| Market | Alpha Vantage | Stooq |
|--------|--------------|-------|
| taiwan | N/A | N/A (handled by TWSE/TPEx/Emerging) |
| us | `AAPL` (as-is) | `AAPL.US` |
| uk | `VWRA.LON` | `VWRA.L` |

## Error Handling

- Alpha Vantage returns `{"Note": "..."}` when rate-limited → treat as null, fallback to Stooq.
- Stooq returns CSV `N/D` for unknown symbols → return null.
- Any `DioException` → log + return null (existing behaviour).

## Settings

Alpha Vantage API key field already exists in `SettingsScreen`. Update helper text from "備援" to "主要查詢方式（美股 / 英股）".

No new UI changes to settings required.

## Out of Scope

- GBP→USD conversion (user inputs USD-denominated symbols for UK)
- DB migration (web DB resets; no persistent data to migrate)
- iOS/native build
