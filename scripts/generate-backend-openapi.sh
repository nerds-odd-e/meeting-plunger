#!/usr/bin/env bash
set -euo pipefail

# Script to generate OpenAPI spec from FastAPI backend
# This script extracts the spec directly from the FastAPI app without running the server
# The generated openapi.json will be placed in backend/generated/

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
BACKEND_DIR="$PROJECT_ROOT/backend"
GENERATED_DIR="$BACKEND_DIR/generated"

echo "🔄 Generating OpenAPI spec from FastAPI backend..."
echo "   Output dir: $GENERATED_DIR"
echo ""

# Ensure generated directory exists
mkdir -p "$GENERATED_DIR"

# Generate OpenAPI spec using Python script (no server needed)
echo "Extracting OpenAPI spec from FastAPI app..."

# Check if running in CI or if nix is not available
if [ "${CI:-false}" = "true" ] || ! command -v nix > /dev/null 2>&1; then
  # Running in CI or without Nix - python should be in PATH
  python3 -c "
import json
import sys
sys.path.insert(0, '$BACKEND_DIR')
from main import app
with open('$GENERATED_DIR/openapi.json', 'w') as f:
    json.dump(app.openapi(), f, indent=2)
"
else
  # Running locally with Nix
  nix develop -c python -c "
import json
import sys
sys.path.insert(0, '$BACKEND_DIR')
from main import app
with open('$GENERATED_DIR/openapi.json', 'w') as f:
    json.dump(app.openapi(), f, indent=2)
"
fi

if [ -f "$GENERATED_DIR/openapi.json" ]; then
  echo "✅ Generated: $GENERATED_DIR/openapi.json"
else
  echo "❌ Error: Failed to generate OpenAPI spec"
  exit 1
fi

echo ""
echo "✅ Backend OpenAPI generation complete!"
echo "   File: backend/generated/openapi.json"
echo ""
echo "To view the spec:"
echo "  cat backend/generated/openapi.json | jq"
