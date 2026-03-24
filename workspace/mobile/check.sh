#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
MOBILE_DIR="$ROOT_DIR/workspace/mobile"

printf 'mobile check: flutter pub get, analyze\n'
cd "$MOBILE_DIR"
flutter pub get
flutter analyze
