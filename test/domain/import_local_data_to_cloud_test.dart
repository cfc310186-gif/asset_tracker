import 'dart:async';

import 'package:asset_tracker/domain/enums/currency_code.dart';
import 'package:asset_tracker/domain/enums/loan_type.dart';
import 'package:asset_tracker/domain/enums/market_code.dart';
import 'package:asset_tracker/domain/models/cash_account.dart';
import 'package:asset_tracker/domain/models/exchange_rate.dart';
import 'package:asset_tracker/domain/models/loan.dart';
import 'package:asset_tracker/domain/models/net_worth_snapshot.dart';
import 'package:asset_tracker/domain/models/real_estate_asset.dart';
import 'package:asset_tracker/domain/models/stock_holding.dart';
import 'package:asset_tracker/domain/models/transaction.dart';
import 'package:asset_tracker/domain/repositories/cash_repository.dart';
import 'package:asset_tracker/domain/repositories/exchange_rate_repository.dart';
import 'package:asset_tracker/domain/repositories/loan_repository.dart';
import 'package:asset_tracker/domain/repositories/net_worth_snapshot_repository.dart';
import 'package:asset_tracker/domain/repositories/real_estate_repository.dart';
import 'package:asset_tracker/domain/repositories/stock_repository.dart';
import 'package:asset_tracker/domain/repositories/transaction_repository.dart';
import 'package:asset_tracker/domain/usecases/import_local_data_to_cloud.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('imports local data idempotently and preserves linked loan ids',
      () async {
    final now = DateTime(2026, 5, 2, 12);
    final stock = StockHolding(
      id: 'stock-1',
      symbol: '2330',
      market: MarketCode.taiwan,
      name: '台積電',
      quantity: 10,
      avgCost: Decimal.fromInt(200),
      currency: CurrencyCode.twd,
      isMargin: true,
      marginAmount: Decimal.fromInt(1200),
      linkedLoanId: 'loan-1',
      createdAt: now,
      updatedAt: now,
    );
    final realEstate = RealEstateAsset(
      id: 'home-1',
      name: '台北住宅',
      address: 'Taipei',
      estimatedValue: Decimal.fromInt(10000000),
      purchasePrice: Decimal.fromInt(8000000),
      purchaseDate: '2020-01-01',
      currency: CurrencyCode.twd,
      hasMortgage: true,
      linkedLoanId: 'loan-2',
      createdAt: now,
      updatedAt: now,
    );
    final stockLoan = Loan(
      id: 'loan-1',
      type: LoanType.stockMarginLoan,
      name: '2330 融資',
      principal: Decimal.fromInt(1200),
      remainingBalance: Decimal.fromInt(1200),
      interestRate: Decimal.zero,
      termMonths: 0,
      monthlyPayment: Decimal.zero,
      currency: CurrencyCode.twd,
      hasGracePeriod: false,
      startDate: '2026-05-02',
      sourceType: 'stock',
      sourceId: 'stock-1',
      createdAt: now,
      updatedAt: now,
    );
    final mortgage = stockLoan.copyWith(
      id: 'loan-2',
      type: LoanType.mortgage,
      name: '台北住宅 房貸',
      sourceType: 'real_estate',
      sourceId: 'home-1',
    );

    final localStocks = _StockRepo([stock]);
    final cloudStocks = _StockRepo();
    final localRealEstate = _RealEstateRepo([realEstate]);
    final cloudRealEstate = _RealEstateRepo();
    final localLoans = _LoanRepo([stockLoan, mortgage]);
    final cloudLoans = _LoanRepo();

    final useCase = ImportLocalDataToCloud(
      localStockRepo: localStocks,
      cloudStockRepo: cloudStocks,
      localCashRepo: _CashRepo(),
      cloudCashRepo: _CashRepo(),
      localRealEstateRepo: localRealEstate,
      cloudRealEstateRepo: cloudRealEstate,
      localLoanRepo: localLoans,
      cloudLoanRepo: cloudLoans,
      localTransactionRepo: _TransactionRepo(),
      cloudTransactionRepo: _TransactionRepo(),
      localSnapshotRepo: _SnapshotRepo(),
      cloudSnapshotRepo: _SnapshotRepo(),
      localExchangeRateRepo: _ExchangeRateRepo(),
      cloudExchangeRateRepo: _ExchangeRateRepo(),
    );

    final first = await useCase.execute();
    final second = await useCase.execute();

    expect(first.imported, 4);
    expect(first.failed, 0);
    expect(second.imported, 4);
    expect(cloudStocks.items, hasLength(1));
    expect(cloudStocks.items.single.linkedLoanId, 'loan-1');
    expect(cloudRealEstate.items, hasLength(1));
    expect(cloudRealEstate.items.single.linkedLoanId, 'loan-2');
    expect(cloudLoans.items, hasLength(2));
  });
}

class _StockRepo implements StockRepository {
  _StockRepo([List<StockHolding> seed = const []]) {
    for (final item in seed) {
      _items[item.id] = item;
    }
  }

