# API Type Sharing

This document describes how API definitions are shared across all services in the Meeting Plunger project.

## Overview

The Meeting Plunger project uses OpenAPI/Swagger to maintain a single source of truth for API types across three services:
- **Backend (Python/FastAPI)** - Core transcription service
- **Local Service (Go)** - Client API bridge
- **Frontend (TypeScript/Vue)** - Web UI

Code generation flows bidirectionally to ensure type safety everywhere.

## Architecture

### Local Service → Frontend

```
Go Local Service (handlers.go)
  ↓ swag annotations
  ↓ swag init
OpenAPI Spec (local-service/generated/openapi.json)
  ↓ @hey-api/openapi-ts
TypeScript Client (frontend/src/generated/client/)
```

### Backend → Local Service

```
Python Backend (main.py)
  ↓ FastAPI /openapi.json
OpenAPI Spec (backend/generated/openapi.json)
  ↓ oapi-codegen
Go Client (local-service/generated/backend_client/)
```

## Current Setup

### Backend → Go Client

The Python FastAPI backend provides an OpenAPI 3.0 specification at `/openapi.json`. This is fetched and used to generate a type-safe Go client for the local-service.

**Location:** `backend/generated/openapi.json` → `local-service/generated/backend_client/`

**Generate:**
```bash
# No backend server needed - extracts spec directly from FastAPI app
nix develop -c pnpm generate:api
```

