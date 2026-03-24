#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
FRONTEND_DIR="$ROOT_DIR/workspace/frontend"

printf 'frontend test: vitest\n'
cd "$FRONTEND_DIR"
npm install
npm run test -- --run
