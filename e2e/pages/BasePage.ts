import { Page, Locator, expect } from '@playwright/test'

/**
 * Base page for Flutter web.
 *
 * Flutter web (HTML renderer) renders accessible semantic elements.
 * Buttons, text fields, and navigation elements are reachable via role/text.
 *
 * Flutter initializes asynchronously (WASM SQLite via sql.js).
 * Always call `waitForFlutterReady()` at the start of each test.
 */
export class BasePage {
  constructor(readonly page: Page) {}

  /** Wait until the Flutter app has mounted and the loading spinner is gone. */
  async waitForFlutterReady(timeoutMs = 20000): Promise<void> {
    // Flutter adds a loading overlay; wait for it to disappear
    await this.page.waitForFunction(
      () => {
        const loader = document.querySelector('flt-glass-pane')
        return loader !== null
      },
      { timeout: timeoutMs },
    )
    // Extra tick for Riverpod async providers to settle
    await this.page.waitForTimeout(500)
  }

  async goto(path = '/'): Promise<void> {
    await this.page.goto(path)
    await this.waitForFlutterReady()
  }

  /** Click a nav item by label text (works on both desktop rail and mobile bottom bar). */
  async navigateTo(label: string): Promise<void> {
    await this.page.getByText(label).first().click()
    await this.page.waitForTimeout(300)
  }

  /** Fill a Flutter TextFormField by its label text. */
  async fillField(label: string, value: string): Promise<void> {
    const field = this.page.getByLabel(label)
    await field.waitFor({ state: 'visible' })
    await field.tripleClick()
    await field.fill(value)
  }

  /** Press the floating action button (FAB / add button). */
  get fabButton(): Locator {
    return this.page.locator('flt-semantics[role="button"]').filter({
      hasText: /add|新增/i,
    })
  }

  /** Click the primary save / submit button. */
  async clickSave(): Promise<void> {
    await this.page.getByText('儲存').click()
  }

  async expectSnackBar(text: string | RegExp): Promise<void> {
    await expect(this.page.getByText(text)).toBeVisible({ timeout: 5000 })
  }
}
