import { expect, type Page, test } from '@playwright/test';

test('auth smoke register enters the authenticated web shell', async ({
  context,
  page,
}) => {
  const email = smokeEmail('register');

  await registerThroughUi(page, email);

  await expect(
    page.getByRole('heading', { name: /session restored/i }),
  ).toBeVisible();
  expect(
    (await context.cookies()).some((cookie) => cookie.name === 'hed_session'),
  ).toBeTruthy();
});

test('auth smoke restore keeps the cookie session after reload', async ({
  page,
}) => {
  const email = smokeEmail('restore');

  await registerThroughUi(page, email);
  await expect(
    page.getByRole('heading', { name: /session restored/i }),
  ).toBeVisible();
  await page.reload();

  await expect(
    page.getByRole('heading', { name: /session restored/i }),
  ).toBeVisible();
  await expect(page.getByText(email)).toBeVisible();
});

test('auth smoke login re-enters the authenticated web shell after logout', async ({
  page,
}) => {
  const email = smokeEmail('login');

  await registerThroughUi(page, email);
  await logoutThroughUi(page);

  await page.getByLabel('Email').fill(email);
  await page.getByLabel('Password', { exact: true }).fill('Harness1!');
  await page.getByRole('button', { name: /^sign in$/i }).click();

  await expect(
    page.getByRole('heading', { name: /session restored/i }),
  ).toBeVisible();
  await expect(page.getByText(email)).toBeVisible();
});

test('auth smoke logout returns the browser to the login shell', async ({
  page,
}) => {
  const email = smokeEmail('logout');

  await registerThroughUi(page, email);
  await logoutThroughUi(page);

  await expect(
    page.getByRole('heading', { name: /^sign in\.$/i }),
  ).toBeVisible();
});

async function registerThroughUi(page: Page, email: string) {
  await page.goto('/register');
  await page.getByLabel('Email').fill(email);
  await page.getByLabel('Password', { exact: true }).fill('Harness1!');
  await page.getByLabel('Confirm password').fill('Harness1!');
  await page.getByRole('button', { name: /^create account$/i }).click();
}

async function logoutThroughUi(page: Page) {
  await page.getByRole('button', { name: /log out/i }).click();
  await expect(
    page.getByRole('heading', { name: /^sign in\.$/i }),
  ).toBeVisible();
}

function smokeEmail(scenario: string): string {
  return `web-smoke-${scenario}-${Date.now()}-${Math.floor(Math.random() * 1000)}@example.com`;
}
