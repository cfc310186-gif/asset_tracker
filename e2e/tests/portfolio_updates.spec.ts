import { expect, Locator, Page, test } from '@playwright/test'
import { BasePage } from '../pages/BasePage'
import { StocksPage } from '../pages/StocksPage'

test.describe('Portfolio updates', () => {
  test.setTimeout(120000)

  test('auto-calculates Taiwan margin amount and refreshes dashboard/reports', async ({
    page,
  }) => {
    const base = new BasePage(page)
    const stocks = new StocksPage(page)

    await base.goto('/')
    await expect(page.getByText('總淨資產').first()).toBeVisible()

    await base.navigateTo('股票')
    await stocks.addButton.click()
    await expect(stocks.symbolField).toBeVisible()

    await fillFlutterTextBox(page, stocks.symbolField, '2330')
    await fillFlutterTextBox(page, stocks.nameField, '台積電')
    await fillFlutterTextBox(page, stocks.quantityField, '10')
    await fillFlutterTextBox(page, stocks.avgCostField, '200')
    await page.getByRole('switch', { name: '是否融資' }).click()

    await expect(page.getByText('NT$1,200').first()).toBeVisible()
    await stocks.saveButton.click()
    await expect(page.getByText('股票已新增').first()).toBeVisible({
      timeout: 10000,
    })

    await goHash(page, '/loans')
    await expect(page.getByText('2330 融資')).toBeVisible({ timeout: 10000 })
    await expect(page.getByText('NT$1,200').first()).toBeVisible()

    await goHash(page, '/')
    await expect(
      page.locator('[flt-semantics-identifier="net-worth-card"]'),
    ).toHaveAttribute('aria-label', /NT\$800/, { timeout: 10000 })
    await expect(
      page.locator('[flt-semantics-identifier="asset-tile-股票"]'),
    ).toHaveAttribute('aria-label', /股票 NT\$2,000/)
    await expect(
      page.locator('[flt-semantics-identifier="asset-tile-貸款"]'),
    ).toHaveAttribute('aria-label', /貸款 NT\$1,200/)

    await goHash(page, '/reports')
    await expect(page.getByText(/最新淨資產 NT\$800/).first()).toBeVisible({
      timeout: 10000,
    })

    await page.locator('[flt-semantics-identifier="tab-comparison"]').click()
    await expect(
      page
        .getByText(/最新類別比較[\s\S]*股票 NT\$2,000[\s\S]*貸款 NT\$1,200/)
        .first(),
    ).toBeVisible()
  })
})

async function fillFlutterTextBox(
  page: Page,
  locator: Locator,
  value: string,
) {
  await locator.click()
  await page.keyboard.press(
    process.platform === 'darwin' ? 'Meta+A' : 'Control+A',
  )
  await page.keyboard.press('Backspace')
  await page.keyboard.insertText(value)
}

async function goHash(page: Page, route: string) {
  await page.evaluate((nextRoute) => {
    window.location.hash = nextRoute
  }, route)
  await page.waitForTimeout(500)
}
