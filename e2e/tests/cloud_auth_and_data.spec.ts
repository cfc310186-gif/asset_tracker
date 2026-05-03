import { expect, Locator, Page, test } from '@playwright/test'
import { BasePage } from '../pages/BasePage'
import { StocksPage } from '../pages/StocksPage'

const cloudEnv = {
  url: process.env.SUPABASE_URL,
  anonKey: process.env.SUPABASE_ANON_KEY,
  email: process.env.SUPABASE_TEST_EMAIL,
  password: process.env.SUPABASE_TEST_PASSWORD,
}

test.describe('Cloud auth and data', () => {
  test.skip(
    !cloudEnv.url ||
      !cloudEnv.anonKey ||
      !cloudEnv.email ||
      !cloudEnv.password,
    'Supabase cloud E2E requires SUPABASE_URL, SUPABASE_ANON_KEY, SUPABASE_TEST_EMAIL, and SUPABASE_TEST_PASSWORD',
  )

  test.setTimeout(180000)

  test('shows the same stock after login, reload, and second browser context', async ({
    page,
    browser,
  }) => {
    const symbol = `CLD${Date.now().toString().slice(-4)}`
    const name = `CloudTest-${Date.now()}`

    await login(page)
    await addStock(page, { symbol, name })

    await page.reload()
    await new BasePage(page).waitForFlutterReady()
    await goToStocks(page)
    await expect(new StocksPage(page).stockTile(symbol)).toBeVisible({
      timeout: 20000,
    })

    const secondContext = await browser.newContext()
    const secondPage = await secondContext.newPage()
    try {
      await login(secondPage)
      await goToStocks(secondPage)
      await expect(new StocksPage(secondPage).stockTile(symbol)).toBeVisible({
        timeout: 20000,
      })
    } finally {
      await secondContext.close()
    }
  })
})

async function login(page: Page) {
  const base = new BasePage(page)
  await base.goto('/#/login')
  await fillFlutterTextBox(
    page,
    page.getByRole('textbox', { name: /^Email$/ }),
    cloudEnv.email!,
  )
  await fillFlutterTextBox(
    page,
    page.getByRole('textbox', { name: /^Password$/ }),
    cloudEnv.password!,
  )
  await page.getByRole('button', { name: /^Login$/ }).click()
  await expect(
    page.getByRole('group', { name: cloudEnv.email! }),
  ).toBeVisible({ timeout: 20000 })
  await expect(page.getByRole('button', { name: /^Sign out$/ })).toBeVisible()
}

async function addStock(
  page: Page,
  input: { symbol: string; name: string },
) {
  const stocks = new StocksPage(page)

  await goToStocks(page)
  await stocks.addButton.click()
  await fillFlutterTextBox(page, stocks.symbolField, input.symbol)
  await fillFlutterTextBox(page, stocks.nameField, input.name)
  await fillFlutterTextBox(page, stocks.quantityField, '1')
  await fillFlutterTextBox(page, stocks.avgCostField, '100')
  await stocks.saveButton.click()
  await expect(stocks.stockTile(input.symbol)).toBeVisible({ timeout: 20000 })
}

async function goToStocks(page: Page) {
  await page.evaluate(() => {
    window.location.hash = '/stocks'
  })
  await new BasePage(page).waitForFlutterReady()
  await page.waitForTimeout(300)
}

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
