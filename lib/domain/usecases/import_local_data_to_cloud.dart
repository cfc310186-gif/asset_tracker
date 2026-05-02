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

class ImportLocalDataToCloud {
  const ImportLocalDataToCloud({
    required StockRepository localStockRepo,
    required StockRepository cloudStockRepo,
    required CashRepository localCashRepo,
    required CashRepository cloudCashRepo,
    required RealEstateRepository localRealEstateRepo,
    required RealEstateRepository cloudRealEstateRepo,
    required LoanRepository localLoanRepo,
    required LoanRepository cloudLoanRepo,
    required TransactionRepository localTransactionRepo,
    required TransactionRepository cloudTransactionRepo,
    required NetWorthSnapshotRepository localSnapshotRepo,
    required NetWorthSnapshotRepository cloudSnapshotRepo,
    required ExchangeRateRepository localExchangeRateRepo,
    required ExchangeRateRepository cloudExchangeRateRepo,
  })  : _localStockRepo = localStockRepo,
        _cloudStockRepo = cloudStockRepo,
        _localCashRepo = localCashRepo,
        _cloudCashRepo = cloudCashRepo,
        _localRealEstateRepo = localRealEstateRepo,
        _cloudRealEstateRepo = cloudRealEstateRepo,
        _localLoanRepo = localLoanRepo,
        _cloudLoanRepo = cloudLoanRepo,
        _localTransactionRepo = localTransactionRepo,
        _cloudTransactionRepo = cloudTransactionRepo,
        _localSnapshotRepo = localSnapshotRepo,
        _cloudSnapshotRepo = cloudSnapshotRepo,
        _localExchangeRateRepo = localExchangeRateRepo,
        _cloudExchangeRateRepo = cloudExchangeRateRepo;

  final StockRepository _localStockRepo;
  final StockRepository _cloudStockRepo;
  final CashRepository _localCashRepo;
  final CashRepository _cloudCashRepo;
  final RealEstateRepository _localRealEstateRepo;
  final RealEstateRepository _cloudRealEstateRepo;
  final LoanRepository _localLoanRepo;
  final LoanRepository _cloudLoanRepo;
  final TransactionRepository _localTransactionRepo;
  final TransactionRepository _cloudTransactionRepo;
  final NetWorthSnapshotRepository _localSnapshotRepo;
  final NetWorthSnapshotRepository _cloudSnapshotRepo;
  final ExchangeRateRepository _localExchangeRateRepo;
  final ExchangeRateRepository _cloudExchangeRateRepo;

  Future<CloudImportResult> execute() async {
    final result = CloudImportResult();

    await _importStocks(result);
    await _importCashAccounts(result);
    await _importRealEstateAssets(result);
    await _importLoans(result);
    await _importTransactions(result);
    await _importSnapshots(result);
    await _importExchangeRates(result);

    return result;
  }

  Future<void> _importStocks(CloudImportResult result) async {
    final rows = await _localStockRepo.getAll();
    await _importEach<StockHolding>(
      rows,
      result.stocks,
      (stock) => _cloudStockRepo.save(stock),
    );
  }

  Future<void> _importCashAccounts(CloudImportResult result) async {
    final rows = await _localCashRepo.getAll();
    await _importEach<CashAccount>(
      rows,
      result.cashAccounts,
      (account) => _cloudCashRepo.save(account),
    );
  }

  Future<void> _importRealEstateAssets(CloudImportResult result) async {
    final rows = await _localRealEstateRepo.getAll();
    await _importEach<RealEstateAsset>(
      rows,
      result.realEstateAssets,
      (asset) => _cloudRealEstateRepo.save(asset),
    );
  }

  Future<void> _importLoans(CloudImportResult result) async {
    final rows = await _localLoanRepo.getAll();
    await _importEach<Loan>(
      rows,
      result.loans,
      (loan) => _cloudLoanRepo.save(loan),
    );
  }

  Future<void> _importTransactions(CloudImportResult result) async {
    final rows = await _localTransactionRepo.getAll();
    await _importEach<Transaction>(
      rows,
      result.transactions,
      (tx) => _cloudTransactionRepo.add(tx),
    );
  }

  Future<void> _importSnapshots(CloudImportResult result) async {
    final rows = await _localSnapshotRepo.getAll();
    await _importEach<NetWorthSnapshot>(
      rows,
      result.netWorthSnapshots,
      (snapshot) => _cloudSnapshotRepo.upsert(snapshot),
    );
  }

  Future<void> _importExchangeRates(CloudImportResult result) async {
    final rows = await _localExchangeRateRepo.getAll();
    await _importEach<ExchangeRate>(
      rows,
      result.exchangeRates,
      (rate) => _cloudExchangeRateRepo.save(rate),
    );
  }

  Future<void> _importEach<T>(
    List<T> rows,
    CloudImportCategoryResult category,
    Future<void> Function(T row) save,
  ) async {
    for (final row in rows) {
      try {
        await save(row);
        category.imported += 1;
      } on Exception catch (e) {
        category.failed += 1;
        category.errors.add(e.toString());
      }
    }
  }
}

class CloudImportResult {
  final stocks = CloudImportCategoryResult('股票');
  final cashAccounts = CloudImportCategoryResult('現金');
  final realEstateAssets = CloudImportCategoryResult('不動產');
  final loans = CloudImportCategoryResult('貸款');
  final transactions = CloudImportCategoryResult('交易');
  final netWorthSnapshots = CloudImportCategoryResult('淨資產快照');
  final exchangeRates = CloudImportCategoryResult('匯率');

  List<CloudImportCategoryResult> get categories => [
        stocks,
        cashAccounts,
        realEstateAssets,
        loans,
        transactions,
        netWorthSnapshots,
        exchangeRates,
      ];

  int get imported =>
      categories.fold(0, (total, category) => total + category.imported);

  int get failed =>
      categories.fold(0, (total, category) => total + category.failed);

  bool get hasFailures => failed > 0;

  String get summaryText {
    final importedText = '匯入 $imported 筆';
    if (!hasFailures) return importedText;
    return '$importedText，失敗 $failed 筆';
  }
}

class CloudImportCategoryResult {
  CloudImportCategoryResult(this.label);

  final String label;
  int imported = 0;
  int failed = 0;
  final List<String> errors = [];
}
