import { Locator } from '@playwright/test'
import { BasePage } from './BasePage'

/**
 * Stocks list / add-edit page object.
 *
 * Prefers `flt-semantics-identifier` attributes (see `Semantics(identifier: ...)`
 * wrappers in `stock_list_screen.dart`) over raw text, to avoid collisions
 * with identical strings elsewhere in the page (e.g. navigation labels).
 */
export class StocksPage extends BasePage {
  // ---- form fields (add/edit) ---------------------------------------------
  get symbolField(): Locator {
    return this.page.getByLabel('股票代碼')
  }

  get nameField(): Locator {
    return this.page.getByLabel('股票名稱')
  }

  get quantityField(): Locator {
    return this.page.getByLabel('持有股數')
  }

  get avgCostField(): Locator {
    return this.page.getByLabel('平均成本')
  }

  get saveButton(): Locator {
    return this.page.getByText('儲存')
  }

  // ---- list screen --------------------------------------------------------
  /** Empty-state container. Marked via `stocks-empty-state` identifier. */
  get emptyState(): Locator {
    return this.page
      .locator('[flt-semantics-identifier="stocks-empty-state"]')
      .or(this.page.getByText('尚未新增股票'))
  }

  /** FAB that opens the add-stock route. */
  get addButton(): Locator {
    return this.fab('fab-add-stock')
  }

  /** Refresh-prices toolbar button. */
  get refreshButton(): Locator {
    return this.page
      .locator('[flt-semantics-identifier="btn-refresh-prices"]')
      .or(this.page.getByRole('button', { name: /更新股價/i }))
  }

  /** Banner shown when no Alpha Vantage key is configured. */
  get noApiKeyBanner(): Locator {
    return this.page
      .locator('[flt-semantics-identifier="banner-no-api-key"]')
      .or(this.page.getByText(/免費來源/))
  }

  /** Find a listed stock row by symbol text. */
  stockTile(symbol: string): Locator {
    return this.page.getByText(symbol).first()
  }
}
