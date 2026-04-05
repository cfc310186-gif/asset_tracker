import 'package:decimal/decimal.dart';
import 'package:uuid/uuid.dart';

import '../enums/loan_type.dart';
import '../models/loan.dart';
import '../models/real_estate_asset.dart';
import '../repositories/loan_repository.dart';
import '../repositories/real_estate_repository.dart';

/// Creates a placeholder [Loan] of type [LoanType.mortgage] when a
/// [RealEstateAsset] is saved with [RealEstateAsset.hasMortgage] set to true
/// and no linked loan exists yet.
class CreateMortgage {
  const CreateMortgage({
    required RealEstateRepository realEstateRepo,
    required LoanRepository loanRepo,
  })  : _realEstateRepo = realEstateRepo,
        _loanRepo = loanRepo;

  final RealEstateRepository _realEstateRepo;
  final LoanRepository _loanRepo;

  /// Creates a linked mortgage loan for [asset] if one does not already exist.
  ///
  /// Precondition: [asset.hasMortgage] must be true.
  Future<void> execute(RealEstateAsset asset) async {
    assert(asset.hasMortgage);

    if (asset.linkedLoanId != null) {
      // Already linked — user manages the loan details in the Loans screen.
      return;
    }

    final loanId = const Uuid().v4();
    final loan = Loan(
      id: loanId,
      type: LoanType.mortgage,
      name: '${asset.name} 房貸',
      principal: asset.purchasePrice,
      remainingBalance: asset.purchasePrice,
      interestRate: Decimal.zero,
      termMonths: 0,
      monthlyPayment: Decimal.zero,
      currency: asset.currency,
      hasGracePeriod: false,
      startDate: asset.purchaseDate,
      sourceType: 'real_estate',
      sourceId: asset.id,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await _loanRepo.save(loan);
    await _realEstateRepo.save(asset.copyWith(linkedLoanId: loanId));
  }
}
