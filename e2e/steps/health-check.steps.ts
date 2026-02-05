import { Given, When, Then } from '@cucumber/cucumber';
import { expect } from '@playwright/test';
import { CustomWorld } from '../support/world.js';

Given(
  'the backend service is running on {string}',
  async function (this: CustomWorld, url: string) {
    this.baseUrl = url;
  }
);

Given('the client service is running on {string}', async function (this: CustomWorld, url: string) {
  this.baseUrl = url;
});

When('I request the health endpoint', async function (this: CustomWorld) {
  if (!this.page) throw new Error('Page is not initialized');
  this.response = await this.page.request.get(`${this.baseUrl}/health`);
});

Then('the response status should be {int}', async function (this: CustomWorld, statusCode: number) {
  if (!this.response) throw new Error('Response is not available');
  expect(this.response.status()).toBe(statusCode);
});

Then('the response should contain {string}', async function (this: CustomWorld, text: string) {
  if (!this.response) throw new Error('Response is not available');
  const body = await this.response.json();
  const bodyString = JSON.stringify(body);
  expect(bodyString).toContain(text);
});
