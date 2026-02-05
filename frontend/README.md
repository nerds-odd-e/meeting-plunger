# Meeting Plunger Frontend

Vue.js 3 + TypeScript + Vite frontend for Meeting Plunger.

## Development

All commands should be prefixed with `nix develop -c`:

```bash
# Install dependencies (from project root)
nix develop -c pnpm install

# Start development server
nix develop -c pnpm --filter frontend dev

# Run unit tests
nix develop -c pnpm --filter frontend test

# Run unit tests in watch mode
nix develop -c pnpm --filter frontend test:watch

# Lint
nix develop -c pnpm --filter frontend lint

# Format
nix develop -c pnpm --filter frontend format

# Build for production
nix develop -c pnpm --filter frontend build
```

## Project Structure

```
frontend/
├── src/
│   ├── components/          # Vue components
│   │   ├── UploadForm.vue
│   │   └── TranscriptResult.vue
│   ├── App.vue              # Root component
│   ├── main.ts              # Application entry point
│   └── style.css            # Global styles
├── index.html               # HTML template
├── vite.config.ts           # Vite configuration
├── tsconfig.json            # TypeScript configuration
└── package.json             # Dependencies and scripts
```

## Features

- Vue.js 3 with Composition API
- TypeScript for type safety
- Vite for fast development and building
- Vitest for unit testing
- ESLint + Prettier for code quality
- Proxy to backend API (port 8000)

## API Integration

The frontend proxies `/upload` and `/health` requests to the client API server running on port 3001. The client then communicates with the backend on port 8000.

**Architecture:**
- Frontend (Vue.js): http://localhost:3000
- Client (Go API): http://localhost:3001 ← Frontend talks to this
- Backend (Python): http://localhost:8000 ← Client talks to this

Make sure all services are running: `nix develop -c pnpm sut`
