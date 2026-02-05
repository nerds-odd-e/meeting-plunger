import { Given, When, Then } from '@cucumber/cucumber';
import { expect } from '@playwright/test';
import path from 'path';
import { CustomWorld } from '../support/world.js';

Given(
  'OpenAI transcription API replys the following when the model is {string}:',
  async function (this: CustomWorld, _model: string, _docString: string) {
    // TODO: Mock OpenAI API - skip for now
  }
);

When(
  'I convert the audio file {string} into text',
  async function (this: CustomWorld, filename: string) {
    if (!this.page) throw new Error('Page is not initialized');

    // Navigate to the client application
    await this.page.goto('http://localhost:3000');

    // Find the file upload control (with shorter timeout for clearer error)
    const fileInput = this.page.locator('input[type="file"]');
    await fileInput.waitFor({ timeout: 3000 });

    // Upload the fixture file
    const fixturePath = path.join(process.cwd(), 'fixtures', filename);
    await fileInput.setInputFiles(fixturePath);

    // Click the upload button
    const uploadButton = this.page.locator('button:has-text("Upload")');
    await uploadButton.click();
  }
);

Then('the text should be {string}', async function (this: CustomWorld, expectedText: string) {
  if (!this.page) throw new Error('Page is not initialized');

  // Wait for and verify the transcription result
  const result = this.page.locator('text=' + expectedText);
  await expect(result).toBeVisible();
});
