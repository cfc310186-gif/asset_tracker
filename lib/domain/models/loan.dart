import 'package:decimal/decimal.dart';
import 'package:flutter/foundation.dart';

import '../enums/currency_code.dart';
import '../enums/loan_type.dart';

@immutable
class Loan {
  final String id;
  final LoanType type;
  final String name;
  final Decimal principal;
  final Decimal remainingBalance;

  /// Annual interest rate, e.g. Decimal.parse("0.025") for 2.5%
  final Decimal interestRate;
  final int termMonths;
  final Decimal monthlyPayment;
  final CurrencyCode currency;
  final bool hasGracePeriod;
  final int? gracePeriodMonths;

  /// ISO date string, e.g. "2024-06-01"
  final String? gracePeriodEndDate;

  /// ISO date string, e.g. "2023-01-01"
  final String startDate;

  /// e.g. "real_estate", "stock", "personal"
  final String sourceType;
  final String? sourceId;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Loan({
    required this.id,
    required this.type,
    required this.name,
    required this.principal,
    required this.remainingBalance,
    required this.interestRate,
    required this.termMonths,
    required this.monthlyPayment,
    required this.currency,
    required this.hasGracePeriod,
    this.gracePeriodMonths,
    this.gracePeriodEndDate,
    required this.startDate,
    required this.sourceType,
    this.sourceId,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Returns true if the loan has an active grace period (end date is in the future).
  bool get isInGracePeriod {
    if (!hasGracePeriod || gracePeriodEndDate == null) return false;
    final endDate = DateTime.parse(gracePeriodEndDate!);
    return endDate.isAfter(DateTime.now());
  }

  Loan copyWith({
    String? id,
    LoanType? type,
    String? name,
    Decimal? principal,
    Decimal? remainingBalance,
    Decimal? interestRate,
    int? termMonths,
    Decimal? monthlyPayment,
    CurrencyCode? currency,
    bool? hasGracePeriod,
    Object? gracePeriodMonths = _sentinel,
    Object? gracePeriodEndDate = _sentinel,
    String? startDate,
    String? sourceType,
    Object? sourceId = _sentinel,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Loan(
      id: id ?? this.id,
      type: type ?? this.type,
      name: name ?? this.name,
      principal: principal ?? this.principal,
      remainingBalance: remainingBalance ?? this.remainingBalance,
      interestRate: interestRate ?? this.interestRate,
      termMonths: termMonths ?? this.termMonths,
      monthlyPayment: monthlyPayment ?? this.monthlyPayment,
      currency: currency ?? this.currency,
      hasGracePeriod: hasGracePeriod ?? this.hasGracePeriod,
      gracePeriodMonths: gracePeriodMonths == _sentinel
          ? this.gracePeriodMonths
          : gracePeriodMonths as int?,
      gracePeriodEndDate: gracePeriodEndDate == _sentinel
          ? this.gracePeriodEndDate
          : gracePeriodEndDate as String?,
      startDate: startDate ?? this.startDate,
      sourceType: sourceType ?? this.sourceType,
      sourceId:
          sourceId == _sentinel ? this.sourceId : sourceId as String?,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

const Object _sentinel = Object();
