import 'package:decimal/decimal.dart';
import 'package:uuid/uuid.dart';

import '../enums/currency_code.dart';
import '../models/transaction.dart';
import '../repositories/transaction_repository.dart';

/// Convenience use case to record a transaction with auto id + timestamps.
class RecordTransaction {
  RecordTransaction(this._repo, {Uuid? uuid}) : _uuid = uuid ?? const Uuid();

  final TransactionRepository _repo;
  final Uuid _uuid;

  Future<void> execute({
    required TransactionAssetType assetType,
    required String assetId,
    required TransactionKind kind,
    required Decimal amount,
    required CurrencyCode currency,
    Decimal? quantity,
    Decimal? price,
    DateTime? occurredAt,
    String? note,
  }) async {
    final now = DateTime.now();
    await _repo.add(Transaction(
      id: _uuid.v4(),
      assetType: assetType,
      assetId: assetId,
      kind: kind,
      quantity: quantity,
      price: price,
      amount: amount,
      currency: currency,
      occurredAt: occurredAt ?? now,
      note: note,
      createdAt: now,
    ));
  }
}
