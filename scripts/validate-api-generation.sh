#!/usr/bin/env bash
set -euo pipefail

# Script to validate that generated API files are up to date
# Used in CI to ensure developers regenerate files after changing API code

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
BACKEND_DIR="$PROJECT_ROOT/backend"
LOCAL_SERVICE_DIR="$PROJECT_ROOT/local-service"
FRONTEND_DIR="$PROJECT_ROOT/frontend"
BACKEND_OPENAPI_FILE="$BACKEND_DIR/generated/openapi.json"
BACKEND_CLIENT_FILE="$LOCAL_SERVICE_DIR/generated/backend_client/client.go"
LOCAL_SERVICE_OPENAPI_FILE="$LOCAL_SERVICE_DIR/generated/openapi.json"
FRONTEND_GENERATED_DIR="$FRONTEND_DIR/src/generated/client"

echo "🔍 Validating generated API files are up to date..."
echo ""

# Create a temporary directory for comparison
TEMP_DIR=$(mktemp -d)
trap "rm -rf $TEMP_DIR" EXIT

# ============================================================================
# STEP 1: Validate Backend OpenAPI Spec
# ============================================================================

echo ""
echo "📄 Checking backend OpenAPI spec (backend/generated/openapi.json)..."

# Check if the backend OpenAPI file exists
if [ ! -f "$BACKEND_OPENAPI_FILE" ]; then
  echo "❌ Error: Backend OpenAPI spec not found at $BACKEND_OPENAPI_FILE"
  echo ""
  echo "Please run: nix develop -c pnpm generate:api"
  exit 1
fi

# Copy the current backend OpenAPI file to temp for comparison
cp "$BACKEND_OPENAPI_FILE" "$TEMP_DIR/backend-openapi.json.old"

# Regenerate backend OpenAPI spec
"$SCRIPT_DIR/generate-backend-openapi.sh" > /dev/null 2>&1

# Compare backend OpenAPI files
if ! diff -q "$TEMP_DIR/backend-openapi.json.old" "$BACKEND_OPENAPI_FILE" > /dev/null 2>&1; then
  echo ""
  echo "❌ ERROR: Backend OpenAPI spec is out of date!"
  echo ""
  echo "The committed backend openapi.json differs from the generated version."
  echo "This usually means the FastAPI backend was modified but the spec wasn't regenerated."
  echo ""
  echo "📋 Differences in backend/generated/openapi.json:"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  
  # Show colorful diff if available, otherwise plain diff
  if command -v colordiff > /dev/null 2>&1; then
    diff -u "$TEMP_DIR/backend-openapi.json.old" "$BACKEND_OPENAPI_FILE" | colordiff || true
  else
    diff -u "$TEMP_DIR/backend-openapi.json.old" "$BACKEND_OPENAPI_FILE" || true
  fi
  
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo ""
  echo "🔧 To fix this:"
  echo "   1. Ensure backend is running: nix develop -c pnpm sut:backend"
  echo "   2. Run: nix develop -c pnpm generate:api"
  echo "   3. Commit the updated files:"
  echo "      - backend/generated/openapi.json"
  echo "      - local-service/generated/backend_client/client.go"
  echo ""
  
  # Restore the old file so the working directory is not modified
  cp "$TEMP_DIR/backend-openapi.json.old" "$BACKEND_OPENAPI_FILE"
  
  exit 1
fi

echo "   ✅ Backend OpenAPI spec is up to date"

# ============================================================================
# STEP 3: Validate Backend Go Client
# ============================================================================

echo ""
echo "📄 Checking backend Go client (local-service/generated/backend_client/client.go)..."

# Check if the backend client file exists
if [ ! -f "$BACKEND_CLIENT_FILE" ]; then
  echo "❌ Error: Backend Go client not found at $BACKEND_CLIENT_FILE"
  echo ""
  echo "Please run: nix develop -c pnpm generate:api"
  exit 1
fi

# Copy the current backend client to temp for comparison
cp "$BACKEND_CLIENT_FILE" "$TEMP_DIR/backend-client.go.old"

