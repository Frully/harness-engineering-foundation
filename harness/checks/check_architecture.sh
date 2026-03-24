#!/usr/bin/env bash

set -u

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
ERROR_COUNT=0
SOURCE_FILE_REGEX='.*\.(js|ts|jsx|tsx|py|go|rs|java|kt|swift|rb|php|c|cpp|m|mm)$'

print_error() {
  printf 'ERROR: %s\n' "$1" >&2
  ERROR_COUNT=$((ERROR_COUNT + 1))
}

has_rg() {
  command -v rg >/dev/null 2>&1
}

run_text_search() {
  local pattern="$1"
  local file="$2"

  if has_rg; then
    rg -n -i "$pattern" "$file" || true
  else
    grep -nHiE "$pattern" "$file" || true
  fi
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

scan_source_content() {
  local pattern="$1"
  local path="$2"
  local file
  local result
  local matches=""

  while IFS= read -r file; do
    [ -n "$file" ] || continue

    result=$(run_text_search "$pattern" "$file")

    if [ -n "$result" ]; then
      matches="${matches}${result}"$'\n'
    fi
  done < <(list_source_files "$path")

  printf '%s' "$matches"
}

scan_source_content_patterns() {
  local path="$1"
  shift
  local file
  local pattern
  local result
  local matches=""

  while IFS= read -r file; do
    [ -n "$file" ] || continue

    for pattern in "$@"; do
      result=$(run_text_search "$pattern" "$file")

      if [ -n "$result" ]; then
        matches="${matches}${result}"$'\n'
        break
      fi
    done
  done < <(list_source_files "$path")

  printf '%s' "$matches"
}

scan_dependency_imports() {
  local path="$1"
  local target_pattern="$2"
  local file
  local result
  local matches=""
  local patterns=(
    '^[[:space:]]*(import|export)[[:space:]].*["'"'"'][^"'"'"']*'"$target_pattern"'[^"'"'"']*["'"'"']'
    '^[[:space:]]*from[[:space:]]+["'"'"'][^"'"'"']*'"$target_pattern"'[^"'"'"']*["'"'"']'
    '(^|[^[:alnum:]_])(require|import)[[:space:]]*\([[:space:]]*["'"'"'][^"'"'"']*'"$target_pattern"'[^"'"'"']*["'"'"'][[:space:]]*\)'
    '^[[:space:]]*from[[:space:]]+'"${target_pattern}"'([[:space:].]|$)'
    '^[[:space:]]*import[[:space:]].*'"${target_pattern}"'([[:space:].,]|$)'
  )

  while IFS= read -r file; do
    [ -n "$file" ] || continue

    for pattern in "${patterns[@]}"; do
      result=$(run_text_search "$pattern" "$file")

      if [ -n "$result" ]; then
        matches="${matches}${result}"$'\n'
        break
      fi
    done
  done < <(list_source_files "$path")

  printf '%s' "$matches"
}

is_allowed_root_source_file() {
  local file_name="$1"

  case "$file_name" in
    *.config.js|*.config.ts|*.config.jsx|*.config.tsx)
      return 0
      ;;
    vite.config.js|vite.config.ts|vite.config.jsx|vite.config.tsx)
      return 0
      ;;
    vitest.config.js|vitest.config.ts|vitest.config.jsx|vitest.config.tsx)
      return 0
      ;;
    eslint.config.js|eslint.config.ts|eslint.config.jsx|eslint.config.tsx)
      return 0
      ;;
    prettier.config.js|prettier.config.ts|prettier.config.jsx|prettier.config.tsx)
      return 0
      ;;
    jest.config.js|jest.config.ts|jest.config.jsx|jest.config.tsx)
      return 0
      ;;
    playwright.config.js|playwright.config.ts|playwright.config.jsx|playwright.config.tsx)
      return 0
      ;;
    cypress.config.js|cypress.config.ts|cypress.config.jsx|cypress.config.tsx)
      return 0
      ;;
    tailwind.config.js|tailwind.config.ts|tailwind.config.jsx|tailwind.config.tsx)
      return 0
      ;;
    postcss.config.js|postcss.config.ts|postcss.config.jsx|postcss.config.tsx)
      return 0
      ;;
    webpack.config.js|webpack.config.ts|webpack.config.jsx|webpack.config.tsx)
      return 0
      ;;
    rollup.config.js|rollup.config.ts|rollup.config.jsx|rollup.config.tsx)
      return 0
      ;;
    babel.config.js|babel.config.ts|babel.config.jsx|babel.config.tsx)
      return 0
      ;;
    tsup.config.js|tsup.config.ts|tsup.config.jsx|tsup.config.tsx)
      return 0
      ;;
    commitlint.config.js|commitlint.config.ts|commitlint.config.jsx|commitlint.config.tsx)
      return 0
      ;;
    lint-staged.config.js|lint-staged.config.ts|lint-staged.config.jsx|lint-staged.config.tsx)
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
    print_error "Business code must live under workspace/. Root source files are only allowed for common tooling config:"
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
    print_error "deploy/ is for deployment assets only. Move these business source files into workspace/:"
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

