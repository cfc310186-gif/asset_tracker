import 'package:flutter/foundation.dart';

import '../repositories/price_repository.dart';
import '../repositories/stock_repository.dart';

class RefreshResult {
  const RefreshResult({
    required this.updated,
    required this.failed,
    required this.nextPointer,
    required this.queueSize,
    this.updatedSymbol,
  });

  final int updated;
  final int failed;

  /// Index that should be used on the NEXT refresh call.
  final int nextPointer;

  /// Total number of stocks in the queue.
  final int queueSize;

  /// Symbol of the stock that was attempted this cycle (null if queue empty).
  final String? updatedSymbol;
}

/// Refreshes one stock per call in a circular FIFO order.
///
/// Holdings are sorted by [createdAt] for a stable queue. On each call the
/// stock at [pointer % queueSize] is fetched; the returned [RefreshResult]
/// carries [nextPointer] which the caller must persist and pass back next time.
class RefreshStockPrices {
  const RefreshStockPrices({
    required StockRepository stockRepo,
    required PriceRepository priceRepo,
  })  : _stockRepo = stockRepo,
        _priceRepo = priceRepo;

  final StockRepository _stockRepo;
  final PriceRepository _priceRepo;

  Future<RefreshResult> execute({int pointer = 0}) async {
    final holdings = await _stockRepo.getAll();
    if (holdings.isEmpty) {
      return const RefreshResult(
        updated: 0,
        failed: 0,
        nextPointer: 0,
        queueSize: 0,
      );
    }

    // Stable queue order: oldest first.
    final sorted = [...holdings]
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));

    final idx = pointer % sorted.length;
    final target = sorted[idx];
    final nextPointer = (idx + 1) % sorted.length;

    debugPrint(
      '[RefreshStockPrices] Updating ${target.symbol} '
      '(${idx + 1}/${sorted.length})',
    );

    try {
      final quote = await _priceRepo.getQuote(target.symbol, target.market);

      if (quote != null) {
        await _stockRepo.save(
          target.copyWith(
            latestPrice: quote.price,
            priceUpdatedAt: quote.fetchedAt,
          ),
        );
        return RefreshResult(
          updated: 1,
          failed: 0,
          nextPointer: nextPointer,
          queueSize: sorted.length,
          updatedSymbol: target.symbol,
        );
      } else {
        return RefreshResult(
          updated: 0,
          failed: 1,
          nextPointer: nextPointer,
          queueSize: sorted.length,
          updatedSymbol: target.symbol,
        );
      }
    } on Exception catch (e) {
      debugPrint('[RefreshStockPrices] Error updating ${target.symbol}: $e');
      return RefreshResult(
        updated: 0,
        failed: 1,
        nextPointer: nextPointer,
        queueSize: sorted.length,
        updatedSymbol: target.symbol,
      );
    }
  }
}
