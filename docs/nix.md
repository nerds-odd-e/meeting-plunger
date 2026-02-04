# Local Development Environment Setup with Nix

## :warning: 🚨 **ONLY PROCEED** with the subsequent steps if `./setup-meeting-plunger-dev.sh` (see [README.md](../README.md)) somehow failed horribly for you!!!

### 1. Install Nix

We use Nix installer by Determinate Systems to manage and ensure a reproducible development environment ([https://determinate.systems/posts/determinate-nix-installer/](https://determinate.systems/posts/determinate-nix-installer/)).

Full details on Nix installation via Determinate nix-installer [here](https://github.com/DeterminateSystems/nix-installer)

```bash
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install --determinate
```

### 2. Setup and Run Meeting Plunger for the First Time (Local Development Profile)

```bash
mkdir -p ~/.config/nix
echo 'experimental-features = nix-command flakes' >> ~/.config/nix/nix.conf
```

Launch a new terminal in your favourite shell (I highly recommend zsh).
Clone the meeting-plunger codebase from Github (Microsoft Windows OS users, please clone the repo to a non-Windows mount directory)

```bash
git config --global core.autocrlf input
git clone git@github.com:YOUR_USERNAME/meeting-plunger.git
cd meeting-plunger
git add --renormalize .
```

Boot up your meeting-plunger development environment.
The Nix development environment will be started on entering the local cloned `meeting-plunger` source directory via `direnv` (if installed and configured), else run `nix develop`.

```bash
cd meeting-plunger
```

All development tool commands henceforth should work when in the `nix` development environment that will be bootstrapped by `direnv` (if installed and configured correctly), else run `nix develop` to get the necessary tooling installed correctly.

**Install dependencies (first time only):**

```bash
# from meeting-plunger source root dir
pnpm install && pnpm e2e:install
```

**Start the complete development environment (recommended):**

```bash
# from meeting-plunger source root dir
pnpm sut
```

This starts both backend (Python FastAPI) and client (Golang) - both with auto-reload on code changes.

**Alternative - Start services individually:**

```bash
# Backend only (Python FastAPI on :8000)
pnpm sut:backend

# Client only (Golang on :3000)
pnpm sut:client
```

The backend will automatically restart when you change Python code.
The client will automatically restart when you change Go code (using air).

Navigate to [README.md](../README.md) for more information.

### 3. Running Tests

With services running (in Terminal 1), open a second terminal and run:

```bash
# Run e2e tests (headless)
pnpm e2e

# Run e2e tests (with browser visible)
pnpm e2e:headed

# Run e2e tests (debug mode)
pnpm e2e:debug
```

See [e2e/README.md](../e2e/README.md) for detailed testing guide.

### 4. Uninstalling

IF YOU REALLY REALLY NEED TO, you can remove Nix by running:

```bash
/nix/nix-installer uninstall
```
