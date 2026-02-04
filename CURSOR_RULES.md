# Cursor Rules Documentation

## What is `.cursorrules`?

The `.cursorrules` file contains instructions for Cursor AI (and other AI assistants) on how to work with this project.

## Key Rules

### 1. ALWAYS Use Nix Prefix

**CRITICAL:** All commands must be prefixed with `nix develop -c`

```bash
# ❌ WRONG
pnpm sut
pnpm e2e
python --version

# ✅ CORRECT
nix develop -c pnpm sut
nix develop -c pnpm e2e
nix develop -c python --version
```

### Why?

This project uses Nix for reproducible development. Running commands without the Nix prefix may:
- Use wrong tool versions
- Fail with "command not found"
- Create inconsistent environments
- Cause "works on my machine" problems

### Exception

You can omit the prefix if you're already inside a `nix develop` shell or using `direnv`.

## Quick Reference

### Start Services
```bash
nix develop -c pnpm sut
```

### Run Tests
```bash
nix develop -c pnpm e2e         # Headless
nix develop -c pnpm e2e:headed  # With browser
nix develop -c pnpm e2e:debug   # Debug mode
```

### Development Workflow
1. Terminal 1: `nix develop -c pnpm sut`
2. Terminal 2: `nix develop -c pnpm e2e`
3. Make changes
4. Tests auto-run or re-run `pnpm e2e`

## For AI Assistants

When providing commands:
- **ALWAYS** include `nix develop -c` prefix
- Explain that services must be running before tests
- Mention that backend auto-reloads, client needs restart
- Reference relevant documentation files

## Project Structure Reminder

- `backend/` - Python/FastAPI (auto-reloads)
- `client/` - Go (manual restart needed)
- `e2e/` - Playwright + Cucumber tests
- `.vscode/` - VSCode settings (Cucumber plugin configured)

## Testing Notes

- Feature files: `e2e/features/*.feature`
- Step definitions: `e2e/steps/*.steps.js`
- Support code: `e2e/support/world.js`
- VSCode has autocomplete and go-to-definition for Gherkin steps

## Documentation Files

For detailed information, refer to:
- `NIX_COMMANDS.md` - Complete Nix command guide
- `QUICK_START.md` - Quick start guide
- `COMMANDS.md` - All available commands
- `VSCODE_SETUP.md` - VSCode configuration

---

**Remember:** When in doubt, use `nix develop -c` prefix! 🎯
