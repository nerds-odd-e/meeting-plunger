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
├── client/           # Golang CLI and local HTTP service
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
- **Client**: Golang, CLI + HTTP server with auto-reload (air)
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
## Documentation

- [`.cursor/rules/general.mdc`](.cursor/rules/general.mdc) - **Essential commands & workflow**
- [docs/QUICK_START.md](docs/QUICK_START.md) - Quick start guide
- [docs/VSCODE_SETUP.md](docs/VSCODE_SETUP.md) - VSCode + Cucumber setup
- [docs/VERIFICATION.md](docs/VERIFICATION.md) - Setup verification
- [e2e/README.md](e2e/README.md) - E2E testing guide

