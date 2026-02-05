# Client (Golang)

Golang CLI and API server for Meeting Plunger. The client bridges communication between the frontend (Vue.js) and backend (Python).

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

## Architecture

**Request Flow:**
```
Frontend (Vue :3000) → Client (Go :3001) → Backend (Python :8000) → OpenAI API
```

The client API server runs on port 3001 and:
- Receives requests from the frontend
- Handles file uploads
- Communicates with the backend API
- Returns transcription results

## API Documentation

### OpenAPI Specification

The client API is documented using OpenAPI/Swagger. The specification is automatically generated from code annotations using [swaggo/swag](https://github.com/swaggo/swag).

**Generated spec:** `client/generated/openapi.json`

#### Regenerate OpenAPI Spec

After modifying API endpoints or their annotations:

```bash
# From project root
nix develop -c pnpm generate:openapi

# Or run the script directly
./scripts/generate-client-openapi.sh
```

#### Validate OpenAPI Spec

Check if the generated spec is up to date (used in CI):

```bash
# From project root
nix develop -c pnpm validate:api

# Or run the script directly
./scripts/validate-api-generation.sh
```

The validation will fail with a diff if the generated file doesn't match the code. This ensures the OpenAPI spec is always kept in sync with the API implementation.

The generated `openapi.json` file is committed to the repository and can be used to:
- Generate TypeScript types for the frontend
- Generate API clients
- View in Swagger UI or other OpenAPI tools

### Endpoints

- **GET /health** - Health check endpoint
- **POST /upload** - Upload audio file for transcription (returns hardcoded response for now)

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
