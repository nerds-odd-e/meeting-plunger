import { setWorldConstructor, Before, After, World } from '@cucumber/cucumber';
import { Browser, BrowserContext, Page, chromium, APIResponse } from 'playwright';

export class CustomWorld extends World {
  browser: Browser | null;
  context: BrowserContext | null;
  page: Page | null;
  response: APIResponse | null;
  baseUrl?: string;

  constructor(options: any) {
    super(options);
    this.browser = null;
    this.context = null;
    this.page = null;
    this.response = null;
  }

  async init(): Promise<void> {
    const headed = process.env.HEADED === 'true';
    this.browser = await chromium.launch({
      headless: !headed,
      slowMo: headed ? 100 : 0,
    });
    this.context = await this.browser.newContext();
    this.page = await this.context.newPage();
  }

  async cleanup(): Promise<void> {
    if (this.page) await this.page.close();
    if (this.context) await this.context.close();
    if (this.browser) await this.browser.close();
  }
}

setWorldConstructor(CustomWorld);

Before(async function (this: CustomWorld) {
  await this.init();
});

After(async function (this: CustomWorld) {
  await this.cleanup();
});
