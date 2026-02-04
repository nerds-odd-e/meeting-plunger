# Linting and Formatting

This document describes the linting and formatting setup for the Meeting Plunger project.

## Quick Start

**IMPORTANT**: Always use the `nix develop -c` prefix for all commands.

### Format all code
```bash
nix develop -c pnpm format
```

### Lint all code
```bash
nix develop -c pnpm lint
```

## Tools Used

### Client (Go)
- **Formatter**: `gofmt` + `goimports` - Standard Go formatting tools
- **Linter**: `golangci-lint` - Comprehensive Go linter with multiple checks
- **Config**: `client/.golangci.yml`

### Backend (Python)
- **Formatter**: `ruff format` - Fast Python formatter (Black-compatible)
- **Linter**: `ruff check` - Fast Python linter (replaces flake8, isort, etc.)
- **Config**: `backend/pyproject.toml`

### E2E Tests (JavaScript)
- **Formatter**: `prettier` - Opinionated code formatter
- **Linter**: `eslint` - JavaScript linting utility (v9 flat config)
- **Config**: `e2e/eslint.config.js`, `e2e/.prettierrc.json`

## Per-Project Commands

### Client (Go)
```bash
cd client
nix develop -c make lint      # Run linter
nix develop -c make format    # Format code
```

### Backend (Python)
```bash
cd backend
nix develop -c pnpm lint      # Run linter
nix develop -c pnpm format    # Format code
```

### E2E Tests (JavaScript)
```bash
cd e2e
nix develop -c pnpm lint      # Run linter
nix develop -c pnpm format    # Format code
```

## Root-Level Commands

From the project root, you can run linting/formatting for all subprojects:

```bash
# Lint all projects
nix develop -c pnpm lint

# Or individually
nix develop -c pnpm lint:client
nix develop -c pnpm lint:backend
nix develop -c pnpm lint:e2e

# Format all projects
nix develop -c pnpm format

# Or individually
nix develop -c pnpm format:client
nix develop -c pnpm format:backend
nix develop -c pnpm format:e2e
```

## IDE Integration

### VSCode
Consider installing these extensions:
- **Go**: `golang.go` (includes formatting support)
- **Python**: `charliermarsh.ruff` (Ruff formatter and linter)
- **JavaScript/Prettier**: `esbenp.prettier-vscode`
- **ESLint**: `dbaeumer.vscode-eslint`

Configure format-on-save in `.vscode/settings.json`:
```json
{
  "[go]": {
    "editor.formatOnSave": true,
    "editor.defaultFormatter": "golang.go"
  },
  "[python]": {
    "editor.formatOnSave": true,
    "editor.defaultFormatter": "charliermarsh.ruff"
  },
  "[javascript]": {
    "editor.formatOnSave": true,
    "editor.defaultFormatter": "esbenp.prettier-vscode"
  }
}
```

## What Gets Checked

### Go (golangci-lint)
- Code formatting (`gofmt`)
- Import organization (`goimports`)
- Vet analysis (`govet`)
- Error checking (`errcheck`)
- Static analysis (`staticcheck`)
- Unused code detection (`unused`)
- Code simplification (`gosimple`)
- Inefficient assignments (`ineffassign`)
- Type checking (`typecheck`)

### Python (ruff)
- PEP 8 style compliance (`E`, `W`)
- Pyflakes checks (`F`)
- Import sorting (`I`)
- Bug detection (`B`)
- Comprehension improvements (`C4`)
- Python version upgrades (`UP`)

### JavaScript (eslint)
- Basic recommended rules
- Unused variables (with underscore prefix exception)
- No-console allowed (for test logging)

## CI/CD Integration

To add linting checks to your CI pipeline:

```bash
# In your CI script
nix develop -c pnpm lint || exit 1
```

This will run all linters and exit with non-zero status if any fail.
