import 'package:decimal/decimal.dart';
import 'package:drift/drift.dart';

import '../../domain/enums/currency_code.dart';
import '../../domain/models/transaction.dart';
import '../../domain/repositories/transaction_repository.dart';
import '../database/app_database.dart';
import '../database/daos/transaction_dao.dart';

class TransactionRepositoryImpl implements TransactionRepository {
  const TransactionRepositoryImpl(this._dao);

  final TransactionDao _dao;

  @override
  Future<void> add(Transaction tx) async {
    await _dao.insertOne(_toCompanion(tx));
  }

  @override
  Future<List<Transaction>> getAll() async {
    final entries = await _dao.getAll();
    return entries.map<Transaction>(_fromEntry).toList();
  }

  @override
  Stream<List<Transaction>> watchAll() => _dao
      .watchAll()
      .map((entries) => entries.map<Transaction>(_fromEntry).toList());

  @override
  Stream<List<Transaction>> watchByRange(DateTime from, DateTime to) => _dao
      .watchByRange(from, to)
      .map((entries) => entries.map<Transaction>(_fromEntry).toList());

  @override
  Stream<List<Transaction>> watchByAssetType(TransactionAssetType type) => _dao
      .watchByAssetType(type.storageKey)
      .map((entries) => entries.map<Transaction>(_fromEntry).toList());

  @override
  Future<void> deleteByAsset(TransactionAssetType type, String assetId) =>
      _dao.deleteByAsset(type.storageKey, assetId).then((_) {});

  Transaction _fromEntry(TransactionEntry e) => Transaction(
        id: e.id,
        assetType: TransactionAssetType.fromKey(e.assetType),
        assetId: e.assetId,
        kind: TransactionKind.fromKey(e.kind),
        quantity: e.quantity != null ? Decimal.parse(e.quantity!) : null,
        price: e.price != null ? Decimal.parse(e.price!) : null,
        amount: Decimal.parse(e.amount),
        currency: CurrencyCode.values.byName(e.currency),
        occurredAt: e.occurredAt,
        note: e.note,
        createdAt: e.createdAt,
      );

  TransactionsCompanion _toCompanion(Transaction t) => TransactionsCompanion(
        id: Value(t.id),
        assetType: Value(t.assetType.storageKey),
        assetId: Value(t.assetId),
        kind: Value(t.kind.storageKey),
        quantity: Value(t.quantity?.toString()),
        price: Value(t.price?.toString()),
        amount: Value(t.amount.toString()),
        currency: Value(t.currency.name),
        occurredAt: Value(t.occurredAt),
        note: Value(t.note),
        createdAt: Value(t.createdAt),
      );
}
