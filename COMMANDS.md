# Meeting Plunger - Command Reference

## Root Level Commands (From project root)

### Quick Start Commands

```bash
pnpm sut              # Start backend + client (System Under Test)
pnpm e2e              # Run all e2e tests
```

### All Available Commands

```bash
# Development
pnpm sut              # Start backend + client with color-coded output
pnpm dev              # Alias for 'pnpm sut'

# Testing
pnpm e2e              # Run all e2e tests (headless)
pnpm e2e:headed       # Run e2e tests with visible browser
pnpm e2e:debug        # Run e2e tests in debug mode
pnpm test             # Alias for 'pnpm e2e'

# Setup
pnpm install          # Install root dependencies (concurrently)
pnpm e2e:install      # Install e2e test dependencies
```

### Individual Service Commands

```bash
pnpm sut:backend      # Start backend only
pnpm sut:client       # Start client only
```

## Backend Commands (From backend/)

```bash
cd backend

# Development
uvicorn main:app --reload              # Start with auto-reload
uvicorn main:app --reload --port 8080  # Custom port
python main.py                          # Run directly

# Testing (when implemented)
pytest                                  # Run unit tests
pytest -v                              # Verbose output
pytest tests/test_api.py               # Run specific test
```

## Client Commands (From client/)

```bash
cd client

# Development
go run .                # Show CLI usage
go run . serve          # Start HTTP server

# Building
go build                # Build binary
go build -o plunger     # Build with custom name

# Testing (when implemented)
go test ./...           # Run all tests
go test -v ./...        # Verbose output
```

## E2E Commands (From e2e/)

```bash
cd e2e

# Run tests
pnpm test               # Run all tests (headless)
pnpm test:headed        # Run with visible browser
pnpm test:debug         # Run in debug mode

# Run specific tests
pnpm test:health        # Run health check tests only
pnpm test:ui            # Run UI tests only

# Validation
pnpm dry-run            # Validate test structure without running

# Development
pnpm install            # Install dependencies
```

## Nix Commands

```bash
# Environment
nix develop             # Enter development environment
nix develop --command bash  # Enter and run bash
nix flake update        # Update dependencies

# Build
nix build               # Build the project (when configured)
nix flake check         # Check flake validity
nix flake show          # Show flake outputs
```

## Git Commands

```bash
# Add all files to Git (required for Nix)
git add .

# Commit changes
git commit -m "your message"

# Push to remote
git push
```

## Docker Commands (Future)

```bash
# Backend
docker build -t meeting-plunger-backend ./backend
docker run -p 8000:8000 meeting-plunger-backend

# Client
docker build -t meeting-plunger-client ./client
docker run -p 3000:3000 meeting-plunger-client

# Full stack with docker-compose
docker-compose up
docker-compose down
```

## Kubernetes Commands (Future)

```bash
# Deploy
kubectl apply -f k8s/

# Check status
kubectl get pods
kubectl get services

# Logs
kubectl logs -f deployment/backend
kubectl logs -f deployment/client

# Delete
kubectl delete -f k8s/
```

## Utility Commands

### Port Management

```bash
# Find process on port
lsof -i :8000        # Backend port
lsof -i :3000        # Client port

# Kill process
kill -9 <PID>

# Or use pkill
pkill -f uvicorn     # Kill backend
pkill -f "go run"    # Kill client
```

### Health Checks

```bash
# Backend
curl http://localhost:8000/health
curl http://localhost:8000/

# Client
curl http://localhost:3000/health
curl http://localhost:3000/

# Both with jq for pretty JSON
curl -s http://localhost:8000/health | jq
curl -s http://localhost:3000/health | jq
```

### Logs

```bash
# Follow logs (when using pnpm sut)
# Logs appear in the same terminal with color coding

# Backend logs (when run separately)
cd backend && uvicorn main:app --reload --log-level debug

# Client logs (when run separately)
cd client && go run . serve 2>&1 | tee client.log
```

## Environment Variables

```bash
# Backend (.env file in backend/)
PORT=8000
DEBUG=true
OPENAI_API_KEY=your-key

# Client
CLIENT_PORT=3000
BACKEND_URL=http://localhost:8000

# E2E Tests
HEADED=true          # Show browser
PWDEBUG=1           # Playwright debug mode
```

## Troubleshooting Commands

```bash
# Check what's running
ps aux | grep uvicorn
ps aux | grep "go run"

# Check ports
netstat -an | grep LISTEN

# Check Nix environment
nix-shell --version
nix --version

# Check tool versions
python --version
go version
node --version
pnpm --version

# Reinstall dependencies
rm -rf node_modules e2e/node_modules
pnpm install
cd e2e && pnpm install
```

## Quick Recipes

### Full Test Cycle

```bash
# Terminal 1
pnpm sut

# Terminal 2
sleep 5 && pnpm e2e
```

### Watch Mode Development

```bash
# Terminal 1 - Backend (auto-reloads)
cd backend
uvicorn main:app --reload

# Terminal 2 - Client (manual restart needed)
cd client
while true; do go run . serve; sleep 1; done

# Terminal 3 - Run tests on demand
cd e2e
pnpm test
```

### Debug Failing Test

```bash
# 1. Start services
pnpm sut

# 2. Run test in debug mode
pnpm e2e:debug

# 3. Or with headed mode
pnpm e2e:headed
```

### Clean Start

```bash
# Stop all services
pkill -f uvicorn
pkill -f "go run"

# Clean dependencies
rm -rf node_modules e2e/node_modules

# Reinstall
pnpm install
pnpm e2e:install

# Start fresh
pnpm sut
```

## Summary of Most Used Commands

```bash
# Daily workflow
nix develop          # 1. Enter environment
pnpm install         # 2. Install (first time)
pnpm sut             # 3. Start services
pnpm e2e             # 4. Run tests (separate terminal)

# Quick test
pnpm sut & sleep 5 && pnpm e2e

# Debug
pnpm e2e:headed      # Visual debugging
pnpm e2e:debug       # Full debug mode
```
