# Supabase Cloud Storage Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Move asset data from local-only Drift storage to Supabase so the same Email/password account can access data from phone and computer, while retaining explicit import/export flows instead of offline sync.

**Architecture:** Keep the existing domain repository interfaces and add Supabase-backed implementations beside the current Drift-backed implementations. The app selects local repositories before login and Supabase repositories after login; no offline write queue is introduced. Import/export is explicit and user-triggered.

**Tech Stack:** Flutter, Riverpod, Supabase Flutter SDK, Supabase Auth, Supabase Postgres, Row Level Security, existing Drift local database for pre-login/local import source.

---

## Decisions

- Backend: Supabase.
- Auth: Email/password first.
- Offline: Not required. If network is unavailable while logged in, show a clear error and retry option.
- Local data: Existing local Drift data remains readable and can be uploaded to Supabase through an explicit import action.
- Export: Provide JSON export from Supabase data. Google Sheets can be added later as a separate export adapter, not as the primary database.

## Target File Structure

- Create `supabase/migrations/202605020001_initial_cloud_schema.sql`: Cloud tables, indexes, triggers, and RLS policies.
- Create `lib/core/config/supabase_config.dart`: Reads Supabase URL and anon key from build-time environment.
- Create `lib/data/supabase/supabase_mappers.dart`: Converts Supabase rows to domain models and domain models to row payloads.
- Create `lib/data/supabase/supabase_repository_base.dart`: Shared helpers for auth user id, error wrapping, and decimal/date encoding.
- Create `lib/data/repositories/supabase_stock_repository.dart`: Implements `StockRepository`.
- Create `lib/data/repositories/supabase_cash_repository.dart`: Implements `CashRepository`.
- Create `lib/data/repositories/supabase_loan_repository.dart`: Implements `LoanRepository`.
- Create `lib/data/repositories/supabase_real_estate_repository.dart`: Implements `RealEstateRepository`.
- Create `lib/data/repositories/supabase_transaction_repository.dart`: Implements `TransactionRepository`.
- Create `lib/data/repositories/supabase_net_worth_snapshot_repository.dart`: Implements `NetWorthSnapshotRepository`.
- Modify `lib/providers/repository_providers.dart`: Select Drift or Supabase repository based on auth state.
- Create `lib/providers/auth_providers.dart`: Supabase client and auth state providers.
- Create `lib/providers/cloud_sync_providers.dart`: Import/export orchestration providers.
- Create `lib/presentation/auth/login_screen.dart`: Email/password login and registration.
- Modify `lib/presentation/shared/app_router.dart`: Add auth routes and account/settings entry points.
- Modify `lib/presentation/settings/settings_screen.dart`: Add cloud account, import, export, and sign-out actions.
- Create `lib/domain/usecases/import_local_data_to_cloud.dart`: Upload existing local records to Supabase.
- Create `lib/domain/usecases/export_cloud_data.dart`: Export current cloud records to a JSON document.
- Create `test/data/supabase/supabase_mappers_test.dart`: Mapper tests.
- Create `test/domain/import_local_data_to_cloud_test.dart`: Import behavior tests with fake repositories.
- Create `e2e/tests/cloud_auth_and_data.spec.ts`: Playwright coverage for login and cross-session data visibility.

## Supabase Schema Contract

All user-owned tables must include:

```sql
id uuid primary key,
user_id uuid not null references auth.users(id) on delete cascade,
created_at timestamptz not null default now(),
updated_at timestamptz not null default now(),
deleted_at timestamptz
```

RLS policy pattern for every user-owned table:

```sql
alter table public.stock_holdings enable row level security;

create policy "stock_holdings_select_own"
on public.stock_holdings
for select
using (user_id = auth.uid());

create policy "stock_holdings_insert_own"
on public.stock_holdings
for insert
with check (user_id = auth.uid());

create policy "stock_holdings_update_own"
on public.stock_holdings
for update
using (user_id = auth.uid())
with check (user_id = auth.uid());

create policy "stock_holdings_delete_own"
on public.stock_holdings
for delete
using (user_id = auth.uid());
```

Use `numeric` for Decimal values, `text` for enum storage keys, and `jsonb` for net worth snapshot breakdown.

## Phase 1: Supabase Foundation

### Task 1: Add Supabase dependency and config boundary

**Files:**
- Modify: `pubspec.yaml`
- Create: `lib/core/config/supabase_config.dart`
- Create: `lib/providers/auth_providers.dart`

- [ ] Add dependency:

```yaml
dependencies:
  supabase_flutter: ^2.8.0
```

- [ ] Create config that fails fast when required values are missing:

```dart
class SupabaseConfig {
  const SupabaseConfig._();

  static const url = String.fromEnvironment('SUPABASE_URL');
  static const anonKey = String.fromEnvironment('SUPABASE_ANON_KEY');

  static bool get isConfigured => url.isNotEmpty && anonKey.isNotEmpty;
}
```

