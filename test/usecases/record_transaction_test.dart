import 'package:asset_tracker/domain/enums/currency_code.dart';
import 'package:asset_tracker/domain/models/transaction.dart';
import 'package:asset_tracker/domain/repositories/transaction_repository.dart';
import 'package:asset_tracker/domain/usecases/record_transaction.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeTransactionRepository implements TransactionRepository {
  final List<Transaction> stored = [];

  @override
  Future<void> add(Transaction tx) async => stored.add(tx);

  @override
  Future<List<Transaction>> getAll() async => List.unmodifiable(stored);

  @override
  Stream<List<Transaction>> watchAll() => Stream.value(stored);

  @override
  Stream<List<Transaction>> watchByRange(DateTime from, DateTime to) =>
      Stream.value(stored
          .where((t) =>
              !t.occurredAt.isBefore(from) && t.occurredAt.isBefore(to))
          .toList());

  @override
  Stream<List<Transaction>> watchByAssetType(TransactionAssetType type) =>
      Stream.value(stored.where((t) => t.assetType == type).toList());

  @override
  Future<void> deleteByAsset(
      TransactionAssetType type, String assetId) async {
    stored.removeWhere((t) => t.assetType == type && t.assetId == assetId);
  }
}

void main() {
  group('RecordTransaction', () {
    late _FakeTransactionRepository repo;
    late RecordTransaction useCase;

    setUp(() {
      repo = _FakeTransactionRepository();
      useCase = RecordTransaction(repo);
    });

    test('persists a stock buy with amount and metadata', () async {
      await useCase.execute(
        assetType: TransactionAssetType.stock,
        assetId: 'stock-1',
        kind: TransactionKind.buy,
        amount: Decimal.parse('-1000'),
        currency: CurrencyCode.usd,
        quantity: Decimal.parse('10'),
        price: Decimal.parse('100'),
        note: 'first buy',
      );

      expect(repo.stored, hasLength(1));
      final tx = repo.stored.single;
      expect(tx.assetType, TransactionAssetType.stock);
      expect(tx.assetId, 'stock-1');
      expect(tx.kind, TransactionKind.buy);
      expect(tx.amount, Decimal.parse('-1000'));
      expect(tx.currency, CurrencyCode.usd);
      expect(tx.quantity, Decimal.parse('10'));
      expect(tx.price, Decimal.parse('100'));
      expect(tx.note, 'first buy');
      expect(tx.id, isNotEmpty);
    });

    test('auto-fills occurredAt and createdAt when omitted', () async {
      final before = DateTime.now();
      await useCase.execute(
        assetType: TransactionAssetType.cash,
        assetId: 'cash-1',
        kind: TransactionKind.deposit,
        amount: Decimal.parse('500'),
        currency: CurrencyCode.twd,
      );
      final after = DateTime.now();

      final tx = repo.stored.single;
      expect(tx.occurredAt.isBefore(before), isFalse);
      expect(tx.occurredAt.isAfter(after), isFalse);
      expect(tx.createdAt.isBefore(before), isFalse);
      expect(tx.createdAt.isAfter(after), isFalse);
    });

    test('respects supplied occurredAt', () async {
      final t = DateTime.utc(2025, 1, 15, 10);
      await useCase.execute(
        assetType: TransactionAssetType.cash,
        assetId: 'cash-2',
        kind: TransactionKind.withdraw,
        amount: Decimal.parse('-200'),
        currency: CurrencyCode.twd,
        occurredAt: t,
      );

      expect(repo.stored.single.occurredAt, t);
    });

    test('produces unique ids across multiple records', () async {
      for (var i = 0; i < 5; i++) {
        await useCase.execute(
          assetType: TransactionAssetType.cash,
          assetId: 'cash-$i',
          kind: TransactionKind.deposit,
          amount: Decimal.parse('100'),
          currency: CurrencyCode.twd,
        );
      }
      final ids = repo.stored.map((t) => t.id).toSet();
      expect(ids, hasLength(5));
    });
  });
}
