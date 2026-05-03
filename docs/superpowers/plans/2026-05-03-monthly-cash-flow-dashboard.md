# Monthly Cash Flow Dashboard Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use test-driven development for the domain calculation first, then integrate the dashboard UI and verify with Flutter tests plus Playwright.

**Goal:** Show monthly positive and negative cash flow on the overview dashboard.

**Scope:** Positive cash flow is estimated monthly interest from cash deposits. Negative cash flow is the sum of loan monthly repayments. Values are displayed in the current dashboard display currency.

**Out of scope:** Dividends, rent, recurring expenses, cash transaction history, and offline support.

**Tech Stack:** Flutter, Riverpod, Decimal, existing repository/usecase pattern, Playwright E2E.

---

## Behavioral Decisions

- Positive monthly cash flow = sum of `CashAccount.estimatedMonthlyInterest`.
- Cash accounts without `annualRate` contribute zero.
- Negative monthly cash flow = sum of `Loan.monthlyPayment`.
- Loan grace period fields will not change the calculation in this slice. The feature uses the currently stored monthly payment as the source of truth.
- Every amount is converted to `displayCurrency` using the same exchange-rate semantics as net worth calculation:
  - same currency returns unchanged amount
  - available exchange rate is applied
  - missing exchange rate falls back to `1:1`, matching current behavior
- No database schema change is required because all source data already exists.

---

## Target Files

- Create `lib/domain/models/monthly_cash_flow_summary.dart`
- Create `lib/domain/usecases/calculate_monthly_cash_flow.dart`
- Modify `lib/providers/usecase_providers.dart`
- Create `lib/presentation/dashboard/widgets/monthly_cash_flow_card.dart`
- Modify `lib/presentation/dashboard/dashboard_screen.dart`
- Add `test/usecases/calculate_monthly_cash_flow_test.dart`
- Modify `e2e/pages/DashboardPage.ts`
- Modify `e2e/tests/dashboard.spec.ts`

---

## Implementation Steps

### 1. Add Domain Tests First

Create `test/usecases/calculate_monthly_cash_flow_test.dart`.

Test cases:

- Empty cash accounts and loans returns zero positive, zero negative, zero net.
- Cash account interest is calculated monthly:
  - balance `120000`
  - annual rate `0.012`
  - expected monthly positive cash flow `120`.
- Multiple loans sum monthly repayments:
  - `1000 + 2500`
  - expected negative cash flow `3500`.
- Null cash annual rate contributes zero.
- Multi-currency conversion works:
  - USD cash monthly interest converted to TWD
  - USD loan monthly payment converted to TWD
  - use fake exchange rate repository.

Expected model API:

```dart
class MonthlyCashFlowSummary {
  final Decimal positiveCashFlow;
  final Decimal negativeCashFlow;
  final CurrencyCode displayCurrency;
  final DateTime calculatedAt;

  Decimal get netCashFlow => positiveCashFlow - negativeCashFlow;
}
```

### 2. Implement Cash Flow Use Case

Create `CalculateMonthlyCashFlow`.

Responsibilities:

- Load all cash accounts from `CashRepository`.
- Load all loans from `LoanRepository`.
- Load exchange rates from `ExchangeRateRepository`.
- Convert each source amount to the requested display currency.
- Sum positive and negative monthly cash flow separately.
- Return `MonthlyCashFlowSummary`.

Constructor shape:

```dart
class CalculateMonthlyCashFlow {
  CalculateMonthlyCashFlow({
    required CashRepository cashRepo,
    required LoanRepository loanRepo,
    required ExchangeRateRepository exchangeRateRepo,
  });

  Future<MonthlyCashFlowSummary> execute({
    required CurrencyCode displayCurrency,
  });
}
```

Implementation note:

- Prefer extracting a small shared currency conversion helper if this avoids duplicating `CalculateNetWorth` conversion behavior.
- Keep rounding consistent with `CalculateNetWorth`: converted values are rounded to two decimals.

### 3. Wire Riverpod Provider

Modify `lib/providers/usecase_providers.dart`.

