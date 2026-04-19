import 'package:decimal/decimal.dart';
import 'package:flutter/foundation.dart';

import '../enums/currency_code.dart';

enum TransactionAssetType {
  stock,
  cash,
  realEstate,
  loan;

  String get storageKey => switch (this) {
        TransactionAssetType.stock => 'stock',
        TransactionAssetType.cash => 'cash',
        TransactionAssetType.realEstate => 'real_estate',
        TransactionAssetType.loan => 'loan',
      };

  static TransactionAssetType fromKey(String key) => switch (key) {
        'stock' => TransactionAssetType.stock,
        'cash' => TransactionAssetType.cash,
        'real_estate' => TransactionAssetType.realEstate,
        'loan' => TransactionAssetType.loan,
        _ => TransactionAssetType.cash,
      };

  String get displayName => switch (this) {
        TransactionAssetType.stock => '股票',
        TransactionAssetType.cash => '現金',
        TransactionAssetType.realEstate => '不動產',
        TransactionAssetType.loan => '貸款',
      };
}

enum TransactionKind {
  buy,
  sell,
  deposit,
  withdraw,
  dividend,
  adjust;

  String get storageKey => name;

  static TransactionKind fromKey(String key) => TransactionKind.values
      .firstWhere((k) => k.name == key, orElse: () => TransactionKind.adjust);

  String get displayName => switch (this) {
        TransactionKind.buy => '買入',
        TransactionKind.sell => '賣出',
        TransactionKind.deposit => '存入',
        TransactionKind.withdraw => '提出',
        TransactionKind.dividend => '股利',
        TransactionKind.adjust => '調整',
      };
}

@immutable
class Transaction {
  final String id;
  final TransactionAssetType assetType;
  final String assetId;
  final TransactionKind kind;
  final Decimal? quantity;
  final Decimal? price;

  /// Signed amount in [currency]. Positive = inflow, negative = outflow.
  final Decimal amount;
  final CurrencyCode currency;
  final DateTime occurredAt;
  final String? note;
  final DateTime createdAt;

  const Transaction({
    required this.id,
    required this.assetType,
    required this.assetId,
    required this.kind,
    this.quantity,
    this.price,
    required this.amount,
    required this.currency,
    required this.occurredAt,
    this.note,
    required this.createdAt,
  });
}
