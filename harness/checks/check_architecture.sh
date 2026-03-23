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

    if has_rg; then
      result=$(rg -n -i "$pattern" "$file" || true)
    else
      result=$(grep -nHiE "$pattern" "$file" || true)
    fi

    if [ -n "$result" ]; then
      matches="${matches}${result}"$'\n'
    fi
  done < <(list_source_files "$path")

  printf '%s' "$matches"
}

check_root_business_files() {
  local root_files
  root_files=$(find "$ROOT_DIR" -maxdepth 1 -type f | grep -E "$SOURCE_FILE_REGEX" || true)

  if [ -n "$root_files" ]; then
    print_error "Business code must live under workspace/. Move these root files into the correct workspace directory:"
    printf '%s\n' "$root_files" >&2
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

  [ -d "$service_dir" ] || return 0

  matches=$(scan_source_content 'SELECT|INSERT|UPDATE|DELETE|FROM|JOIN|db\\.|sql\\.|prisma|sequelize|mongoose|typeorm|gorm|jdbc' "$service_dir")

  if [ -n "$matches" ]; then
    print_error "workspace/backend/service should not implement direct database access. Move data access into repo/:"
    printf '%s\n' "$matches" >&2
  fi
}

check_backend_runtime_repo_dependency() {
  local runtime_dir="$ROOT_DIR/workspace/backend/runtime"
  local matches

  [ -d "$runtime_dir" ] || return 0

  matches=$(scan_source_content '\.\./repo|/repo/|workspace/backend/repo|from .*(repo)|require\(.*repo' "$runtime_dir")

  if [ -n "$matches" ]; then
    print_error "workspace/backend/runtime should not depend on repo directly. Runtime must go through service/:"
    printf '%s\n' "$matches" >&2
  fi
}

check_backend_repo_higher_layer_dependency() {
  local repo_dir="$ROOT_DIR/workspace/backend/repo"
  local matches

  [ -d "$repo_dir" ] || return 0

  matches=$(scan_source_content '\.\./service|/service/|workspace/backend/service|\.\./runtime|/runtime/|workspace/backend/runtime|from .*(service|runtime)|require\(.*(service|runtime)' "$repo_dir")

  if [ -n "$matches" ]; then
    print_error "workspace/backend/repo should not depend on service/ or runtime/:"
    printf '%s\n' "$matches" >&2
  fi
}

check_backend_config_higher_layer_dependency() {
  local config_dir="$ROOT_DIR/workspace/backend/config"
  local matches

  [ -d "$config_dir" ] || return 0

  matches=$(scan_source_content '\.\./repo|/repo/|workspace/backend/repo|\.\./service|/service/|workspace/backend/service|\.\./runtime|/runtime/|workspace/backend/runtime|from .*(repo|service|runtime)|require\(.*(repo|service|runtime)' "$config_dir")

  if [ -n "$matches" ]; then
    print_error "workspace/backend/config should not depend on repo/, service/, or runtime/:"
    printf '%s\n' "$matches" >&2
  fi
}

check_backend_types_higher_layer_dependency() {
  local types_dir="$ROOT_DIR/workspace/backend/types"
  local matches

  [ -d "$types_dir" ] || return 0

  matches=$(scan_source_content '\.\./config|/config/|workspace/backend/config|\.\./repo|/repo/|workspace/backend/repo|\.\./service|/service/|workspace/backend/service|\.\./runtime|/runtime/|workspace/backend/runtime|from .*(config|repo|service|runtime)|require\(.*(config|repo|service|runtime)' "$types_dir")

  if [ -n "$matches" ]; then
    print_error "workspace/backend/types should not depend on higher backend layers:"
    printf '%s\n' "$matches" >&2
  fi
}

check_frontend_cross_runtime_imports() {
  local frontend_dir="$ROOT_DIR/workspace/frontend"
  local matches

  [ -d "$frontend_dir" ] || return 0

  matches=$(scan_source_content '\.\./backend|/backend/|workspace/backend|\.\./mobile|/mobile/|workspace/mobile' "$frontend_dir")

  if [ -n "$matches" ]; then
    print_error "workspace/frontend should not import backend or mobile code directly. Keep frontend isolated to frontend concerns:"
    printf '%s\n' "$matches" >&2
  fi
}

check_frontend_services_ui_dependency() {
  local services_dir="$ROOT_DIR/workspace/frontend/services"
  local matches

  [ -d "$services_dir" ] || return 0

  matches=$(scan_source_content '\.\./pages|/pages/|workspace/frontend/pages|\.\./components|/components/|workspace/frontend/components|from .*(pages|components)|require\(.*(pages|components)' "$services_dir")

  if [ -n "$matches" ]; then
    print_error "workspace/frontend/services should not depend on pages/ or components/:"
    printf '%s\n' "$matches" >&2
  fi
}

check_frontend_components_page_dependency() {
  local components_dir="$ROOT_DIR/workspace/frontend/components"
  local matches

  [ -d "$components_dir" ] || return 0

  matches=$(scan_source_content '\.\./pages|/pages/|workspace/frontend/pages|from .*pages|require\(.*pages' "$components_dir")

  if [ -n "$matches" ]; then
    print_error "workspace/frontend/components should not depend on pages/:"
    printf '%s\n' "$matches" >&2
  fi
}

check_mobile_cross_runtime_imports() {
  local mobile_dir="$ROOT_DIR/workspace/mobile"
  local matches

  [ -d "$mobile_dir" ] || return 0

  matches=$(scan_source_content '\.\./backend|/backend/|workspace/backend|\.\./frontend|/frontend/|workspace/frontend' "$mobile_dir")

  if [ -n "$matches" ]; then
    print_error "workspace/mobile should not import backend or frontend code directly. Keep mobile isolated to mobile concerns:"
    printf '%s\n' "$matches" >&2
  fi
}

check_mobile_services_ui_dependency() {
  local services_dir="$ROOT_DIR/workspace/mobile/services"
  local matches

  [ -d "$services_dir" ] || return 0

  matches=$(scan_source_content '\.\./screens|/screens/|workspace/mobile/screens|\.\./components|/components/|workspace/mobile/components|from .*(screens|components)|require\(.*(screens|components)' "$services_dir")

  if [ -n "$matches" ]; then
    print_error "workspace/mobile/services should not depend on screens/ or components/:"
    printf '%s\n' "$matches" >&2
  fi
}

check_mobile_components_screen_dependency() {
  local components_dir="$ROOT_DIR/workspace/mobile/components"
  local matches

  [ -d "$components_dir" ] || return 0

  matches=$(scan_source_content '\.\./screens|/screens/|workspace/mobile/screens|from .*screens|require\(.*screens' "$components_dir")

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
check_backend_runtime_repo_dependency
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