Add:

```dart
final calculateMonthlyCashFlowProvider = Provider<CalculateMonthlyCashFlow>((ref) {
  ref.watch(portfolioRevisionProvider);
  return CalculateMonthlyCashFlow(
    cashRepo: ref.watch(cashRepositoryProvider),
    loanRepo: ref.watch(loanRepositoryProvider),
    exchangeRateRepo: ref.watch(exchangeRateRepositoryProvider),
  );
});
```

The provider should watch `portfolioRevisionProvider` so dashboard values refresh after asset changes, matching the existing net worth refresh pattern.

### 4. Build Dashboard Card

Create `lib/presentation/dashboard/widgets/monthly_cash_flow_card.dart`.

UI requirements:

- Compact dashboard card, visually consistent with existing dashboard widgets.
- Title: `每月現金流`.
- Show positive cash flow row.
- Show negative cash flow row.
- Show net monthly cash flow as a secondary summary.
- Use existing currency formatter behavior.
- Add stable semantic identifier:

```dart
identifier: 'monthly-cash-flow-card'
```

States:

- Loading: skeleton or progress state inside the same card footprint.
- Error: compact message and retry affordance if the surrounding dashboard pattern supports it.
- Data: formatted positive, negative, and net values.

### 5. Integrate Into Overview Dashboard

Modify `lib/presentation/dashboard/dashboard_screen.dart`.

Add a new provider:

```dart
final _monthlyCashFlowProvider = FutureProvider<MonthlyCashFlowSummary>((ref) {
  final currency = ref.watch(displayCurrencyProvider);
  ref.watch(portfolioRevisionProvider);
  return ref.watch(calculateMonthlyCashFlowProvider).execute(
        displayCurrency: currency,
      );
});
```

Layout placement:

- Desktop/wide layout: place the monthly cash flow card in the left column after `_NetWorthBlock` and before `AssetBreakdownChart`.
- Mobile layout: place it after `_NetWorthBlock` and before `AssetBreakdownChart`.

This keeps the overview scan order as:

1. Current net worth
2. Monthly cash flow
3. Asset allocation
4. Category summaries

### 6. Update Playwright Page Object And Smoke Test

Modify `e2e/pages/DashboardPage.ts`.

Add locator:

```ts
monthlyCashFlowCard() {
  return this.page.locator('[flt-semantics-identifier="monthly-cash-flow-card"]');
}
```

Modify `e2e/tests/dashboard.spec.ts`.

Add expectation to the existing dashboard overview smoke test:

```ts
await expect(dashboard.monthlyCashFlowCard()).toBeVisible();
```

If text assertions are unstable due Flutter canvas/semantics rendering, rely on the semantic identifier and verify visibility.

### 7. Verification Commands

Run in repo root:

```powershell
flutter analyze --no-pub
flutter test test/usecases/calculate_monthly_cash_flow_test.dart
flutter test
```

Run Playwright from the E2E folder:

```powershell
cd C:\App_Test\asset_tracker\e2e
npx playwright test tests/dashboard.spec.ts --project=chromium --reporter=list --retries=0
```

If Playwright cannot find the configured project, run from the folder that contains `playwright.config.ts`.

---

## Risks And Follow-Up Decisions

- Grace period behavior may need a separate rule. This plan intentionally uses `Loan.monthlyPayment` as stored.
- Missing exchange rates fall back to `1:1`, which is consistent with current net worth behavior but can be misleading.
- Cash account annual rate must remain stored as a decimal rate, for example `0.012` for `1.2%`.
- Future cash-flow expansion should add dividend, rent, recurring expense, and scheduled transaction sources through the same usecase rather than placing calculation logic in UI widgets.

---

## Completion Criteria

- Domain tests prove positive, negative, net, null rate, loan sum, and currency conversion behavior.
- Dashboard shows a stable monthly cash flow card on desktop and mobile layouts.
- Dashboard updates when cash accounts or loans are added or changed.
- Flutter analyze passes.
- Flutter tests pass.
- Playwright dashboard smoke test confirms the card renders in the overview page.
