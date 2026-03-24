#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
MOBILE_DIR="$ROOT_DIR/workspace/mobile"

printf 'mobile check: flutter pub get, format check, analyze\n'
cd "$MOBILE_DIR"
flutter pub get
dart format --output=none --set-exit-if-changed .
flutter analyze
