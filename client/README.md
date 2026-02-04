# Client (Golang)

Golang CLI and HTTP server for Meeting Plunger.

## Development

The client uses `air` for live reload during development. Changes to `.go` files automatically trigger a rebuild.

### Start with Auto-Reload

From the project root:
```bash
nix develop -c pnpm sut
```

Or run the client alone:
```bash
nix develop -c pnpm sut:client
```

Or directly:
```bash
cd client
nix develop -c air
```

### Build Binary

```bash
cd client
nix develop -c go build -o client .
./client serve
```

## Configuration

- **`.air.toml`** - Air live reload configuration
  - Watches `.go` files
  - Rebuilds to `tmp/main`
  - Runs with `serve` argument
  - Cleans up on exit

## How It Works

When you change a `.go` file:
1. `air` detects the change
2. Rebuilds the binary to `tmp/main`
3. Kills the old process
4. Starts the new binary with `serve` argument
5. Server is ready in ~1-2 seconds

## Endpoints

- **GET /** - HTML client interface
- **GET /health** - Health check endpoint

## Commands

```bash
# Run with live reload (recommended for development)
air

# Run directly (no reload)
go run . serve

# Build binary
go build -o client .

# Run binary
./client serve
```

## CLI Usage

```bash
# Show help
go run .

# Start HTTP server
go run . serve
```
