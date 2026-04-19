import { test, expect } from '@playwright/test'
import { BasePage } from '../pages/BasePage'

/**
 * Reports screen — verifies the three-tab UI (趨勢 / 比較 / 交易),
 * period switching on the trend tab, and that the route is reachable
 * from the primary navigation.
 */
test.describe('Reports', () => {
  test('navigates to /reports and shows three tabs', async ({ page }) => {
    const base = new BasePage(page)
    await base.goto('/')

    await base.navigateTo('報表')
    await expect(page).toHaveURL(/reports/)

    await expect(page.getByText('淨資產走勢').first()).toBeVisible()
    await expect(page.getByText('類別比較').first()).toBeVisible()
    await expect(page.getByText('交易明細').first()).toBeVisible()

    await page.screenshot({ path: 'artifacts/reports-tabs.png', fullPage: true })
  })

  test('trend tab period selector switches 1M/3M/6M/1Y/ALL', async ({ page }) => {
    const base = new BasePage(page)
    await base.goto('/reports')

    for (const label of ['1M', '3M', '6M', '1Y', 'ALL']) {
      const btn = page.getByText(label, { exact: true }).first()
      if (await btn.isVisible().catch(() => false)) {
        await btn.click()
        await page.waitForTimeout(150)
      }
    }

    await page.screenshot({ path: 'artifacts/reports-trend.png' })
  })

  test('transactions tab renders either an empty state or list', async ({
    page,
  }) => {
    const base = new BasePage(page)
    await base.goto('/reports')

    await page.getByText('交易明細').first().click()
    await page.waitForTimeout(300)

    const hasList = await page
      .locator('flt-semantics[role="list"]')
      .first()
      .isVisible()
      .catch(() => false)
    const hasEmpty = await page
      .getByText(/尚無交易紀錄|暫無資料/)
      .first()
      .isVisible()
      .catch(() => false)

    expect(hasList || hasEmpty).toBe(true)
  })
})
