# Bidirectional API Code Generation

## Overview

The Meeting Plunger project now has **bidirectional** type-safe API code generation:

```
Backend (Python) ←→ Local Service (Go) ←→ Frontend (TypeScript)
```

All inter-service communication uses generated, type-safe client code - no manual HTTP calls!

## Quick Start

### Generate All API Code

Single command generates everything (no backend server needed):
```bash
nix develop -c pnpm generate:api
```

This generates:
1. **Local Service OpenAPI spec** from Go code (swag)
2. **Frontend TypeScript client** from local-service spec (@hey-api/openapi-ts)
3. **Backend OpenAPI spec** from running FastAPI (curl)
4. **Local Service Go client** from backend spec (oapi-codegen)

## What Gets Generated

### Backend → Local Service (Go Client)

**Source:** `backend/main.py` (Python with FastAPI)
**Generated:** `local-service/generated/backend_client/client.go`

**Before (Manual HTTP):**
```go
// 100+ lines of manual HTTP code, JSON marshaling, error handling
req, err := http.NewRequest("POST", backendURL+"/transcribe", &requestBody)
req.Header.Set("Content-Type", writer.FormDataContentType())
client := &http.Client{}
resp, err := client.Do(req)
body, err := io.ReadAll(resp.Body)
var transcriptResp TranscriptResponse
err = json.Unmarshal(body, &transcriptResp)
// ... more error handling ...
```

**After (Generated Client):**
```go
import "meeting-plunger/local-service/generated/backendclient"

client, _ := backendclient.NewClient("http://localhost:8000")
resp, err := client.PostTranscribe(ctx, file)
// That's it! Type-safe, clean, simple.
```

### Local Service → Frontend (TypeScript Client)

**Source:** `local-service/handlers.go` (Go with swag annotations)
**Generated:** `frontend/src/generated/client/`

**Usage:**
```typescript
import { TranscriptionService } from '../generated/client';

// Type-safe API call
const response = await TranscriptionService.postUpload({ file });
```

## Architecture

### Flow Diagram

```
┌─────────────────┐
│ Backend         │
│ (Python/FastAPI)│
│                 │
│ Type hints →    │
│ Auto OpenAPI 3.0│
└────────┬────────┘
         │ /openapi.json
         │ (curl fetch)
         ↓
┌─────────────────┐
│ backend/        │
│ generated/      │
│ openapi.json    │
└────────┬────────┘
         │ oapi-codegen
         ↓
┌─────────────────┐
│ Local Service   │
│ backend_client/ │
│ client.go       │
└─────────────────┘
         ↑
         │ (uses generated client)
         │
┌────────┴────────┐
│ Local Service   │
│ (Go/net/http)   │
│                 │
│ Swag annotations│
└────────┬────────┘
         │ swag init
         ↓
┌─────────────────┐
│ local-service/  │
│ generated/      │
│ openapi.json    │
└────────┬────────┘
         │ @hey-api/openapi-ts
         ↓
┌─────────────────┐
│ Frontend        │
│ generated/client│
│ *.gen.ts        │
└─────────────────┘
         ↑
         │ (uses generated client)
         │
┌────────┴────────┐
│ Frontend        │
│ (TypeScript/Vue)│
└─────────────────┘
```

## Toolchain

| Tool | Purpose | Input | Output |
|------|---------|-------|--------|
| **FastAPI** | Auto-generate OpenAPI from Python | Type hints in `backend/main.py` | OpenAPI 3.0 at `/openapi.json` |
| **oapi-codegen** | Generate Go client | `backend/generated/openapi.json` | `local-service/generated/backend_client/client.go` |
| **swaggo/swag** | Generate OpenAPI from Go | Annotations in `local-service/*.go` | `local-service/generated/openapi.json` |
| **@hey-api/openapi-ts** | Generate TypeScript client | `local-service/generated/openapi.json` | `frontend/src/generated/client/` |

## When to Regenerate

### Modify Backend API

1. Edit `backend/main.py`
2. Ensure backend is running: `nix develop -c pnpm sut:backend`
3. Regenerate: `nix develop -c pnpm generate:api`
4. Commit all generated files

### Modify Local Service API

1. Edit `local-service/handlers.go`
2. Regenerate: `nix develop -c pnpm generate:api`
3. Commit all generated files

## Benefits

✅ **Type Safety** - Catch API mismatches at compile time in all languages
✅ **No Manual HTTP** - Zero manual JSON marshaling or URL construction
✅ **Refactoring Safety** - Rename fields and compilers catch all usage
✅ **IntelliSense** - Full autocomplete across all services
✅ **Documentation** - OpenAPI specs are always in sync with code
✅ **Single Source of Truth** - Each service is authoritative for its API

## Files to Commit

Always commit generated files:
- `backend/generated/openapi.json`
- `local-service/generated/backend_client/client.go`
- `local-service/generated/openapi.json`
- `frontend/src/generated/client/**`

This ensures consistent API contracts across development, CI, and production.

## Validation

Ensure all generated files are up to date:

```bash
# No backend server needed
nix develop -c pnpm validate:api
```

This validates:
1. Backend OpenAPI spec is fetched correctly
2. Backend Go client is generated correctly
3. Local-service OpenAPI spec is generated correctly
4. Frontend TypeScript client is generated correctly

## Next Steps

- [ ] Add CI validation workflow
- [ ] Use generated backend client in `local-service/handlers.go`
- [ ] Add more backend endpoints with type hints
- [ ] Consider adding integration tests using generated clients

## See Also

- [API_SHARING.md](./API_SHARING.md) - Detailed API type sharing documentation
- [QUICK_START.md](./QUICK_START.md) - Quick reference for development
