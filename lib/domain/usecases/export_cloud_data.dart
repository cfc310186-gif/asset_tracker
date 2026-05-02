import 'dart:convert';

import '../models/cash_account.dart';
import '../models/exchange_rate.dart';
import '../models/loan.dart';
import '../models/net_worth_snapshot.dart';
import '../models/real_estate_asset.dart';
import '../models/stock_holding.dart';
import '../models/transaction.dart';
import '../repositories/cash_repository.dart';
import '../repositories/exchange_rate_repository.dart';
import '../repositories/loan_repository.dart';
import '../repositories/net_worth_snapshot_repository.dart';
import '../repositories/real_estate_repository.dart';
import '../repositories/stock_repository.dart';
import '../repositories/transaction_repository.dart';

class ExportCloudData {
  const ExportCloudData({
    required StockRepository stockRepo,
    required CashRepository cashRepo,
    required RealEstateRepository realEstateRepo,
    required LoanRepository loanRepo,
    required TransactionRepository transactionRepo,
    required NetWorthSnapshotRepository snapshotRepo,
    required ExchangeRateRepository exchangeRateRepo,
  })  : _stockRepo = stockRepo,
        _cashRepo = cashRepo,
        _realEstateRepo = realEstateRepo,
        _loanRepo = loanRepo,
        _transactionRepo = transactionRepo,
        _snapshotRepo = snapshotRepo,
        _exchangeRateRepo = exchangeRateRepo;

  final StockRepository _stockRepo;
  final CashRepository _cashRepo;
  final RealEstateRepository _realEstateRepo;
  final LoanRepository _loanRepo;
  final TransactionRepository _transactionRepo;
  final NetWorthSnapshotRepository _snapshotRepo;
  final ExchangeRateRepository _exchangeRateRepo;

  Future<String> execute({DateTime? exportedAt}) async {
    final stocksFuture = _stockRepo.getAll();
    final cashFuture = _cashRepo.getAll();
    final realEstateFuture = _realEstateRepo.getAll();
    final loansFuture = _loanRepo.getAll();
    final transactionsFuture = _transactionRepo.getAll();
    final snapshotsFuture = _snapshotRepo.getAll();
    final exchangeRatesFuture = _exchangeRateRepo.getAll();

    final payload = {
      'schemaVersion': 1,
      'exportedAt': (exportedAt ?? DateTime.now()).toUtc().toIso8601String(),
      'stocks': (await stocksFuture).map(_stockToJson).toList(),
      'cashAccounts': (await cashFuture).map(_cashToJson).toList(),
      'loans': (await loansFuture).map(_loanToJson).toList(),
      'realEstateAssets':
          (await realEstateFuture).map(_realEstateToJson).toList(),
      'transactions':
          (await transactionsFuture).map(_transactionToJson).toList(),
      'netWorthSnapshots':
          (await snapshotsFuture).map(_snapshotToJson).toList(),
      'exchangeRates':
          (await exchangeRatesFuture).map(_exchangeRateToJson).toList(),
    };

    return const JsonEncoder.withIndent('  ').convert(payload);
  }

  Map<String, Object?> _stockToJson(StockHolding stock) => {
        'id': stock.id,
        'symbol': stock.symbol,
        'market': stock.market.name,
        'name': stock.name,
        'quantity': stock.quantity,
        'avgCost': stock.avgCost.toString(),
        'currency': stock.currency.name,
        'isMargin': stock.isMargin,
        'marginAmount': stock.marginAmount?.toString(),
        'linkedLoanId': stock.linkedLoanId,
        'latestPrice': stock.latestPrice?.toString(),
        'priceUpdatedAt': stock.priceUpdatedAt?.toIso8601String(),
        'createdAt': stock.createdAt.toIso8601String(),
        'updatedAt': stock.updatedAt.toIso8601String(),
      };

  Map<String, Object?> _cashToJson(CashAccount account) => {
        'id': account.id,
        'name': account.name,
        'bankName': account.bankName,
        'balance': account.balance.toString(),
        'currency': account.currency.name,
        'annualRate': account.annualRate?.toString(),
        'createdAt': account.createdAt.toIso8601String(),
        'updatedAt': account.updatedAt.toIso8601String(),
      };

  Map<String, Object?> _loanToJson(Loan loan) => {
        'id': loan.id,
        'type': loan.type.name,
        'name': loan.name,
        'principal': loan.principal.toString(),
        'remainingBalance': loan.remainingBalance.toString(),
        'interestRate': loan.interestRate.toString(),
        'termMonths': loan.termMonths,
        'monthlyPayment': loan.monthlyPayment.toString(),
        'currency': loan.currency.name,
        'hasGracePeriod': loan.hasGracePeriod,
        'gracePeriodMonths': loan.gracePeriodMonths,
        'gracePeriodEndDate': loan.gracePeriodEndDate,
        'startDate': loan.startDate,
        'sourceType': loan.sourceType,
        'sourceId': loan.sourceId,
        'createdAt': loan.createdAt.toIso8601String(),
        'updatedAt': loan.updatedAt.toIso8601String(),
      };

  Map<String, Object?> _realEstateToJson(RealEstateAsset asset) => {
        'id': asset.id,
        'name': asset.name,
        'address': asset.address,
        'estimatedValue': asset.estimatedValue.toString(),
        'purchasePrice': asset.purchasePrice.toString(),
        'purchaseDate': asset.purchaseDate,
        'currency': asset.currency.name,
        'hasMortgage': asset.hasMortgage,
        'linkedLoanId': asset.linkedLoanId,
        'createdAt': asset.createdAt.toIso8601String(),
        'updatedAt': asset.updatedAt.toIso8601String(),
      };

  Map<String, Object?> _transactionToJson(Transaction tx) => {
        'id': tx.id,
        'assetType': tx.assetType.storageKey,
        'assetId': tx.assetId,
        'kind': tx.kind.storageKey,
        'quantity': tx.quantity?.toString(),
        'price': tx.price?.toString(),
        'amount': tx.amount.toString(),
        'currency': tx.currency.name,
        'occurredAt': tx.occurredAt.toIso8601String(),
        'note': tx.note,
        'createdAt': tx.createdAt.toIso8601String(),
      };

  Map<String, Object?> _snapshotToJson(NetWorthSnapshot snapshot) => {
        'id': snapshot.id,
        'capturedAt': snapshot.capturedAt.toIso8601String(),
        'displayCurrency': snapshot.displayCurrency.name,
        'totalAssets': snapshot.totalAssets.toString(),
        'totalLiabilities': snapshot.totalLiabilities.toString(),
        'netWorth': snapshot.netWorth.toString(),
        'breakdown': {
          for (final entry in snapshot.breakdown.entries)
            entry.key: entry.value.toString(),
        },
        'createdAt': snapshot.createdAt.toIso8601String(),
      };

  Map<String, Object?> _exchangeRateToJson(ExchangeRate rate) => {
        'id': rate.id,
        'fromCurrency': rate.fromCurrency.name,
        'toCurrency': rate.toCurrency.name,
        'rate': rate.rate.toString(),
        'fetchedAt': rate.fetchedAt.toIso8601String(),
      };
}
