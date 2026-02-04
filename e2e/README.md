# E2E Tests

End-to-end tests for Meeting Plunger using Playwright and Cucumber (Gherkin).

## Prerequisites

Make sure you're in the Nix development environment:

```bash
nix develop
```

## Setup

Install dependencies:

```bash
cd e2e
pnpm install
```

## Running Tests

Make sure both the backend and client services are running before executing the tests.

**Terminal 1 - Backend:**
```bash
cd backend
uvicorn main:app --reload
```

**Terminal 2 - Client:**
```bash
cd client
go run . serve
```

**Terminal 3 - E2E Tests:**

```bash
cd e2e

# Run all tests (headless)
pnpm test

# Run tests in headed mode (see the browser)
pnpm test:headed

# Run tests in debug mode
pnpm test:debug
```

## Project Structure

```
e2e/
├── features/           # Gherkin feature files
│   ├── health-check.feature
│   └── client-ui.feature
├── steps/              # Step definitions
│   ├── health-check.steps.js
│   └── client-ui.steps.js
├── support/            # Support files
│   └── world.js       # Custom world with Playwright setup
└── package.json        # Dependencies and test scripts
```

## Writing Tests

### Feature Files

Feature files use Gherkin syntax and are located in `features/`:

```gherkin
Feature: My Feature
  As a user
  I want to do something
  So that I can achieve a goal

  Scenario: Test scenario
    Given some precondition
    When I perform an action
    Then I should see the result
```

### Step Definitions

Step definitions are JavaScript files in `steps/` that implement the Gherkin steps:

```javascript
import { Given, When, Then } from '@cucumber/cucumber';
import { expect } from '@playwright/test';

Given('some precondition', async function () {
  // Setup code
});

When('I perform an action', async function () {
  // Action code using this.page
});

Then('I should see the result', async function () {
  // Assertion using expect
});
```

## Available Context

In step definitions, you have access to:

- `this.browser` - Playwright browser instance
- `this.context` - Playwright browser context
- `this.page` - Playwright page instance
- `this.response` - Last HTTP response (if any)

## Reports

After running tests, HTML and JSON reports are generated in the `reports/` directory.
