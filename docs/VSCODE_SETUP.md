# VSCode Setup Guide

This project includes pre-configured VSCode settings for optimal development experience.

## Quick Setup

1. **Open in VSCode**
   ```bash
   code .
   ```

2. **Install Recommended Extensions**
   - When prompted, click "Install All" for recommended extensions
   - Or manually: `Ctrl+Shift+P` → "Extensions: Show Recommended Extensions"

3. **Start Coding!**
   - Cucumber autocomplete works in `.feature` files
   - Click on steps to jump to definitions
   - Use F5 to debug

## Key Features

### 🥒 Cucumber/Gherkin Support

**Autocomplete in Feature Files:**
```gherkin
Feature: My Feature
  Scenario: Test something
    Given I   # <-- Start typing, VSCode suggests existing steps
```

**Go to Definition:**
- `Ctrl+Click` (or `Cmd+Click` on Mac) on any step in a `.feature` file
- Jumps to the step definition in `e2e/steps/`

**Find All References:**
- Right-click on a step definition
- See all feature files using this step

### 🐛 Debugging

**Available Debug Configurations:**

1. **Python: FastAPI** - Debug the backend
2. **Go: Client** - Debug the client
3. **E2E: Debug Tests** - Debug E2E tests with browser visible
4. **Full Stack** - Debug both backend and client simultaneously

**How to Use:**
1. Set breakpoints by clicking left of line numbers
2. Press `F5` or click "Run and Debug" in sidebar
3. Select configuration from dropdown
4. Debug!

### ⚡ Tasks (Quick Actions)

Access via `Ctrl+Shift+P` → "Tasks: Run Task":

- **Start SUT (Backend + Client)** - `pnpm sut`
- **Run E2E Tests** - `pnpm e2e`
- **Run E2E Tests (Headed)** - See browser while testing
- **Install Dependencies**

### 🎨 Code Formatting

**Automatic formatting on save:**
- Python: Black formatter (88 chars)
- Go: gofmt
- JavaScript: Prettier
- Gherkin: Manual (preserves intentional spacing)

## Recommended Extensions

### Essential (Auto-prompted on first open)

1. **Cucumber (Gherkin) Full Support** - Step autocomplete & navigation
2. **Playwright Test** - Test runner integration
3. **Python** - Python language support
4. **Go** - Go language support
5. **Prettier** - Code formatter
6. **ESLint** - JavaScript linting

### Bonus

7. **GitLens** - Enhanced Git features
8. **Code Spell Checker** - Catch typos

## Shortcuts

| Action | Shortcut (Mac) | Shortcut (Win/Linux) |
|--------|----------------|----------------------|
| Command Palette | `Cmd+Shift+P` | `Ctrl+Shift+P` |
| Quick Open File | `Cmd+P` | `Ctrl+P` |
| Toggle Terminal | `Ctrl+\`` | `Ctrl+\`` |
| Start Debugging | `F5` | `F5` |
| Run Task | `Cmd+Shift+B` | `Ctrl+Shift+B` |
| Go to Definition | `Cmd+Click` | `Ctrl+Click` |
| Find All References | `Shift+F12` | `Shift+F12` |
| Format Document | `Shift+Alt+F` | `Shift+Alt+F` |

## Typical Workflow

### 1. Writing a New Feature

```gherkin
# In e2e/features/my-feature.feature
Feature: New Feature
  Scenario: Test something
    Given I start typing...
    # ↑ VSCode suggests existing steps
    When I perform an action  # Ctrl+Click to see/edit implementation
    Then I see the result
```

### 2. Implementing Step Definitions

```javascript
// In e2e/steps/my-feature.steps.js
import { Given, When, Then } from '@cucumber/cucumber';

Given('I start typing...', async function () {
  // Implementation
  // VSCode: Right-click → "Find All References" to see usage
});
```

### 3. Debugging Tests

1. Set breakpoint in step definition
2. Press `F5`
3. Select "E2E: Debug Tests"
4. Browser opens in debug mode
5. Step through code

### 4. Running Tests

**Option 1: Command Line**
```bash
pnpm sut    # Terminal 1
pnpm e2e    # Terminal 2
```

**Option 2: VSCode Task**
1. `Ctrl+Shift+P` → "Tasks: Run Task"
2. Select "Start SUT (Backend + Client)"
3. Open new terminal
4. `Ctrl+Shift+P` → "Tasks: Run Task"
5. Select "Run E2E Tests"

**Option 3: VSCode Terminal**
1. Press `Ctrl+\`` to open terminal
2. Type `pnpm sut`
3. Click `+` for new terminal
4. Type `pnpm e2e`

## Troubleshooting

### Cucumber Autocomplete Not Working

**Solution 1: Reload Window**
1. `Ctrl+Shift+P`
2. "Developer: Reload Window"

**Solution 2: Check Extension**
1. `Ctrl+Shift+X` (Extensions sidebar)
2. Search "Cucumber"
3. Ensure "Cucumber (Gherkin) Full Support" is installed and enabled

**Solution 3: Regenerate Autocomplete**
1. `Ctrl+Shift+P`
2. "Cucumber: Regenerate autocomplete"

### Can't Jump to Step Definition

**Check Settings:**
1. Open `.vscode/settings.json`
2. Verify:
   ```json
   "cucumber.glue": [
     "e2e/steps/**/*.js",
     "e2e/support/**/*.js"
   ]
   ```

### Debug Not Starting

**Check:**
1. Dependencies installed: `pnpm install && pnpm e2e:install`
2. Ports not in use: `lsof -i :8000` and `lsof -i :3000`
3. In Nix environment: `nix develop`

## Customization

### Personal Settings

Create `.vscode/settings.local.json` (git-ignored):

```json
{
  "editor.fontSize": 14,
  "editor.fontFamily": "Fira Code",
  "workbench.colorTheme": "Monokai"
}
```

### Keyboard Shortcuts

1. `Ctrl+Shift+P` → "Preferences: Open Keyboard Shortcuts"
2. Search for command
3. Click pencil icon to change

## Tips & Tricks

### 1. Multi-Cursor Editing

**Add cursors:**
- `Alt+Click` (Mac: `Option+Click`)
- Select word, press `Ctrl+D` to select next occurrence

**Use case:** Edit multiple similar lines at once

### 2. Column Selection

Hold `Alt+Shift` (Mac: `Option+Shift`) and drag mouse

**Use case:** Edit multiple lines at specific column

### 3. Quick File Navigation

- `Ctrl+P` - Open file by name
- `Ctrl+P` then type `@` - Jump to symbol in file
- `Ctrl+P` then type `#` - Search workspace symbols

### 4. Zen Mode

`Ctrl+K` then `Z` - Distraction-free coding

### 5. Split Editor

- Drag file tabs to split
- `Ctrl+\` to split current editor

### 6. Breadcrumbs Navigation

Click breadcrumbs at top to navigate file structure

### 7. Peek Definition

`Alt+F12` - See definition in inline window without navigating away

## More Information

- **Full VSCode Docs**: [.vscode/README.md](.vscode/README.md)
- **Cucumber Extension**: [Marketplace](https://marketplace.visualstudio.com/items?itemName=alexkrechik.cucumberautocomplete)
- **VSCode Docs**: [code.visualstudio.com](https://code.visualstudio.com/docs)

---

**Happy Coding! 🎉**

If you encounter any issues with the VSCode setup, please update this document or the settings files.
