import 'package:decimal/decimal.dart';
import 'package:flutter/foundation.dart';

import '../enums/currency_code.dart';

@immutable
class RealEstateAsset {
  final String id;
  final String name;
  final String address;
  final Decimal estimatedValue;
  final Decimal purchasePrice;

  /// ISO date string, e.g. "2020-03-15"
  final String purchaseDate;
  final CurrencyCode currency;
  final bool hasMortgage;
  final String? linkedLoanId;
  final DateTime createdAt;
  final DateTime updatedAt;

  const RealEstateAsset({
    required this.id,
    required this.name,
    required this.address,
    required this.estimatedValue,
    required this.purchasePrice,
    required this.purchaseDate,
    required this.currency,
    required this.hasMortgage,
    this.linkedLoanId,
    required this.createdAt,
    required this.updatedAt,
  });

  Decimal get appreciationAmount => estimatedValue - purchasePrice;

  RealEstateAsset copyWith({
    String? id,
    String? name,
    String? address,
    Decimal? estimatedValue,
    Decimal? purchasePrice,
    String? purchaseDate,
    CurrencyCode? currency,
    bool? hasMortgage,
    Object? linkedLoanId = _sentinel,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return RealEstateAsset(
      id: id ?? this.id,
      name: name ?? this.name,
      address: address ?? this.address,
      estimatedValue: estimatedValue ?? this.estimatedValue,
      purchasePrice: purchasePrice ?? this.purchasePrice,
      purchaseDate: purchaseDate ?? this.purchaseDate,
      currency: currency ?? this.currency,
      hasMortgage: hasMortgage ?? this.hasMortgage,
      linkedLoanId: linkedLoanId == _sentinel
          ? this.linkedLoanId
          : linkedLoanId as String?,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

const Object _sentinel = Object();
