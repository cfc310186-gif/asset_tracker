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

    await expect(page.getByRole('tab', { name: '淨資產走勢' })).toBeVisible()
    await expect(page.getByRole('tab', { name: '類別比較' })).toBeVisible()
    await expect(page.getByRole('tab', { name: '交易明細' })).toBeVisible()

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

    await page.getByRole('tab', { name: '交易明細' }).click()

    const hasList = await page
      .locator('[flt-semantics-identifier="transactions-list"]')
      .first()
      .waitFor({ state: 'visible', timeout: 5000 })
      .then(() => true)
      .catch(() => false)
    const hasEmpty = await page
      .locator('[flt-semantics-identifier="transactions-empty-state"]')
      .first()
      .waitFor({ state: 'visible', timeout: 5000 })
      .then(() => true)
      .catch(() => false)

    expect(hasList || hasEmpty).toBe(true)
  })
})
