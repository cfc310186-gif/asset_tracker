import 'package:decimal/decimal.dart';
import 'package:drift/drift.dart';

import '../../domain/enums/currency_code.dart';
import '../../domain/enums/market_code.dart';
import '../../domain/models/stock_holding.dart';
import '../../domain/repositories/stock_repository.dart';
import '../database/app_database.dart';
import '../database/daos/stock_dao.dart';

class StockRepositoryImpl implements StockRepository {
  const StockRepositoryImpl(this._dao);

  final StockDao _dao;

  @override
  Stream<List<StockHolding>> watchAll() => _dao
      .watchAll()
      .map((entries) => entries.map<StockHolding>(_fromEntry).toList());

  @override
  Future<List<StockHolding>> getAll() async {
    final entries = await _dao.getAll();
    return entries.map<StockHolding>(_fromEntry).toList();
  }

  @override
  Future<StockHolding?> getById(String id) async {
    final entry = await _dao.getById(id);
    return entry != null ? _fromEntry(entry) : null;
  }

  @override
  Future<void> save(StockHolding holding) async {
    final companion = _toCompanion(holding);
    final updated = await _dao.updateOne(companion);
    if (!updated) {
      await _dao.insertOne(companion);
    }
  }

  @override
  Future<void> delete(String id) => _dao.deleteById(id);

  StockHolding _fromEntry(StockEntry e) => StockHolding(
        id: e.id,
        symbol: e.symbol,
        market: MarketCode.values.byName(e.market),
        name: e.name,
        quantity: e.quantity,
        avgCost: Decimal.parse(e.avgCost),
        currency: CurrencyCode.values.byName(e.currency),
        isMargin: e.isMargin,
        marginAmount:
            e.marginAmount != null ? Decimal.parse(e.marginAmount!) : null,
        linkedLoanId: e.linkedLoanId,
        latestPrice:
            e.latestPrice != null ? Decimal.parse(e.latestPrice!) : null,
        priceUpdatedAt: e.priceUpdatedAt,
        createdAt: e.createdAt,
        updatedAt: e.updatedAt,
      );

  StocksCompanion _toCompanion(StockHolding h) => StocksCompanion(
        id: Value(h.id),
        symbol: Value(h.symbol),
        market: Value(h.market.name),
        name: Value(h.name),
        quantity: Value(h.quantity),
        avgCost: Value(h.avgCost.toString()),
        currency: Value(h.currency.name),
        isMargin: Value(h.isMargin),
        marginAmount: Value(h.marginAmount?.toString()),
        linkedLoanId: Value(h.linkedLoanId),
        latestPrice: Value(h.latestPrice?.toString()),
        priceUpdatedAt: Value(h.priceUpdatedAt),
        createdAt: Value(h.createdAt),
        updatedAt: Value(h.updatedAt),
      );
}
