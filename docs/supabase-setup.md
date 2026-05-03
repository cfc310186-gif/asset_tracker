# Supabase Setup

This app can run in two modes:

- **Local mode:** no Supabase config; data stays in the local Drift database.
- **Cloud mode:** Supabase URL/key are provided with `--dart-define`; signed-in users read/write Supabase data.

Offline cloud sync is intentionally out of scope. When signed in, cloud writes require network access.

## 1. Create Supabase Project

1. Create a Supabase project.
2. Enable Email/password auth in Supabase Authentication settings.
3. Keep email confirmation disabled for local development test accounts, or create confirmed users manually.
4. Copy the project URL and anon public key.

Do not commit Supabase keys into source files. Pass them at build/run time.

## 2. Apply Database Migration

Apply the SQL migration:

```text
supabase/migrations/202605020001_initial_cloud_schema.sql
```

The migration creates:

- `stock_holdings`
- `cash_accounts`
- `loans`
- `real_estate_assets`
- `transactions`
- `net_worth_snapshots`
- `exchange_rates`

Every table is scoped by `user_id`, has soft-delete support through `deleted_at`, and has Row Level Security policies limiting access to `auth.uid()`.

## 3. Run Web Locally

```powershell
flutter run -d chrome `
  --dart-define=SUPABASE_URL="https://your-project.supabase.co" `
  --dart-define=SUPABASE_ANON_KEY="your-anon-key"
```

Without these defines, the app still runs in local-only mode and the cloud login UI shows a configuration message.

## 4. Build Web

```powershell
flutter build web --release `
  --dart-define=SUPABASE_URL="https://your-project.supabase.co" `
  --dart-define=SUPABASE_ANON_KEY="your-anon-key"
```

## 5. Run on Mobile

Use the same dart defines:

```powershell
flutter run -d <device-id> `
  --dart-define=SUPABASE_URL="https://your-project.supabase.co" `
  --dart-define=SUPABASE_ANON_KEY="your-anon-key"
```

For phone access during local development, the phone must be able to reach the dev server or installed app build, and the Supabase project must allow the auth callback/origin used by that build.

## 6. Import Local Data

After signing in:

1. Open the settings page.
2. Use the local-data-to-cloud import action.

Import behavior:

- Preserves local IDs so stock/real-estate linked loan IDs remain valid.
- Uses upsert semantics; running import again overwrites matching cloud rows instead of duplicating them.
- Imports stocks, cash, real estate, loans, transactions, net worth snapshots, and exchange rates.

## 7. Export Cloud Data

After signing in:

1. Open the settings page.
2. Use the cloud JSON export action.
3. Copy the JSON from the dialog.

Export format:

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

Google Sheets export can be added later as a separate export adapter. It is not the primary database.

## 8. Cloud E2E Test

Cloud Playwright tests require environment variables:

```powershell
$env:SUPABASE_URL="https://your-project.supabase.co"
$env:SUPABASE_ANON_KEY="your-anon-key"
$env:SUPABASE_TEST_EMAIL="test@example.com"
$env:SUPABASE_TEST_PASSWORD="test-password"
```

Then run:

```powershell
cd e2e
npx playwright test tests/cloud_auth_and_data.spec.ts --project=chromium --reporter=list --retries=0
```

If any variable is missing, the cloud test is skipped.
