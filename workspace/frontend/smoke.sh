#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
BACKEND_DIR="$ROOT_DIR/workspace/backend"
FRONTEND_DIR="$ROOT_DIR/workspace/frontend"
TMP_DIR="$(mktemp -d)"
ARTIFACT_DIR="$FRONTEND_DIR/.artifacts"
BACKEND_LOG="$ARTIFACT_DIR/backend.log"
FRONTEND_LOG="$ARTIFACT_DIR/frontend.log"
BACKEND_PORT="$(python3 - <<'PY'
import socket

with socket.socket() as sock:
    sock.bind(("127.0.0.1", 0))
    print(sock.getsockname()[1])
PY
)"
FRONTEND_PORT="$(python3 - <<'PY'
import socket

with socket.socket() as sock:
    sock.bind(("127.0.0.1", 0))
    print(sock.getsockname()[1])
PY
)"

cleanup() {
  for pid in "${FRONTEND_PID:-}" "${BACKEND_PID:-}"; do
    if [ -n "$pid" ] && kill -0 "$pid" 2>/dev/null; then
      kill "$pid" 2>/dev/null || true
      wait "$pid" 2>/dev/null || true
    fi
  done
  rm -rf "$TMP_DIR"
}
trap cleanup EXIT
mkdir -p "$ARTIFACT_DIR"

printf 'frontend smoke: booting backend %s and frontend %s\n' "$BACKEND_PORT" "$FRONTEND_PORT"

cd "$BACKEND_DIR"
PORT="$BACKEND_PORT" DB_PATH="$TMP_DIR/frontend-smoke.sqlite" ALLOWED_ORIGIN="http://127.0.0.1:${FRONTEND_PORT}" COOKIE_SECURE=false go run . >"$BACKEND_LOG" 2>&1 &
BACKEND_PID=$!

for _ in $(seq 1 30); do
  if curl -fsS "http://127.0.0.1:${BACKEND_PORT}/healthz" >/dev/null 2>&1; then
    break
  fi
  sleep 1
done

if ! curl -fsS "http://127.0.0.1:${BACKEND_PORT}/healthz" >/dev/null 2>&1; then
  printf 'ERROR: backend did not boot for frontend smoke\n' >&2
  cat "$BACKEND_LOG" >&2
  exit 1
fi

cd "$FRONTEND_DIR"
corepack enable
pnpm install --frozen-lockfile
VITE_API_BASE_URL="http://127.0.0.1:${BACKEND_PORT}" pnpm run build >/dev/null
VITE_API_BASE_URL="http://127.0.0.1:${BACKEND_PORT}" pnpm exec vite preview --host 127.0.0.1 --port "$FRONTEND_PORT" >"$FRONTEND_LOG" 2>&1 &
FRONTEND_PID=$!

for _ in $(seq 1 30); do
  if curl -fsS "http://127.0.0.1:${FRONTEND_PORT}" >/dev/null 2>&1; then
    break
  fi
  sleep 1
done

if ! curl -fsS "http://127.0.0.1:${FRONTEND_PORT}" >/dev/null 2>&1; then
  printf 'ERROR: frontend preview did not boot\n' >&2
  cat "$FRONTEND_LOG" >&2
  exit 1
fi

printf 'frontend smoke: running Playwright\n'
PLAYWRIGHT_BASE_URL="http://127.0.0.1:${FRONTEND_PORT}" pnpm exec playwright test
