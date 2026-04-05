import '../models/real_estate_asset.dart';
import '../models/stock_holding.dart';
import '../repositories/loan_repository.dart';

/// Maintains consistency between assets and their linked loans when
/// assets are deleted or their key fields change.
class SyncLinkedLoans {
  const SyncLinkedLoans({
    required LoanRepository loanRepo,
  }) : _loanRepo = loanRepo;

  final LoanRepository _loanRepo;

  /// Call when a [StockHolding] is deleted.
  ///
  /// Deletes the linked margin loan if one exists.
  Future<void> onStockDeleted(StockHolding holding) async {
    if (holding.linkedLoanId != null) {
      await _loanRepo.delete(holding.linkedLoanId!);
    }
  }

  /// Call when a [RealEstateAsset] is deleted.
  ///
  /// Deletes the linked mortgage loan if one exists.
  Future<void> onRealEstateDeleted(RealEstateAsset asset) async {
    if (asset.linkedLoanId != null) {
      await _loanRepo.delete(asset.linkedLoanId!);
    }
  }

  /// Call when the margin amount changes on a [StockHolding].
  ///
  /// Syncs the linked loan's principal and remaining balance to match
  /// the new margin amount.
  Future<void> onMarginAmountChanged(StockHolding holding) async {
    if (holding.linkedLoanId == null || holding.marginAmount == null) return;

    final loan = await _loanRepo.getById(holding.linkedLoanId!);
    if (loan != null) {
      await _loanRepo.save(
        loan.copyWith(
          principal: holding.marginAmount!,
          remainingBalance: holding.marginAmount!,
        ),
      );
    }
  }
}
