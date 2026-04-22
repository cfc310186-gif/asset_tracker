import 'package:flutter/foundation.dart';

import '../models/stock_holding.dart';
import '../repositories/price_repository.dart';
import '../repositories/stock_repository.dart';

class RefreshResult {
  const RefreshResult({
    required this.updated,
    required this.failed,
    required this.queueSize,
    this.failedSymbols = const [],
  });

  final int updated;
  final int failed;

  /// Total number of stocks that were attempted.
  final int queueSize;

  /// Symbols whose price fetch failed.
  final List<String> failedSymbols;
}

/// Refreshes stock prices in a stable FIFO order (oldest [createdAt] first).
///
/// * [executeAll]    — fetch every holding sequentially, in FIFO order.
/// * [executeSingle] — fetch a single holding (per-tile refresh action).
class RefreshStockPrices {
  const RefreshStockPrices({
    required StockRepository stockRepo,
    required PriceRepository priceRepo,
  })  : _stockRepo = stockRepo,
        _priceRepo = priceRepo;

  final StockRepository _stockRepo;
  final PriceRepository _priceRepo;

  /// Refresh every holding in a single pass, ordered by [createdAt] (FIFO).
  /// Requests run sequentially so providers with per-request rate limits
  /// (notably Alpha Vantage free-tier) stay happy.
  Future<RefreshResult> executeAll() async {
    final holdings = await _stockRepo.getAll();
    if (holdings.isEmpty) {
      return const RefreshResult(updated: 0, failed: 0, queueSize: 0);
    }

    final sorted = [...holdings]
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));

    var updated = 0;
    final failed = <String>[];
    for (var i = 0; i < sorted.length; i++) {
      final h = sorted[i];
      debugPrint(
        '[RefreshStockPrices] Updating ${h.symbol} (${i + 1}/${sorted.length})',
      );
      final ok = await _fetchAndSave(h);
      if (ok) {
        updated++;
      } else {
        failed.add(h.symbol);
      }
    }

    return RefreshResult(
      updated: updated,
      failed: failed.length,
      queueSize: sorted.length,
      failedSymbols: List.unmodifiable(failed),
    );
  }

  /// Refresh a single holding. Used by the per-stock refresh action.
  Future<RefreshResult> executeSingle(StockHolding holding) async {
    debugPrint('[RefreshStockPrices] Updating single ${holding.symbol}');
    final ok = await _fetchAndSave(holding);
    return RefreshResult(
      updated: ok ? 1 : 0,
      failed: ok ? 0 : 1,
      queueSize: 1,
      failedSymbols: ok ? const [] : [holding.symbol],
    );
  }

  /// Returns true when a non-null quote was fetched and persisted.
  Future<bool> _fetchAndSave(StockHolding target) async {
    try {
      final quote = await _priceRepo.getQuote(target.symbol, target.market);
      if (quote == null) return false;

      await _stockRepo.save(
        target.copyWith(
          latestPrice: quote.price,
          priceUpdatedAt: quote.fetchedAt,
        ),
      );
      return true;
    } on Exception catch (e) {
      debugPrint('[RefreshStockPrices] Error updating ${target.symbol}: $e');
      return false;
    }
  }
}
