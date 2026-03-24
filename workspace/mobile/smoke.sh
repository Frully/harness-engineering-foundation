#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
BACKEND_DIR="$ROOT_DIR/workspace/backend"
MOBILE_DIR="$ROOT_DIR/workspace/mobile"
TMP_DIR="$(mktemp -d)"
ARTIFACT_DIR="$MOBILE_DIR/.artifacts"
BACKEND_PORT="$(python3 - <<'PY'
import socket

with socket.socket() as sock:
    sock.bind(("127.0.0.1", 0))
    print(sock.getsockname()[1])
PY
)"
BACKEND_LOG="$ARTIFACT_DIR/backend.log"
FLUTTER_LOG="$ARTIFACT_DIR/flutter-smoke.log"

cleanup() {
  if [ -n "${BACKEND_PID:-}" ] && kill -0 "$BACKEND_PID" 2>/dev/null; then
    kill "$BACKEND_PID" 2>/dev/null || true
    wait "$BACKEND_PID" 2>/dev/null || true
  fi
  rm -rf "$TMP_DIR"
}
trap cleanup EXIT
mkdir -p "$ARTIFACT_DIR"

case "$(uname -s)" in
  Darwin)
    FLUTTER_DEVICE="macos"
    FLUTTER_TEST_RUNNER="flutter test integration_test/auth/smoke_test.dart -d $FLUTTER_DEVICE"
    ;;
  Linux)
    FLUTTER_DEVICE="linux"
    FLUTTER_TEST_RUNNER="xvfb-run -a flutter test integration_test/auth/smoke_test.dart -d $FLUTTER_DEVICE"
    ;;
  *)
    printf 'ERROR: mobile smoke supports macOS or Linux desktop hosts only. Add a runtime-specific smoke runner for %s.\n' "$(uname -s)" >&2
    exit 1
    ;;
esac

printf 'mobile smoke: booting backend %s and running Flutter integration test on %s\n' "$BACKEND_PORT" "$FLUTTER_DEVICE"

cd "$BACKEND_DIR"
PORT="$BACKEND_PORT" DB_PATH="$TMP_DIR/mobile-smoke.sqlite" COOKIE_SECURE=false go run . >"$BACKEND_LOG" 2>&1 &
BACKEND_PID=$!

for _ in $(seq 1 30); do
  if curl -fsS "http://127.0.0.1:${BACKEND_PORT}/healthz" >/dev/null 2>&1; then
    break
  fi
  sleep 1
done

if ! curl -fsS "http://127.0.0.1:${BACKEND_PORT}/healthz" >/dev/null 2>&1; then
  printf 'ERROR: backend did not boot for mobile smoke\n' >&2
  cat "$BACKEND_LOG" >&2
  exit 1
fi

cd "$MOBILE_DIR"
flutter pub get
eval "$FLUTTER_TEST_RUNNER --dart-define=API_BASE_URL=http://127.0.0.1:${BACKEND_PORT}" | tee "$FLUTTER_LOG"
