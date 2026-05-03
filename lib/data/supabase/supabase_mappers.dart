import 'dart:convert';

import 'package:decimal/decimal.dart';

import '../../domain/enums/currency_code.dart';
import '../../domain/enums/loan_type.dart';
import '../../domain/enums/market_code.dart';
import '../../domain/models/cash_account.dart';
import '../../domain/models/exchange_rate.dart';
import '../../domain/models/loan.dart';
import '../../domain/models/net_worth_snapshot.dart';
import '../../domain/models/real_estate_asset.dart';
import '../../domain/models/stock_holding.dart';
import '../../domain/models/transaction.dart';

typedef SupabaseRow = Map<String, dynamic>;

StockHolding stockHoldingFromSupabaseRow(SupabaseRow row) => StockHolding(
      id: _readString(row, 'id'),
      symbol: _readString(row, 'symbol'),
      market: _readEnum(MarketCode.values, row, 'market'),
      name: _readString(row, 'name'),
      quantity: _readInt(row, 'quantity'),
      avgCost: _readDecimal(row, 'avg_cost'),
      currency: _readEnum(CurrencyCode.values, row, 'currency'),
      isMargin: _readBool(row, 'is_margin'),
      marginAmount: _readNullableDecimal(row, 'margin_amount'),
      linkedLoanId: _readNullableString(row, 'linked_loan_id'),
      latestPrice: _readNullableDecimal(row, 'latest_price'),
      priceUpdatedAt: _readNullableDateTime(row, 'price_updated_at'),
      createdAt: _readDateTime(row, 'created_at'),
      updatedAt: _readDateTime(row, 'updated_at'),
    );

SupabaseRow stockHoldingToSupabaseRow(
  StockHolding holding, {
  required String userId,
}) =>
    {
      'id': holding.id,
      'user_id': userId,
      'symbol': holding.symbol,
      'market': holding.market.name,
      'name': holding.name,
      'quantity': holding.quantity,
      'avg_cost': holding.avgCost.toString(),
      'currency': holding.currency.name,
      'is_margin': holding.isMargin,
      'margin_amount': holding.marginAmount?.toString(),
      'linked_loan_id': holding.linkedLoanId,
      'latest_price': holding.latestPrice?.toString(),
      'price_updated_at': _writeNullableDateTime(holding.priceUpdatedAt),
      'created_at': holding.createdAt.toIso8601String(),
      'updated_at': holding.updatedAt.toIso8601String(),
    };

Loan loanFromSupabaseRow(SupabaseRow row) => Loan(
      id: _readString(row, 'id'),
      type: _readEnum(LoanType.values, row, 'type'),
      name: _readString(row, 'name'),
      principal: _readDecimal(row, 'principal'),
      remainingBalance: _readDecimal(row, 'remaining_balance'),
      interestRate: _readDecimal(row, 'interest_rate'),
      termMonths: _readInt(row, 'term_months'),
      monthlyPayment: _readDecimal(row, 'monthly_payment'),
      currency: _readEnum(CurrencyCode.values, row, 'currency'),
      hasGracePeriod: _readBool(row, 'has_grace_period'),
      gracePeriodMonths: _readNullableInt(row, 'grace_period_months'),
      gracePeriodEndDate: _readNullableDateString(row, 'grace_period_end_date'),
      startDate: _readDateString(row, 'start_date'),
      sourceType: _readString(row, 'source_type'),
      sourceId: _readNullableString(row, 'source_id'),
      createdAt: _readDateTime(row, 'created_at'),
      updatedAt: _readDateTime(row, 'updated_at'),
    );

SupabaseRow loanToSupabaseRow(
  Loan loan, {
  required String userId,
}) =>
    {
      'id': loan.id,
      'user_id': userId,
      'type': loan.type.name,
      'name': loan.name,
      'principal': loan.principal.toString(),
      'remaining_balance': loan.remainingBalance.toString(),
      'interest_rate': loan.interestRate.toString(),
      'term_months': loan.termMonths,
      'monthly_payment': loan.monthlyPayment.toString(),
      'currency': loan.currency.name,
      'has_grace_period': loan.hasGracePeriod,
      'grace_period_months': loan.gracePeriodMonths,
      'grace_period_end_date': loan.gracePeriodEndDate,
      'start_date': loan.startDate,
      'source_type': loan.sourceType,
      'source_id': loan.sourceId,
      'created_at': loan.createdAt.toIso8601String(),
      'updated_at': loan.updatedAt.toIso8601String(),
    };

