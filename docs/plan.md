# Asset Tracker - Implementation Plan

## Project Overview
Personal asset management web app (Flutter Web → iOS)
Track: Stocks (TW/US/UK), Real Estate, Cash, Loans

## Tech Stack
- Framework: Flutter (web target)
- DB: Drift (SQLite via sql.js for web)
- State: Riverpod
- HTTP: Dio
- Charts: fl_chart
- Decimal math: decimal package

## Stock Price APIs
| Market | API | Fallback |
|--------|-----|----------|
| TWSE (上市) | twse.com.tw OpenAPI | FinMind |
| TPEx (上櫃) | tpex.org.tw API | FinMind |
| Emerging (興櫃) | tpex.org.tw Emerging API | FinMind |
| US (NYSE/NASDAQ) | Yahoo Finance v8 | Alpha Vantage |
| UK (LSE) | Yahoo Finance v8 (.L suffix) | Alpha Vantage |
| Exchange rates | ExchangeRate-API | Frankfurter |

## Architecture
Clean Architecture + Repository Pattern

```
lib/
├── core/           # constants, utils, theme
├── data/           # DB tables/DAOs, API providers, repo impls
├── domain/         # immutable models, repo interfaces, use cases
├── presentation/   # screens per module
└── providers/      # Riverpod wiring
```

## Data Models
All monetary values stored as TEXT (decimal string) to avoid floating-point issues.

### stocks
- id, symbol, market (TWSE/TPEX/EMERGING/NYSE/NASDAQ/LSE)
- name, quantity, avg_cost, currency
- is_margin, margin_amount, linked_loan_id
- latest_price, price_updated_at

### real_estate
- id, name, address, estimated_value, purchase_price, purchase_date, currency
- has_mortgage, linked_loan_id

### loans
- id, type (mortgage/personal_loan/stock_margin_loan)
- name, principal, remaining_balance, interest_rate, term_months
- monthly_payment, currency
- has_grace_period, grace_period_months, grace_period_end_date
- start_date, source_type, source_id

### cash_accounts
- id, name, bank_name, balance, currency

### exchange_rates
- id, from_currency, to_currency, rate, fetched_at

## Phase 1: Foundation (3-4 days)
Task 1.1: Project dependencies (pubspec.yaml)
Task 1.2: Database schema with Drift (all 5 tables + DAOs)
Task 1.3: Domain models (immutable, copyWith)
Task 1.4: Repository interfaces
Task 1.5: Repository implementations
Task 1.6: Riverpod providers wiring
Task 1.7: Core utilities (currency formatter, loan calculator with grace period, decimal extensions)

## Phase 2: CRUD + Dashboard (4-5 days)
Task 2.1: App shell (routing, theme, responsive scaffold)
Task 2.2: Cash module screens (list, add, edit, delete)
Task 2.3: Loans module screens (list, add, edit with type selector + grace period fields)
Task 2.4: Real estate module screens (list, add, edit with mortgage linkage)
Task 2.5: Stocks module screens (list, add, edit with market selector + margin linkage)
Task 2.6: Dashboard screen (net worth card, breakdown chart, category tiles)

## Phase 3: API Integration (3-4 days)
Task 3.1: TWSE provider (上市 stock prices)
Task 3.2: TPEx provider (上櫃 stock prices)
Task 3.3: Emerging market provider (興櫃 stock prices)
Task 3.4: Yahoo Finance provider (US + UK)
Task 3.5: Exchange rate provider + caching
Task 3.6: Price repository with routing + rate limiting
Task 3.7: Refresh use case + UI integration (pull-to-refresh, stale indicator)

## Phase 4: Linked Asset-Loan Logic (2-3 days)
Task 4.1: Create margin loan use case (stock → auto-create loan)
Task 4.2: Create mortgage use case (real estate → auto-create loan with grace period)
Task 4.3: Sync linked loans use case (edit/delete handling)
Task 4.4: Calculate net worth use case (multi-currency)

## Phase 5: Web Polish (2-3 days)
Task 5.1: Settings screen (display currency, API keys, refresh interval)
Task 5.2: PWA manifest + icons + web-specific optimizations
Task 5.3: Error states, loading states, empty states
Task 5.4: Responsive layout polish (mobile + desktop breakpoints)

## Phase 6: iOS Conversion (future)
- Enable iOS target in flutter create
- Replace web DB (sql.js) with native SQLite (Drift native)
- Push notifications, secure storage
- App Store submission
