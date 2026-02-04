# Nix Command Reference

## ⚠️ IMPORTANT: Nix Prefix Requirement

This project uses Nix for reproducible development. **ALL commands must either:**
1. Be prefixed with `nix develop -c`, OR
2. Be run inside a `nix develop` shell

## Two Ways to Work

### Method 1: Nix Prefix (For Scripts/CI)

```bash
# Run any command with nix develop -c prefix
nix develop -c pnpm sut
nix develop -c pnpm e2e
nix develop -c go version
nix develop -c python --version
```

**Pros:**
- ✅ Works from any shell
- ✅ Good for scripts and CI
- ✅ Ensures Nix environment for each command

**Cons:**
- ❌ More typing for interactive work

### Method 2: Enter Nix Shell (For Development)

```bash
# Enter the Nix environment once
nix develop

# Now run commands normally
pnpm sut
pnpm e2e
go version
python --version
```

**Pros:**
- ✅ Less typing
- ✅ Better for interactive development
- ✅ Single environment session

**Cons:**
- ❌ Need to remember you're in the shell
- ❌ Each terminal needs to enter the shell

### Method 3: direnv (Best for Development)

```bash
# One-time setup
direnv allow

# Environment automatically activates when you cd into the directory
cd meeting-plunger
# direnv: loading ~/git/meeting-plunger/.envrc

# Commands work directly
pnpm sut
pnpm e2e
```

**Pros:**
- ✅ Automatic activation
- ✅ No manual `nix develop` needed
- ✅ Per-terminal activation
- ✅ Best developer experience

**Cons:**
- ❌ Requires direnv installed

## Common Commands

### With Nix Prefix

```bash
# Setup
nix develop -c pnpm install
nix develop -c pnpm e2e:install

# Development
nix develop -c pnpm sut              # Start services
nix develop -c pnpm e2e              # Run tests
nix develop -c pnpm e2e:headed       # Run tests with browser

# Individual services
nix develop -c pnpm sut:backend      # Backend only
nix develop -c pnpm sut:client       # Client only

# Backend
nix develop -c bash -c "cd backend && uvicorn main:app --reload"

# Client
nix develop -c bash -c "cd client && go run . serve"

# E2E Tests
nix develop -c bash -c "cd e2e && pnpm test"
nix develop -c bash -c "cd e2e && pnpm test:headed"
nix develop -c bash -c "cd e2e && pnpm dry-run"
```

### Inside Nix Shell

```bash
# Enter shell
nix develop

# Now run commands normally
pnpm install
pnpm e2e:install
pnpm sut
pnpm e2e

cd backend && uvicorn main:app --reload
cd client && go run . serve
cd e2e && pnpm test
```

## Examples by Use Case

### First Time Setup

**With Prefix:**
```bash
nix develop -c pnpm install && \
nix develop -c pnpm e2e:install
```

**In Shell:**
```bash
nix develop
pnpm install
pnpm e2e:install
```

### Start Development Session

**With Prefix (Two Terminals):**
```bash
# Terminal 1
nix develop -c pnpm sut

# Terminal 2
nix develop -c pnpm e2e
```

**In Shell (Two Terminals):**
```bash
# Terminal 1
nix develop
pnpm sut

# Terminal 2
nix develop
pnpm e2e
```

### Run Single Test

**With Prefix:**
```bash
nix develop -c bash -c "cd e2e && pnpm test:health"
```

**In Shell:**
```bash
nix develop
cd e2e && pnpm test:health
```

### Check Tool Versions

**With Prefix:**
```bash
nix develop -c python --version
nix develop -c go version
nix develop -c node --version
nix develop -c pnpm --version
```

**In Shell:**
```bash
nix develop
python --version
go version
node --version
pnpm --version
```

## Why Nix?

Nix ensures:
- ✅ Consistent Python 3.11.14
- ✅ Consistent Go 1.25.5
- ✅ Consistent Node.js 22.22.0
- ✅ Consistent pnpm 10.28.0
- ✅ Playwright with browsers
- ✅ Same environment for everyone
- ✅ Same environment in CI

Without Nix, you might have:
- ❌ Different Python versions
- ❌ Different Go versions
- ❌ Missing dependencies
- ❌ "Works on my machine" problems

## For AI/Automation

When writing scripts or instructions for AI, **ALWAYS** use the `nix develop -c` prefix:

```bash
# ✅ CORRECT
nix develop -c pnpm sut
nix develop -c pnpm e2e

# ❌ WRONG (will fail if not in Nix shell)
pnpm sut
pnpm e2e
```

## Troubleshooting

### "Command not found"

**Problem:**
```bash
$ pnpm sut
zsh: command not found: pnpm
```

**Solution:**
```bash
# Use Nix prefix
nix develop -c pnpm sut

# Or enter shell first
nix develop
pnpm sut
```

### "Wrong Python/Go version"

**Problem:**
```bash
$ python --version
Python 3.9.6  # Wrong version!
```

**Solution:**
```bash
nix develop -c python --version
# Python 3.11.14  # Correct!
```

### Forgetting Nix Prefix

**Problem:** Commands fail because you forgot the prefix.

**Solution:** Use direnv for automatic activation:
```bash
direnv allow
# Now commands work automatically in this directory
```

## Summary

**For humans developing:**
- Use `nix develop` once per terminal
- Or use `direnv allow` for automatic activation

**For scripts/CI/automation:**
- Always use `nix develop -c` prefix
- Ensures reproducibility

**For AI assistants:**
- **ALWAYS use `nix develop -c` prefix**
- Never assume the environment is active
- This is the safe, reproducible way

---

**Remember:** When in doubt, use `nix develop -c` prefix! 🎯
