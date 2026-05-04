import { expect, Locator, Page, test } from "@playwright/test";
import { BasePage } from "../pages/BasePage";

test.describe("Real estate", () => {
  test.setTimeout(120000);

  test("adds an asset with hidden legacy fields and refreshes dashboard totals", async ({
    page,
  }) => {
    const base = new BasePage(page);
    const name = `Cloud-safe-home-${Date.now()}`;

    await base.goto("/real-estate/add");
    const fields = page.getByRole("textbox");
    await expect(fields.nth(0)).toBeVisible();

    await fillFlutterTextBox(page, fields.nth(0), name);
    await fillFlutterTextBox(page, fields.nth(1), "9000000");
    await fillFlutterTextBox(page, fields.nth(2), "7500000");

    await page.getByRole("button").last().click();
    await expect(page).toHaveURL(/\/real-estate$/, { timeout: 10000 });
    await expect(page.getByText(name)).toBeVisible({ timeout: 10000 });

    await goHash(page, "/");
    await expect(
      page.locator('[flt-semantics-identifier="net-worth-card"]'),
    ).toHaveAttribute("aria-label", /NT\$9,000,000/, { timeout: 10000 });
  });
});

async function fillFlutterTextBox(page: Page, locator: Locator, value: string) {
  await locator.click();
  await page.keyboard.press(
    process.platform === "darwin" ? "Meta+A" : "Control+A",
  );
  await page.keyboard.press("Backspace");
  await page.keyboard.insertText(value);
}

async function goHash(page: Page, route: string) {
  await page.evaluate((nextRoute) => {
    window.location.hash = nextRoute;
  }, route);
  await new BasePage(page).waitForFlutterReady();
  await page.waitForTimeout(300);
}
