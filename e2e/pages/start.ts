import { Page } from '@playwright/test';
import { ClientPage } from './ClientPage.js';

export class Start {
  constructor(private page: Page) {}

  clientPage(): ClientPage {
    return new ClientPage(this.page);
  }
}

export function start(page: Page): Start {
  return new Start(page);
}
