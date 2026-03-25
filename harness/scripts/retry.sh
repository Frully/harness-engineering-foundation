#!/usr/bin/env bash

set -euo pipefail

if [ "$#" -lt 3 ]; then
  printf 'Usage: retry.sh <attempts> <sleep-seconds> <command> [args...]\n' >&2
  exit 1
fi

ATTEMPTS="$1"
SLEEP_SECONDS="$2"
shift 2

for attempt in $(seq 1 "$ATTEMPTS"); do
  if "$@"; then
    exit 0
  fi

  if [ "$attempt" -eq "$ATTEMPTS" ]; then
    break
  fi

  printf 'retry.sh: attempt %s/%s failed, retrying in %ss: %s\n' \
    "$attempt" \
    "$ATTEMPTS" \
    "$SLEEP_SECONDS" \
    "$*" >&2
  sleep "$SLEEP_SECONDS"
done

printf 'retry.sh: command failed after %s attempts: %s\n' "$ATTEMPTS" "$*" >&2
exit 1
