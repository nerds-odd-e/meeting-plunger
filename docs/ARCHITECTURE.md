# Architecture

## Overview

Meeting Plunger is a multi-tier application for converting meeting audio to transcripts.

## System Architecture

```
User's Computer                                Server
┌─────────────────────────────┐               ┌──────────────┐
│ Browser                     │               │ Backend      │
│   ┌─────────────────────┐   │               │ (Python)     │
│   │ Frontend (Vue)      │   │               │              │
│   │ localhost:3000      │   │               │ k8s          │──> OpenAI API
│   └──────────┬──────────┘   │               │              │
│              │               │               └──────▲───────┘
│              ▼               │                      │
│   ┌─────────────────────┐   │                      │
│   │ Client (Golang)     │   │                      │
│   │ API Server :3001    │───┼──── HTTPS ───────────┘
│   │ CLI                 │   │    auth token
│   └─────────────────────┘   │
└─────────────────────────────┘
```

## Components

### Frontend (Vue.js 3)
- **Location**: `frontend/`
- **Port**: 3000
- **Technology**: Vue.js 3, TypeScript, Vite
- **Purpose**: Browser-based user interface
- **Communication**: Proxies API calls to client on port 3001

### Client (Golang)
- **Location**: `client/`
- **Port**: 3001
- **Technology**: Go 1.25+
- **Purpose**: 
  - API server bridging frontend and backend
  - CLI for command-line operations
- **Endpoints**:
  - `GET /health` - Health check
  - `POST /upload` - Upload audio file (currently returns hardcoded response)

### Backend (Python)
- **Location**: `backend/`
- **Port**: 8000
- **Technology**: Python 3.11, FastAPI
- **Purpose**: 
  - AI transcription processing
  - Integration with OpenAI API
- **Deployment**: Kubernetes (k8s)

## Request Flow

### Audio Upload & Transcription

```
1. User uploads audio file in browser
   ↓
2. Frontend (Vue.js :3000)
   - Captures file from upload form
   - Sends POST /upload request
   ↓
3. Client (Go :3001)
   - Receives upload request
   - Processes file
   - Calls backend API
   ↓
4. Backend (Python :8000)
   - Receives request from client
   - Calls OpenAI transcription API
   - Returns transcript
   ↓
5. Response flows back: Backend → Client → Frontend → User
```

## Development Setup

All three services run concurrently during development:

```bash
nix develop -c pnpm sut
```

This starts:
- Backend on http://localhost:8000
- Client on http://localhost:3001  
- Frontend on http://localhost:3000

All services support auto-reload on code changes.

## Testing

### Unit Tests
- **Frontend**: Vitest (`pnpm test:frontend`)
- **Client**: Go test (`pnpm test:client`)
- **Backend**: Pytest (`pnpm test:backend`)

### E2E Tests
- **Framework**: Playwright + Cucumber (Gherkin)
- **Command**: `pnpm e2e`
- **Tests**: Browser automation testing the full stack

## Technology Stack

| Component | Technology | Auto-Reload |
|-----------|------------|-------------|
| Frontend  | Vue.js 3, TypeScript, Vite | ✅ Vite HMR |
| Client    | Golang, net/http | ✅ Air |
| Backend   | Python, FastAPI | ✅ Uvicorn |
| E2E Tests | Playwright, Cucumber | N/A |

## Future Enhancements

- [ ] Implement actual backend transcription (currently hardcoded)
- [ ] Add authentication flow
- [ ] Implement file storage and retrieval
- [ ] Add meeting minutes generation
- [ ] Deploy to Kubernetes
