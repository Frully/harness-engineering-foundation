#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
BACKEND_DIR="$ROOT_DIR/workspace/backend"

printf 'backend check: formatting, vet, and build\n'

cd "$BACKEND_DIR"

UNFORMATTED="$(gofmt -l .)"
if [ -n "$UNFORMATTED" ]; then
  printf 'ERROR: gofmt mismatch in:\n%s\n' "$UNFORMATTED" >&2
  exit 1
fi

go vet ./...
go build ./...
