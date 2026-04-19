import { test, expect } from '@playwright/test'
import { BasePage } from '../pages/BasePage'

/**
 * Navigation smoke tests — verify the app loads and all main routes are reachable.
 * These run first (fast, no data mutation).
 */

test.describe('App navigation', () => {
  test('app loads and shows dashboard', async ({ page }) => {
    const base = new BasePage(page)
    await base.goto('/')

    // Title appears in either NavigationRail (desktop) or AppBar (mobile)
    await expect(page.getByText('資產管理').first()).toBeVisible()
    await page.screenshot({ path: 'artifacts/dashboard-initial.png' })
  })

  test('can navigate to all main sections', async ({ page }) => {
    const base = new BasePage(page)
    await base.goto('/')

    const sections = [
      { label: '股票', url: '/stocks' },
      { label: '不動產', url: '/real-estate' },
      { label: '貸款', url: '/loans' },
      { label: '現金', url: '/cash' },
      { label: '總覽', url: '/' },
    ]

    for (const { label, url } of sections) {
      await base.navigateTo(label)
      await expect(page).toHaveURL(new RegExp(url.replace('/', '\\/')))
      await page.screenshot({ path: `artifacts/nav-${label}.png` })
    }
  })

  test('can open settings', async ({ page }) => {
    const base = new BasePage(page)
    await base.goto('/')

    await page.getByRole('button', { name: /設定/i }).click()
    await expect(page).toHaveURL(/settings/)
    await expect(page.getByText('設定').first()).toBeVisible()
  })
})
