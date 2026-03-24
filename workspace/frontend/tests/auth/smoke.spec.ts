import { expect, test } from '@playwright/test';

test('auth register, login, and logout work in the web shell', async ({ context, page }) => {
  const email = `web-smoke-${Date.now()}@example.com`;

  await page.goto('/register');

  await page.getByLabel('Email').fill(email);
  await page.getByLabel('Password').fill('hunter2');
  await page.getByRole('button', { name: /create account and issue cookie/i }).click();

  await expect(page.getByRole('heading', { name: /cookie session restored/i })).toBeVisible();
  expect((await context.cookies()).some((cookie) => cookie.name === 'hed_session')).toBeTruthy();

  await page.getByRole('button', { name: /logout and revoke current session/i }).click();
  await expect(page.getByRole('heading', { name: /re-enter the operations room/i })).toBeVisible();

  await page.getByLabel('Email').fill(email);
  await page.getByLabel('Password').fill('hunter2');
  await page.getByRole('button', { name: /sign in with cookie auth/i }).click();

  await expect(page.getByRole('heading', { name: /cookie session restored/i })).toBeVisible();
  await page.getByRole('button', { name: /logout and revoke current session/i }).click();
  await expect(page.getByRole('heading', { name: /re-enter the operations room/i })).toBeVisible();
});
