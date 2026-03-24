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
BACKEND_LOG="$ARTIFACT_DIR/android-backend.log"
FLUTTER_LOG="$ARTIFACT_DIR/android-smoke.log"

cleanup() {
  if [ -n "${BACKEND_PID:-}" ] && kill -0 "$BACKEND_PID" 2>/dev/null; then
    kill "$BACKEND_PID" 2>/dev/null || true
    wait "$BACKEND_PID" 2>/dev/null || true
  fi
  rm -rf "$TMP_DIR"
}
trap cleanup EXIT
mkdir -p "$ARTIFACT_DIR"

ANDROID_DEVICE_ID="${ANDROID_DEVICE_ID:-$(adb devices | awk 'NR > 1 && $2 == "device" { print $1; exit }')}"
if [ -z "$ANDROID_DEVICE_ID" ]; then
  printf 'ERROR: no Android device or emulator detected for Flutter smoke\n' >&2
  exit 1
fi

printf 'mobile android smoke: booting backend %s and running integration test on %s\n' "$BACKEND_PORT" "$ANDROID_DEVICE_ID"

cd "$BACKEND_DIR"
PORT="$BACKEND_PORT" DB_PATH="$TMP_DIR/mobile-android-smoke.sqlite" COOKIE_SECURE=false go run . >"$BACKEND_LOG" 2>&1 &
BACKEND_PID=$!

for _ in $(seq 1 30); do
  if curl -fsS "http://127.0.0.1:${BACKEND_PORT}/healthz" >/dev/null 2>&1; then
    break
  fi
  sleep 1
done

if ! curl -fsS "http://127.0.0.1:${BACKEND_PORT}/healthz" >/dev/null 2>&1; then
  printf 'ERROR: backend did not boot for Android smoke\n' >&2
  cat "$BACKEND_LOG" >&2
  exit 1
fi

cd "$MOBILE_DIR"
flutter pub get
flutter test integration_test/auth/smoke_test.dart \
  -d "$ANDROID_DEVICE_ID" \
  --dart-define=API_BASE_URL="http://10.0.2.2:${BACKEND_PORT}" | tee "$FLUTTER_LOG"
