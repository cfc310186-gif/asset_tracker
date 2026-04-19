import { test, expect } from '@playwright/test'
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
    await page.getByRole('button', { name: /add/i }).click()
    await expect(page).toHaveURL(/stocks\/add/)

    // Fill symbol and name
    await stocks.symbolField.fill('2330')
    await stocks.nameField.fill('台積電')
    await stocks.quantityField.fill('1000')
    await stocks.avgCostField.fill('600')

    // Market should default to TWSE — verify the dropdown shows 上市
    await expect(page.getByText('上市').first()).toBeVisible()

    await page.screenshot({ path: 'artifacts/stock-add-twse.png' })
    await stocks.saveButton.click()

    // Back to list
    await expect(page).toHaveURL(/\/stocks$/)
    await expect(page.getByText('帳戶已新增').or(page.getByText('股票已新增'))).toBeVisible({
      timeout: 5000,
    })
    await expect(stocks.stockTile('2330')).toBeVisible()

    await page.screenshot({ path: 'artifacts/stock-after-add.png' })
  })

  test('can add a TPEx listed stock (上櫃)', async ({ page }) => {
    const stocks = new StocksPage(page)

    await page.getByRole('button', { name: /add/i }).click()
    await expect(page).toHaveURL(/stocks\/add/)

    await stocks.symbolField.fill('6547')
    await stocks.nameField.fill('高端疫苗')
    await stocks.quantityField.fill('500')
    await stocks.avgCostField.fill('100')

    // Change market to 上櫃
    await page.getByText('上市').click()
    await page.getByText('上櫃').click()

    await stocks.saveButton.click()
    await expect(page).toHaveURL(/\/stocks$/)
  })

  test('validates required fields on add form', async ({ page }) => {
    const stocks = new StocksPage(page)

    await page.getByRole('button', { name: /add/i }).click()
    await stocks.saveButton.click()

    // Stock form validations
    await expect(page.getByText(/請輸入/).first()).toBeVisible()
  })

  test('refresh button is visible and clickable', async ({ page }) => {
    await expect(page.getByRole('button', { name: /更新股價|refresh/i })).toBeVisible()
    // Click refresh (will likely fail in test environment since real APIs aren't available)
    // Just verify it doesn't crash
    await page.getByRole('button', { name: /更新股價|refresh/i }).click()
    await page.waitForTimeout(1000)
    await page.screenshot({ path: 'artifacts/stocks-after-refresh.png' })
  })
})
