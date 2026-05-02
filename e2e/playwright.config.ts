import { defineConfig, devices } from '@playwright/test'

export default defineConfig({
  testDir: './tests',
  fullyParallel: false, // Flutter web DB is in-memory — run serially to avoid conflicts
  forbidOnly: !!process.env.CI,
  retries: process.env.CI ? 2 : 1,
  workers: 1,
  reporter: [
    ['html', { outputFolder: 'playwright-report', open: 'never' }],
    ['list'],
  ],
  use: {
    baseURL: 'http://localhost:8081',
    trace: 'on-first-retry',
    screenshot: 'only-on-failure',
    video: 'retain-on-failure',
    actionTimeout: 15000,
    navigationTimeout: 30000,
    // Flutter web needs time to initialize WASM/SQLite
    launchOptions: {
      args: ['--disable-web-security'], // allow WASM CORS in local dev
    },
  },
  projects: [
    {
      name: 'chromium',
      use: { ...devices['Desktop Chrome'], viewport: { width: 1280, height: 800 } },
    },
    {
      name: 'mobile-chrome',
      use: { ...devices['Pixel 5'] },
    },
  ],
  // Start Flutter web server before tests.
  // Build and serve the release bundle. `flutter run -d web-server` can hang
  // on the DDC debug loader in headless Playwright sessions.
  webServer: {
    command:
      'cd .. && flutter build web --release && npx --yes http-server build/web -p 8081 --silent -c-1 --proxy http://localhost:8081?',
    url: 'http://localhost:8081',
    reuseExistingServer: true, // reuse if already running (`flutter run` is slow)
    timeout: 240000,
    stderr: 'pipe',
  },
})
