import { expect, Locator, Page, test } from '@playwright/test'
import { BasePage } from '../pages/BasePage'
import { StocksPage } from '../pages/StocksPage'

const TWSE_RE = /mis\.twse\.com\.tw\/stock\/api\/getStockInfo\.jsp/
const TPEX_RE = /tpex\.org\.tw\/openapi\/v1\/tpex_mainboard_quotes/
const EMERGING_RE = /tpex\.org\.tw\/openapi\/v1\/tpex_esb_latest_statistics/
const STOOQ_RE = /stooq\.com\/q\/l/

test.describe('Stock price auto update', () => {
  test.setTimeout(120000)

  test('updates Taiwan, US, and UK stock prices from mocked providers', async ({
    page,
  }) => {
    const calls = await mockStockPriceProviders(page)
    const base = new BasePage(page)
    const stocks = new StocksPage(page)

    await base.goto('/#/stocks')
    await expect(page).toHaveURL(/stocks/)

    await addStock(page, stocks, {
      symbol: '2330',
      name: '台積電',
      quantity: '10',
      avgCost: '500',
    })
    await addStock(page, stocks, {
      symbol: 'AAPL',
      name: 'Apple',
      quantity: '2',
      avgCost: '100',
    })
    await addStock(page, stocks, {
      symbol: 'BP',
      name: 'BP',
      quantity: '3',
      avgCost: '5',
      market: '英股',
    })

    await expect(stocks.stockTile('2330')).toBeVisible()
    await expect(stocks.stockTile('AAPL')).toBeVisible()
    await expect(stocks.stockTile('BP')).toBeVisible()

    await stocks.refreshButton.click()

    await expect(page.getByText(/已更新 3\/3/).first()).toBeVisible({
      timeout: 20000,
    })
    await expect(
      page.getByRole('button', { name: /2330[\s\S]*NT\$650/ }),
    ).toBeVisible()
    await expect(
      page.getByRole('button', { name: /AAPL[\s\S]*\$211\.70/ }),
    ).toBeVisible()
    await expect(
      page.getByRole('button', { name: /BP[\s\S]*\$6\.42/ }),
    ).toBeVisible()

    expect(calls.twse).toBeGreaterThanOrEqual(1)
    expect(calls.stooqAapl).toBeGreaterThanOrEqual(1)
    expect(calls.stooqBp).toBeGreaterThanOrEqual(1)

    await page.screenshot({
      path: 'artifacts/stock-price-auto-update.png',
      fullPage: true,
    })
  })
})

async function addStock(
  page: Page,
  stocks: StocksPage,
  input: {
    symbol: string
    name: string
    quantity: string
    avgCost: string
    market?: '美股' | '英股'
  },
) {
  await stocks.addButton.click()
  const symbolField = page.getByRole('textbox', { name: /股票代號/ })
  const nameField = page.getByRole('textbox', { name: /股票名稱/ })
  const quantityField = page.getByRole('textbox', { name: /股數/ })
  const avgCostField = page.getByRole('textbox', { name: /平均成本/ })

  await expect(symbolField).toBeVisible()
  await fillFlutterTextBox(page, symbolField, input.symbol)

  if (input.market) {
    await page.getByRole('button', { name: /市場.*美股/ }).click()
    await page.getByRole('menuitem', { name: input.market }).click()
    await fillFlutterTextBox(page, symbolField, input.symbol)
  }

  await fillFlutterTextBox(page, nameField, input.name)
  await fillFlutterTextBox(page, quantityField, input.quantity)
  await fillFlutterTextBox(page, avgCostField, input.avgCost)
  await stocks.saveButton.click()

  await expect(stocks.stockTile(input.symbol)).toBeVisible({ timeout: 10000 })
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

async function mockStockPriceProviders(page: Page) {
  const calls = {
    twse: 0,
    tpex: 0,
    emerging: 0,
    stooqAapl: 0,
    stooqBp: 0,
  }

  await page.route(TWSE_RE, async (route) => {
    calls.twse += 1
    await route.fulfill({
      status: 200,
      contentType: 'application/json',
      body: JSON.stringify({
        msgArray: [{ c: '2330', n: '台積電', z: '650', y: '640' }],
      }),
    })
  })

  await page.route(TPEX_RE, async (route) => {
    calls.tpex += 1
    await route.fulfill({
      status: 200,
      contentType: 'application/json',
      body: '[]',
    })
  })

  await page.route(EMERGING_RE, async (route) => {
    calls.emerging += 1
    await route.fulfill({
      status: 200,
      contentType: 'application/json',
      body: '[]',
    })
  })

  await page.route(STOOQ_RE, async (route) => {
    const url = route.request().url().toLowerCase()
    const isBp = url.includes('bp.uk')
    if (isBp) {
      calls.stooqBp += 1
    } else {
      calls.stooqAapl += 1
    }

    await route.fulfill({
      status: 200,
      contentType: 'text/csv',
      body: isBp
        ? csvQuote('BP.UK', 'BP', '6.42')
        : csvQuote('AAPL.US', 'APPLE', '211.70'),
    })
  })

  return calls
}

function csvQuote(symbol: string, name: string, close: string) {
  return (
    'Symbol,Name,Date,Time,Open,High,Low,Close,Volume\n' +
    `${symbol},${name},2026-05-01,22:00:00,1,1,1,${close},1000`
  )
}