  final Map<String, StockHolding> _items = {};
  List<StockHolding> get items => _items.values.toList();

  @override
  Future<void> delete(String id) async => _items.remove(id);

  @override
  Future<List<StockHolding>> getAll() async => items;

  @override
  Future<StockHolding?> getById(String id) async => _items[id];

  @override
  Future<void> save(StockHolding holding) async => _items[holding.id] = holding;

  @override
  Stream<List<StockHolding>> watchAll() => Stream.value(items);
}

class _RealEstateRepo implements RealEstateRepository {
  _RealEstateRepo([List<RealEstateAsset> seed = const []]) {
    for (final item in seed) {
      _items[item.id] = item;
    }
  }

  final Map<String, RealEstateAsset> _items = {};
  List<RealEstateAsset> get items => _items.values.toList();

  @override
  Future<void> delete(String id) async => _items.remove(id);

  @override
  Future<List<RealEstateAsset>> getAll() async => items;

  @override
  Future<RealEstateAsset?> getById(String id) async => _items[id];

  @override
  Future<void> save(RealEstateAsset asset) async => _items[asset.id] = asset;

  @override
  Stream<List<RealEstateAsset>> watchAll() => Stream.value(items);
}

class _LoanRepo implements LoanRepository {
  _LoanRepo([List<Loan> seed = const []]) {
    for (final item in seed) {
      _items[item.id] = item;
    }
  }

  final Map<String, Loan> _items = {};
  List<Loan> get items => _items.values.toList();

  @override
  Future<void> delete(String id) async => _items.remove(id);

  @override
  Future<List<Loan>> getAll() async => items;

  @override
  Future<Loan?> getById(String id) async => _items[id];

  @override
  Future<void> save(Loan loan) async => _items[loan.id] = loan;

  @override
  Stream<List<Loan>> watchAll() => Stream.value(items);
}

class _CashRepo implements CashRepository {
  final Map<String, CashAccount> _items = {};

  @override
  Future<void> delete(String id) async => _items.remove(id);

  @override
  Future<List<CashAccount>> getAll() async => _items.values.toList();

  @override
  Future<CashAccount?> getById(String id) async => _items[id];

  @override
  Future<void> save(CashAccount account) async => _items[account.id] = account;

  @override
  Stream<List<CashAccount>> watchAll() => Stream.value(_items.values.toList());
}

class _TransactionRepo implements TransactionRepository {
  final Map<String, Transaction> _items = {};

  @override
  Future<void> add(Transaction tx) async => _items[tx.id] = tx;

  @override
  Future<void> deleteByAsset(TransactionAssetType type, String assetId) async {
    _items.removeWhere(
      (_, tx) => tx.assetType == type && tx.assetId == assetId,
    );
  }

  @override
  Future<List<Transaction>> getAll() async => _items.values.toList();

  @override
  Stream<List<Transaction>> watchAll() => Stream.value(_items.values.toList());

  @override
  Stream<List<Transaction>> watchByAssetType(TransactionAssetType type) =>
      Stream.value(
        _items.values.where((tx) => tx.assetType == type).toList(),
      );

  @override
  Stream<List<Transaction>> watchByRange(DateTime from, DateTime to) =>
      Stream.value(
        _items.values
            .where(
              (tx) =>
                  !tx.occurredAt.isBefore(from) && tx.occurredAt.isBefore(to),
            )
            .toList(),
      );
}

class _SnapshotRepo implements NetWorthSnapshotRepository {
  final Map<String, NetWorthSnapshot> _items = {};

  @override
  Future<List<NetWorthSnapshot>> getAll() async => _items.values.toList();

  @override
  Future<void> upsert(NetWorthSnapshot snapshot) async =>
      _items[snapshot.id] = snapshot;

  @override
  Stream<List<NetWorthSnapshot>> watchAll() =>
      Stream.value(_items.values.toList());

  @override
  Stream<List<NetWorthSnapshot>> watchByCurrency(CurrencyCode currency) =>
      Stream.value(
        _items.values
            .where((snapshot) => snapshot.displayCurrency == currency)
            .toList(),
      );
}

class _ExchangeRateRepo implements ExchangeRateRepository {
  final Map<String, ExchangeRate> _items = {};

  @override
  Future<void> delete(String id) async => _items.remove(id);

  @override
  Future<List<ExchangeRate>> getAll() async => _items.values.toList();

  @override
  Future<ExchangeRate?> getById(String id) async => _items[id];

  @override
  Future<ExchangeRate?> getByPair(
    CurrencyCode from,
    CurrencyCode to,
  ) async {
    for (final rate in _items.values) {
      if (rate.fromCurrency == from && rate.toCurrency == to) {
        return rate;
      }
    }
    return null;
  }

  @override
  Future<void> save(ExchangeRate rate) async => _items[rate.id] = rate;

  @override
  Stream<List<ExchangeRate>> watchAll() => Stream.value(_items.values.toList());
}
