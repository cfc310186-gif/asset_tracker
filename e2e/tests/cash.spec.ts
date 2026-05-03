import { test, expect, Locator, Page } from '@playwright/test'
import { CashPage } from '../pages/CashPage'
import { BasePage } from '../pages/BasePage'

test.describe('Cash accounts - CRUD', () => {
  test.beforeEach(async ({ page }) => {
    const base = new BasePage(page)
    await base.goto('/')
    await base.navigateTo('/cash')
    await expect(page).toHaveURL(/cash/)
  })

  test('shows cash page', async ({ page }) => {
    await expect(
      page.locator('[flt-semantics-identifier="fab-add-cash"]'),
    ).toBeVisible()
    await page.screenshot({ path: 'artifacts/cash-list.png' })
  })

  test('can add a new cash account', async ({ page }) => {
    const cash = new CashPage(page)

    await cash.addButton.click()
    await expect(page.getByRole('textbox').first()).toBeVisible()

    await fillFlutterTextBox(page, page.getByRole('textbox').nth(0), 'cash-e2e-account')
    await fillFlutterTextBox(page, page.getByRole('textbox').nth(1), '100000')

    await page.screenshot({ path: 'artifacts/cash-add-form.png' })
    await page.getByRole('button').last().click()

    await expect(page).toHaveURL(/\/cash$/)
    await expect(cash.accountTile('cash-e2e-account')).toBeVisible()

    await page.screenshot({ path: 'artifacts/cash-after-add.png' })
  })

  test('validates required fields on add form', async ({ page }) => {
    const cash = new CashPage(page)

    await cash.addButton.click()
    await expect(page.getByRole('textbox').first()).toBeVisible()

    await page.getByRole('button').last().click()

    await expect(page.getByRole('textbox').nth(0)).toBeVisible()
    await expect(page.getByRole('textbox').nth(1)).toBeVisible()
  })

  test('validates balance must be a positive number', async ({ page }) => {
    const cash = new CashPage(page)

    await cash.addButton.click()
    await expect(page.getByRole('textbox').first()).toBeVisible()
    await fillFlutterTextBox(page, page.getByRole('textbox').nth(0), 'cash-e2e-invalid')
    await fillFlutterTextBox(page, page.getByRole('textbox').nth(1), '-100')
    await page.getByRole('button').last().click()

    await expect(page.getByRole('textbox').nth(1)).toBeVisible()

    await fillFlutterTextBox(page, page.getByRole('textbox').nth(1), 'abc')
    await page.getByRole('button').last().click()
    await expect(page.getByRole('textbox').nth(1)).toBeVisible()
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
