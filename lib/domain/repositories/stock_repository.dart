import '../models/stock_holding.dart';

abstract interface class StockRepository {
  Stream<List<StockHolding>> watchAll();
  Future<List<StockHolding>> getAll();
  Future<StockHolding?> getById(String id);
  Future<void> save(StockHolding holding);
  Future<void> delete(String id);
}
