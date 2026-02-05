# API Type Sharing

This document describes how API definitions are shared between the Go client and TypeScript frontend.

## Overview

The Meeting Plunger project uses OpenAPI/Swagger to maintain a single source of truth for API types. The Go client generates an OpenAPI specification from code annotations, which can then be used to generate TypeScript types for the frontend.

## Architecture

```
Go Client (handlers.go)
  ↓ swag annotations
  ↓ swag init
OpenAPI Spec (client/generated/openapi.json)
  ↓ openapi-typescript (future)
TypeScript Types (frontend/src/types/api.ts)
```

## Current Setup

### Go Client → OpenAPI

The Go client uses [swaggo/swag](https://github.com/swaggo/swag) to generate OpenAPI specs from code annotations.

**Location:** `client/generated/openapi.json`

**Generate:**
```bash
nix develop -c pnpm generate:openapi
```

**Validate (CI check):**
```bash
nix develop -c pnpm validate:api
```

**Example annotations in `client/handlers.go`:**
```go
// HealthResponse represents the health check response
type HealthResponse struct {
    Status string `json:"status" example:"healthy"`
}

// HandleHealth serves the health check endpoint
// @Summary Health check
// @Description Returns the health status of the client service
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
  input: '../client/generated/openapi.json',
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

1. **Update Go handlers** with swag annotations in `client/handlers.go` or `client/main.go`
2. **Regenerate both OpenAPI spec and TypeScript types:**
   ```bash
   nix develop -c pnpm generate:api
   ```
   This single command:
   - Generates `client/generated/openapi.json` from Go code
   - Converts Swagger 2.0 to OpenAPI 3.0
   - Generates `frontend/src/generated/client/types.ts` from OpenAPI spec
   
3. **Validate generated files are up to date** (optional, CI will check):
   ```bash
   nix develop -c pnpm validate:api
   ```
4. **Commit all changes:**
   - Go code changes (`client/*.go`)
   - Generated OpenAPI spec (`client/generated/openapi.json`)
   - Generated TypeScript types (`frontend/src/generated/client/types.ts`)

**Note:** CI will automatically validate that both the OpenAPI spec and frontend types match the code. If you forget to regenerate after modifying the API, the CI build will fail with a helpful diff showing exactly what's out of sync.

### When Using Generated Client

**Frontend (TypeScript with SDK):**
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

**Client (Go):**
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

1. **Type Safety:** Catch API contract violations at compile time in both Go and TypeScript
2. **Single Source of Truth:** Go code is the authoritative API definition
3. **CI Validation:** Automatically validates both OpenAPI spec and TypeScript types are in sync
4. **Documentation:** OpenAPI spec serves as API documentation
5. **Developer Experience:** IntelliSense and autocomplete for all API calls
6. **Refactoring Safety:** Rename or change an API, and TypeScript compiler catches all usage sites

## File Locations

| File/Directory | Description | Committed? |
|----------------|-------------|------------|
| `client/handlers.go` | Go handlers with swag annotations | ✅ Yes |
| `client/main.go` | Main API metadata annotations | ✅ Yes |
| `client/generated/openapi.json` | Generated OpenAPI spec (Swagger 2.0) | ✅ Yes |
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

The API type sharing uses a two-stage pipeline:

1. **[swaggo/swag](https://github.com/swaggo/swag)** - Generates Swagger 2.0 from Go annotations
   - Input: Go code with swag annotations
   - Output: `client/generated/openapi.json` (Swagger 2.0)

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

- [swaggo/swag](https://github.com/swaggo/swag) - Swagger generator for Go
- [@hey-api/openapi-ts](https://github.com/hey-api/openapi-ts) - Generate TypeScript client and SDK from OpenAPI
- [OpenAPI Specification](https://swagger.io/specification/) - API standard
