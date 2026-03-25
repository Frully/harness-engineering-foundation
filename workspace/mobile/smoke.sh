#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
BACKEND_DIR="$ROOT_DIR/workspace/backend"
MOBILE_DIR="$ROOT_DIR/workspace/mobile"
START_BACKEND_HELPER="$ROOT_DIR/harness/scripts/start_backend_for_smoke.sh"
TMP_DIR="$(mktemp -d)"
ARTIFACT_DIR="$MOBILE_DIR/.artifacts"
ARTIFACT_RUN_DIR="$ARTIFACT_DIR/desktop"
BACKEND_PORT="$(python3 - <<'PY'
import socket

with socket.socket() as sock:
    sock.bind(("127.0.0.1", 0))
    print(sock.getsockname()[1])
PY
)"
BACKEND_LOG="$ARTIFACT_RUN_DIR/backend.log"
FLUTTER_LOG="$ARTIFACT_RUN_DIR/flutter-smoke.log"
BACKEND_BIN="$TMP_DIR/mobile-smoke-backend"
PID_FILE="$TMP_DIR/backend.pid"

cleanup() {
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

bash "$START_BACKEND_HELPER" \
  --output-bin "$BACKEND_BIN" \
  --log-path "$BACKEND_LOG" \
  --pid-file "$PID_FILE" \
  --port "$BACKEND_PORT" \
  --db-path "$TMP_DIR/mobile-smoke.sqlite" \
  --health-url "http://127.0.0.1:${BACKEND_PORT}/healthz" \
  --label "mobile desktop smoke backend"

cd "$MOBILE_DIR"
flutter pub get
eval "$FLUTTER_TEST_RUNNER --dart-define=API_BASE_URL=http://127.0.0.1:${BACKEND_PORT}" | tee "$FLUTTER_LOG"
