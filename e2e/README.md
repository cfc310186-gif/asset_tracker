# Asset Tracker — E2E Tests

Playwright test suite for the Flutter web app.

## Prerequisites

- Node.js ≥ 18
- Flutter SDK installed
- Chromium (installed via Playwright)

## Setup

```bash
cd e2e
npm install
npx playwright install chromium
```

## Running Tests

### Option A — Let Playwright start Flutter (slow, ~3 min cold start)

```bash
npm test
```

### Option B — Start Flutter server manually first (recommended for development)

Terminal 1:
```bash
# From project root
flutter run -d web-server --web-port 8081
```

Terminal 2:
```bash
cd e2e
npm test
```

### Run a specific suite

```bash
npm run test:navigation   # smoke tests (fast)
npm run test:dashboard    # dashboard screen
npm run test:cash         # cash CRUD
npm run test:stocks       # stocks CRUD
```

### Headed mode (watch browser)

```bash
npm run test:headed
```

### Debug mode (step through)

```bash
npm run test:debug
```

## View Report

```bash
npm run test:report
```

## Artifacts

On failure, Playwright saves:
- `artifacts/*.png` — screenshots
- `artifacts/videos/` — test replay
- `playwright-report/` — full HTML report

## Notes on Flutter Web E2E

- Uses `--web-renderer html` so DOM elements are accessible via role/text
- The app uses an in-memory SQLite database (sql.js WASM) — data does NOT persist between page reloads
- Stock price API calls will fail in test environment (expected) — tests are scoped to UI interactions
- Run tests serially (`workers: 1`) to avoid SQLite concurrency issues
