import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/stocks_table.dart';

part 'stock_dao.g.dart';

@DriftAccessor(tables: [Stocks])
class StockDao extends DatabaseAccessor<AppDatabase> with _$StockDaoMixin {
  StockDao(super.db);

  Stream<List<StockEntry>> watchAll() => select(stocks).watch();

  Future<List<StockEntry>> getAll() => select(stocks).get();

  Future<StockEntry?> getById(String id) =>
      (select(stocks)..where((t) => t.id.equals(id))).getSingleOrNull();

  Future<StockEntry?> findBySymbolAndMarket(String symbol, String market) =>
      (select(stocks)
            ..where((t) => t.symbol.equals(symbol) & t.market.equals(market)))
          .getSingleOrNull();

  Future<int> insertOne(StocksCompanion entry) =>
      into(stocks).insert(entry);

  Future<bool> updateOne(StocksCompanion entry) =>
      update(stocks).replace(entry);

  Future<int> deleteById(String id) =>
      (delete(stocks)..where((t) => t.id.equals(id))).go();
}
