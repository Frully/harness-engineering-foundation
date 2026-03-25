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
DEVICE_TYPES_JSON="$TMP_DIR/ios-device-types.json"
SELECTION_LOG="$ARTIFACT_DIR/ios-simulator-selection.txt"
xcrun simctl list devices available -j >"$DEVICES_JSON"
xcrun simctl list runtimes -j >"$RUNTIMES_JSON"
xcrun simctl list devicetypes -j >"$DEVICE_TYPES_JSON"

cp "$DEVICES_JSON" "$ARTIFACT_DIR/ios-devices.json"
cp "$RUNTIMES_JSON" "$ARTIFACT_DIR/ios-runtimes.json"
cp "$DEVICE_TYPES_JSON" "$ARTIFACT_DIR/ios-device-types.json"

SIMULATOR_SELECTION="$(
  python3 - "$DEVICES_JSON" "$RUNTIMES_JSON" "$DEVICE_TYPES_JSON" <<'PY'
import json
import pathlib
import sys

devices_payload = json.loads(pathlib.Path(sys.argv[1]).read_text())
runtimes_payload = json.loads(pathlib.Path(sys.argv[2]).read_text())
device_types_payload = json.loads(pathlib.Path(sys.argv[3]).read_text())

PREFERRED_IPHONES = [
    "iPhone 16",
    "iPhone 15",
    "iPhone 14",
    "iPhone 13",
    "iPhone SE",
]

def version_key(value: str):
    parts = []
    for item in value.split("."):
        try:
            parts.append(int(item))
        except ValueError:
            parts.append(0)
    return tuple(parts)

def runtime_version_number(version: str) -> int:
    parts = [int(item) for item in version.split(".")]
    while len(parts) < 3:
        parts.append(0)
    return (parts[0] << 16) | (parts[1] << 8) | parts[2]

def preferred_rank(name: str) -> tuple[int, str]:
    for index, preferred in enumerate(PREFERRED_IPHONES):
        if preferred in name:
            return (index, name)
    return (len(PREFERRED_IPHONES), name)

available_runtimes = [
    runtime for runtime in runtimes_payload.get("runtimes", [])
    if runtime.get("isAvailable") and runtime.get("platform") == "iOS"
]

if not available_runtimes:
    raise SystemExit("no available iOS simulator runtime found")

available_runtimes.sort(key=lambda item: version_key(item.get("version", "0")), reverse=True)
available_runtime_ids = {runtime["identifier"] for runtime in available_runtimes}
devices_by_runtime = devices_payload.get("devices", {})

existing_candidates = []
for runtime in available_runtimes:
    for device in devices_by_runtime.get(runtime["identifier"], []):
        if not device.get("isAvailable"):
            continue
        name = device.get("name", "")
        if "iPhone" not in name:
            continue
        existing_candidates.append(
            (
                version_key(runtime.get("version", "0")),
                preferred_rank(name),
                device["udid"],
                name,
                runtime["identifier"],
            )
        )

if existing_candidates:
    _, _, udid, name, runtime_id = sorted(existing_candidates, reverse=True)[0]
    print(f"existing\t{udid}\t{name}\t{runtime_id}")
    raise SystemExit(0)

iphone_types = [
    device_type for device_type in device_types_payload.get("devicetypes", [])
    if device_type.get("productFamily") == "iPhone"
]

for runtime in available_runtimes:
    runtime_number = runtime_version_number(runtime["version"])
    compatible_types = []
    for device_type in iphone_types:
        min_version = int(device_type.get("minRuntimeVersion", 0))
        max_version = int(device_type.get("maxRuntimeVersion", 2**32 - 1))
        if runtime_number < min_version or runtime_number > max_version:
            continue
        compatible_types.append(device_type)

    if compatible_types:
        compatible_types.sort(key=lambda item: preferred_rank(item.get("name", "")))
        chosen = compatible_types[0]
        print(
            "create\t{}\t{}\t{}".format(
                runtime["identifier"],
                chosen["identifier"],
                chosen["name"],
            )
        )
        raise SystemExit(0)

raise SystemExit("no compatible iPhone simulator device type found for available runtimes")
PY
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

cd "$BACKEND_DIR"
PORT="$BACKEND_PORT" DB_PATH="$TMP_DIR/mobile-ios-smoke.sqlite" COOKIE_SECURE=false go run . >"$BACKEND_LOG" 2>&1 &
BACKEND_PID=$!

for _ in $(seq 1 90); do
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
