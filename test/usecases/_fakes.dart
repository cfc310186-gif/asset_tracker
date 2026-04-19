import 'package:asset_tracker/domain/enums/currency_code.dart';
import 'package:asset_tracker/domain/models/cash_account.dart';
import 'package:asset_tracker/domain/models/exchange_rate.dart';
import 'package:asset_tracker/domain/models/loan.dart';
import 'package:asset_tracker/domain/models/net_worth_snapshot.dart';
import 'package:asset_tracker/domain/models/real_estate_asset.dart';
import 'package:asset_tracker/domain/models/stock_holding.dart';
import 'package:asset_tracker/domain/repositories/cash_repository.dart';
import 'package:asset_tracker/domain/repositories/exchange_rate_repository.dart';
import 'package:asset_tracker/domain/repositories/loan_repository.dart';
import 'package:asset_tracker/domain/repositories/net_worth_snapshot_repository.dart';
import 'package:asset_tracker/domain/repositories/real_estate_repository.dart';
import 'package:asset_tracker/domain/repositories/stock_repository.dart';

class FakeStockRepository implements StockRepository {
  FakeStockRepository([List<StockHolding>? items]) : items = items ?? [];
  final List<StockHolding> items;

  @override
  Future<List<StockHolding>> getAll() async => List.unmodifiable(items);

  @override
  Stream<List<StockHolding>> watchAll() => Stream.value(items);

  @override
  Future<StockHolding?> getById(String id) async =>
      items.where((s) => s.id == id).firstOrNull;

  @override
  Future<void> save(StockHolding holding) async {
    items.removeWhere((s) => s.id == holding.id);
    items.add(holding);
  }

  @override
  Future<void> delete(String id) async =>
      items.removeWhere((s) => s.id == id);
}

class FakeRealEstateRepository implements RealEstateRepository {
  FakeRealEstateRepository([List<RealEstateAsset>? items])
      : items = items ?? [];
  final List<RealEstateAsset> items;

  @override
  Future<List<RealEstateAsset>> getAll() async => List.unmodifiable(items);

  @override
  Stream<List<RealEstateAsset>> watchAll() => Stream.value(items);

  @override
  Future<RealEstateAsset?> getById(String id) async =>
      items.where((s) => s.id == id).firstOrNull;

  @override
  Future<void> save(RealEstateAsset asset) async {
    items.removeWhere((s) => s.id == asset.id);
    items.add(asset);
  }

  @override
  Future<void> delete(String id) async =>
      items.removeWhere((s) => s.id == id);
}

class FakeLoanRepository implements LoanRepository {
  FakeLoanRepository([List<Loan>? items]) : items = items ?? [];
  final List<Loan> items;

  @override
  Future<List<Loan>> getAll() async => List.unmodifiable(items);

  @override
  Stream<List<Loan>> watchAll() => Stream.value(items);

  @override
  Future<Loan?> getById(String id) async =>
      items.where((s) => s.id == id).firstOrNull;

  @override
  Future<void> save(Loan loan) async {
    items.removeWhere((s) => s.id == loan.id);
    items.add(loan);
  }

  @override
  Future<void> delete(String id) async =>
      items.removeWhere((s) => s.id == id);
}

class FakeCashRepository implements CashRepository {
  FakeCashRepository([List<CashAccount>? items]) : items = items ?? [];
  final List<CashAccount> items;

  @override
  Future<List<CashAccount>> getAll() async => List.unmodifiable(items);

  @override
  Stream<List<CashAccount>> watchAll() => Stream.value(items);

  @override
  Future<CashAccount?> getById(String id) async =>
      items.where((s) => s.id == id).firstOrNull;

  @override
  Future<void> save(CashAccount account) async {
    items.removeWhere((s) => s.id == account.id);
    items.add(account);
  }

  @override
  Future<void> delete(String id) async =>
      items.removeWhere((s) => s.id == id);
}

class FakeExchangeRateRepository implements ExchangeRateRepository {
  FakeExchangeRateRepository([List<ExchangeRate>? items])
      : items = items ?? [];
  final List<ExchangeRate> items;

  @override
  Future<List<ExchangeRate>> getAll() async => List.unmodifiable(items);

  @override
  Stream<List<ExchangeRate>> watchAll() => Stream.value(items);

  @override
  Future<ExchangeRate?> getById(String id) async =>
      items.where((s) => s.id == id).firstOrNull;

  @override
  Future<ExchangeRate?> getByPair(CurrencyCode from, CurrencyCode to) async =>
      items
          .where((r) => r.fromCurrency == from && r.toCurrency == to)
          .firstOrNull;

  @override
  Future<void> save(ExchangeRate rate) async {
    items.removeWhere((r) => r.id == rate.id);
    items.add(rate);
  }

  @override
  Future<void> delete(String id) async =>
      items.removeWhere((r) => r.id == id);
}

class FakeSnapshotRepository implements NetWorthSnapshotRepository {
  final List<NetWorthSnapshot> stored = [];

  @override
  Future<List<NetWorthSnapshot>> getAll() async => List.unmodifiable(stored);

  @override
  Stream<List<NetWorthSnapshot>> watchAll() => Stream.value(stored);

  @override
  Stream<List<NetWorthSnapshot>> watchByCurrency(CurrencyCode currency) =>
      Stream.value(
          stored.where((s) => s.displayCurrency == currency).toList());

  @override
  Future<void> upsert(NetWorthSnapshot snapshot) async {
    stored.removeWhere((s) =>
        s.capturedAt == snapshot.capturedAt &&
        s.displayCurrency == snapshot.displayCurrency);
    stored.add(snapshot);
  }
}

extension _FirstOrNull<E> on Iterable<E> {
  E? get firstOrNull => isEmpty ? null : first;
}
