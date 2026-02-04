# Meeting Plunger

Meeting Plunger exists to turn messy meeting audio into usable, trustworthy meeting minutes with minimal human effort.

A monorepo project with:
- **Backend**: Python FastAPI server (deployed on k8s)
- **Client**: Golang CLI with local HTTP service for browser interface

## Architecture

```
User's Computer                    Server
┌─────────────────┐               ┌──────────────┐
│ Browser         │               │ Backend      │
│                 │               │ (Python)     │──> OpenAI API
│ Client (Golang) │─── HTTPS ────>│              │
│ CLI & HTTP      │  auth token   │ k8s          │
│ DB              │               └──────────────┘
└─────────────────┘
```

## Development Setup

### Prerequisites

- [Nix](https://nixos.org/download.html) with flakes enabled
- (Optional) [direnv](https://direnv.net/) for automatic environment loading

### Getting Started

### Option 1: Using `nix develop` (Recommended for running commands)

All commands must be prefixed with `nix develop -c`:

```bash
# Install dependencies (first time only)
nix develop -c pnpm install
nix develop -c pnpm e2e:install

# Start services
nix develop -c pnpm sut

# Run tests (in another terminal)
nix develop -c pnpm e2e
```

### Option 2: Enter Nix shell (Recommended for development)

```bash
nix develop
# Now you're in the Nix environment, commands work directly
pnpm sut
```

Or use direnv for automatic activation:
```bash
direnv allow
# Environment activates automatically when you cd into the directory
```

### Quick Start

**Start all services (System Under Test):**
```bash
pnpm sut
```

This starts both the backend and client in a single command with color-coded output.

**Run E2E tests (in another terminal):**
```bash
pnpm e2e
```

### Manual Start (Alternative)

If you prefer to start services individually:

**Backend:**
```bash
cd backend
uvicorn main:app --reload
```

**Client:**
```bash
cd client
go run . serve
```

**E2E tests:**
```bash
cd e2e
pnpm test
```

## Project Structure

```
.
├── backend/          # Python FastAPI backend
├── client/           # Golang CLI and local HTTP service
├── e2e/              # Playwright + Gherkin e2e tests
├── .vscode/          # Shared VSCode settings
│   ├── settings.json       # Workspace settings (Cucumber config)
│   ├── extensions.json     # Recommended extensions
│   ├── launch.json         # Debug configurations
│   └── tasks.json          # Task runner
├── flake.nix         # Nix development environment
├── package.json      # Root package scripts (pnpm sut, pnpm e2e)
└── README.md
```

## Technology Stack

- **Backend**: Python 3.11, FastAPI, running on Kubernetes
- **Client**: Golang, CLI + HTTP server
- **E2E Testing**: Playwright + Cucumber (Gherkin), managed with pnpm
- **Infrastructure**: Kubernetes (k8s)
- **AI Integration**: OpenAI API
- **Authentication**: Token-based auth over HTTPS
- **IDE**: VSCode with Cucumber plugin configured (see `.vscode/`)

## Testing

### E2E Tests

The project uses Playwright with Cucumber (Gherkin syntax) for end-to-end testing.

See [e2e/README.md](e2e/README.md) for detailed testing instructions.

**Quick start:**

```bash
# Terminal 1 - Start all services
pnpm sut

# Terminal 2 - Run e2e tests
pnpm e2e
```

**Available test commands:**
```bash
pnpm e2e          # Run all e2e tests (headless)
pnpm e2e:headed   # Run with visible browser
pnpm e2e:debug    # Run in debug mode
```

## Documentation

- [QUICK_START.md](QUICK_START.md) - Quick start guide
- [NIX_COMMANDS.md](NIX_COMMANDS.md) - **Nix command reference (READ THIS!)**
- [COMMANDS.md](COMMANDS.md) - All available commands
- [VSCODE_SETUP.md](VSCODE_SETUP.md) - VSCode + Cucumber setup
- [SETUP_SUMMARY.md](SETUP_SUMMARY.md) - Detailed setup guide
- [e2e/README.md](e2e/README.md) - E2E testing guide
- [.cursorrules](.cursorrules) - Cursor AI rules

