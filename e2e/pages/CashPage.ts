import { Locator } from '@playwright/test'
import { BasePage } from './BasePage'

/**
 * Cash accounts list / add-edit page object.
 *
 * Uses `flt-semantics-identifier` locators for the FAB and empty state
 * (see `cash_list_screen.dart`) to keep selectors stable across builds.
 */
export class CashPage extends BasePage {
  /** FAB that opens the add-cash route. */
  get addButton(): Locator {
    return this.fab('fab-add-cash')
  }

  // ---- form fields --------------------------------------------------------
  get nameField(): Locator {
    return this.page.getByLabel('帳戶名稱')
  }

  get bankField(): Locator {
    return this.page.getByLabel('銀行名稱')
  }

  get balanceField(): Locator {
    return this.page.getByLabel('餘額')
  }

  get saveButton(): Locator {
    return this.page.getByText('儲存')
  }

  // ---- list screen --------------------------------------------------------
  /** Empty-state container. Marked via `cash-empty-state` identifier. */
  get emptyState(): Locator {
    return this.page
      .locator('[flt-semantics-identifier="cash-empty-state"]')
      .or(this.page.getByText('尚未新增現金帳戶'))
  }

  /** Find a listed cash account by name. */
  accountTile(name: string): Locator {
    return this.page.getByText(name).first()
  }

  async navigateToAdd(): Promise<void> {
    await this.addButton.click()
    await this.page.waitForTimeout(300)
  }

  async fillAddForm(params: {
    name: string
    bank?: string
    balance: string
  }): Promise<void> {
    await this.nameField.fill(params.name)
    if (params.bank) await this.bankField.fill(params.bank)
    await this.balanceField.fill(params.balance)
  }
}
