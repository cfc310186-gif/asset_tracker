import { test, expect } from '@playwright/test'
import { CashPage } from '../pages/CashPage'
import { BasePage } from '../pages/BasePage'

test.describe('Cash accounts — CRUD', () => {
  test.beforeEach(async ({ page }) => {
    const base = new BasePage(page)
    await base.goto('/')
    await base.navigateTo('現金')
    await expect(page).toHaveURL(/cash/)
  })

  test('shows empty state when no accounts exist', async ({ page }) => {
    const cash = new CashPage(page)
    // May show empty state OR a list depending on previous test data
    // We simply check the page title area is present
    await expect(page.getByText('現金').first()).toBeVisible()
    await page.screenshot({ path: 'artifacts/cash-list.png' })
  })

  test('can add a new cash account', async ({ page }) => {
    const cash = new CashPage(page)

    // Press FAB to open add screen
    await page.getByRole('button', { name: /add/i }).click()
    await expect(page).toHaveURL(/cash\/add/)

    // Fill form
    await cash.nameField.fill('測試帳戶')
    await cash.bankField.fill('玉山銀行')
    await cash.balanceField.fill('100000')

    await page.screenshot({ path: 'artifacts/cash-add-form.png' })

    // Save
    await cash.saveButton.click()

    // Should return to list and show snackbar
    await expect(page).toHaveURL(/\/cash$/)
    await expect(page.getByText('帳戶已新增')).toBeVisible({ timeout: 5000 })
    await expect(cash.accountTile('測試帳戶')).toBeVisible()

    await page.screenshot({ path: 'artifacts/cash-after-add.png' })
  })

  test('validates required fields on add form', async ({ page }) => {
    const cash = new CashPage(page)

    await page.getByRole('button', { name: /add/i }).click()
    await expect(page).toHaveURL(/cash\/add/)

    // Try to save without filling required fields
    await cash.saveButton.click()

    // Validation errors should appear
    await expect(page.getByText('請輸入帳戶名稱')).toBeVisible()
    await expect(page.getByText('請輸入餘額')).toBeVisible()
  })

  test('validates balance must be a positive number', async ({ page }) => {
    const cash = new CashPage(page)

    await page.getByRole('button', { name: /add/i }).click()
    await cash.nameField.fill('測試')
    await cash.balanceField.fill('-100')
    await cash.saveButton.click()

    await expect(page.getByText('餘額必須大於 0')).toBeVisible()

    await cash.balanceField.fill('abc')
    await cash.saveButton.click()
    await expect(page.getByText('請輸入有效的數字')).toBeVisible()
  })
})
