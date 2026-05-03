import { test, expect, Locator, Page } from '@playwright/test'
import { DashboardPage } from '../pages/DashboardPage'

test.describe('Dashboard', () => {
  test('shows net worth card and category tiles', async ({ page }) => {
    const dashboard = new DashboardPage(page)
    await dashboard.goto('/')

    await expect(dashboard.netWorthCard).toBeVisible()
    await expect(dashboard.monthlyCashFlowCard).toBeVisible()

    await expect(dashboard.stocksTile).toBeVisible()
    await expect(dashboard.realEstateTile).toBeVisible()
    await expect(dashboard.cashTile).toBeVisible()
    await expect(dashboard.loansTile).toBeVisible()

    await page.screenshot({ path: 'artifacts/dashboard-full.png', fullPage: true })
  })

  test('category tile navigates to the correct section', async ({ page }) => {
    const dashboard = new DashboardPage(page)
    await dashboard.goto('/')

    await dashboard.stocksTile.click()
    await expect(page).toHaveURL(/stocks/)

    await page.goBack()
    await dashboard.waitForFlutterReady()

    await dashboard.cashTile.click()
    await expect(page).toHaveURL(/cash/)
  })

  test('renders dashboard data after app initialization', async ({ page }) => {
    const dashboard = new DashboardPage(page)
    await dashboard.goto('/')

    await expect(dashboard.netWorthCard).toBeVisible()
    await expect(dashboard.monthlyCashFlowCard).toBeVisible()
  })

  test('renders monthly cash flow card in a narrow viewport', async ({ page }) => {
    await page.setViewportSize({ width: 393, height: 851 })
    const dashboard = new DashboardPage(page)
    await dashboard.goto('/')

    await expect(dashboard.monthlyCashFlowCard).toBeVisible()
  })

  test('updates monthly cash flow after adding cash interest and loan payment', async ({
    page,
  }) => {
    const dashboard = new DashboardPage(page)
    await dashboard.goto('/')

    await goHash(page, '/cash')
    await page.locator('[flt-semantics-identifier="fab-add-cash"]').click()
    await fillFlutterTextBox(page, page.getByLabel('帳戶名稱'), 'cash-flow-e2e')
    await fillFlutterTextBox(page, page.getByLabel('餘額'), '120000')
    await fillFlutterTextBox(page, page.getByLabel('年利率 (%)'), '1.2')
    await page.getByText('儲存').click()
    await expect(page).toHaveURL(/\/cash$/)

    await goHash(page, '/loans')
    await page.getByRole('button', { name: '新增貸款' }).click()
    await fillFlutterTextBox(page, page.getByLabel('貸款名稱'), 'cash-flow-loan-e2e')
    await fillFlutterTextBox(page, page.getByLabel('本金'), '1200')
    await fillFlutterTextBox(page, page.getByLabel('剩餘餘額'), '1200')
    await fillFlutterTextBox(page, page.getByLabel('年利率 (%)'), '0.0001')
    await fillFlutterTextBox(page, page.getByLabel('貸款期限（月）'), '12')
    await page.getByText('儲存').click()
    await expect(page).toHaveURL(/\/loans$/)

    await goHash(page, '/')
    await expect(dashboard.monthlyCashFlowCard).toHaveAttribute(
      'aria-label',
      /正現金流 NT\$120[\s\S]*負現金流 -NT\$100[\s\S]*淨現金流 \+NT\$20/,
      { timeout: 10000 },
    )
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

async function goHash(page: Page, route: string) {
  await page.evaluate((nextRoute) => {
    window.location.hash = nextRoute
  }, route)
  await page.waitForTimeout(500)
}
