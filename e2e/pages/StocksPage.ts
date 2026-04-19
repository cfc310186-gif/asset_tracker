import { Locator } from '@playwright/test'
import { BasePage } from './BasePage'

export class StocksPage extends BasePage {
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

  get emptyState(): Locator {
    return this.page.getByText('尚未新增股票')
  }

  /** Find a listed stock by symbol text. */
  stockTile(symbol: string): Locator {
    return this.page.getByText(symbol).first()
  }

  get refreshButton(): Locator {
    return this.page.getByRole('button', { name: /更新股價|refresh/i })
  }
}
