#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
BACKEND_DIR="$ROOT_DIR/workspace/backend"
START_BACKEND_HELPER="$ROOT_DIR/harness/scripts/start_backend_for_smoke.sh"
TMP_DIR="$(mktemp -d)"
ARTIFACT_DIR="$BACKEND_DIR/.artifacts"
DB_PATH="$TMP_DIR/smoke.sqlite"
PORT="$(python3 - <<'PY'
import socket

with socket.socket() as sock:
    sock.bind(("127.0.0.1", 0))
    print(sock.getsockname()[1])
PY
)"
BASE_URL="http://127.0.0.1:${PORT}"
COOKIE_JAR="$TMP_DIR/cookies.txt"
ARTIFACT_RUN_DIR="$ARTIFACT_DIR/smoke"
SERVER_LOG="$ARTIFACT_RUN_DIR/backend.log"
BACKEND_BIN="$TMP_DIR/backend-smoke"
PID_FILE="$TMP_DIR/backend.pid"

cleanup() {
  if [ -f "$PID_FILE" ]; then
    SERVER_PID="$(cat "$PID_FILE")"
    if [ -n "$SERVER_PID" ] && kill -0 "$SERVER_PID" 2>/dev/null; then
      kill "$SERVER_PID" 2>/dev/null || true
      wait "$SERVER_PID" 2>/dev/null || true
    fi
  fi
  rm -rf "$TMP_DIR"
}
trap cleanup EXIT
mkdir -p "$ARTIFACT_RUN_DIR"

printf 'backend smoke: booting server at %s\n' "$BASE_URL"

bash "$START_BACKEND_HELPER" \
  --output-bin "$BACKEND_BIN" \
  --log-path "$SERVER_LOG" \
  --pid-file "$PID_FILE" \
  --port "$PORT" \
  --db-path "$DB_PATH" \
  --health-url "$BASE_URL/healthz" \
  --label "backend smoke"

printf 'backend smoke: exercising web cookie register and session restore flow\n'
WEB_REGISTER_HEADERS="$TMP_DIR/web-register.headers"
WEB_REGISTER_BODY="$TMP_DIR/web-register.json"

curl -fsS \
  -D "$WEB_REGISTER_HEADERS" \
  -c "$COOKIE_JAR" \
  -H 'Content-Type: application/json' \
  -d '{"email":"web@example.com","password":"Harness1!","confirmPassword":"Harness1!"}' \
  "$BASE_URL/api/auth/register" >"$WEB_REGISTER_BODY"

CSRF_TOKEN="$(python3 - <<'PY' "$WEB_REGISTER_BODY"
import json, sys
with open(sys.argv[1], 'r', encoding='utf-8') as handle:
    print(json.load(handle)['csrfToken'])
PY
)"

if ! grep -qi 'Set-Cookie: hed_session=' "$WEB_REGISTER_HEADERS"; then
  printf 'ERROR: expected session cookie in web register response\n' >&2
  cat "$WEB_REGISTER_HEADERS" >&2
  exit 1
fi

curl -fsS -b "$COOKIE_JAR" "$BASE_URL/api/me" >/dev/null

MISSING_CSRF_STATUS="$(curl -s -o /dev/null -w '%{http_code}' -b "$COOKIE_JAR" -X POST "$BASE_URL/api/auth/logout")"
if [ "$MISSING_CSRF_STATUS" != "403" ]; then
  printf 'ERROR: expected 403 without csrf token, got %s\n' "$MISSING_CSRF_STATUS" >&2
  exit 1
fi

curl -fsS -o /dev/null \
  -b "$COOKIE_JAR" \
  -H "X-CSRF-Token: $CSRF_TOKEN" \
  -X POST \
  "$BASE_URL/api/auth/logout"