NetWorthSnapshot netWorthSnapshotFromSupabaseRow(SupabaseRow row) {
  final rawBreakdown = _readJsonObject(row, 'breakdown');
  final breakdown = <String, Decimal>{
    for (final entry in rawBreakdown.entries)
      entry.key: Decimal.parse(entry.value.toString()),
  };

  return NetWorthSnapshot(
    id: _readString(row, 'id'),
    capturedAt: _readDateTime(row, 'captured_at'),
    displayCurrency:
        _readEnum(CurrencyCode.values, row, 'display_currency'),
    totalAssets: _readDecimal(row, 'total_assets'),
    totalLiabilities: _readDecimal(row, 'total_liabilities'),
    netWorth: _readDecimal(row, 'net_worth'),
    breakdown: breakdown,
    createdAt: _readDateTime(row, 'created_at'),
  );
}

SupabaseRow netWorthSnapshotToSupabaseRow(
  NetWorthSnapshot snapshot, {
  required String userId,
}) =>
    {
      'id': snapshot.id,
      'user_id': userId,
      'captured_at': snapshot.capturedAt.toIso8601String(),
      'display_currency': snapshot.displayCurrency.name,
      'total_assets': snapshot.totalAssets.toString(),
      'total_liabilities': snapshot.totalLiabilities.toString(),
      'net_worth': snapshot.netWorth.toString(),
      'breakdown': {
        for (final entry in snapshot.breakdown.entries)
          entry.key: entry.value.toString(),
      },
      'created_at': snapshot.createdAt.toIso8601String(),
    };

CashAccount cashAccountFromSupabaseRow(SupabaseRow row) => CashAccount(
      id: _readString(row, 'id'),
      name: _readString(row, 'name'),
      bankName: _readNullableString(row, 'bank_name'),
      balance: _readDecimal(row, 'balance'),
      currency: _readEnum(CurrencyCode.values, row, 'currency'),
      annualRate: _readNullableDecimal(row, 'annual_rate'),
      createdAt: _readDateTime(row, 'created_at'),
      updatedAt: _readDateTime(row, 'updated_at'),
    );

SupabaseRow cashAccountToSupabaseRow(
  CashAccount account, {
  required String userId,
}) =>
    {
      'id': account.id,
      'user_id': userId,
      'name': account.name,
      'bank_name': account.bankName,
      'balance': account.balance.toString(),
      'currency': account.currency.name,
      'annual_rate': account.annualRate?.toString(),
      'created_at': account.createdAt.toIso8601String(),
      'updated_at': account.updatedAt.toIso8601String(),
    };

RealEstateAsset realEstateAssetFromSupabaseRow(SupabaseRow row) =>
    RealEstateAsset(
      id: _readString(row, 'id'),
      name: _readString(row, 'name'),
      address: _readString(row, 'address'),
      estimatedValue: _readDecimal(row, 'estimated_value'),
      purchasePrice: _readDecimal(row, 'purchase_price'),
      purchaseDate: _readDateString(row, 'purchase_date'),
      currency: _readEnum(CurrencyCode.values, row, 'currency'),
      hasMortgage: _readBool(row, 'has_mortgage'),
      linkedLoanId: _readNullableString(row, 'linked_loan_id'),
      createdAt: _readDateTime(row, 'created_at'),
      updatedAt: _readDateTime(row, 'updated_at'),
    );

SupabaseRow realEstateAssetToSupabaseRow(
  RealEstateAsset asset, {
  required String userId,
}) =>
    {
      'id': asset.id,
      'user_id': userId,
      'name': asset.name,
      'address': asset.address,
      'estimated_value': asset.estimatedValue.toString(),
      'purchase_price': asset.purchasePrice.toString(),
      'purchase_date': asset.purchaseDate,
      'currency': asset.currency.name,
      'has_mortgage': asset.hasMortgage,
      'linked_loan_id': asset.linkedLoanId,
      'created_at': asset.createdAt.toIso8601String(),
      'updated_at': asset.updatedAt.toIso8601String(),
    };