check_backend_service_db_access() {
  local service_dir="$ROOT_DIR/workspace/backend/service"
  local matches
  local db_patterns=(
    '(^|[^[:alnum:]_])(import|from)[[:space:]].*(prisma|sequelize|mongoose|typeorm|jdbc)([^[:alnum:]_]|$)'
    '(^|[^[:alnum:]_])require\([[:space:]]*["'"'"'][^"'"'"']*(prisma|sequelize|mongoose|typeorm|jdbc)[^"'"'"']*["'"'"'][[:space:]]*\)'
    '(^|[^[:alnum:]_])(use|extern[[:space:]]+crate)[[:space:]].*(gorm|sqlx|diesel|mongodb)([^[:alnum:]_]|$)'
    '(^|[^[:alnum:]_])(new[[:space:]]+PrismaClient|createConnection|createPool|openDatabase)\b'
    '(^|[^[:alnum:]_])(sql[[:space:]]*`|prisma\\.[[:space:]]*\\$queryRaw|prisma\\.[[:space:]]*\\$executeRaw)\b'
    '(^|[^[:alnum:]_])(db|database|repo|conn|connection|pool|client)[[:space:]]*\\.[[:space:]]*(query|execute|exec|raw)\s*\('
    '["'"'"'`][[:space:]]*(select\b|insert[[:space:]]+into\b|update\b.+\bset\b|delete[[:space:]]+from\b|with\b)'
  )

  [ -d "$service_dir" ] || return 0

  matches=$(scan_source_content_patterns "$service_dir" "${db_patterns[@]}")

  if [ -n "$matches" ]; then
    print_error "workspace/backend/service should not implement direct database access. Move data access into repo/:"
    printf '%s\n' "$matches" >&2
  fi
}

check_backend_service_higher_layer_dependency() {
  local service_dir="$ROOT_DIR/workspace/backend/service"
  local matches
  local higher_targets='(\.\./composition|/composition/|workspace/backend/composition|workspace\.backend\.composition|backend\.composition|\.\./runtime|/runtime/|workspace/backend/runtime|workspace\.backend\.runtime|backend\.runtime)'

  [ -d "$service_dir" ] || return 0

  matches=$(scan_dependency_imports "$service_dir" "$higher_targets")

  if [ -n "$matches" ]; then
    print_error "workspace/backend/service should not depend on composition/ or runtime/:"
    printf '%s\n' "$matches" >&2
  fi
}

