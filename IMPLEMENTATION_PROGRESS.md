# Implementation Progress — v2.0 Optimization

Plan reference: `/root/.claude/plans/uiux-serene-planet.md`
Branch: `claude/analyze-and-optimize-plan-TbLDf`

## Resume instructions
If this session paused (token limit), next session should:
1. Read this file first
2. Check `git log` to see latest commit
3. Pick up at the first `[ ]` unchecked box below
4. After finishing each box, tick it and commit

## Stage 1 — Data layer + theme + free price (lowest risk)

### 1a. Free price query (A5)
- [x] Create `stooq_provider.dart` (CSV, no key, US/UK)
- [x] Create `foreign_waterfall_provider.dart` (Stooq → AV → NoOp)
- [x] Add `corsProxyUrlProvider` + `prefCorsProxy` constant
- [x] Wire into `price_providers.dart` (replace direct AV/NoOp with waterfall)
- [x] Update `_NoApiKeyBanner` copy in `stock_list_screen.dart`
- [x] Add CORS proxy input to `settings_screen.dart`
- [x] Commit: "feat: Stooq free price provider + foreign waterfall"

### 1b. Dark theme
- [x] Extend `app_theme.dart` with `darkTheme` + `_build(Brightness)`
- [x] Add `themeModeProvider` + load/save helpers in `settings_providers.dart`
- [x] Add `prefThemeMode` constant
- [x] Wire `MaterialApp.router` in `app.dart` with `themeMode` + `darkTheme`
- [x] Add theme switcher UI in `settings_screen.dart`
- [x] Commit: "feat: dark mode + theme mode switcher"

### 1c. DB schema v2 (transactions + snapshots)
- [x] Create `lib/data/database/tables/transactions_table.dart`
- [x] Create `lib/data/database/tables/net_worth_snapshots_table.dart`
- [x] Create `lib/data/database/daos/transaction_dao.dart`
- [x] Create `lib/data/database/daos/net_worth_snapshot_dao.dart`
- [x] Update `app_database.dart` schemaVersion 1→2 + migration
- [x] Run `flutter pub run build_runner build`
- [x] Commit: "feat: schema v2 — transactions + net_worth_snapshots"

## Stage 2 — Use cases wiring
- [x] Create `domain/models/transaction.dart`
- [x] Create `domain/models/time_series_point.dart`
- [x] Create `domain/usecases/record_transaction.dart`
- [x] Create `domain/usecases/capture_net_worth_snapshot.dart`
- [x] Create `domain/usecases/build_net_worth_series.dart`
- [x] Create `domain/usecases/build_category_comparison.dart`
- [x] Hook `RecordTransaction` into `stock_repository_impl.dart`
- [x] Hook `RecordTransaction` into `cash_repository_impl.dart`
- [x] Trigger `CaptureNetWorthSnapshot` at app startup
- [x] Commit: "feat: transaction recording + daily net worth snapshots"

## Stage 3 — Reports + Dashboard (UI work, most complex)
- [ ] Create `presentation/reports/reports_screen.dart` with 3 tabs
- [ ] Create `widgets/net_worth_trend_chart.dart`
- [ ] Create `widgets/category_comparison_chart.dart`
- [ ] Create `widgets/transactions_list.dart`
- [ ] Add `/reports` route + nav item
- [ ] Dashboard sparkline
- [ ] Dashboard desktop two-column layout
- [ ] Commit: "feat: reports screen + dashboard revamp"

## Stage 4 — Tests + CI
- [ ] Add `http_mock_adapter` to dev_dependencies
- [ ] `test/providers/stooq_provider_test.dart`
- [ ] `test/providers/foreign_waterfall_provider_test.dart`
- [ ] `test/usecases/calculate_net_worth_test.dart`
- [ ] `test/usecases/record_transaction_test.dart`
- [ ] `test/usecases/capture_net_worth_snapshot_test.dart`
- [ ] `e2e/tests/price_no_key.spec.ts`
- [ ] `e2e/tests/theme.spec.ts`
- [ ] `e2e/tests/reports.spec.ts`
- [ ] `.github/workflows/test.yml`
- [ ] Commit: "test: unit + provider + e2e coverage; add CI"

## Resumption cheat sheet
- Each stage's files are listed in the plan's "關鍵檔案" section
- All commits target `claude/analyze-and-optimize-plan-TbLDf`
- `flutter test` + `flutter analyze` should pass before each commit
