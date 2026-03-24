#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
FRONTEND_DIR="$ROOT_DIR/workspace/frontend"

printf 'frontend check: npm install, lint, typecheck, build\n'
cd "$FRONTEND_DIR"
npm install
npm run lint
npm run typecheck
npm run build
