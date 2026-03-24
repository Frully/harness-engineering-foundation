#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
FRONTEND_DIR="$ROOT_DIR/workspace/frontend"

printf 'frontend check: pnpm install, biome format check, lint, typecheck, build\n'
cd "$FRONTEND_DIR"
corepack enable
pnpm install --frozen-lockfile
pnpm exec biome check --formatter-enabled=true --linter-enabled=false --assist-enabled=false .
pnpm run lint
pnpm run typecheck
pnpm run build
