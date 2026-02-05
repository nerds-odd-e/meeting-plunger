# Meeting Plunger - Quick Start Guide

**⚠️ Essential:** Read [`.cursor/rules/general.mdc`](../.cursor/rules/general.mdc) first for command syntax.

## One-Time Setup

```bash
nix develop -c pnpm install && nix develop -c pnpm e2e:install
```

## Daily Workflow

```bash
# Terminal 1 - Start services
nix develop -c pnpm sut

# Terminal 2 - Run tests
nix develop -c pnpm e2e
```

## Available Commands

See [`.cursor/rules/general.mdc`](.cursor/rules/general.mdc) for all commands.

### API Code Generation

When you modify API endpoints:

```bash
# No backend server needed
nix develop -c pnpm generate:api
```

This generates type-safe clients for:
- Go client for local-service → backend
- TypeScript client for frontend → local-service

See [API_SHARING.md](API_SHARING.md) for details.

## Services

- **Backend:** http://localhost:8000 (FastAPI, auto-reloads on changes)
- **Local Service:** http://localhost:3001 (Go, auto-reloads on changes)
- **Frontend:** http://localhost:3000 (Vue.js, auto-reloads on changes)

## More Information

- [`.cursor/rules/general.mdc`](../.cursor/rules/general.mdc) - Essential workflow
- [VSCODE_SETUP.md](VSCODE_SETUP.md) - IDE setup
