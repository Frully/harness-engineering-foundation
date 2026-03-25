#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
BACKEND_DIR="$ROOT_DIR/workspace/backend"
MOBILE_DIR="$ROOT_DIR/workspace/mobile"
START_BACKEND_HELPER="$ROOT_DIR/harness/scripts/start_backend_for_smoke.sh"
TMP_DIR="$(mktemp -d)"
ARTIFACT_DIR="$MOBILE_DIR/.artifacts"
ARTIFACT_RUN_DIR="$ARTIFACT_DIR/ios"
BACKEND_PORT="$(python3 - <<'PY'
import socket

with socket.socket() as sock:
    sock.bind(("127.0.0.1", 0))
    print(sock.getsockname()[1])
PY
)"
BACKEND_LOG="$ARTIFACT_RUN_DIR/backend.log"
FLUTTER_LOG="$ARTIFACT_RUN_DIR/flutter.log"
BACKEND_BIN="$TMP_DIR/mobile-ios-smoke-backend"
SIMULATOR_DEVICE_ID=""
CREATED_SIMULATOR_DEVICE="false"
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

  if [ -n "$SIMULATOR_DEVICE_ID" ]; then
    xcrun simctl shutdown "$SIMULATOR_DEVICE_ID" >/dev/null 2>&1 || true
    if [ "$CREATED_SIMULATOR_DEVICE" = "true" ]; then
      xcrun simctl delete "$SIMULATOR_DEVICE_ID" >/dev/null 2>&1 || true
    fi
  fi

  rm -rf "$TMP_DIR"
}
trap cleanup EXIT
mkdir -p "$ARTIFACT_RUN_DIR" "$DIAG_DIR"

if [ "$(uname -s)" != "Darwin" ]; then
  printf 'ERROR: iOS smoke requires a macOS host.\n' >&2
  exit 1
fi

DEVICES_JSON="$TMP_DIR/ios-devices.json"
RUNTIMES_JSON="$TMP_DIR/ios-runtimes.json"
DEVICE_TYPES_JSON="$TMP_DIR/ios-device-types.json"
SELECTION_LOG="$ARTIFACT_DIR/ios-simulator-selection.txt"
XCODE_LOG="$DIAG_DIR/xcode-version.txt"
FLUTTER_DOCTOR_LOG="$DIAG_DIR/flutter-doctor.txt"
xcrun simctl list devices available -j >"$DEVICES_JSON"
xcrun simctl list runtimes -j >"$RUNTIMES_JSON"
xcrun simctl list devicetypes -j >"$DEVICE_TYPES_JSON"
flutter doctor -v >"$FLUTTER_DOCTOR_LOG" 2>&1 || true
xcodebuild -version >"$XCODE_LOG" 2>&1 || true

cp "$DEVICES_JSON" "$DIAG_DIR/ios-devices.json"
cp "$RUNTIMES_JSON" "$DIAG_DIR/ios-runtimes.json"
cp "$DEVICE_TYPES_JSON" "$DIAG_DIR/ios-device-types.json"

SIMULATOR_SELECTION="$(
  python3 "$MOBILE_DIR/tools/select_ios_simulator.py" \
    "$DEVICES_JSON" \
    "$RUNTIMES_JSON" \
    "$DEVICE_TYPES_JSON"
)"

printf '%s\n' "$SIMULATOR_SELECTION" >"$SELECTION_LOG"

SELECTION_MODE="$(printf '%s' "$SIMULATOR_SELECTION" | cut -f1)"

case "$SELECTION_MODE" in
  existing)
    SIMULATOR_DEVICE_ID="$(printf '%s' "$SIMULATOR_SELECTION" | cut -f2)"
    SIMULATOR_DEVICE_NAME="$(printf '%s' "$SIMULATOR_SELECTION" | cut -f3)"
    SIMULATOR_RUNTIME_ID="$(printf '%s' "$SIMULATOR_SELECTION" | cut -f4)"
    ;;
  create)
    RUNTIME_IDENTIFIER="$(printf '%s' "$SIMULATOR_SELECTION" | cut -f2)"
    DEVICE_TYPE_IDENTIFIER="$(printf '%s' "$SIMULATOR_SELECTION" | cut -f3)"
    SIMULATOR_DEVICE_NAME="$(printf '%s' "$SIMULATOR_SELECTION" | cut -f4)"
    SIMULATOR_RUNTIME_ID="$RUNTIME_IDENTIFIER"
    SIMULATOR_DEVICE_ID="$(
      xcrun simctl create "Harness iOS Smoke" "$DEVICE_TYPE_IDENTIFIER" "$RUNTIME_IDENTIFIER"
    )"
    CREATED_SIMULATOR_DEVICE="true"
    ;;
  *)
    printf 'ERROR: failed to select an iOS simulator.\n' >&2
    exit 1
    ;;
esac

if [ -z "$SIMULATOR_DEVICE_ID" ]; then
  printf 'ERROR: no available iOS simulator found.\n' >&2
  exit 1
fi

printf 'mobile ios smoke: booting backend %s and running integration test on simulator %s\n' \
  "$BACKEND_PORT" \
  "$SIMULATOR_DEVICE_ID"
printf 'mobile ios smoke: selected simulator name=%s runtime=%s mode=%s\n' \
  "${SIMULATOR_DEVICE_NAME:-unknown}" \
  "${SIMULATOR_RUNTIME_ID:-unknown}" \
  "$SELECTION_MODE"

open -a Simulator >/dev/null 2>&1 || true
xcrun simctl boot "$SIMULATOR_DEVICE_ID" >/dev/null 2>&1 || true
xcrun simctl bootstatus "$SIMULATOR_DEVICE_ID" -b

bash "$START_BACKEND_HELPER" \
  --output-bin "$BACKEND_BIN" \
  --log-path "$BACKEND_LOG" \
  --pid-file "$PID_FILE" \
  --port "$BACKEND_PORT" \
  --db-path "$TMP_DIR/mobile-ios-smoke.sqlite" \
  --health-url "http://127.0.0.1:${BACKEND_PORT}/healthz" \
  --health-timeout 90 \
  --label "mobile ios smoke backend"

cd "$MOBILE_DIR"
flutter pub get
flutter test integration_test/auth/smoke_test.dart \
  -d "$SIMULATOR_DEVICE_ID" \
  --dart-define=API_BASE_URL="http://127.0.0.1:${BACKEND_PORT}" | tee "$FLUTTER_LOG"
