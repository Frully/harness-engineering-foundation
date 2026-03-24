#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
POLICY_PATH="$ROOT_DIR/harness/checks/architecture_policy.json"
ERROR_COUNT=0
SOURCE_FILE_REGEX='.*\.(js|ts|jsx|tsx|py|go|rs|java|kt|swift|rb|php|c|cpp|m|mm)$'
DART_BIN=""

print_error() {
  printf 'ERROR: %s\n' "$1" >&2
  ERROR_COUNT=$((ERROR_COUNT + 1))
}

list_source_files() {
  local path="$1"

  [ -d "$path" ] || return 0

  find "$path" -type f \
    \( -name '*.js' -o -name '*.ts' -o -name '*.jsx' -o -name '*.tsx' -o -name '*.py' -o \
       -name '*.go' -o -name '*.rs' -o -name '*.java' -o -name '*.kt' -o -name '*.swift' -o \
       -name '*.rb' -o -name '*.php' -o -name '*.c' -o -name '*.cpp' -o -name '*.m' -o -name '*.mm' \) \
    -print 2>/dev/null || true
}

is_allowed_root_source_file() {
  local file_name="$1"

  case "$file_name" in
    *.config.js|*.config.ts|*.config.jsx|*.config.tsx)
      return 0
      ;;
    vite.config.js|vite.config.ts|eslint.config.js|eslint.config.ts|playwright.config.ts|playwright.config.js)
      return 0
      ;;
    *)
      return 1
      ;;
  esac
}

check_root_business_files() {
  local file
  local file_name
  local matches=""

  while IFS= read -r file; do
    [ -n "$file" ] || continue
    file_name="$(basename "$file")"

    if ! is_allowed_root_source_file "$file_name"; then
      matches="${matches}${file}"$'\n'
    fi
  done < <(find "$ROOT_DIR" -maxdepth 1 -type f | grep -E "$SOURCE_FILE_REGEX" || true)

  if [ -n "$matches" ]; then
    print_error "Business code must live under workspace/. Root source files are only allowed for shared tooling config:"
    printf '%s\n' "$matches" >&2
  fi
}

check_docs_for_business_code() {
  local docs_dir="$ROOT_DIR/docs"
  local matches

  [ -d "$docs_dir" ] || return 0
  matches=$(list_source_files "$docs_dir")

  if [ -n "$matches" ]; then
    print_error "docs/ is for documentation only. Move these source files into workspace/:"
    printf '%s\n' "$matches" >&2
  fi
}

check_deploy_for_business_code() {
  local deploy_dir="$ROOT_DIR/deploy"
  local matches

  [ -d "$deploy_dir" ] || return 0
  matches=$(list_source_files "$deploy_dir")

  if [ -n "$matches" ]; then
    print_error "deploy/ is for deployment assets only. Move these source files into workspace/:"
    printf '%s\n' "$matches" >&2
  fi
}

check_forbidden_shared_directories() {
  local dir_name
  local target
  local forbidden_names="shared common core base"

  for dir_name in $forbidden_names; do
    for target in "$ROOT_DIR/$dir_name" "$ROOT_DIR/workspace/$dir_name"; do
      if [ -d "$target" ]; then
        print_error "Forbidden generic shared-code directory detected: $target. Do not introduce ad hoc shared/common/core/base areas without a harness-defined shared-code policy."
      fi
    done
  done
}

check_manifest() {
  local label="$1"
  local manifest="$2"
  if [ ! -f "$ROOT_DIR/$manifest" ]; then
    print_error "$label manifest not found at $manifest"
  fi
}

resolve_dart_bin() {
  if command -v dart >/dev/null 2>&1; then
    command -v dart
    return 0
  fi

  if [ -n "${FLUTTER_ROOT:-}" ] && [ -x "${FLUTTER_ROOT}/bin/dart" ]; then
    printf '%s\n' "${FLUTTER_ROOT}/bin/dart"
    return 0
  fi

  return 1
}

run_runtime_check() {
  local label="$1"
  shift
  if ! "$@"; then
    print_error "$label architecture analysis failed"
  fi
}

run_frontend_architecture_check() {
  (
    cd "$ROOT_DIR/harness/checks/frontend_architecture"
    npm ci --ignore-scripts --no-audit --no-fund >/dev/null
    node bin/frontend_architecture.mjs "$ROOT_DIR" "$POLICY_PATH"
  )
}

run_mobile_architecture_check() {
  if [ -z "$DART_BIN" ]; then
    printf 'Dart SDK not found. Set PATH or FLUTTER_ROOT before running architecture checks.\n' >&2
    return 1
  fi

  (
    cd "$ROOT_DIR/harness/checks/mobile_architecture"
    "$DART_BIN" pub get >/dev/null
    "$DART_BIN" run bin/mobile_architecture.dart "$ROOT_DIR" "$POLICY_PATH"
  )
}

check_root_business_files
check_docs_for_business_code
check_deploy_for_business_code
check_forbidden_shared_directories
DART_BIN="$(resolve_dart_bin || true)"

check_manifest "backend" "workspace/backend/go.mod"
check_manifest "frontend" "workspace/frontend/package.json"
check_manifest "mobile" "workspace/mobile/pubspec.yaml"

run_runtime_check "backend" go run "$ROOT_DIR/harness/checks/backend_architecture.go" "$ROOT_DIR" "$POLICY_PATH"
run_runtime_check "frontend" run_frontend_architecture_check
run_runtime_check "mobile" run_mobile_architecture_check

if [ "$ERROR_COUNT" -gt 0 ]; then
  printf 'Architecture check failed with %s issue(s).\n' "$ERROR_COUNT" >&2
  exit 1
fi

printf 'Architecture check passed.\n'
