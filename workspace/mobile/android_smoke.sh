#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
BACKEND_DIR="$ROOT_DIR/workspace/backend"
MOBILE_DIR="$ROOT_DIR/workspace/mobile"
START_BACKEND_HELPER="$ROOT_DIR/harness/scripts/start_backend_for_smoke.sh"
TMP_DIR="$(mktemp -d)"
ARTIFACT_DIR="$MOBILE_DIR/.artifacts"
ARTIFACT_RUN_DIR="$ARTIFACT_DIR/android"
BACKEND_PORT="$(python3 - <<'PY'
import socket

with socket.socket() as sock:
    sock.bind(("127.0.0.1", 0))
    print(sock.getsockname()[1])
PY
)"
BACKEND_LOG="$ARTIFACT_RUN_DIR/backend.log"
FLUTTER_LOG="$ARTIFACT_RUN_DIR/flutter.log"
BACKEND_BIN="$TMP_DIR/mobile-android-smoke-backend"
PID_FILE="$TMP_DIR/backend.pid"
DIAG_DIR="$ARTIFACT_RUN_DIR/diagnostics"

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
mkdir -p "$ARTIFACT_RUN_DIR" "$DIAG_DIR"

ANDROID_DEVICE_ID="${ANDROID_DEVICE_ID:-$(adb devices | awk 'NR > 1 && $2 == "device" { print $1; exit }')}"
if [ -z "$ANDROID_DEVICE_ID" ]; then
  printf 'ERROR: no Android device or emulator detected for Flutter smoke\n' >&2
  exit 1
fi

printf 'mobile android smoke: booting backend %s and running integration test on %s\n' "$BACKEND_PORT" "$ANDROID_DEVICE_ID"
flutter doctor -v >"$DIAG_DIR/flutter-doctor.txt" 2>&1 || true
adb devices -l >"$DIAG_DIR/adb-devices.txt" 2>&1 || true
adb -s "$ANDROID_DEVICE_ID" shell getprop >"$DIAG_DIR/device-props.txt" 2>&1 || true

bash "$START_BACKEND_HELPER" \
  --output-bin "$BACKEND_BIN" \
  --log-path "$BACKEND_LOG" \
  --pid-file "$PID_FILE" \
  --port "$BACKEND_PORT" \
  --db-path "$TMP_DIR/mobile-android-smoke.sqlite" \
  --health-url "http://127.0.0.1:${BACKEND_PORT}/healthz" \
  --label "mobile android smoke backend"

cd "$MOBILE_DIR"
flutter pub get
flutter test integration_test/auth/smoke_test.dart \
  -d "$ANDROID_DEVICE_ID" \
  --dart-define=API_BASE_URL="http://10.0.2.2:${BACKEND_PORT}" | tee "$FLUTTER_LOG"