# Regenerate backend Go client
"$SCRIPT_DIR/generate-backend-client.sh" > /dev/null 2>&1

# Compare backend client files
if ! diff -q "$TEMP_DIR/backend-client.go.old" "$BACKEND_CLIENT_FILE" > /dev/null 2>&1; then
  echo ""
  echo "❌ ERROR: Backend Go client is out of date!"
  echo ""
  echo "The committed backend client differs from the generated version."
  echo "This usually means:"
  echo "  - The backend OpenAPI spec was updated but Go client wasn't regenerated"
  echo "  - OR someone modified the generated files manually (don't do this!)"
  echo ""
  echo "📋 Differences in local-service/generated/backend_client/client.go:"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  
  # Show a summary of changes (first 50 lines)
  if command -v colordiff > /dev/null 2>&1; then
    diff -u "$TEMP_DIR/backend-client.go.old" "$BACKEND_CLIENT_FILE" | head -50 | colordiff || true
  else
    diff -u "$TEMP_DIR/backend-client.go.old" "$BACKEND_CLIENT_FILE" | head -50 || true
  fi
  echo "   ... (diff truncated, use 'git diff' for full output)"
  
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo ""
  echo "🔧 To fix this:"
  echo "   1. Run: nix develop -c pnpm generate:api"
  echo "   2. Commit the updated files:"
  echo "      - backend/generated/openapi.json"
  echo "      - local-service/generated/backend_client/client.go"
  echo ""
  
  # Restore the old file so the working directory is not modified
  cp "$TEMP_DIR/backend-client.go.old" "$BACKEND_CLIENT_FILE"
  
  exit 1
fi

echo "   ✅ Backend Go client is up to date"

# ============================================================================
# STEP 3: Validate Local Service OpenAPI Spec
# ============================================================================

echo ""
echo "📄 Checking local-service OpenAPI spec (local-service/generated/openapi.json)..."

# Check if the OpenAPI file exists
if [ ! -f "$LOCAL_SERVICE_OPENAPI_FILE" ]; then
  echo "❌ Error: Generated OpenAPI spec not found at $LOCAL_SERVICE_OPENAPI_FILE"
  echo ""
  echo "Please run: nix develop -c pnpm generate:api"
  exit 1
fi

# Copy the current OpenAPI file to temp for comparison
cp "$LOCAL_SERVICE_OPENAPI_FILE" "$TEMP_DIR/openapi.json.old"

# Regenerate OpenAPI spec
"$SCRIPT_DIR/generate-local-service-openapi.sh" > /dev/null 2>&1

# Compare OpenAPI files
if ! diff -q "$TEMP_DIR/openapi.json.old" "$LOCAL_SERVICE_OPENAPI_FILE" > /dev/null 2>&1; then
  echo ""
  echo "❌ ERROR: Local-service OpenAPI spec is out of date!"
  echo ""
  echo "The committed openapi.json differs from the generated version."
  echo "This usually means the Go API code was modified but the spec wasn't regenerated."
  echo ""
  echo "📋 Differences in local-service/generated/openapi.json:"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  
  # Show colorful diff if available, otherwise plain diff
  if command -v colordiff > /dev/null 2>&1; then
    diff -u "$TEMP_DIR/openapi.json.old" "$LOCAL_SERVICE_OPENAPI_FILE" | colordiff || true
  else
    diff -u "$TEMP_DIR/openapi.json.old" "$LOCAL_SERVICE_OPENAPI_FILE" || true
  fi
  
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo ""
  echo "🔧 To fix this:"
  echo "   1. Run: nix develop -c pnpm generate:api"
  echo "   2. Commit the updated files:"
  echo "      - backend/generated/openapi.json"
  echo "      - local-service/generated/backend_client/client.go"
  echo "      - local-service/generated/openapi.json"
  echo "      - frontend/src/generated/client/**"
  echo ""
  
  # Restore the old file so the working directory is not modified
  cp "$TEMP_DIR/openapi.json.old" "$LOCAL_SERVICE_OPENAPI_FILE"
  
  exit 1
