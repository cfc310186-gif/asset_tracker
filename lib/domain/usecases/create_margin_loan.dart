import 'package:decimal/decimal.dart';
import 'package:uuid/uuid.dart';

import '../enums/loan_type.dart';
import '../models/loan.dart';
import '../models/stock_holding.dart';
import '../repositories/loan_repository.dart';
import '../repositories/stock_repository.dart';

/// Creates or updates a [Loan] of type [LoanType.stockMarginLoan] when a
/// [StockHolding] is saved with [StockHolding.isMargin] set to true.
class CreateMarginLoan {
  const CreateMarginLoan({
    required StockRepository stockRepo,
    required LoanRepository loanRepo,
  })  : _stockRepo = stockRepo,
        _loanRepo = loanRepo;

  final StockRepository _stockRepo;
  final LoanRepository _loanRepo;

  /// Creates or updates the linked margin loan for [holding].
  ///
  /// Precondition: [holding.isMargin] must be true and
  /// [holding.marginAmount] must be non-null.
  Future<void> execute(StockHolding holding) async {
    assert(holding.isMargin && holding.marginAmount != null);

    // If already linked, update the existing loan's principal and balance.
    if (holding.linkedLoanId != null) {
      final existingLoan = await _loanRepo.getById(holding.linkedLoanId!);
      if (existingLoan != null) {
        await _loanRepo.save(
          existingLoan.copyWith(
            principal: holding.marginAmount!,
            remainingBalance: holding.marginAmount!,
          ),
        );
        return;
      }
    }

    // Create a new placeholder loan.
    final loanId = const Uuid().v4();
    final loan = Loan(
      id: loanId,
      type: LoanType.stockMarginLoan,
      name: '${holding.symbol} 融資',
      principal: holding.marginAmount!,
      remainingBalance: holding.marginAmount!,
      interestRate: Decimal.zero,
      termMonths: 0,
      monthlyPayment: Decimal.zero,
      currency: holding.currency,
      hasGracePeriod: false,
      startDate: DateTime.now().toIso8601String().substring(0, 10),
      sourceType: 'stock',
      sourceId: holding.id,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await _loanRepo.save(loan);

    // Link the new loan back to the holding.
    await _stockRepo.save(holding.copyWith(linkedLoanId: loanId));
  }
}