**Toolchain:**
- [FastAPI](https://fastapi.tiangolo.com/) - Automatically generates OpenAPI 3.0 from Python type hints
- [oapi-codegen](https://github.com/deepmap/oapi-codegen) - Generates Go client from OpenAPI 3.0

**Example backend code:**
```python
@app.post("/transcribe")
async def transcribe(file: UploadFile = File(...)):
    """Transcribe audio file."""
    return {"transcript": "Hello, how are you?"}
```

**Generated Go client usage:**
```go
import "meeting-plunger/local-service/generated/backendclient"

// Create client
client, err := backendclient.NewClient("http://localhost:8000")

// Type-safe API call
resp, err := client.PostTranscribe(ctx, file)
```

### Go Local Service → OpenAPI

The Go local-service uses [swaggo/swag](https://github.com/swaggo/swag) to generate OpenAPI specs from code annotations.

**Location:** `local-service/generated/openapi.json`

**Generate:**
```bash
nix develop -c pnpm generate:openapi
```

**Validate (CI check):**
```bash
nix develop -c pnpm validate:api
```

**Example annotations in `local-service/handlers.go`:**
```go
// HealthResponse represents the health check response
type HealthResponse struct {
    Status string `json:"status" example:"healthy"`
}

// HandleHealth serves the health check endpoint
// @Summary Health check
// @Description Returns the health status of the local service
// @Tags health
// @Produce json
// @Success 200 {object} HealthResponse
// @Router /health [get]
func HandleHealth(w http.ResponseWriter, r *http.Request) {
    // ...
}
```

### OpenAPI → TypeScript Client & SDK

TypeScript types, client, and SDK are automatically generated from the OpenAPI spec using [@hey-api/openapi-ts](https://github.com/hey-api/openapi-ts).

**Location:** `frontend/src/generated/client/`

**Generated files:**
- `index.ts` - Main export file
- `types.gen.ts` - TypeScript type definitions
- `services.gen.ts` - Service classes for API calls
- `core/` - Client utilities (ApiError, OpenAPI config, request handler)

**Generate:**
```bash
# Generate both OpenAPI JSON and TypeScript client in one command
nix develop -c pnpm generate:api

# Or generate only TypeScript client (requires OpenAPI JSON to exist)
cd frontend && nix develop -c pnpm generate:client
```

**Configuration:** `frontend/openapi-ts.config.ts`
```typescript
export default defineConfig({
  input: '../local-service/generated/openapi.json',
  output: 'src/generated/client',
  client: 'fetch',
  services: {
    asClass: true,
  },
});
```

**Example generated types:**
```typescript
// Type definitions
export type main_HealthResponse = {
  status?: string;
};

export type main_TranscriptResponse = {
  transcript?: string;
};

export type PostUploadData = {
  file: (Blob | File);
};
```

**Example generated services:**
```typescript
export class TranscriptionService {
  /**
   * Upload audio file for transcription
   */
  public static postUpload(data: PostUploadData): CancelablePromise<PostUploadResponse> {
    return __request(OpenAPI, {
      method: 'POST',
      url: '/upload',
      formData: { file: data.file }
    });
  }
}
```

## Workflow

### When Adding/Modifying API Endpoints

**For Backend endpoints:**
1. **Update Python code** in `backend/main.py` with type hints
2. **Regenerate all API code:**
   ```bash
   nix develop -c pnpm generate:api
   ```

**For Local Service endpoints:**
1. **Update Go handlers** with swag annotations in `local-service/handlers.go` or `local-service/main.go`
2. **Regenerate all API code:**
   ```bash
   nix develop -c pnpm generate:api
   ```

### Single Command for All

The `pnpm generate:api` command handles everything:
- Generates `local-service/generated/openapi.json` from Go code (swag)
- Generates `frontend/src/generated/client/` from local-service spec (@hey-api/openapi-ts)
- Extracts `backend/generated/openapi.json` from FastAPI app (no server needed)
- Generates `local-service/generated/backend_client/` from backend spec (oapi-codegen)

### Validation

To ensure all generated files are up to date:

```bash
# No backend server needed
nix develop -c pnpm validate:api
```

This validates:
- Backend OpenAPI spec (fetched from FastAPI)
- Backend Go client (generated from backend spec)
- Local-service OpenAPI spec (generated from Go code)
- Frontend TypeScript client (generated from local-service spec)

### Commit All Generated Files

Always commit:
- Backend OpenAPI spec (`backend/generated/openapi.json`)
- Backend Go client (`local-service/generated/backend_client/client.go`)
- Local service OpenAPI spec (`local-service/generated/openapi.json`)
- Frontend TypeScript client (`frontend/src/generated/client/`)

**Note:** Use `nix develop -c pnpm validate:api` to verify all generated files are in sync with source code.

### When Using Generated Clients

**Local Service calling Backend (Go):**
```go
import "meeting-plunger/local-service/generated/backendclient"

// Create client once (typically in main or handler initialization)
client, err := backendclient.NewClient(backendURL)
if err != nil {
    log.Fatal(err)
}

// Type-safe API call
resp, err := client.PostTranscribe(ctx, backendclient.PostTranscribeJSONRequestBody{
    File: file,
})
if err != nil {
    log.Printf("Backend error: %v", err)
    return
}
// resp is already typed!
log.Printf("Transcript: %s", resp.Transcript)
```

**Frontend calling Local Service (TypeScript with SDK):**
```typescript
import { TranscriptionService, OpenAPI, ApiError } from '../generated/client';
import type { main_TranscriptResponse } from '../generated/client';

// Configure OpenAPI client (set base URL to empty for Vite proxy)
OpenAPI.BASE = '';

// Type-safe API call using generated SDK
async function uploadFile(file: File): Promise<string> {
  try {
    const response: main_TranscriptResponse = await TranscriptionService.postUpload({ file });
    return response.transcript || '';
  } catch (error) {
    if (error instanceof ApiError) {
      throw new Error(error.body?.error || error.message);
    }
    throw error;
  }
}

// Example in Vue component
const handleSubmit = async () => {
  const file = fileInput.value?.files?[0];
  if (!file) return;
  
  try {
    const response = await TranscriptionService.postUpload({ file });
    emit('transcript', response.transcript || '');
  } catch (error) {
    if (error instanceof ApiError) {
      emit('transcript', `Error: ${error.body?.error || error.message}`);
    }
  }
};
```

**Local Service (Go):**
```go
type TranscriptResponse struct {
    Transcript string `json:"transcript" example:"Hello, how are you?"`
}

type HealthResponse struct {
    Status string `json:"status" example:"healthy"`
}

// Use directly in handlers
```

## Benefits

1. **Type Safety:** Catch API contract violations at compile time in Python, Go, and TypeScript
2. **Single Source of Truth:** Each service is authoritative for its own API
3. **Bidirectional Generation:** Backend ↔ Local Service ↔ Frontend all use generated code
4. **Documentation:** OpenAPI specs serve as API documentation
5. **Developer Experience:** IntelliSense and autocomplete for all API calls across all languages
6. **Refactoring Safety:** Rename or change an API, and compilers catch all usage sites
7. **No Manual HTTP Code:** No manual JSON marshaling, URL construction, or error handling

## File Locations

| File/Directory | Description | Committed? |
|----------------|-------------|------------|
| **Backend** | | |
| `backend/main.py` | Python FastAPI with type hints | ✅ Yes |
| `backend/generated/openapi.json` | Fetched from FastAPI /openapi.json | ✅ Yes |
| **Local Service** | | |
| `local-service/handlers.go` | Go handlers with swag annotations | ✅ Yes |
| `local-service/main.go` | Main API metadata annotations | ✅ Yes |
| `local-service/generated/openapi.json` | Generated from Go code (Swagger 2.0) | ✅ Yes |
| `local-service/generated/backend_client/` | Generated Go client for backend | ✅ Yes |
| `└── client.go` | Type-safe backend client | ✅ Yes |
| **Frontend** | | |
| `frontend/src/generated/client/` | Generated TypeScript client | ✅ Yes |
| `├── index.ts` | Main export file | ✅ Yes |
| `├── types.gen.ts` | Type definitions | ✅ Yes |
| `├── services.gen.ts` | Service classes (SDK) | ✅ Yes |
| `└── core/` | Client utilities (ApiError, OpenAPI config, etc.) | ✅ Yes |
| `frontend/openapi-ts.config.ts` | openapi-ts configuration | ✅ Yes |

**Why commit generated files?**
- Ensures everyone (developers, CI, production) uses the same client code
- CI can validate that generated files are up to date
- Prevents runtime type mismatches
- Enables code review of API changes through SDK diffs
- No need to regenerate during deployment

## Toolchain

The API type sharing uses multiple code generators:

### Backend → Local Service

1. **[FastAPI](https://fastapi.tiangolo.com/)** - Auto-generates OpenAPI 3.0 from Python type hints
   - Input: Python code with type hints
   - Output: OpenAPI 3.0 spec at `/openapi.json` endpoint

2. **[oapi-codegen](https://github.com/deepmap/oapi-codegen)** - Generates Go client from OpenAPI 3.0
   - Input: `backend/generated/openapi.json` (OpenAPI 3.0)
   - Output: `local-service/generated/backend_client/client.go`
   - Features: Type-safe client, models, error handling

**Why oapi-codegen?**
- Most popular Go OpenAPI code generator (7.5k+ stars)
- Native OpenAPI 3.0 support
- Generates clean, idiomatic Go code
- Uses standard `net/http`, no external dependencies

### Local Service → Frontend

1. **[swaggo/swag](https://github.com/swaggo/swag)** - Generates Swagger 2.0 from Go annotations
   - Input: Go code with swag annotations
   - Output: `local-service/generated/openapi.json` (Swagger 2.0)

2. **[@hey-api/openapi-ts](https://github.com/hey-api/openapi-ts)** - Generates TypeScript client, SDK, and types
   - Input: Swagger 2.0/OpenAPI 3.0 JSON
   - Output: `frontend/src/generated/client/`
     - `types.gen.ts` - Type definitions
     - `services.gen.ts` - Service classes
     - `core/` - Client utilities (OpenAPI config, ApiError, etc.)

**Why @hey-api/openapi-ts?**
- Works with both Swagger 2.0 and OpenAPI 3.0
- Generates not just types, but full SDK with type-safe API calls
- Generates service classes for better organization
- Includes error handling with ApiError
- No need for manual fetch/response.json() calls

## References

- [FastAPI](https://fastapi.tiangolo.com/) - Python web framework with automatic OpenAPI generation
- [oapi-codegen](https://github.com/deepmap/oapi-codegen) - OpenAPI code generator for Go
- [swaggo/swag](https://github.com/swaggo/swag) - Swagger generator for Go
- [@hey-api/openapi-ts](https://github.com/hey-api/openapi-ts) - Generate TypeScript client and SDK from OpenAPI
- [OpenAPI Specification](https://swagger.io/specification/) - API standard
