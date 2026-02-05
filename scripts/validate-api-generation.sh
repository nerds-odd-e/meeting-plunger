#!/usr/bin/env bash
set -euo pipefail

# Script to validate that generated API files are up to date
# Used in CI to ensure developers regenerate files after changing API code

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
CLIENT_DIR="$PROJECT_ROOT/client"
FRONTEND_DIR="$PROJECT_ROOT/frontend"
OPENAPI_FILE="$CLIENT_DIR/generated/openapi.json"
FRONTEND_GENERATED_DIR="$FRONTEND_DIR/src/generated/client"

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
  echo "      - frontend/src/generated/client/**"
  echo ""
  
  # Restore the old file so the working directory is not modified
  cp "$TEMP_DIR/openapi.json.old" "$OPENAPI_FILE"
  
  exit 1
fi

echo "   ✅ OpenAPI spec is up to date"

# ============================================================================
# STEP 2: Validate Frontend Generated Client
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
cp -r "$FRONTEND_GENERATED_DIR" "$TEMP_DIR/client.old"

# Regenerate frontend client
cd "$FRONTEND_DIR"
pnpm generate:client > /dev/null 2>&1

# Compare all generated files
DIFF_OUTPUT=$(diff -r -q "$TEMP_DIR/client.old" "$FRONTEND_GENERATED_DIR" 2>&1 || true)

if [ -n "$DIFF_OUTPUT" ]; then
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
  echo "$DIFF_OUTPUT"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo ""
  echo "🔧 To fix this:"
  echo "   1. Run: nix develop -c pnpm generate:api"
  echo "   2. Commit the updated files:"
  echo "      - client/generated/openapi.json"
  echo "      - frontend/src/generated/client/**"
  echo ""
  
  # Restore the old files so the working directory is not modified
  cp "$TEMP_DIR/openapi.json.old" "$OPENAPI_FILE"
  rm -rf "$FRONTEND_GENERATED_DIR"
  cp -r "$TEMP_DIR/client.old" "$FRONTEND_GENERATED_DIR"
  
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
