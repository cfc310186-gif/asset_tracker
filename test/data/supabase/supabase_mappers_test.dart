import 'package:asset_tracker/data/supabase/supabase_mappers.dart';
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
import 'package:decimal/decimal.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Supabase stock holding mapper', () {
    test('throws when a required string field is null or missing', () {
      final row = _stockRow();

      expect(
        () => stockHoldingFromSupabaseRow({...row, 'id': null}),
        throwsA(
          isA<FormatException>().having(
            (error) => error.message,
            'message',
            'Missing required Supabase field: id',
          ),
        ),
      );

      final missingSymbolRow = {...row}..remove('symbol');
      expect(
        () => stockHoldingFromSupabaseRow(missingSymbolRow),
        throwsA(
          isA<FormatException>().having(
            (error) => error.message,
            'message',
            'Missing required Supabase field: symbol',
          ),
        ),
      );
    });

    test('round-trips a stock holding with margin fields', () {
      final createdAt = DateTime.utc(2026, 5, 1, 10, 30);
      final updatedAt = DateTime.utc(2026, 5, 2, 11, 45);
      final priceUpdatedAt = DateTime.utc(2026, 5, 2, 9, 15);
      final holding = StockHolding(
        id: '11111111-1111-1111-1111-111111111111',
        symbol: '2330',
        market: MarketCode.taiwan,
        name: 'TSMC',
        quantity: 1000,
        avgCost: Decimal.parse('610.25'),
        currency: CurrencyCode.twd,
        isMargin: true,
        marginAmount: Decimal.parse('120000.50'),
        linkedLoanId: '22222222-2222-2222-2222-222222222222',
        latestPrice: Decimal.parse('789.10'),
        priceUpdatedAt: priceUpdatedAt,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );

      final row = stockHoldingToSupabaseRow(
        holding,
        userId: '33333333-3333-3333-3333-333333333333',
      );

      expect(row, {
        'id': holding.id,
        'user_id': '33333333-3333-3333-3333-333333333333',
        'symbol': '2330',
        'market': 'taiwan',
        'name': 'TSMC',
        'quantity': 1000,
        'avg_cost': '610.25',
        'currency': 'twd',
        'is_margin': true,
        'margin_amount': '120000.5',
        'linked_loan_id': '22222222-2222-2222-2222-222222222222',
        'latest_price': '789.1',
        'price_updated_at': priceUpdatedAt.toIso8601String(),
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      });

      final mapped = stockHoldingFromSupabaseRow(row);

      expect(mapped.id, holding.id);
      expect(mapped.market, MarketCode.taiwan);
      expect(mapped.avgCost, Decimal.parse('610.25'));
      expect(mapped.isMargin, isTrue);
      expect(mapped.marginAmount, Decimal.parse('120000.50'));
      expect(mapped.linkedLoanId, '22222222-2222-2222-2222-222222222222');
      expect(mapped.latestPrice, Decimal.parse('789.10'));
      expect(mapped.priceUpdatedAt, priceUpdatedAt);
    });

    test('reads enum fields case-insensitively', () {
      final mapped = stockHoldingFromSupabaseRow({
        ..._stockRow(),
        'market': 'TAIWAN',
        'currency': 'TWD',
      });

      expect(mapped.market, MarketCode.taiwan);
      expect(mapped.currency, CurrencyCode.twd);
    });
  });

  group('Supabase loan mapper', () {
    test('round-trips grace period fields and allows termMonths zero', () {
      final createdAt = DateTime.utc(2026, 1, 1, 8);
      final updatedAt = DateTime.utc(2026, 2, 1, 8);
      final loan = Loan(
        id: '44444444-4444-4444-4444-444444444444',
        type: LoanType.stockMarginLoan,
        name: 'Margin facility',
        principal: Decimal.parse('500000'),
        remainingBalance: Decimal.parse('250000.75'),
        interestRate: Decimal.parse('0.0285'),
        termMonths: 0,
        monthlyPayment: Decimal.parse('0'),
        currency: CurrencyCode.twd,
        hasGracePeriod: true,
        gracePeriodMonths: 6,
        gracePeriodEndDate: '2026-08-01',
        startDate: '2026-02-01',
        sourceType: 'stock',
        sourceId: '55555555-5555-5555-5555-555555555555',
        createdAt: createdAt,
        updatedAt: updatedAt,
      );

      final row = loanToSupabaseRow(
        loan,
        userId: '33333333-3333-3333-3333-333333333333',
      );

      expect(row['term_months'], 0);
      expect(row['grace_period_months'], 6);
      expect(row['grace_period_end_date'], '2026-08-01');
      expect(row['principal'], '500000');
      expect(row['remaining_balance'], '250000.75');
      expect(row['interest_rate'], '0.0285');
      expect(row['monthly_payment'], '0');

      final mapped = loanFromSupabaseRow(row);

      expect(mapped.type, LoanType.stockMarginLoan);
      expect(mapped.termMonths, 0);
      expect(mapped.hasGracePeriod, isTrue);
      expect(mapped.gracePeriodMonths, 6);
      expect(mapped.gracePeriodEndDate, '2026-08-01');
      expect(mapped.startDate, '2026-02-01');
      expect(mapped.monthlyPayment, Decimal.zero);
    });
  });

  group('Supabase net worth snapshot mapper', () {
    test('writes breakdown as strings and reads breakdown as decimals', () {
      final capturedAt = DateTime.utc(2026, 5, 2);
      final createdAt = DateTime.utc(2026, 5, 2, 1);
      final snapshot = NetWorthSnapshot(
        id: '66666666-6666-6666-6666-666666666666',
        capturedAt: capturedAt,
        displayCurrency: CurrencyCode.usd,
        totalAssets: Decimal.parse('1250.10'),
        totalLiabilities: Decimal.parse('300.05'),
        netWorth: Decimal.parse('950.05'),
        breakdown: {
          'stock': Decimal.parse('1000.10'),
          'cash': Decimal.parse('250'),
          'loan': Decimal.parse('300.05'),
        },
        createdAt: createdAt,
      );

      final row = netWorthSnapshotToSupabaseRow(
        snapshot,
        userId: '33333333-3333-3333-3333-333333333333',
      );

      expect(row['breakdown'], {
        'stock': '1000.1',
        'cash': '250',
        'loan': '300.05',
      });

      final mapped = netWorthSnapshotFromSupabaseRow(row);

      expect(mapped.displayCurrency, CurrencyCode.usd);
      expect(mapped.totalAssets, Decimal.parse('1250.10'));
      expect(mapped.totalLiabilities, Decimal.parse('300.05'));
      expect(mapped.netWorth, Decimal.parse('950.05'));
      expect(mapped.breakdown, {
        'stock': Decimal.parse('1000.10'),
        'cash': Decimal.parse('250'),
        'loan': Decimal.parse('300.05'),
      });
    });

    test('reads jsonb breakdown returned as a dynamic map', () {
      final mapped = netWorthSnapshotFromSupabaseRow({
        'id': '66666666-6666-6666-6666-666666666666',
        'captured_at': DateTime.utc(2026, 5, 2).toIso8601String(),
        'display_currency': 'usd',
        'total_assets': 1250.10,
        'total_liabilities': 300,
        'net_worth': '950.10',
        'breakdown': <dynamic, dynamic>{
          'stock': 1000.10,
          'cash': 250,
          'loan': '300.00',
        },
        'created_at': DateTime.utc(2026, 5, 2, 1).toIso8601String(),
      });

      expect(mapped.totalAssets, Decimal.parse('1250.1'));
      expect(mapped.totalLiabilities, Decimal.parse('300'));
      expect(mapped.netWorth, Decimal.parse('950.10'));
      expect(mapped.breakdown, {
        'stock': Decimal.parse('1000.1'),
        'cash': Decimal.parse('250'),
        'loan': Decimal.parse('300.00'),
      });
    });
  });

  group('Supabase cash account mapper', () {
    test('round-trips nullable fields and numeric row shapes', () {
      final createdAt = DateTime.utc(2026, 3, 1, 9);
      final updatedAt = DateTime.utc(2026, 3, 2, 10);
      final account = CashAccount(
        id: '77777777-7777-7777-7777-777777777777',
        name: 'Emergency fund',
        bankName: null,
        balance: Decimal.parse('1000.50'),
        currency: CurrencyCode.usd,
        annualRate: null,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );

      final row = cashAccountToSupabaseRow(
        account,
        userId: '33333333-3333-3333-3333-333333333333',
      );

      expect(row['bank_name'], isNull);
      expect(row['annual_rate'], isNull);
      expect(row['balance'], '1000.5');

      final mapped = cashAccountFromSupabaseRow({
        ...row,
        'balance': 1000,
        'annual_rate': 0.015,
      });

      expect(mapped.bankName, isNull);
      expect(mapped.balance, Decimal.parse('1000'));
      expect(mapped.annualRate, Decimal.parse('0.015'));
    });
  });

  group('Supabase real estate asset mapper', () {
    test('writes cloud-safe defaults for hidden legacy fields', () {
      final createdAt = DateTime.utc(2026, 5, 4, 9);
      final updatedAt = DateTime.utc(2026, 5, 4, 10);
      final asset = RealEstateAsset(
        id: '88888888-8888-8888-8888-888888888888',
        name: 'Hidden fields home',
        address: '',
        estimatedValue: Decimal.parse('9000000'),
        purchasePrice: Decimal.parse('7500000'),
        purchaseDate: '',
        currency: CurrencyCode.twd,
        hasMortgage: false,
        linkedLoanId: null,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );

      final row = realEstateAssetToSupabaseRow(
        asset,
        userId: '33333333-3333-3333-3333-333333333333',
      );

      expect(row['address'], '-');
      expect(row['purchase_date'], '2026-05-04');
    });

    test('reads legacy rows with missing hidden fields', () {
      final mapped = realEstateAssetFromSupabaseRow({
        'id': '88888888-8888-8888-8888-888888888888',
        'name': 'Legacy home',
        'estimated_value': 9000000,
        'purchase_price': 7500000,
        'currency': 'twd',
        'linked_loan_id': null,
        'created_at': DateTime.utc(2026, 5, 4, 9).toIso8601String(),
        'updated_at': DateTime.utc(2026, 5, 4, 10).toIso8601String(),
      });

      expect(mapped.address, '');
      expect(mapped.purchaseDate, '2026-05-04');
      expect(mapped.hasMortgage, isFalse);
    });

    test('round-trips nullable loan link and numeric row shapes', () {
      final createdAt = DateTime.utc(2026, 4, 1, 9);
      final updatedAt = DateTime.utc(2026, 4, 2, 10);
      final asset = RealEstateAsset(
        id: '88888888-8888-8888-8888-888888888888',
        name: 'Home',
        address: '1 Main St',
        estimatedValue: Decimal.parse('9000000'),
        purchasePrice: Decimal.parse('7500000.25'),
        purchaseDate: '2020-03-15',
        currency: CurrencyCode.twd,
        hasMortgage: false,
        linkedLoanId: null,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );

      final row = realEstateAssetToSupabaseRow(
        asset,
        userId: '33333333-3333-3333-3333-333333333333',
      );

      expect(row['linked_loan_id'], isNull);
      expect(row['estimated_value'], '9000000');
      expect(row['purchase_price'], '7500000.25');

      final mapped = realEstateAssetFromSupabaseRow({
        ...row,
        'estimated_value': 9000000,
        'purchase_price': 7500000.25,
        'purchase_date': '2020-03-15',
      });

      expect(mapped.linkedLoanId, isNull);
      expect(mapped.estimatedValue, Decimal.parse('9000000'));
      expect(mapped.purchasePrice, Decimal.parse('7500000.25'));
      expect(mapped.purchaseDate, '2020-03-15');
    });
  });

  group('Supabase transaction mapper', () {
    test('uses storage keys and handles nullable numeric fields', () {
      final occurredAt = DateTime.utc(2026, 5, 1, 12);
      final createdAt = DateTime.utc(2026, 5, 1, 12, 5);
      final transaction = Transaction(
        id: '99999999-9999-9999-9999-999999999999',
        assetType: TransactionAssetType.realEstate,
        assetId: '88888888-8888-8888-8888-888888888888',
        kind: TransactionKind.adjust,
        quantity: null,
        price: null,
        amount: Decimal.parse('-123.45'),
        currency: CurrencyCode.usd,
        occurredAt: occurredAt,
        note: null,
        createdAt: createdAt,
      );

      final row = transactionToSupabaseRow(
        transaction,
        userId: '33333333-3333-3333-3333-333333333333',
      );

      expect(row['asset_type'], 'real_estate');
      expect(row['quantity'], isNull);
      expect(row['price'], isNull);
      expect(row['note'], isNull);

      final mapped = transactionFromSupabaseRow({
        ...row,
        'quantity': 10,
        'price': 12.5,
        'amount': '-125',
      });

      expect(mapped.assetType, TransactionAssetType.realEstate);
      expect(mapped.kind, TransactionKind.adjust);
      expect(mapped.quantity, Decimal.parse('10'));
      expect(mapped.price, Decimal.parse('12.5'));
      expect(mapped.amount, Decimal.parse('-125'));
    });
  });

  group('Supabase exchange rate mapper', () {
    test('round-trips currencies and reads numeric shapes', () {
      final fetchedAt = DateTime.utc(2026, 5, 2, 2);
      final rate = ExchangeRate(
        id: 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa',
        fromCurrency: CurrencyCode.usd,
        toCurrency: CurrencyCode.twd,
        rate: Decimal.parse('32.125'),
        fetchedAt: fetchedAt,
      );

      final row = exchangeRateToSupabaseRow(
        rate,
        userId: '33333333-3333-3333-3333-333333333333',
      );

      expect(row['from_currency'], 'usd');
      expect(row['to_currency'], 'twd');
      expect(row['rate'], '32.125');

      final mapped = exchangeRateFromSupabaseRow({...row, 'rate': 32});

      expect(mapped.fromCurrency, CurrencyCode.usd);
      expect(mapped.toCurrency, CurrencyCode.twd);
      expect(mapped.rate, Decimal.parse('32'));
      expect(mapped.fetchedAt, fetchedAt);
    });
  });
}

SupabaseRow _stockRow() => {
      'id': '11111111-1111-1111-1111-111111111111',
      'symbol': '2330',
      'market': 'taiwan',
      'name': 'TSMC',
      'quantity': 1000,
      'avg_cost': '610.25',
      'currency': 'twd',
      'is_margin': true,
      'margin_amount': '120000.5',
      'linked_loan_id': '22222222-2222-2222-2222-222222222222',
      'latest_price': '789.1',
      'price_updated_at': DateTime.utc(2026, 5, 2, 9, 15).toIso8601String(),
      'created_at': DateTime.utc(2026, 5, 1, 10, 30).toIso8601String(),
      'updated_at': DateTime.utc(2026, 5, 2, 11, 45).toIso8601String(),
    };
