import 'package:decimal/decimal.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../../domain/enums/market_code.dart';
import '../stock_price_provider.dart';

/// Fetches US and UK stock prices from Stooq CSV endpoint.
///
/// No API key required. Endpoint format:
///   https://stooq.com/q/l/?s=aapl.us&f=sd2t2ohlcv&h&e=csv
///
/// Web caveat: Stooq does not send CORS headers. On Flutter Web a CORS proxy
/// may be required — [corsProxyUrl] is prepended verbatim to the request URL
/// when non-empty (e.g. "https://corsproxy.io/?"). Native apps leave it empty.
class StooqProvider implements StockPriceProvider {
  StooqProvider(this._dio, {this.corsProxyUrl = ''});

  final Dio _dio;
  final String corsProxyUrl;

  static const _baseUrl = 'https://stooq.com/q/l/';

  @override
  bool supportsMarket(MarketCode market) =>
      market == MarketCode.us || market == MarketCode.uk;

  @override
  Future<StockQuote?> getQuote(String symbol, MarketCode market) async {
    final stooqSymbol = _formatSymbol(symbol, market);
    // f=snd2t2ohlcv => Symbol, Name, Date, Time, OHLC, Volume
    final target = '$_baseUrl?s=$stooqSymbol&f=snd2t2ohlcv&h&e=csv';
    final url = corsProxyUrl.isEmpty ? target : '$corsProxyUrl$target';
    try {
      final response = await _dio.get<String>(
        url,
        options: Options(responseType: ResponseType.plain),
      );

      final body = response.data;
      if (body == null || body.isEmpty) return null;

      return _parseCsv(body, symbol);
    } on DioException catch (e) {
      debugPrint('[Stooq] DioException for $stooqSymbol: $e');
      return null;
    } on Exception catch (e) {
      debugPrint('[Stooq] Exception for $stooqSymbol: $e');
      return null;
    }
  }

  @override
  Future<List<StockQuote>> getBatchQuotes(
    List<String> symbols,
    MarketCode market,
  ) async {
    if (symbols.isEmpty) return [];
    final futures = symbols.map((s) => getQuote(s, market));
    final results = await Future.wait(futures);
    return results.whereType<StockQuote>().toList();
  }

  String _formatSymbol(String symbol, MarketCode market) {
    final lower = symbol.toLowerCase();
    if (lower.contains('.')) return lower;
    return market == MarketCode.uk ? '$lower.uk' : '$lower.us';
  }

  StockQuote? _parseCsv(String body, String symbol) {
    // Expected CSV (f=snd2t2ohlcv):
    //   Symbol,Name,Date,Time,Open,High,Low,Close,Volume
    //   AAPL.US,APPLE,2025-04-18,22:00:00,210.0,212.1,209.5,211.7,45123456
    // Note: Name itself may contain commas wrapped in quotes (e.g.
    //   "ALPHABET, INC."). Use a quote-aware splitter.
    final lines = body.trim().split(RegExp(r'\r?\n'));
    if (lines.length < 2) return null;

    final header = _splitCsvLine(lines.first);
    final closeIdx = header.indexWhere((h) => h.trim().toLowerCase() == 'close');
    if (closeIdx < 0) return null;
    final nameIdx = header.indexWhere((h) => h.trim().toLowerCase() == 'name');

    final row = _splitCsvLine(lines[1]);
    if (row.length <= closeIdx) return null;

    final closeStr = row[closeIdx].trim();
    if (closeStr.isEmpty || closeStr.toUpperCase() == 'N/D') return null;

    final price = Decimal.tryParse(closeStr);
    if (price == null) return null;

    String? name;
    if (nameIdx >= 0 && row.length > nameIdx) {
      final raw = row[nameIdx].trim();
      if (raw.isNotEmpty && raw.toUpperCase() != 'N/D') {
        name = raw;
      }
    }

    return StockQuote(
      symbol: symbol,
      price: price,
      fetchedAt: DateTime.now(),
      name: name,
    );
  }

  /// Splits a CSV line, treating double-quoted segments as a single field
  /// (so commas inside `"ALPHABET, INC."` don't break parsing). Surrounding
  /// quotes are stripped from the returned values.
  List<String> _splitCsvLine(String line) {
    final out = <String>[];
    final buf = StringBuffer();
    var inQuotes = false;
    for (var i = 0; i < line.length; i++) {
      final ch = line[i];
      if (ch == '"') {
        inQuotes = !inQuotes;
        continue;
      }
      if (ch == ',' && !inQuotes) {
        out.add(buf.toString());
        buf.clear();
      } else {
        buf.write(ch);
      }
    }
    out.add(buf.toString());
    return out;
  }
}