fi

echo "   ✅ Local-service OpenAPI spec is up to date"

# ============================================================================
# STEP 4: Validate Frontend Generated Client
# ============================================================================

echo ""
echo "📄 Checking frontend generated client (frontend/src/generated/client/)..."

# Check if the generated client directory exists
if [ ! -d "$FRONTEND_GENERATED_DIR" ]; then
  echo "❌ Error: Generated frontend client not found at $FRONTEND_GENERATED_DIR"
  echo ""
  echo "Please run: nix develop -c pnpm generate:api"
  exit 1
fi

# Backup the current generated client
cp -r "$FRONTEND_GENERATED_DIR" "$TEMP_DIR/client.committed"

# Generate a fresh client in a clean directory
mkdir -p "$TEMP_DIR/fresh-client"
cd "$FRONTEND_DIR"

# Temporarily move the generated directory and generate fresh
mv "$FRONTEND_GENERATED_DIR" "$TEMP_DIR/client.backup"
mkdir -p "$FRONTEND_GENERATED_DIR"
pnpm generate:client > /dev/null 2>&1
cp -r "$FRONTEND_GENERATED_DIR" "$TEMP_DIR/client.fresh"

# Restore the original committed version
rm -rf "$FRONTEND_GENERATED_DIR"
mv "$TEMP_DIR/client.backup" "$FRONTEND_GENERATED_DIR"

# Compare committed files with freshly generated files
DIFF_OUTPUT=$(diff -r -q "$TEMP_DIR/client.committed" "$TEMP_DIR/client.fresh" 2>&1 || true)

# Check specifically for extra files in the committed version
EXTRA_FILES=$(echo "$DIFF_OUTPUT" | grep "Only in $TEMP_DIR/client.committed" || true)

# Check for other differences (modified files, missing files)
OTHER_DIFFS=$(echo "$DIFF_OUTPUT" | grep -v "Only in $TEMP_DIR/client.committed" || true)

if [ -n "$EXTRA_FILES" ]; then
  echo ""
  echo "❌ ERROR: Extra files found in frontend/src/generated/client/!"
  echo ""
  echo "The committed generated directory contains files that should not be there."
  echo "Generated code should ONLY contain files created by the code generator."
  echo ""
  echo "📋 Extra files that should NOT be in the repository:"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "$EXTRA_FILES" | sed "s|Only in $TEMP_DIR/client.committed|Only in frontend/src/generated/client|g"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo ""
  echo "🔧 To fix this:"
  echo "   1. Remove the extra files from frontend/src/generated/client/"
  echo "   2. Run: nix develop -c pnpm generate:api"
  echo "   3. Commit only the legitimate generated files"
  echo ""
  
  # Note: Working directory is not modified (we kept the committed version intact)
  exit 1
fi

if [ -n "$OTHER_DIFFS" ]; then
  echo ""
  echo "❌ ERROR: Frontend generated client is out of date!"
  echo ""
  echo "The committed generated files differ from the newly generated version."
  echo "This usually means:"
  echo "  - The OpenAPI spec was updated but frontend client wasn't regenerated"
  echo "  - OR someone modified the generated files manually (don't do this!)"
  echo ""
  echo "📋 Differences in frontend/src/generated/client/:"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "$OTHER_DIFFS"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo ""
  echo "🔧 To fix this:"
  echo "   1. Run: nix develop -c pnpm generate:api"
  echo "   2. Commit the updated files:"
  echo "      - backend/generated/openapi.json"
  echo "      - local-service/generated/backend_client/client.go"
  echo "      - local-service/generated/openapi.json"
  echo "      - frontend/src/generated/client/**"
  echo ""
  
  # Note: Working directory is not modified (we kept the committed version intact)
  exit 1
fi

echo "   ✅ Frontend generated client is up to date"

# ============================================================================
# Success!
# ============================================================================

echo ""
echo "✅ All generated API files are up to date!"
echo ""
exit 0
