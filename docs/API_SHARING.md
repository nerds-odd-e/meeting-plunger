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
nix develop -c pnpm validate:openapi
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

### OpenAPI → TypeScript

TypeScript types are automatically generated from the OpenAPI spec using [openapi-typescript](https://github.com/drwpow/openapi-typescript).

**Location:** `frontend/src/generated/client/types.ts`

**Generate:**
```bash
# Generate both OpenAPI JSON and TypeScript types in one command
nix develop -c pnpm generate:api

# Or generate only TypeScript types (requires OpenAPI JSON to exist)
cd frontend && nix develop -c pnpm generate:client
```

**Example generated types:**
```typescript
export interface paths {
  "/health": {
    get: {
      responses: {
        200: {
          content: {
            "application/json": components["schemas"]["main.HealthResponse"];
          };
        };
      };
    };
  };
  "/upload": {
    post: {
      requestBody: {
        content: {
          "multipart/form-data": {
            file: Blob;
          };
        };
      };
      responses: {
        200: {
          content: {
            "application/json": components["schemas"]["main.TranscriptResponse"];
          };
        };
      };
    };
  };
}

export interface components {
  schemas: {
    "main.HealthResponse": {
      status?: string;
    };
    "main.TranscriptResponse": {
      transcript?: string;
    };
    "main.ErrorResponse": {
      error?: string;
    };
  };
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
   
3. **Validate OpenAPI spec is up to date** (optional, CI will check):
   ```bash
   nix develop -c pnpm validate:openapi
   ```
4. **Commit all changes:**
   - Go code changes (`client/*.go`)
   - Generated OpenAPI spec (`client/generated/openapi.json`)
   - Frontend types are gitignored (regenerated on demand)

**Note:** CI will automatically validate that the generated OpenAPI spec matches the code. If you forget to regenerate after modifying the API, the CI build will fail with a helpful diff.

### When Using API Types

**Frontend (TypeScript):**
```typescript
import type { components } from '@generated/client/types';

type TranscriptResponse = components['schemas']['main.TranscriptResponse'];
type HealthResponse = components['schemas']['main.HealthResponse'];

// Using in API calls
const response = await fetch('/upload', {
  method: 'POST',
  body: formData,
});

const data: TranscriptResponse = await response.json();
console.log(data.transcript); // TypeScript knows this is a string

// Type-safe API client helper
async function uploadFile(file: File): Promise<TranscriptResponse> {
  const formData = new FormData();
  formData.append('file', file);
  
  const response = await fetch('/upload', {
    method: 'POST',
    body: formData,
  });
  
  if (!response.ok) {
    throw new Error(`Upload failed: ${response.statusText}`);
  }
  
  return response.json();
}
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

1. **Type Safety:** Catch API contract violations at compile time
2. **Single Source of Truth:** Go code is the authoritative API definition
3. **Documentation:** OpenAPI spec serves as API documentation
4. **Tooling:** Can generate clients, mocks, validators, etc.

## File Locations

| File | Description | Committed? |
|------|-------------|------------|
| `client/handlers.go` | Go handlers with swag annotations | ✅ Yes |
| `client/main.go` | Main API metadata annotations | ✅ Yes |
| `client/generated/openapi.json` | Generated OpenAPI spec (Swagger 2.0) | ✅ Yes |
| `frontend/src/generated/client/types.ts` | Generated TypeScript types | ❌ No (gitignored) |

## Toolchain

The API type sharing uses a pipeline of three tools:

1. **[swaggo/swag](https://github.com/swaggo/swag)** - Generates Swagger 2.0 from Go annotations
   - Input: Go code with swag annotations
   - Output: `client/generated/openapi.json` (Swagger 2.0)

2. **[swagger2openapi](https://github.com/Mermade/oas-kit/tree/main/packages/swagger2openapi)** - Converts Swagger 2.0 to OpenAPI 3.0
   - Input: Swagger 2.0 JSON
   - Output: OpenAPI 3.0 JSON (temporary, not committed)

3. **[openapi-typescript](https://github.com/drwpow/openapi-typescript)** - Generates TypeScript types from OpenAPI 3.0
   - Input: OpenAPI 3.0 JSON
   - Output: `frontend/src/generated/client/types.ts`

**Why the conversion?**
- swaggo generates Swagger 2.0 format
- openapi-typescript requires OpenAPI 3.0
- swagger2openapi bridges the gap automatically

## References

- [swaggo/swag](https://github.com/swaggo/swag) - Swagger generator for Go
- [openapi-typescript](https://github.com/drwpow/openapi-typescript) - Generate TypeScript from OpenAPI
- [swagger2openapi](https://github.com/Mermade/oas-kit) - Convert Swagger 2.0 to OpenAPI 3.0
- [OpenAPI Specification](https://swagger.io/specification/) - API standard
