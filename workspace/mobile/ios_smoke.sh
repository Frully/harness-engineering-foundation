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
BACKEND_LOG="$ARTIFACT_DIR/ios-backend.log"
FLUTTER_LOG="$ARTIFACT_DIR/ios-smoke.log"
SIMULATOR_DEVICE_ID=""
CREATED_SIMULATOR_DEVICE="false"

cleanup() {
  if [ -n "${BACKEND_PID:-}" ] && kill -0 "$BACKEND_PID" 2>/dev/null; then
    kill "$BACKEND_PID" 2>/dev/null || true
    wait "$BACKEND_PID" 2>/dev/null || true
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
mkdir -p "$ARTIFACT_DIR"

if [ "$(uname -s)" != "Darwin" ]; then
  printf 'ERROR: iOS smoke requires a macOS host.\n' >&2
  exit 1
fi

DEVICES_JSON="$TMP_DIR/ios-devices.json"
RUNTIMES_JSON="$TMP_DIR/ios-runtimes.json"
xcrun simctl list devices available -j >"$DEVICES_JSON"
xcrun simctl list runtimes -j >"$RUNTIMES_JSON"

SIMULATOR_SELECTION="$(
  python3 - "$DEVICES_JSON" "$RUNTIMES_JSON" <<'PY'
import json
import pathlib
import sys

devices_payload = json.loads(pathlib.Path(sys.argv[1]).read_text())
runtimes_payload = json.loads(pathlib.Path(sys.argv[2]).read_text())

devices_by_runtime = devices_payload.get("devices", {})

for runtime_key in sorted((key for key in devices_by_runtime if "iOS" in key), reverse=True):
    devices = devices_by_runtime.get(runtime_key, [])
    iphone_candidates = [
        device for device in devices
        if device.get("isAvailable") and "iPhone" in device.get("name", "")
    ]
    if iphone_candidates:
        print(f"existing\t{iphone_candidates[0]['udid']}")
        raise SystemExit(0)

available_runtimes = [
    runtime for runtime in runtimes_payload.get("runtimes", [])
    if runtime.get("isAvailable") and runtime.get("platform") == "iOS"
]

for runtime in sorted(available_runtimes, key=lambda item: item.get("version", ""), reverse=True):
    iphone_types = [
        device_type for device_type in runtime.get("supportedDeviceTypes", [])
        if device_type.get("productFamily") == "iPhone"
    ]
    if iphone_types:
        print(
            "create\t{}\t{}".format(
                runtime["identifier"],
                iphone_types[0]["identifier"],
            )
        )
        raise SystemExit(0)

raise SystemExit("no available iOS simulator runtime or device type found")
PY
)"

SELECTION_MODE="$(printf '%s' "$SIMULATOR_SELECTION" | cut -f1)"

case "$SELECTION_MODE" in
  existing)
    SIMULATOR_DEVICE_ID="$(printf '%s' "$SIMULATOR_SELECTION" | cut -f2)"
    ;;
  create)
    RUNTIME_IDENTIFIER="$(printf '%s' "$SIMULATOR_SELECTION" | cut -f2)"
    DEVICE_TYPE_IDENTIFIER="$(printf '%s' "$SIMULATOR_SELECTION" | cut -f3)"
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

xcrun simctl boot "$SIMULATOR_DEVICE_ID" >/dev/null 2>&1 || true
xcrun simctl bootstatus "$SIMULATOR_DEVICE_ID" -b

cd "$BACKEND_DIR"
PORT="$BACKEND_PORT" DB_PATH="$TMP_DIR/mobile-ios-smoke.sqlite" COOKIE_SECURE=false go run . >"$BACKEND_LOG" 2>&1 &
BACKEND_PID=$!

for _ in $(seq 1 30); do
  if curl -fsS "http://127.0.0.1:${BACKEND_PORT}/healthz" >/dev/null 2>&1; then
    break
  fi
  sleep 1
done

if ! curl -fsS "http://127.0.0.1:${BACKEND_PORT}/healthz" >/dev/null 2>&1; then
  printf 'ERROR: backend did not boot for iOS smoke\n' >&2
  cat "$BACKEND_LOG" >&2
  exit 1
fi

cd "$MOBILE_DIR"
flutter pub get
flutter test integration_test/auth/smoke_test.dart \
  -d "$SIMULATOR_DEVICE_ID" \
  --dart-define=API_BASE_URL="http://127.0.0.1:${BACKEND_PORT}" | tee "$FLUTTER_LOG"
