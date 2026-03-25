#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
BACKEND_DIR="$ROOT_DIR/workspace/backend"
RETRY_HELPER="$ROOT_DIR/harness/scripts/retry.sh"

OUTPUT_BIN=""
LOG_PATH=""
PID_FILE=""
PORT=""
DB_PATH=""
HEALTH_URL=""
HEALTH_TIMEOUT=30
COOKIE_SECURE=false
ALLOWED_ORIGIN=""
LABEL="backend smoke"
: "${GOPROXY:=https://proxy.golang.org|direct}"

while [ "$#" -gt 0 ]; do
  case "$1" in
    --output-bin)
      OUTPUT_BIN="$2"
      shift 2
      ;;
    --log-path)
      LOG_PATH="$2"
      shift 2
      ;;
    --pid-file)
      PID_FILE="$2"
      shift 2
      ;;
    --port)
      PORT="$2"
      shift 2
      ;;
    --db-path)
      DB_PATH="$2"
      shift 2
      ;;
    --health-url)
      HEALTH_URL="$2"
      shift 2
      ;;
    --health-timeout)
      HEALTH_TIMEOUT="$2"
      shift 2
      ;;
    --cookie-secure)
      COOKIE_SECURE="$2"
      shift 2
      ;;
    --allowed-origin)
      ALLOWED_ORIGIN="$2"
      shift 2
      ;;
    --label)
      LABEL="$2"
      shift 2
      ;;
    *)
      printf 'ERROR: unknown start_backend_for_smoke option: %s\n' "$1" >&2
      exit 1
      ;;
  esac
done

for required in OUTPUT_BIN LOG_PATH PID_FILE PORT DB_PATH HEALTH_URL; do
  if [ -z "${!required}" ]; then
    printf 'ERROR: missing required start_backend_for_smoke value for %s\n' "$required" >&2
    exit 1
  fi
done

mkdir -p "$(dirname "$OUTPUT_BIN")" "$(dirname "$LOG_PATH")" "$(dirname "$PID_FILE")"

cd "$BACKEND_DIR"
bash "$RETRY_HELPER" 3 5 env GOPROXY="$GOPROXY" go mod download >>"$LOG_PATH" 2>&1
bash "$RETRY_HELPER" 3 5 env GOPROXY="$GOPROXY" go build -o "$OUTPUT_BIN" . >>"$LOG_PATH" 2>&1

START_CMD=(env PORT="$PORT" DB_PATH="$DB_PATH" COOKIE_SECURE="$COOKIE_SECURE")
if [ -n "$ALLOWED_ORIGIN" ]; then
  START_CMD+=(ALLOWED_ORIGIN="$ALLOWED_ORIGIN")
fi
START_CMD+=(GOPROXY="$GOPROXY")
START_CMD+=("$OUTPUT_BIN")

nohup "${START_CMD[@]}" >>"$LOG_PATH" 2>&1 &
SERVER_PID=$!
printf '%s\n' "$SERVER_PID" >"$PID_FILE"

for _ in $(seq 1 "$HEALTH_TIMEOUT"); do
  if curl -fsS "$HEALTH_URL" >/dev/null 2>&1; then
    exit 0
  fi
  sleep 1
done

printf 'ERROR: %s did not boot within %ss\n' "$LABEL" "$HEALTH_TIMEOUT" >&2
cat "$LOG_PATH" >&2
kill "$SERVER_PID" 2>/dev/null || true
wait "$SERVER_PID" 2>/dev/null || true
exit 1