- [ ] Initialize Supabase before `runApp` in `lib/main.dart` only when configured.
- [ ] Add `supabaseClientProvider` and `authStateProvider` in `lib/providers/auth_providers.dart`.
- [ ] Verification:
  - Run `flutter pub get`.
  - Run `flutter analyze --no-pub`.
  - Run app with `--dart-define=SUPABASE_URL=... --dart-define=SUPABASE_ANON_KEY=...`.

### Task 2: Create Supabase schema migration

**Files:**
- Create: `supabase/migrations/202605020001_initial_cloud_schema.sql`

- [ ] Create these tables:
  - `stock_holdings`
  - `cash_accounts`
  - `loans`
  - `real_estate_assets`
  - `transactions`
  - `net_worth_snapshots`
  - `exchange_rates`

- [ ] Include `user_id`, timestamps, `deleted_at`, indexes on `user_id`, and unique key for `net_worth_snapshots(user_id, captured_at, display_currency)`.
- [ ] Add RLS policies for every user-owned table.
- [ ] Add `updated_at` trigger:

```sql
create or replace function public.set_updated_at()
returns trigger as $$
begin
  new.updated_at = now();
  return new;
end;
$$ language plpgsql;
```

- [ ] Verification:
  - Apply migration in Supabase SQL editor or CLI.
  - Create two test users and confirm each user cannot query the other user's rows.

## Phase 2: Auth UI

### Task 3: Add Email/password login and registration

**Files:**
- Create: `lib/presentation/auth/login_screen.dart`
- Modify: `lib/presentation/shared/app_router.dart`
- Modify: `lib/presentation/settings/settings_screen.dart`

- [ ] Add a login screen with email, password, login, register, and error display.
- [ ] Use Supabase Auth methods:

```dart
await client.auth.signInWithPassword(email: email, password: password);
await client.auth.signUp(email: email, password: password);
await client.auth.signOut();
```

- [ ] Add route `/login`.
- [ ] Add account section in settings showing signed-in email and sign-out button.
- [ ] Verification:
  - Widget test for empty email/password validation.
  - Manual test: register, sign out, sign in.

## Phase 3: Supabase Repository Layer

### Task 4: Add row mappers and shared repository helpers

**Files:**
- Create: `lib/data/supabase/supabase_mappers.dart`
- Create: `lib/data/supabase/supabase_repository_base.dart`
- Test: `test/data/supabase/supabase_mappers_test.dart`

- [ ] Implement deterministic conversion for:
  - Decimal as `value.toString()` on writes and `Decimal.parse(row['field'].toString())` on reads.
  - Enums as existing storage keys or enum names.
  - Dates as ISO 8601 strings.
  - `net_worth_snapshots.breakdown` as `Map<String, String>` inside `jsonb`.

- [ ] Mapper tests must cover at least:
  - Stock with margin fields.
  - Loan with grace period fields.
  - Net worth snapshot breakdown.

- [ ] Verification:
  - Run `flutter test test/data/supabase/supabase_mappers_test.dart`.

### Task 5: Implement Supabase repositories

**Files:**
- Create: `lib/data/repositories/supabase_stock_repository.dart`
- Create: `lib/data/repositories/supabase_cash_repository.dart`
- Create: `lib/data/repositories/supabase_loan_repository.dart`
- Create: `lib/data/repositories/supabase_real_estate_repository.dart`
- Create: `lib/data/repositories/supabase_transaction_repository.dart`
- Create: `lib/data/repositories/supabase_net_worth_snapshot_repository.dart`

- [ ] Implement current repository contracts exactly:

```dart
Stream<List<T>> watchAll();
Future<List<T>> getAll();
Future<T?> getById(String id);
Future<void> save(T value);
Future<void> delete(String id);
```

- [ ] `delete` should set `deleted_at` instead of hard delete.
- [ ] `getAll` and `watchAll` should exclude `deleted_at != null`.
- [ ] `watchAll` can start as Supabase realtime stream ordered by `updated_at`; if realtime is unstable, use refetch after mutation for MVP.
- [ ] Verification:
  - Add fake-client tests where practical.
  - Manual Supabase test: create a stock, reload app, confirm it appears.

### Task 6: Switch repository providers by auth state

**Files:**
- Modify: `lib/providers/repository_providers.dart`
- Modify: `lib/providers/usecase_providers.dart`

- [ ] If `authStateProvider` has a signed-in user and Supabase is configured, return Supabase repositories.
- [ ] Otherwise return existing Drift repositories.
- [ ] Keep all use cases unchanged.
- [ ] Verification:
  - Existing local Playwright tests still pass when not logged in.
  - Logged-in manual session writes to Supabase.

## Phase 4: Import/Export

### Task 7: Import local Drift data to Supabase

**Files:**
- Create: `lib/domain/usecases/import_local_data_to_cloud.dart`
- Create: `lib/providers/cloud_sync_providers.dart`
- Modify: `lib/presentation/settings/settings_screen.dart`
- Test: `test/domain/import_local_data_to_cloud_test.dart`

