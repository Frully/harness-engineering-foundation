#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
BACKEND_DIR="$ROOT_DIR/workspace/backend"
FRONTEND_DIR="$ROOT_DIR/workspace/frontend"
START_BACKEND_HELPER="$ROOT_DIR/harness/scripts/start_backend_for_smoke.sh"
TMP_DIR="$(mktemp -d)"
ARTIFACT_DIR="$FRONTEND_DIR/.artifacts"
ARTIFACT_RUN_DIR="$ARTIFACT_DIR/smoke"
BACKEND_LOG="$ARTIFACT_RUN_DIR/backend.log"
FRONTEND_LOG="$ARTIFACT_RUN_DIR/frontend.log"
BACKEND_BIN="$TMP_DIR/frontend-smoke-backend"
PID_FILE="$TMP_DIR/backend.pid"
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
  for pid in "${FRONTEND_PID:-}"; do
    if [ -n "$pid" ] && kill -0 "$pid" 2>/dev/null; then
      kill "$pid" 2>/dev/null || true
      wait "$pid" 2>/dev/null || true
    fi
  done
  if [ -f "$PID_FILE" ]; then
    BACKEND_PID="$(cat "$PID_FILE")"
    if [ -n "$BACKEND_PID" ] && kill -0 "$BACKEND_PID" 2>/dev/null; then
      kill "$BACKEND_PID" 2>/dev/null || true
      wait "$BACKEND_PID" 2>/dev/null || true
    fi
  fi
  rm -rf "$TMP_DIR"
}
trap cleanup EXIT
mkdir -p "$ARTIFACT_RUN_DIR"

printf 'frontend smoke: booting backend %s and frontend %s\n' "$BACKEND_PORT" "$FRONTEND_PORT"

bash "$START_BACKEND_HELPER" \
  --output-bin "$BACKEND_BIN" \
  --log-path "$BACKEND_LOG" \
  --pid-file "$PID_FILE" \
  --port "$BACKEND_PORT" \
  --db-path "$TMP_DIR/frontend-smoke.sqlite" \
  --allowed-origin "http://127.0.0.1:${FRONTEND_PORT}" \
  --health-url "http://127.0.0.1:${BACKEND_PORT}/healthz" \
  --label "frontend smoke backend"

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
