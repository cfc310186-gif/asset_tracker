import 'dart:math' show pow;

import 'package:decimal/decimal.dart';

/// Amortization schedule entry for a single month.
class AmortizationEntry {
  const AmortizationEntry({
    required this.month,
    required this.payment,
    required this.principal,
    required this.interest,
    required this.balance,
  });

  final int month;
  final Decimal payment;
  final Decimal principal;
  final Decimal interest;
  final Decimal balance;
}

class LoanCalculator {
  LoanCalculator._();

  /// Calculate monthly payment for a standard amortizing loan.
  ///
  /// Formula: M = P * [r(1+r)^n] / [(1+r)^n - 1]
  /// where P = principal, r = monthly rate, n = term in months.
  static Decimal calculateMonthlyPayment({
    required Decimal principal,
    required Decimal annualRate,
    required int termMonths,
  }) {
    if (termMonths <= 0) {
      throw ArgumentError('termMonths must be positive, got $termMonths');
    }

    if (annualRate == Decimal.zero) {
      // Zero interest: simple division, rounded to whole currency unit.
      return (principal / Decimal.fromInt(termMonths))
          .toDecimal(scaleOnInfinitePrecision: 0)
          .round();
    }

    // The exponentiation (1+r)^n has no exact closed-form Decimal equivalent.
    // We use double arithmetic here for the formula calculation only.
    // The result is rounded to the nearest monetary unit before storage,
    // so any floating-point noise in intermediate calculation is eliminated at rounding.
    final r = (annualRate / Decimal.fromInt(12))
        .toDecimal(scaleOnInfinitePrecision: 10)
        .toDouble();
    final n = termMonths;
    final p = principal.toDouble();
    final factor = pow(1 + r, n) as double;
    final payment = p * (r * factor) / (factor - 1);
    return Decimal.parse(payment.toStringAsFixed(0));
  }

  /// Calculate interest-only payment (used during a grace period).
  static Decimal calculateInterestOnlyPayment({
    required Decimal principal,
    required Decimal annualRate,
  }) {
    final monthlyRate =
        (annualRate / Decimal.fromInt(12)).toDecimal(scaleOnInfinitePrecision: 10);
    return (principal * monthlyRate).round();
  }

  /// Generate a full amortization schedule.
  ///
  /// When [gracePeriodMonths] > 0, the first N months are interest-only;
  /// principal repayment begins in month N+1 using the REMAINING months
  /// (termMonths - gracePeriodMonths) to ensure the loan is fully paid off
  /// within [termMonths] total (Taiwan 房貸寬限期 practice).
  static List<AmortizationEntry> generateSchedule({
    required Decimal principal,
    required Decimal annualRate,
    required int termMonths,
    int gracePeriodMonths = 0,
  }) {
    if (gracePeriodMonths >= termMonths) {
      throw ArgumentError(
        'gracePeriodMonths ($gracePeriodMonths) must be less than termMonths ($termMonths)',
      );
    }

    final schedule = <AmortizationEntry>[];
    var balance = principal;
    final monthlyRate =
        (annualRate / Decimal.fromInt(12)).toDecimal(scaleOnInfinitePrecision: 10);

    // Calculate regular amortization payment for the post-grace period.
    // Uses remaining term after grace period so the loan is fully paid within termMonths.
    final remainingTermAfterGrace = termMonths - gracePeriodMonths;
    final regularPayment = gracePeriodMonths > 0 && remainingTermAfterGrace > 0
        ? calculateMonthlyPayment(
            principal: principal,
            annualRate: annualRate,
            termMonths: remainingTermAfterGrace,
          )
        : calculateMonthlyPayment(
            principal: principal,
            annualRate: annualRate,
            termMonths: termMonths,
          );

    for (var month = 1; month <= termMonths; month++) {
      final interestPayment = (balance * monthlyRate).round();

      if (month <= gracePeriodMonths) {
        // Grace period: interest-only, balance unchanged.
        schedule.add(
          AmortizationEntry(
            month: month,
            payment: interestPayment,
            principal: Decimal.zero,
            interest: interestPayment,
            balance: balance,
          ),
        );
      } else {
        // Regular amortization.
        final principalPayment = regularPayment - interestPayment;
        final newBalance = balance - principalPayment;
        final clampedBalance =
            newBalance > Decimal.zero ? newBalance : Decimal.zero;
        final clampedPrincipal =
            principalPayment > Decimal.zero ? principalPayment : Decimal.zero;

        schedule.add(
          AmortizationEntry(
            month: month,
            payment: regularPayment,
            principal: clampedPrincipal,
            interest: interestPayment,
            balance: clampedBalance,
          ),
        );
        balance = clampedBalance;
      }
    }

    return schedule;
  }

  /// Calculate remaining balance after [paymentsMade] payments.
  static Decimal calculateRemainingBalance({
    required Decimal principal,
    required Decimal annualRate,
    required int termMonths,
    required int paymentsMade,
    int gracePeriodMonths = 0,
  }) {
    final schedule = generateSchedule(
      principal: principal,
      annualRate: annualRate,
      termMonths: termMonths,
      gracePeriodMonths: gracePeriodMonths,
    );
    if (paymentsMade >= schedule.length) return Decimal.zero;
    return schedule[paymentsMade].balance;
  }
}