- [ ] Import order:
  1. Stocks
  2. Cash
  3. Real estate
  4. Loans
  5. Transactions
  6. Net worth snapshots
  7. Exchange rates

- [ ] Preserve ids so linked loans still work.
- [ ] Use upsert semantics so pressing import twice does not duplicate records.
- [ ] Show result summary: imported, skipped, failed.
- [ ] Verification:
  - Test import idempotency.
  - Test linked `stock.linkedLoanId` and `realEstate.linkedLoanId` survive import.

### Task 8: Export cloud data to JSON

**Files:**
- Create: `lib/domain/usecases/export_cloud_data.dart`
- Modify: `lib/providers/cloud_sync_providers.dart`
- Modify: `lib/presentation/settings/settings_screen.dart`

- [ ] Export all current user cloud data into one JSON object:

```json
{
  "schemaVersion": 1,
  "exportedAt": "2026-05-02T00:00:00.000Z",
  "stocks": [],
  "cashAccounts": [],
  "loans": [],
  "realEstateAssets": [],
  "transactions": [],
  "netWorthSnapshots": [],
  "exchangeRates": []
}
```

- [ ] Use platform file save/share support in a follow-up if this project does not already have file picker/share packages.
- [ ] MVP can display JSON in a copyable dialog on web/desktop.
- [ ] Verification:
  - Export after importing local data.
  - Validate JSON can be parsed and row counts match cloud records.

## Phase 5: E2E Verification

### Task 9: Add Playwright auth and cloud data tests

**Files:**
- Create: `e2e/tests/cloud_auth_and_data.spec.ts`
- Modify: `e2e/playwright.config.ts` if env vars are needed.

- [ ] Test account setup should use Supabase test credentials from environment:

```text
SUPABASE_TEST_EMAIL
SUPABASE_TEST_PASSWORD
```

- [ ] Test flow:
  1. Open app.
  2. Log in.
  3. Add stock.
  4. Reload browser.
  5. Confirm stock remains.
  6. Open a second browser context with same login.
  7. Confirm same stock appears.

- [ ] Keep existing local tests runnable without Supabase env vars.
- [ ] Verification:
  - `flutter analyze --no-pub`
  - `npx playwright test tests/cloud_auth_and_data.spec.ts --project=chromium --reporter=list`
  - Existing local tests still pass.

## Phase 6: Documentation

### Task 10: Document setup and operation

**Files:**
- Modify: `docs/build-setup.md`
- Create: `docs/supabase-setup.md`

- [ ] Document required Supabase project settings.
- [ ] Document SQL migration order.
- [ ] Document local run command:

```powershell
flutter run -d chrome --dart-define=SUPABASE_URL="..." --dart-define=SUPABASE_ANON_KEY="..."
```

- [ ] Document mobile run command with the same dart defines.
- [ ] Document import/export behavior and limitations.

## Checkpoints

### Checkpoint A: Foundation

- [ ] Supabase project can authenticate users.
- [ ] RLS prevents cross-user access.
- [ ] App runs with and without Supabase dart defines.

### Checkpoint B: First Cloud Slice

- [ ] Login works.
- [ ] Stock repository writes to Supabase.
- [ ] Stock list reloads from Supabase after browser reload.
- [ ] Local mode still works when logged out.

### Checkpoint C: Full Cloud Data

- [ ] All asset categories work against Supabase.
- [ ] Dashboard and reports calculate from cloud records.
- [ ] Import local data to cloud is idempotent.
- [ ] Export JSON contains all current cloud data.

## Risks and Mitigations

| Risk | Impact | Mitigation |
|---|---:|---|
| RLS misconfiguration exposes data | High | Write and manually verify RLS policies with two users before app integration |
| Decimal precision loss | High | Store numeric values as Postgres `numeric`; parse through `Decimal` |
| Linked loan ids break on import | Medium | Preserve existing ids and import linked entities before validation |
| Supabase realtime complexity | Medium | MVP can refetch after mutation; realtime can be incremental |
| Existing local tests become cloud-dependent | Medium | Provider selection must keep logged-out mode on Drift |
| Secrets accidentally committed | High | Use `--dart-define`, never commit anon key into source files |

## Out of Scope for MVP

- Offline write queue.
- Google login.
- Google Sheets as primary database.
- Multi-user shared portfolios.
- Conflict resolution between simultaneous editors.
- Server-side scheduled price refresh.

## Final Verification

- [ ] `flutter analyze --no-pub`
- [ ] `flutter test`
- [ ] `npx playwright test tests/stocks.spec.ts tests/portfolio_updates.spec.ts --project=chromium --reporter=list --retries=0`
- [ ] `npx playwright test tests/cloud_auth_and_data.spec.ts --project=chromium --reporter=list --retries=0`
- [ ] Manual mobile browser check on same network or deployed build: login and confirm cloud data appears.
