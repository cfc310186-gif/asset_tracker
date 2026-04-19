import { Page, Locator, expect } from '@playwright/test'

/**
 * Base page for Flutter web.
 *
 * Flutter web renders accessible semantic elements as `flt-semantics` DOM nodes.
 * Widgets annotated with `Semantics(identifier: ...)` expose the identifier as
 * the `flt-semantics-identifier` attribute — a stable, collision-free target
 * that tests should prefer over visible text.
 *
 * Flutter initializes asynchronously (WASM SQLite via sql.js).
 * Always call `waitForFlutterReady()` at the start of each test.
 */
export class BasePage {
  constructor(readonly page: Page) {}

  /** Wait until the Flutter app has mounted and the loading spinner is gone. */
  async waitForFlutterReady(timeoutMs = 20000): Promise<void> {
    await this.page.waitForFunction(
      () => {
        const loader = document.querySelector('flt-glass-pane')
        return loader !== null
      },
      { timeout: timeoutMs },
    )
    await this.page.waitForTimeout(500)
  }

  async goto(path = '/'): Promise<void> {
    await this.page.goto(path)
    await this.waitForFlutterReady()
  }

  /**
   * Navigate via the primary nav. Resolves routes by label to the stable
   * `nav-<route>` semantic identifier wired in `responsive_scaffold.dart`.
   * Falls back to visible text when the identifier is not available
   * (e.g. tests running against an older build).
   */
  async navigateTo(labelOrRoute: string): Promise<void> {
    const route = LABEL_TO_ROUTE[labelOrRoute] ?? labelOrRoute
    const byIdentifier = this.page.locator(
      `[flt-semantics-identifier="nav-${route}"]`,
    )

    if (await byIdentifier.count()) {
      await byIdentifier.first().click()
    } else {
      // Legacy fallback — target text that matches the label form.
      const fallbackLabel = ROUTE_TO_LABEL[route] ?? labelOrRoute
      await this.page.getByText(fallbackLabel).first().click()
    }
    await this.page.waitForTimeout(300)
  }

  /** Fill a Flutter TextFormField by its label text. */
  async fillField(label: string, value: string): Promise<void> {
    const field = this.page.getByLabel(label)
    await field.waitFor({ state: 'visible' })
    await field.tripleClick()
    await field.fill(value)
  }

  /** FAB by identifier, preferred over text search. */
  fab(identifier: string): Locator {
    return this.page.locator(`[flt-semantics-identifier="${identifier}"]`)
  }

  /** Click the primary save / submit button. */
  async clickSave(): Promise<void> {
    await this.page.getByText('儲存').click()
  }

  async expectSnackBar(text: string | RegExp): Promise<void> {
    await expect(this.page.getByText(text)).toBeVisible({ timeout: 5000 })
  }
}

/** Nav destinations: label <-> route, mirrors responsive_scaffold.dart. */
const LABEL_TO_ROUTE: Record<string, string> = {
  總覽: '/',
  股票: '/stocks',
  不動產: '/real-estate',
  貸款: '/loans',
  現金: '/cash',
  報表: '/reports',
  設定: '/settings',
}

const ROUTE_TO_LABEL: Record<string, string> = Object.fromEntries(
  Object.entries(LABEL_TO_ROUTE).map(([k, v]) => [v, k]),
)