POST_LOGOUT_STATUS="$(curl -s -o /dev/null -w '%{http_code}' -b "$COOKIE_JAR" "$BASE_URL/api/me")"
if [ "$POST_LOGOUT_STATUS" != "401" ]; then
  printf 'ERROR: expected 401 after cookie logout, got %s\n' "$POST_LOGOUT_STATUS" >&2
  exit 1
fi

printf 'backend smoke: exercising web cookie login flow\n'
WEB_LOGIN_HEADERS="$TMP_DIR/web-login.headers"
WEB_LOGIN_BODY="$TMP_DIR/web-login.json"

curl -fsS \
  -D "$WEB_LOGIN_HEADERS" \
  -c "$COOKIE_JAR" \
  -H 'Content-Type: application/json' \
  -d '{"email":"web@example.com","password":"Harness1!"}' \
  "$BASE_URL/api/auth/login" >"$WEB_LOGIN_BODY"

WEB_LOGIN_CSRF_TOKEN="$(python3 - <<'PY' "$WEB_LOGIN_BODY"
import json, sys
with open(sys.argv[1], 'r', encoding='utf-8') as handle:
    print(json.load(handle)['csrfToken'])
PY
)"

curl -fsS -b "$COOKIE_JAR" "$BASE_URL/api/me" >/dev/null
curl -fsS -o /dev/null \
  -b "$COOKIE_JAR" \
  -H "X-CSRF-Token: $WEB_LOGIN_CSRF_TOKEN" \
  -X POST \
  "$BASE_URL/api/auth/logout"

printf 'backend smoke: exercising mobile bearer register and session restore flow\n'
MOBILE_REGISTER_BODY="$TMP_DIR/mobile-register.json"
curl -fsS \
  -H 'Content-Type: application/json' \
  -H 'X-Client-Type: mobile' \
  -d '{"email":"mobile@example.com","password":"Harness1!","confirmPassword":"Harness1!"}' \
  "$BASE_URL/api/auth/register" >"$MOBILE_REGISTER_BODY"

MOBILE_TOKEN="$(python3 - <<'PY' "$MOBILE_REGISTER_BODY"
import json, sys
with open(sys.argv[1], 'r', encoding='utf-8') as handle:
    print(json.load(handle)['token'])
PY
)"

curl -fsS -H "Authorization: Bearer $MOBILE_TOKEN" "$BASE_URL/api/me" >/dev/null
curl -fsS -o /dev/null -H "Authorization: Bearer $MOBILE_TOKEN" -X POST "$BASE_URL/api/auth/logout"

MOBILE_POST_LOGOUT_STATUS="$(curl -s -o /dev/null -w '%{http_code}' -H "Authorization: Bearer $MOBILE_TOKEN" "$BASE_URL/api/me")"
if [ "$MOBILE_POST_LOGOUT_STATUS" != "401" ]; then
  printf 'ERROR: expected 401 after bearer logout, got %s\n' "$MOBILE_POST_LOGOUT_STATUS" >&2
  exit 1
fi

printf 'backend smoke: exercising mobile bearer login flow\n'
MOBILE_LOGIN_BODY="$TMP_DIR/mobile-login.json"
curl -fsS \
  -H 'Content-Type: application/json' \
  -H 'X-Client-Type: mobile' \
  -d '{"email":"mobile@example.com","password":"Harness1!"}' \
  "$BASE_URL/api/auth/login" >"$MOBILE_LOGIN_BODY"

MOBILE_LOGIN_TOKEN="$(python3 - <<'PY' "$MOBILE_LOGIN_BODY"
import json, sys
with open(sys.argv[1], 'r', encoding='utf-8') as handle:
    print(json.load(handle)['token'])
PY
)"

curl -fsS -H "Authorization: Bearer $MOBILE_LOGIN_TOKEN" "$BASE_URL/api/me" >/dev/null
curl -fsS -o /dev/null -H "Authorization: Bearer $MOBILE_LOGIN_TOKEN" -X POST "$BASE_URL/api/auth/logout"

printf 'backend smoke: PASS\n'
