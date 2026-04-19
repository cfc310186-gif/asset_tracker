import { Locator } from '@playwright/test'
import { BasePage } from './BasePage'

/**
 * Dashboard page object.
 *
 * Widgets are annotated with Flutter `Semantics(identifier: ...)` which renders
 * as the `flt-semantics-identifier` attribute on the semantic DOM node. Tests
 * prefer this over raw text to avoid false positives (e.g., "股票" appears in
 * both the navigation rail and the dashboard tile).
 */
export class DashboardPage extends BasePage {
  /** Net worth summary card (header + totals). */
  get netWorthCard(): Locator {
    return this.page.locator('[flt-semantics-identifier="net-worth-card"]')
  }

  private tile(title: string): Locator {
    // Semantic identifier first; fall back to text if Flutter version exposes
    // the identifier attribute under a different name.
    return this.page
      .locator(`[flt-semantics-identifier="asset-tile-${title}"]`)
      .or(this.page.getByLabel(new RegExp(`^${title} `)))
  }

  get stocksTile(): Locator {
    return this.tile('股票')
  }

  get realEstateTile(): Locator {
    return this.tile('不動產')
  }

  get cashTile(): Locator {
    return this.tile('現金')
  }

  get loansTile(): Locator {
    return this.tile('貸款')
  }

  get breakdownChart(): Locator {
    return this.page.locator('canvas').first()
  }

  async waitForData(): Promise<void> {
    await this.page.waitForFunction(() => {
      const spinners = document.querySelectorAll(
        'flt-semantics[aria-label*="載入"], flt-semantics[aria-label*="loading"]',
      )
      return spinners.length === 0
    }, { timeout: 10000 })
  }
}
