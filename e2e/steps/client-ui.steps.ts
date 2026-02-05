import { Given, Then } from '@cucumber/cucumber';
import { expect } from '@playwright/test';
import { CustomWorld } from '../support/world.js';

Given('I open the client application at {string}', async function (this: CustomWorld, url: string) {
  if (!this.page) throw new Error('Page is not initialized');
  await this.page.goto(url);
});

Then('the page title should contain {string}', async function (this: CustomWorld, text: string) {
  if (!this.page) throw new Error('Page is not initialized');
  const title = await this.page.title();
  expect(title).toContain(text);
});

Then('the page should display {string}', async function (this: CustomWorld, text: string) {
  if (!this.page) throw new Error('Page is not initialized');
  await expect(this.page.locator(`text=${text}`)).toBeVisible();
});