Transaction transactionFromSupabaseRow(SupabaseRow row) => Transaction(
      id: _readString(row, 'id'),
      assetType: TransactionAssetType.fromKey(_readEnumKey(row, 'asset_type')),
      assetId: _readString(row, 'asset_id'),
      kind: TransactionKind.fromKey(_readEnumKey(row, 'kind')),
      quantity: _readNullableDecimal(row, 'quantity'),
      price: _readNullableDecimal(row, 'price'),
      amount: _readDecimal(row, 'amount'),
      currency: _readEnum(CurrencyCode.values, row, 'currency'),
      occurredAt: _readDateTime(row, 'occurred_at'),
      note: _readNullableString(row, 'note'),
      createdAt: _readDateTime(row, 'created_at'),
    );

SupabaseRow transactionToSupabaseRow(
  Transaction transaction, {
  required String userId,
}) =>
    {
      'id': transaction.id,
      'user_id': userId,
      'asset_type': transaction.assetType.storageKey,
      'asset_id': transaction.assetId,
      'kind': transaction.kind.storageKey,
      'quantity': transaction.quantity?.toString(),
      'price': transaction.price?.toString(),
      'amount': transaction.amount.toString(),
      'currency': transaction.currency.name,
      'occurred_at': transaction.occurredAt.toIso8601String(),
      'note': transaction.note,
      'created_at': transaction.createdAt.toIso8601String(),
    };

ExchangeRate exchangeRateFromSupabaseRow(SupabaseRow row) => ExchangeRate(
      id: _readString(row, 'id'),
      fromCurrency:
          _readEnum(CurrencyCode.values, row, 'from_currency'),
      toCurrency: _readEnum(CurrencyCode.values, row, 'to_currency'),
      rate: _readDecimal(row, 'rate'),
      fetchedAt: _readDateTime(row, 'fetched_at'),
    );

SupabaseRow exchangeRateToSupabaseRow(
  ExchangeRate rate, {
  required String userId,
}) =>
    {
      'id': rate.id,
      'user_id': userId,
      'from_currency': rate.fromCurrency.name,
      'to_currency': rate.toCurrency.name,
      'rate': rate.rate.toString(),
      'fetched_at': rate.fetchedAt.toIso8601String(),
    };

String _readString(SupabaseRow row, String field) {
  final value = row[field];
  if (value == null) {
    throw FormatException('Missing required Supabase field: $field');
  }
  return value.toString();
}

String _readEnumKey(SupabaseRow row, String field) =>
    _readString(row, field).trim().toLowerCase();

T _readEnum<T extends Enum>(List<T> values, SupabaseRow row, String field) {
  final key = _readEnumKey(row, field);
  for (final value in values) {
    if (value.name.toLowerCase() == key) return value;
  }
  throw FormatException('Invalid Supabase enum field: $field=$key');
}

String? _readNullableString(SupabaseRow row, String field) {
  final value = row[field];
  return value?.toString();
}

int _readInt(SupabaseRow row, String field) {
  final value = row[field];
  return value is int ? value : int.parse(value.toString());
}

int? _readNullableInt(SupabaseRow row, String field) {
  final value = row[field];
  if (value == null) return null;
  return value is int ? value : int.parse(value.toString());
}

bool _readBool(SupabaseRow row, String field) {
  final value = row[field];
  if (value is bool) return value;
  return bool.parse(value.toString());
}

Decimal _readDecimal(SupabaseRow row, String field) =>
    Decimal.parse(row[field].toString());

Decimal? _readNullableDecimal(SupabaseRow row, String field) {
  final value = row[field];
  return value == null ? null : Decimal.parse(value.toString());
}

DateTime _readDateTime(SupabaseRow row, String field) =>
    DateTime.parse(row[field].toString());

DateTime? _readNullableDateTime(SupabaseRow row, String field) {
  final value = row[field];
  return value == null ? null : DateTime.parse(value.toString());
}

String _readDateString(SupabaseRow row, String field) =>
    _toIsoDateString(row[field]);

String? _readNullableDateString(SupabaseRow row, String field) {
  final value = row[field];
  return value == null ? null : _toIsoDateString(value);
}

String _toIsoDateString(Object? value) {
  final text = value.toString();
  return DateTime.parse(text).toIso8601String().split('T').first;
}

String? _writeNullableDateTime(DateTime? value) => value?.toIso8601String();

Map<String, dynamic> _readJsonObject(SupabaseRow row, String field) {
  final value = row[field];
  if (value is Map<String, dynamic>) return value;
  if (value is Map) {
    return value.map((key, value) => MapEntry(key.toString(), value));
  }
  return jsonDecode(value.toString()) as Map<String, dynamic>;
}
