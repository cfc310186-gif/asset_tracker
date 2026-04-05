import 'package:decimal/decimal.dart';
import 'package:flutter/foundation.dart';

import '../enums/currency_code.dart';

@immutable
class CashAccount {
  final String id;
  final String name;
  final String? bankName;
  final Decimal balance;
  final CurrencyCode currency;
  final DateTime createdAt;
  final DateTime updatedAt;

  const CashAccount({
    required this.id,
    required this.name,
    this.bankName,
    required this.balance,
    required this.currency,
    required this.createdAt,
    required this.updatedAt,
  });

  CashAccount copyWith({
    String? id,
    String? name,
    Object? bankName = _sentinel,
    Decimal? balance,
    CurrencyCode? currency,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CashAccount(
      id: id ?? this.id,
      name: name ?? this.name,
      bankName:
          bankName == _sentinel ? this.bankName : bankName as String?,
      balance: balance ?? this.balance,
      currency: currency ?? this.currency,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

const Object _sentinel = Object();
