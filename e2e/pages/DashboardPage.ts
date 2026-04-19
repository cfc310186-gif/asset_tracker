import { Locator } from '@playwright/test'
import { BasePage } from './BasePage'

export class DashboardPage extends BasePage {
  /** Net worth card headline. */
  get netWorthCard(): Locator {
    return this.page.getByText('淨資產')
  }

  /** Asset category tiles. */
  get stocksTile(): Locator {
    return this.page.getByText('股票').first()
  }

  get realEstateTile(): Locator {
    return this.page.getByText('不動產').first()
  }

  get cashTile(): Locator {
    return this.page.getByText('現金').first()
  }

  get loansTile(): Locator {
    return this.page.getByText('貸款').first()
  }

  get breakdownChart(): Locator {
    // fl_chart renders an SVG canvas — check it exists in DOM
    return this.page.locator('canvas').first()
  }

  async waitForData(): Promise<void> {
    // Spinner disappears when FutureProvider resolves
    await this.page.waitForFunction(() => {
      const spinners = document.querySelectorAll(
        'flt-semantics[aria-label*="載入"], flt-semantics[aria-label*="loading"]',
      )
      return spinners.length === 0
    }, { timeout: 10000 })
  }
}
