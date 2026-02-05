# Meeting Plunger

Meeting Plunger exists to turn messy meeting audio into usable, trustworthy meeting minutes with minimal human effort.

A monorepo project with:
- **Backend**: Python FastAPI server (deployed on k8s) - handles AI transcription
- **Frontend**: Vue.js 3 web interface (localhost:3000) - browser UI
- **Local Service**: Golang API server (localhost:3001) - bridges frontend and backend, processes audio locally

## Architecture

```
User's Computer                                Server
┌─────────────────────────────┐               ┌──────────────┐
│ Browser                     │               │ Backend      │
│   ┌─────────────────────┐   │               │ (Python)     │
│   │ Frontend (Vue)      │   │               │              │
│   │ localhost:3000      │   │               │ k8s          │──> OpenAI API
│   └──────────┬──────────┘   │               │              │
│              │               │               └──────▲───────┘
│              ▼               │                      │
│   ┌─────────────────────┐   │                      │
│   │ Local Service (Go)  │   │                      │
│   │ API Server :3001    │───┼──── HTTPS ───────────┘
│   └─────────────────────┘   │    auth token
└─────────────────────────────┘
```

## Development Setup

### Quick Setup (Recommended)

For first-time setup, run the automated setup script:

```bash
./setup-meeting-plunger-dev.sh
```

This script will:
- Install Nix package manager (if not already installed)
- Configure Nix flakes
- Set up the development environment

After the script completes, exit your terminal, open a new one, and proceed to **Getting Started** below.

### Manual Setup

If the automated setup fails, see [docs/nix.md](docs/nix.md) for detailed manual installation instructions.

### Prerequisites

- [Nix](https://nixos.org/download.html) with flakes enabled (installed by setup script)
- (Optional) [direnv](https://direnv.net/) for automatic environment loading
- **Windows users:** See [docs/WSL2_SETUP.md](docs/WSL2_SETUP.md) for WSL2 installation guide

### Getting Started

**⚠️ Important:** All commands must be prefixed with `nix develop -c`. See [`.cursor/rules/general.mdc`](.cursor/rules/general.mdc) for details.

```bash
# Install dependencies (first time)
nix develop -c pnpm install && nix develop -c pnpm e2e:install

# Start services (Terminal 1)
nix develop -c pnpm sut

# Run tests (Terminal 2)
nix develop -c pnpm e2e
```

**Alternative:** Use `nix develop` or `direnv allow` to enter the environment, then run commands directly.

See [docs/QUICK_START.md](docs/QUICK_START.md) for more details.

## Project Structure

```
.
├── backend/          # Python FastAPI backend
├── frontend/         # Vue.js 3 web interface
├── local-service/    # Golang local HTTP service
├── e2e/              # Playwright + Gherkin e2e tests
├── docs/             # Documentation
├── .cursor/          # Cursor AI rules
│   └── rules/
│       └── general.mdc     # Essential workflow & commands
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

- **Backend**: Python 3.11, FastAPI with auto-reload (uvicorn)
- **Frontend**: Vue.js 3, TypeScript, Vite with auto-reload
- **Local Service**: Golang, HTTP server with auto-reload (air)
- **API Code Generation**: Bidirectional type-safe client generation (FastAPI → oapi-codegen → Go, swag → @hey-api/openapi-ts → TypeScript)
- **E2E Testing**: Playwright + Cucumber (Gherkin), managed with pnpm
- **Infrastructure**: Kubernetes (k8s)
- **AI Integration**: OpenAI API
- **Authentication**: Token-based auth over HTTPS
- **IDE**: VSCode with Cucumber plugin configured (see `.vscode/`)

## Testing

E2E tests use Playwright + Cucumber (Gherkin). See [`.cursor/rules/general.mdc`](.cursor/rules/general.mdc) for commands.

```bash
nix develop -c pnpm e2e         # Run tests
nix develop -c pnpm e2e:headed  # With browser
```

Full details: [e2e/README.md](e2e/README.md)

## API Code Generation

All inter-service communication uses type-safe generated clients. Single command to generate all:

```bash
# No backend server needed - extracts OpenAPI specs directly from code
nix develop -c pnpm generate:api
```

This generates:
- **Go client** for local-service to call backend (oapi-codegen)
- **TypeScript client** for frontend to call local-service (@hey-api/openapi-ts)

Validate all generated files are up to date:
```bash
nix develop -c pnpm validate:api
```

Benefits: Type safety, no manual HTTP code, IntelliSense across all services.

Full details: [docs/API_SHARING.md](docs/API_SHARING.md) | [docs/BIDIRECTIONAL_API_GENERATION.md](docs/BIDIRECTIONAL_API_GENERATION.md)

## Code Quality

Linting and formatting tools are configured for all subprojects:

```bash
nix develop -c pnpm lint    # Lint all code (Go, Python, JS)
nix develop -c pnpm format  # Format all code
```

Individual projects:
```bash
nix develop -c pnpm lint:local-service  # Go (golangci-lint)
nix develop -c pnpm lint:backend        # Python (ruff)
nix develop -c pnpm lint:frontend       # TypeScript/Vue (eslint)
nix develop -c pnpm lint:e2e            # JavaScript (eslint)
```

Full details: [docs/LINTING_AND_FORMATTING.md](docs/LINTING_AND_FORMATTING.md)

## Documentation

- [`.cursor/rules/general.mdc`](.cursor/rules/general.mdc) - **Essential commands & workflow**
- [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) - System architecture and request flow
- [docs/API_SHARING.md](docs/API_SHARING.md) - API type sharing and code generation
- [docs/BIDIRECTIONAL_API_GENERATION.md](docs/BIDIRECTIONAL_API_GENERATION.md) - Bidirectional code generation guide
- [docs/nix.md](docs/nix.md) - Nix environment setup (manual installation)
- [docs/WSL2_SETUP.md](docs/WSL2_SETUP.md) - WSL2 setup for Windows users ([中文版](docs/WSL2_SETUP.zh-CN.md))
- [docs/QUICK_START.md](docs/QUICK_START.md) - Quick start guide
- [docs/VSCODE_SETUP.md](docs/VSCODE_SETUP.md) - VSCode + Cucumber setup
- [docs/VERIFICATION.md](docs/VERIFICATION.md) - Setup verification
- [docs/LINTING_AND_FORMATTING.md](docs/LINTING_AND_FORMATTING.md) - Code quality tools
- [docs/UNIT_TESTING.md](docs/UNIT_TESTING.md) - Unit testing guide
- [e2e/README.md](e2e/README.md) - E2E testing guide

