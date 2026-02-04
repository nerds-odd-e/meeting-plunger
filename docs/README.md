# Documentation

All documentation for the Meeting Plunger project.

## Essential Reading

- [`.cursor/rules/general.mdc`](../.cursor/rules/general.mdc) - **Start here!** Essential commands and workflow

## Guides

- [QUICK_START.md](QUICK_START.md) - Quick start guide for getting up and running
- [VERIFICATION.md](VERIFICATION.md) - Verify your setup is working correctly
- [VSCODE_SETUP.md](VSCODE_SETUP.md) - VSCode configuration with Cucumber plugin

## Additional Documentation

- [Main README](../README.md) - Project overview
- [E2E Tests](../e2e/README.md) - E2E testing with Playwright + Cucumber
- [VSCode Settings](../.vscode/README.md) - VSCode configuration details

## Quick Reference

### Start Development

```bash
# Terminal 1 - Start services
nix develop -c pnpm sut

# Terminal 2 - Run tests
nix develop -c pnpm e2e
```

See [`.cursor/rules/general.mdc`](../.cursor/rules/general.mdc) for complete command reference.
