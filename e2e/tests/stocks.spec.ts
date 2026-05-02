import { Locator, Page, test, expect } from '@playwright/test'
import { StocksPage } from '../pages/StocksPage'
import { BasePage } from '../pages/BasePage'

test.describe('Stocks — CRUD', () => {
  test.beforeEach(async ({ page }) => {
    const base = new BasePage(page)
    await base.goto('/')
    await base.navigateTo('股票')
    await expect(page).toHaveURL(/stocks/)
  })

  test('shows stocks list screen', async ({ page }) => {
    await expect(page.getByText('股票').first()).toBeVisible()
    await page.screenshot({ path: 'artifacts/stocks-list.png' })
  })

  test('can add a Taiwan listed stock (TWSE)', async ({ page }) => {
    const stocks = new StocksPage(page)

    // Open add screen
    await stocks.addButton.click()
    await expect(stocks.symbolField).toBeVisible()

    // Fill symbol and name
    await fillFlutterTextBox(page, stocks.symbolField, '2330')
    await fillFlutterTextBox(page, stocks.nameField, '台積電')
    await fillFlutterTextBox(page, stocks.quantityField, '1000')
    await fillFlutterTextBox(page, stocks.avgCostField, '600')

    // Taiwan numeric symbols are auto-detected.
    await expect(page.getByText(/市場：台股/).first()).toBeVisible()

    await page.screenshot({ path: 'artifacts/stock-add-twse.png' })
    await stocks.saveButton.click()

    // Back to list
    await expect(
      page.getByText('帳戶已新增').or(page.getByText('股票已新增')).first(),
    ).toBeVisible({ timeout: 5000 })
    await expect(stocks.stockTile('2330')).toBeVisible()

    await page.screenshot({ path: 'artifacts/stock-after-add.png' })
  })

  test('can add another Taiwan numeric stock', async ({ page }) => {
    const stocks = new StocksPage(page)

    await stocks.addButton.click()
    await expect(stocks.symbolField).toBeVisible()

    await fillFlutterTextBox(page, stocks.symbolField, '6547')
    await fillFlutterTextBox(page, stocks.nameField, '高端疫苗')
    await fillFlutterTextBox(page, stocks.quantityField, '500')
    await fillFlutterTextBox(page, stocks.avgCostField, '100')
    await stocks.saveButton.click()
    await expect(stocks.stockTile('6547')).toBeVisible({ timeout: 10000 })
  })

  test('validates required fields on add form', async ({ page }) => {
    const stocks = new StocksPage(page)

    await stocks.addButton.click()
    await stocks.saveButton.click()

    // Stock form validations
    await expect(page.getByText(/請輸入/).first()).toBeVisible()
  })

  test('refresh button is visible and clickable', async ({ page }) => {
    await expect(new StocksPage(page).refreshButton).toBeVisible()
    // Click refresh (will likely fail in test environment since real APIs aren't available)
    // Just verify it doesn't crash
    await new StocksPage(page).refreshButton.click()
    await page.waitForTimeout(1000)
    await page.screenshot({ path: 'artifacts/stocks-after-refresh.png' })
  })
})

async function fillFlutterTextBox(page: Page, locator: Locator, value: string) {
  await locator.click()
  await page.keyboard.press(
    process.platform === 'darwin' ? 'Meta+A' : 'Control+A',
  )
  await page.keyboard.press('Backspace')
  await page.keyboard.insertText(value)
}
