import 'package:flutter/foundation.dart';

import '../../data/api/stock_price_provider.dart';
import '../repositories/price_repository.dart';
import '../repositories/stock_repository.dart';

class RefreshResult {
  const RefreshResult({required this.updated, required this.failed});

  final int updated;
  final int failed;
}

class RefreshStockPrices {
  const RefreshStockPrices({
    required StockRepository stockRepo,
    required PriceRepository priceRepo,
  })  : _stockRepo = stockRepo,
        _priceRepo = priceRepo;

  final StockRepository _stockRepo;
  final PriceRepository _priceRepo;

  Future<RefreshResult> execute() async {
    final holdings = await _stockRepo.getAll();
    if (holdings.isEmpty) return const RefreshResult(updated: 0, failed: 0);

    final specs = holdings
        .map((h) => (symbol: h.symbol, market: h.market))
        .toList();

    final quotes = await _priceRepo.refreshAll(specs);

    int updated = 0;
    int failed = 0;

    for (final holding in holdings) {
      StockQuote? match;
      for (final q in quotes) {
        if (q.symbol == holding.symbol) {
          match = q;
          break;
        }
      }

      if (match != null) {
        try {
          await _stockRepo.save(
            holding.copyWith(
              latestPrice: match.price,
              priceUpdatedAt: match.fetchedAt,
            ),
          );
          updated++;
        } on Exception catch (e) {
          debugPrint('[RefreshStockPrices] Failed to save ${holding.symbol}: $e');
          failed++;
        }
      } else {
        failed++;
      }
    }

    return RefreshResult(updated: updated, failed: failed);
  }
}
