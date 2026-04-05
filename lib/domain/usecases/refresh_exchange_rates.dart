import 'package:uuid/uuid.dart';

import '../models/exchange_rate.dart';
import '../enums/currency_code.dart';
import '../repositories/exchange_rate_repository.dart';
import '../../data/api/providers/exchange_rate_provider.dart';

class RefreshExchangeRates {
  RefreshExchangeRates({
    required ExchangeRateProvider exchangeRateProvider,
    required ExchangeRateRepository exchangeRateRepo,
  })  : _provider = exchangeRateProvider,
        _repo = exchangeRateRepo;

  final ExchangeRateProvider _provider;
  final ExchangeRateRepository _repo;

  Future<void> execute() async {
    final rates = await _provider.fetchRates();
    final now = DateTime.now();
    const uuid = Uuid();

    for (final entry in rates.entries) {
      final parts = entry.key.split('_'); // e.g. "USD_TWD"
      if (parts.length != 2) continue;
      final from = _parseCurrency(parts[0]);
      final to = _parseCurrency(parts[1]);
      if (from == null || to == null) continue;

      final existing = await _repo.getByPair(from, to);
      final rate = ExchangeRate(
        id: existing?.id ?? uuid.v4(),
        fromCurrency: from,
        toCurrency: to,
        rate: entry.value,
        fetchedAt: now,
      );
      await _repo.save(rate);
    }
  }

  CurrencyCode? _parseCurrency(String code) {
    try {
      return CurrencyCode.values.byName(code.toLowerCase());
    } on ArgumentError {
      return null;
    }
  }
}
