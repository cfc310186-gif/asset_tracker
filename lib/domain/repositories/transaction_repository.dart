import '../models/transaction.dart';

abstract class TransactionRepository {
  Future<void> add(Transaction tx);
  Future<List<Transaction>> getAll();
  Stream<List<Transaction>> watchAll();
  Stream<List<Transaction>> watchByRange(DateTime from, DateTime to);
  Stream<List<Transaction>> watchByAssetType(TransactionAssetType type);
  Future<void> deleteByAsset(TransactionAssetType type, String assetId);
}
