#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
BACKEND_DIR="$ROOT_DIR/workspace/backend"

printf 'backend test: go test ./...\n'
cd "$BACKEND_DIR"
go test ./...