check_backend_runtime_business_dependency() {
  local runtime_dir="$ROOT_DIR/workspace/backend/runtime"
  local matches
  local forbidden_targets='(\.\./composition|/composition/|workspace/backend/composition|workspace\.backend\.composition|backend\.composition|\.\./repo|/repo/|workspace/backend/repo|workspace\.backend\.repo|backend\.repo|\.\./service|/service/|workspace/backend/service|workspace\.backend\.service|backend\.service)'

  [ -d "$runtime_dir" ] || return 0

  matches=$(scan_dependency_imports "$runtime_dir" "$forbidden_targets")

  if [ -n "$matches" ]; then
    print_error "workspace/backend/runtime should not depend on composition/, repo/, or service/ directly. Let composition/ assemble runtime:"
    printf '%s\n' "$matches" >&2
  fi
}

check_backend_repo_higher_layer_dependency() {
  local repo_dir="$ROOT_DIR/workspace/backend/repo"
  local matches
  local higher_targets='(\.\./service|/service/|workspace/backend/service|workspace\.backend\.service|backend\.service|\.\./composition|/composition/|workspace/backend/composition|workspace\.backend\.composition|backend\.composition|\.\./runtime|/runtime/|workspace/backend/runtime|workspace\.backend\.runtime|backend\.runtime)'

  [ -d "$repo_dir" ] || return 0

  matches=$(scan_dependency_imports "$repo_dir" "$higher_targets")

  if [ -n "$matches" ]; then
    print_error "workspace/backend/repo should not depend on service/ or runtime/:"
    printf '%s\n' "$matches" >&2
  fi
}

check_backend_config_higher_layer_dependency() {
  local config_dir="$ROOT_DIR/workspace/backend/config"
  local matches
  local higher_targets='(\.\./repo|/repo/|workspace/backend/repo|workspace\.backend\.repo|backend\.repo|\.\./service|/service/|workspace/backend/service|workspace\.backend\.service|backend\.service|\.\./composition|/composition/|workspace/backend/composition|workspace\.backend\.composition|backend\.composition|\.\./runtime|/runtime/|workspace/backend/runtime|workspace\.backend\.runtime|backend\.runtime)'

  [ -d "$config_dir" ] || return 0

  matches=$(scan_dependency_imports "$config_dir" "$higher_targets")

  if [ -n "$matches" ]; then
    print_error "workspace/backend/config should not depend on repo/, service/, or runtime/:"
    printf '%s\n' "$matches" >&2
  fi
}

check_backend_types_higher_layer_dependency() {
  local types_dir="$ROOT_DIR/workspace/backend/types"
  local matches
  local higher_targets='(\.\./config|/config/|workspace/backend/config|workspace\.backend\.config|backend\.config|\.\./repo|/repo/|workspace/backend/repo|workspace\.backend\.repo|backend\.repo|\.\./service|/service/|workspace/backend/service|workspace\.backend\.service|backend\.service|\.\./composition|/composition/|workspace/backend/composition|workspace\.backend\.composition|backend\.composition|\.\./runtime|/runtime/|workspace/backend/runtime|workspace\.backend\.runtime|backend\.runtime)'

  [ -d "$types_dir" ] || return 0

  matches=$(scan_dependency_imports "$types_dir" "$higher_targets")

  if [ -n "$matches" ]; then
    print_error "workspace/backend/types should not depend on higher backend layers:"
    printf '%s\n' "$matches" >&2
  fi
}

check_frontend_cross_runtime_imports() {
  local frontend_dir="$ROOT_DIR/workspace/frontend"
  local matches
  local runtime_targets='(\.\./backend|/backend/|workspace/backend|workspace\.backend|backend|\.\./mobile|/mobile/|workspace/mobile|workspace\.mobile|mobile)'

  [ -d "$frontend_dir" ] || return 0

  matches=$(scan_dependency_imports "$frontend_dir" "$runtime_targets")

  if [ -n "$matches" ]; then
    print_error "workspace/frontend should not import backend or mobile code directly. Keep frontend isolated to frontend concerns:"
    printf '%s\n' "$matches" >&2
  fi
}

