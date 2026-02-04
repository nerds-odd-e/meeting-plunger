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

## Services

- **Backend:** http://localhost:8000 (FastAPI)
- **Client:** http://localhost:3000 (Go)

## More Information

- [`.cursor/rules/general.mdc`](../.cursor/rules/general.mdc) - Essential workflow
- [VSCODE_SETUP.md](VSCODE_SETUP.md) - IDE setup
