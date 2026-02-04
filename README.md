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

1. Enter the development environment:

```bash
nix develop
```

Or if using direnv:
```bash
direnv allow
```

2. Install dependencies (first time only):

```bash
pnpm install
pnpm e2e:install
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
├── flake.nix         # Nix development environment
└── README.md
```

## Technology Stack

- **Backend**: Python 3.11, FastAPI, running on Kubernetes
- **Client**: Golang, CLI + HTTP server
- **E2E Testing**: Playwright + Cucumber (Gherkin), managed with pnpm
- **Infrastructure**: Kubernetes (k8s)
- **AI Integration**: OpenAI API
- **Authentication**: Token-based auth over HTTPS

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