check_frontend_services_ui_dependency() {
  local services_dir="$ROOT_DIR/workspace/frontend/services"
  local matches
  local ui_targets='(\.\./pages|/pages/|workspace/frontend/pages|workspace\.frontend\.pages|frontend\.pages|\.\./components|/components/|workspace/frontend/components|workspace\.frontend\.components|frontend\.components)'

  [ -d "$services_dir" ] || return 0

  matches=$(scan_dependency_imports "$services_dir" "$ui_targets")

  if [ -n "$matches" ]; then
    print_error "workspace/frontend/services should not depend on pages/ or components/:"
    printf '%s\n' "$matches" >&2
  fi
}

check_frontend_components_page_dependency() {
  local components_dir="$ROOT_DIR/workspace/frontend/components"
  local matches
  local page_targets='(\.\./pages|/pages/|workspace/frontend/pages|workspace\.frontend\.pages|frontend\.pages)'

  [ -d "$components_dir" ] || return 0

  matches=$(scan_dependency_imports "$components_dir" "$page_targets")

  if [ -n "$matches" ]; then
    print_error "workspace/frontend/components should not depend on pages/:"
    printf '%s\n' "$matches" >&2
  fi
}

check_mobile_cross_runtime_imports() {
  local mobile_dir="$ROOT_DIR/workspace/mobile"
  local matches
  local runtime_targets='(\.\./backend|/backend/|workspace/backend|workspace\.backend|backend|\.\./frontend|/frontend/|workspace/frontend|workspace\.frontend|frontend)'

  [ -d "$mobile_dir" ] || return 0

  matches=$(scan_dependency_imports "$mobile_dir" "$runtime_targets")

  if [ -n "$matches" ]; then
    print_error "workspace/mobile should not import backend or frontend code directly. Keep mobile isolated to mobile concerns:"
    printf '%s\n' "$matches" >&2
  fi
}

check_mobile_services_ui_dependency() {
  local services_dir="$ROOT_DIR/workspace/mobile/services"
  local matches
  local ui_targets='(\.\./screens|/screens/|workspace/mobile/screens|workspace\.mobile\.screens|mobile\.screens|\.\./components|/components/|workspace/mobile/components|workspace\.mobile\.components|mobile\.components)'

  [ -d "$services_dir" ] || return 0

  matches=$(scan_dependency_imports "$services_dir" "$ui_targets")

  if [ -n "$matches" ]; then
    print_error "workspace/mobile/services should not depend on screens/ or components/:"
    printf '%s\n' "$matches" >&2
  fi
}

check_mobile_components_screen_dependency() {
  local components_dir="$ROOT_DIR/workspace/mobile/components"
  local matches
  local screen_targets='(\.\./screens|/screens/|workspace/mobile/screens|workspace\.mobile\.screens|mobile\.screens)'

  [ -d "$components_dir" ] || return 0

  matches=$(scan_dependency_imports "$components_dir" "$screen_targets")

  if [ -n "$matches" ]; then
    print_error "workspace/mobile/components should not depend on screens/:"
    printf '%s\n' "$matches" >&2
  fi
}

check_root_business_files
check_docs_for_business_code
check_deploy_for_business_code
check_forbidden_shared_directories
check_backend_types_higher_layer_dependency
check_backend_config_higher_layer_dependency
check_backend_repo_higher_layer_dependency
check_backend_service_db_access
check_backend_service_higher_layer_dependency
check_backend_runtime_business_dependency
check_frontend_cross_runtime_imports
check_frontend_services_ui_dependency
check_frontend_components_page_dependency
check_mobile_cross_runtime_imports
check_mobile_services_ui_dependency
check_mobile_components_screen_dependency

if [ "$ERROR_COUNT" -gt 0 ]; then
  printf 'Architecture check failed with %s issue(s).\n' "$ERROR_COUNT" >&2
  exit 1
fi

printf 'Architecture check passed.\n'
