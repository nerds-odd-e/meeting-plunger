#!/usr/bin/env bash
set -euo pipefail

# Script to validate that generated API files are up to date
# Used in CI to ensure developers regenerate files after changing API code

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
CLIENT_DIR="$PROJECT_ROOT/client"
FRONTEND_DIR="$PROJECT_ROOT/frontend"
OPENAPI_FILE="$CLIENT_DIR/generated/openapi.json"
FRONTEND_TYPES_FILE="$FRONTEND_DIR/src/generated/client/types.ts"

echo "🔍 Validating generated API files are up to date..."
echo ""

# Create a temporary directory for comparison
TEMP_DIR=$(mktemp -d)
trap "rm -rf $TEMP_DIR" EXIT

# ============================================================================
# STEP 1: Validate OpenAPI JSON
# ============================================================================

echo "📄 Checking OpenAPI spec (client/generated/openapi.json)..."

# Check if the OpenAPI file exists
if [ ! -f "$OPENAPI_FILE" ]; then
  echo "❌ Error: Generated OpenAPI spec not found at $OPENAPI_FILE"
  echo ""
  echo "Please run: nix develop -c pnpm generate:api"
  exit 1
fi

# Copy the current OpenAPI file to temp for comparison
cp "$OPENAPI_FILE" "$TEMP_DIR/openapi.json.old"

# Regenerate OpenAPI spec
"$SCRIPT_DIR/generate-client-openapi.sh" > /dev/null 2>&1

# Compare OpenAPI files
if ! diff -q "$TEMP_DIR/openapi.json.old" "$OPENAPI_FILE" > /dev/null 2>&1; then
  echo ""
  echo "❌ ERROR: OpenAPI spec is out of date!"
  echo ""
  echo "The committed openapi.json differs from the generated version."
  echo "This usually means the Go API code was modified but the spec wasn't regenerated."
  echo ""
  echo "📋 Differences in client/generated/openapi.json:"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  
  # Show colorful diff if available, otherwise plain diff
  if command -v colordiff > /dev/null 2>&1; then
    diff -u "$TEMP_DIR/openapi.json.old" "$OPENAPI_FILE" | colordiff || true
  else
    diff -u "$TEMP_DIR/openapi.json.old" "$OPENAPI_FILE" || true
  fi
  
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo ""
  echo "🔧 To fix this:"
  echo "   1. Run: nix develop -c pnpm generate:api"
  echo "   2. Commit the updated files:"
  echo "      - client/generated/openapi.json"
  echo "      - frontend/src/generated/client/types.ts"
  echo ""
  
  # Restore the old file so the working directory is not modified
  cp "$TEMP_DIR/openapi.json.old" "$OPENAPI_FILE"
  
  exit 1
fi

echo "   ✅ OpenAPI spec is up to date"

# ============================================================================
# STEP 2: Validate Frontend TypeScript Types
# ============================================================================

echo ""
echo "📄 Checking frontend types (frontend/src/generated/client/types.ts)..."

# Check if the frontend types file exists
if [ ! -f "$FRONTEND_TYPES_FILE" ]; then
  echo "❌ Error: Generated frontend types not found at $FRONTEND_TYPES_FILE"
  echo ""
  echo "Please run: nix develop -c pnpm generate:api"
  exit 1
fi

# Copy the current frontend types to temp for comparison
cp "$FRONTEND_TYPES_FILE" "$TEMP_DIR/types.ts.old"

# Regenerate frontend types
cd "$FRONTEND_DIR"
mkdir -p src/generated/client
pnpm generate:client > /dev/null 2>&1

# Compare frontend types
if ! diff -q "$TEMP_DIR/types.ts.old" "$FRONTEND_TYPES_FILE" > /dev/null 2>&1; then
  echo ""
  echo "❌ ERROR: Frontend TypeScript types are out of date!"
  echo ""
  echo "The committed types.ts differs from the generated version."
  echo "This usually means:"
  echo "  - The OpenAPI spec was updated but frontend types weren't regenerated"
  echo "  - OR someone modified the types file manually (don't do this!)"
  echo ""
  echo "📋 Differences in frontend/src/generated/client/types.ts:"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  
  # Show colorful diff if available, otherwise plain diff (limit to first 100 lines for readability)
  if command -v colordiff > /dev/null 2>&1; then
    diff -u "$TEMP_DIR/types.ts.old" "$FRONTEND_TYPES_FILE" | head -100 | colordiff || true
  else
    diff -u "$TEMP_DIR/types.ts.old" "$FRONTEND_TYPES_FILE" | head -100 || true
  fi
  
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo ""
  echo "🔧 To fix this:"
  echo "   1. Run: nix develop -c pnpm generate:api"
  echo "   2. Commit the updated files:"
  echo "      - client/generated/openapi.json"
  echo "      - frontend/src/generated/client/types.ts"
  echo ""
  
  # Restore the old files so the working directory is not modified
  cp "$TEMP_DIR/openapi.json.old" "$OPENAPI_FILE"
  cp "$TEMP_DIR/types.ts.old" "$FRONTEND_TYPES_FILE"
  
  exit 1
fi

echo "   ✅ Frontend types are up to date"

# ============================================================================
# Success!
# ============================================================================

echo ""
echo "✅ All generated API files are up to date!"
echo ""
exit 0
