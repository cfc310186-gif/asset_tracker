import '../enums/currency_code.dart';
import '../models/net_worth_snapshot.dart';

abstract class NetWorthSnapshotRepository {
  Future<void> upsert(NetWorthSnapshot snapshot);
  Future<List<NetWorthSnapshot>> getAll();
  Stream<List<NetWorthSnapshot>> watchAll();
  Stream<List<NetWorthSnapshot>> watchByCurrency(CurrencyCode currency);
}
