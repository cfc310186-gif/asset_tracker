import { Locator } from '@playwright/test'
import { BasePage } from './BasePage'

export class CashPage extends BasePage {
  get addButton(): Locator {
    return this.page.getByRole('button', { name: /add|新增/i })
  }

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

  get emptyState(): Locator {
    return this.page.getByText('尚未新增現金帳戶')
  }

  /** Find a listed cash account by name. */
  accountTile(name: string): Locator {
    return this.page.getByText(name).first()
  }

  async navigateToAdd(): Promise<void> {
    // FAB on list screen
    await this.page.getByRole('button').filter({ hasText: '' }).last().click()
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
