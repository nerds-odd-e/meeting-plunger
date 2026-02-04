# Meeting Plunger - Quick Start Guide

## One-Time Setup

### Option 1: With Nix Prefix (One Command)

```bash
nix develop -c pnpm install && nix develop -c pnpm e2e:install
```

### Option 2: Inside Nix Shell (Interactive)

```bash
# Enter Nix environment
nix develop

# Install dependencies
pnpm install
pnpm e2e:install
```

**Note:** All commands require `nix develop -c` prefix OR being run inside `nix develop` shell.

## Daily Workflow

### Option 1: Quick Start with Nix Prefix

```bash
# Terminal 1 - Start all services
nix develop -c pnpm sut

# Terminal 2 - Run tests
nix develop -c pnpm e2e
```

### Option 2: Inside Nix Shell (Recommended)

```bash
# Terminal 1
nix develop
pnpm sut

# Terminal 2
nix develop
pnpm e2e
```

### Option 2: Step by Step

```bash
# Terminal 1 - Backend
cd backend
uvicorn main:app --reload

# Terminal 2 - Client
cd client
go run . serve

# Terminal 3 - Tests
cd e2e
pnpm test
```

## Available Commands

### Root Level Commands

| Command | Description |
|---------|-------------|
| `pnpm sut` | Start backend + client together (System Under Test) |
| `pnpm e2e` | Run all e2e tests (headless) |
| `pnpm e2e:headed` | Run e2e tests with visible browser |
| `pnpm e2e:debug` | Run e2e tests in debug mode |
| `pnpm dev` | Alias for `pnpm sut` |
| `pnpm test` | Alias for `pnpm e2e` |

### E2E Test Commands (from e2e/)

| Command | Description |
|---------|-------------|
| `pnpm test` | Run all tests |
| `pnpm test:headed` | Run with visible browser |
| `pnpm test:debug` | Debug mode |
| `pnpm test:health` | Run health check tests only |
| `pnpm test:ui` | Run UI tests only |
| `pnpm dry-run` | Validate test structure |

## Services

- **Backend:** http://localhost:8000
  - GET `/` - Root endpoint
  - GET `/health` - Health check
  - GET `/docs` - API documentation (Swagger)

- **Client:** http://localhost:3000
  - GET `/` - Client interface
  - GET `/health` - Health check

## Typical Development Cycle

1. Start services:
   ```bash
   pnpm sut
   ```

2. Make changes to code

3. Run tests:
   ```bash
   pnpm e2e
   ```

4. Debug if needed:
   ```bash
   pnpm e2e:headed  # or pnpm e2e:debug
   ```

## Tips

- Use **direnv** for automatic environment activation:
  ```bash
  direnv allow
  ```

- The `pnpm sut` command shows color-coded logs:
  - 🔵 Blue: Backend logs
  - 🟢 Green: Client logs

- Services auto-reload on code changes:
  - Backend: uvicorn `--reload` flag
  - Client: restart `go run` command

## Troubleshooting

### Port already in use

If you get "port already in use" errors:

```bash
# Find process using port 8000 (backend)
lsof -i :8000

# Find process using port 3000 (client)
lsof -i :3000

# Kill process
kill -9 <PID>
```

### Tests failing

1. Ensure both services are running:
   ```bash
   curl http://localhost:8000/health
   curl http://localhost:3000/health
   ```

2. Check logs in the terminal running `pnpm sut`

3. Run tests with visible browser to debug:
   ```bash
   pnpm e2e:headed
   ```

### Nix environment issues

```bash
# Rebuild environment
rm flake.lock
nix flake update
nix develop
```

## Next Steps

1. ✅ Setup complete
2. 🔨 Implement features
3. ✅ Write tests
4. 🚀 Deploy

Happy coding! 🎉
