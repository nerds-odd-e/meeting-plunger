# Meeting Plunger - Setup Summary

## ✅ Completed Setup

### 1. Nix Development Environment

**File:** `flake.nix`

The project now has a complete Nix development environment with:
- **Python 3.11.14** with FastAPI, Uvicorn, pytest, and other dependencies
- **Go 1.25.5** for the CLI client
- **Node.js 22.22.0** for e2e tests
- **pnpm 10.28.0** as the package manager
- **Playwright** with browser binaries

**Usage:**
```bash
nix develop
```

Or use direnv for automatic activation:
```bash
direnv allow
```

### 2. Project Structure

```
meeting-plunger/
├── backend/              # Python FastAPI backend
│   ├── main.py          # FastAPI app with health endpoints
│   └── requirements.txt # Python dependencies
├── client/              # Golang CLI and HTTP server
│   ├── main.go         # Go application
│   └── go.mod          # Go module
├── e2e/                 # E2E tests (Playwright + Gherkin)
│   ├── features/       # Gherkin feature files
│   ├── steps/          # Step definitions
│   ├── support/        # Test support code
│   └── package.json    # Node dependencies
├── flake.nix           # Nix environment configuration
├── flake.lock          # Nix lock file
├── .envrc              # direnv configuration
├── .gitignore          # Git ignore rules
└── README.md           # Main documentation
```

### 3. Backend (Python FastAPI)

**Location:** `backend/`

**Features:**
- FastAPI application with CORS support
- Health check endpoint at `/health`
- Root endpoint at `/`

**Run:**
```bash
cd backend
uvicorn main:app --reload
# Runs on http://localhost:8000
```

**API Endpoints:**
- `GET /` - Root endpoint
- `GET /health` - Health check endpoint

### 4. Client (Golang)

**Location:** `client/`

**Features:**
- CLI application with `serve` command
- HTTP server for browser interface
- Health check endpoint at `/health`

**Run:**
```bash
cd client
go run . serve
# Runs on http://localhost:3000
```

**Endpoints:**
- `GET /` - HTML interface
- `GET /health` - Health check endpoint

### 5. E2E Tests (Playwright + Gherkin/Cucumber)

**Location:** `e2e/`

**Technology Stack:**
- Playwright 1.58.1 for browser automation
- Cucumber 11.3.0 for Gherkin support
- pnpm for package management

**Setup:**
```bash
cd e2e
pnpm install
```

**Test Files:**
- `features/health-check.feature` - Backend and client health checks
- `features/client-ui.feature` - Client UI tests

**Run Tests:**
```bash
# Headless mode
pnpm test

# Headed mode (see the browser)
pnpm test:headed

# Debug mode
pnpm test:debug

# Specific tests
pnpm test:health
pnpm test:ui

# Dry run (validate test structure)
pnpm dry-run
```

## Quick Start Guide

### First Time Setup

1. Enter the Nix environment:
```bash
nix develop
```

2. Install dependencies:
```bash
pnpm install          # Root dependencies (concurrently)
pnpm e2e:install      # E2E test dependencies
```

### Running the Application

**Quick Start (Recommended):**

Open 2 terminals, both inside `nix develop`:

**Terminal 1 - Start all services:**
```bash
pnpm sut
```

**Terminal 2 - Run E2E tests:**
```bash
pnpm e2e
```

**Manual Start (Alternative):**

Open 3 terminals, all inside `nix develop`:

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
pnpm test
```

## Development Workflow

1. Start backend and client services
2. Write or modify Gherkin features in `e2e/features/`
3. Implement step definitions in `e2e/steps/`
4. Run tests to verify functionality
5. Iterate on implementation

## Test Writing Guide

### Gherkin Feature Example

```gherkin
Feature: My Feature
  As a user
  I want to do something
  So that I can achieve a goal

  Scenario: Test scenario
    Given I have a precondition
    When I perform an action
    Then I should see the result
```

### Step Definition Example

```javascript
import { Given, When, Then } from '@cucumber/cucumber';
import { expect } from '@playwright/test';

Given('I have a precondition', async function () {
  // Setup code using this.page
});

When('I perform an action', async function () {
  await this.page.click('button');
});

Then('I should see the result', async function () {
  await expect(this.page.locator('text=Success')).toBeVisible();
});
```

## Next Steps

1. **Backend Development:**
   - Add authentication endpoints
   - Integrate with OpenAI API
   - Implement business logic

2. **Client Development:**
   - Enhance UI with proper styling
   - Add database integration
   - Implement CLI commands

3. **E2E Tests:**
   - Add more feature scenarios
   - Test authentication flows
   - Add API integration tests

4. **Infrastructure:**
   - Create Kubernetes deployment manifests
   - Set up CI/CD pipeline
   - Configure production environment

## Useful Commands

```bash
# Nix
nix develop                    # Enter development environment
nix flake update              # Update dependencies

# Root Level (Quick Commands)
pnpm install                  # Install root dependencies
pnpm sut                      # Start backend + client (System Under Test)
pnpm e2e                      # Run all e2e tests
pnpm e2e:headed              # Run e2e tests with visible browser
pnpm e2e:debug               # Run e2e tests in debug mode
pnpm e2e:install             # Install e2e test dependencies
pnpm dev                      # Alias for 'pnpm sut'
pnpm test                     # Alias for 'pnpm e2e'

# Backend
cd backend
python main.py                # Run directly
uvicorn main:app --reload    # Run with auto-reload
pytest                        # Run tests (when added)

# Client
cd client
go run .                      # Show usage
go run . serve               # Start HTTP server
go build                     # Build binary

# E2E Tests
cd e2e
pnpm install                 # Install dependencies
pnpm test                    # Run all tests
pnpm test:headed            # Run with visible browser
pnpm test:debug             # Run in debug mode
pnpm dry-run                # Validate test structure

# Git
git add .
git commit -m "message"
git push
```

## Troubleshooting

### Nix Issues

If you encounter Nix-related issues:
```bash
# Rebuild the environment
rm flake.lock
nix flake update
nix develop
```

### E2E Test Issues

If tests fail to run:
```bash
cd e2e
# Reinstall dependencies
rm -rf node_modules
pnpm install

# Ensure services are running
# Backend should be on http://localhost:8000
# Client should be on http://localhost:3000
```

### Port Conflicts

If ports are already in use:
- Backend default: 8000 (change with `--port`)
- Client default: 3000 (change in code)

## Documentation

- [README.md](README.md) - Main project documentation
- [e2e/README.md](e2e/README.md) - E2E testing guide
- [Playwright Docs](https://playwright.dev/)
- [Cucumber Docs](https://cucumber.io/docs/cucumber/)
- [FastAPI Docs](https://fastapi.tiangolo.com/)
- [Go Docs](https://go.dev/doc/)
