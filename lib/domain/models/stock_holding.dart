import 'package:decimal/decimal.dart';
import 'package:flutter/foundation.dart';

import '../enums/currency_code.dart';
import '../enums/market_code.dart';

@immutable
class StockHolding {
  final String id;
  final String symbol;
  final MarketCode market;
  final String name;
  final int quantity;
  final Decimal avgCost;
  final CurrencyCode currency;
  final bool isMargin;
  final Decimal? marginAmount;
  final String? linkedLoanId;
  final Decimal? latestPrice;
  final DateTime? priceUpdatedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  const StockHolding({
    required this.id,
    required this.symbol,
    required this.market,
    required this.name,
    required this.quantity,
    required this.avgCost,
    required this.currency,
    required this.isMargin,
    this.marginAmount,
    this.linkedLoanId,
    this.latestPrice,
    this.priceUpdatedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  Decimal get totalValue => latestPrice != null
      ? latestPrice! * Decimal.fromInt(quantity)
      : avgCost * Decimal.fromInt(quantity);

  Decimal get totalCost => avgCost * Decimal.fromInt(quantity);

  Decimal get unrealizedGain =>
      latestPrice != null ? totalValue - totalCost : Decimal.zero;

  StockHolding copyWith({
    String? id,
    String? symbol,
    MarketCode? market,
    String? name,
    int? quantity,
    Decimal? avgCost,
    CurrencyCode? currency,
    bool? isMargin,
    Object? marginAmount = _sentinel,
    Object? linkedLoanId = _sentinel,
    Object? latestPrice = _sentinel,
    Object? priceUpdatedAt = _sentinel,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return StockHolding(
      id: id ?? this.id,
      symbol: symbol ?? this.symbol,
      market: market ?? this.market,
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      avgCost: avgCost ?? this.avgCost,
      currency: currency ?? this.currency,
      isMargin: isMargin ?? this.isMargin,
      marginAmount: marginAmount == _sentinel
          ? this.marginAmount
          : marginAmount as Decimal?,
      linkedLoanId: linkedLoanId == _sentinel
          ? this.linkedLoanId
          : linkedLoanId as String?,
      latestPrice: latestPrice == _sentinel
          ? this.latestPrice
          : latestPrice as Decimal?,
      priceUpdatedAt: priceUpdatedAt == _sentinel
          ? this.priceUpdatedAt
          : priceUpdatedAt as DateTime?,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

// Sentinel object used to distinguish "not provided" from explicit null in copyWith.
const Object _sentinel = Object();
