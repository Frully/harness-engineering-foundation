#!/usr/bin/env bash

set -u

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
CHECK_SCRIPT="$ROOT_DIR/harness/checks/check_architecture.sh"
ERROR_COUNT=0

workspace_has_business_code() {
  local workspace_name="$1"
  local workspace_dir="$ROOT_DIR/workspace/$workspace_name"

  find "$workspace_dir" -type f \
    ! -name 'README.md' \
    ! -name 'check.sh' \
    ! -name 'test.sh' \
    -print -quit 2>/dev/null | grep -q .
}

hook_is_placeholder() {
  local hook_path="$1"

  grep -q 'placeholder only' "$hook_path" 2>/dev/null
}

run_workspace_hook() {
  local workspace_name="$1"
  local hook_name="$2"
  local hook_path="$ROOT_DIR/workspace/$workspace_name/$hook_name"

  [ -x "$hook_path" ] || return 0

  if hook_is_placeholder "$hook_path" && workspace_has_business_code "$workspace_name"; then
    printf 'ERROR: workspace/%s/%s is still a placeholder hook, but workspace/%s already contains real business code. Replace it with a real check or test.\n' \
      "$workspace_name" "$hook_name" "$workspace_name" >&2
    ERROR_COUNT=$((ERROR_COUNT + 1))
    return 0
  fi

  printf 'Running workspace/%s/%s...\n' "$workspace_name" "$hook_name"

  if ! bash "$hook_path"; then
    ERROR_COUNT=$((ERROR_COUNT + 1))
  fi
}

printf 'Running baseline architecture checks...\n'

if ! bash "$CHECK_SCRIPT"; then
  printf 'Checks failed. Fix the reported issues before continuing.\n' >&2
  exit 1
fi

printf 'Looking for workspace-specific hooks...\n'

run_workspace_hook frontend check.sh
run_workspace_hook frontend test.sh
run_workspace_hook backend check.sh
run_workspace_hook backend test.sh
run_workspace_hook mobile check.sh
run_workspace_hook mobile test.sh

if [ "$ERROR_COUNT" -ne 0 ]; then
  printf 'Workspace hooks failed with %s issue(s).\n' "$ERROR_COUNT" >&2
  exit 1
fi

printf 'Checks passed. Minimal done loop: keep code in workspace/, run this script, and improve harness/ if the same issue repeats.\n'
