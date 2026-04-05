enum LoanType {
  mortgage, // 房貸
  personalLoan, // 信貸
  stockMarginLoan; // 股票質押貸

  String get displayName => switch (this) {
        LoanType.mortgage => '房貸',
        LoanType.personalLoan => '信貸',
        LoanType.stockMarginLoan => '股票質押貸',
      };
}
