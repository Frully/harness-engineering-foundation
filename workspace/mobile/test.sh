#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
MOBILE_DIR="$ROOT_DIR/workspace/mobile"

printf 'mobile test: simulator selection tests and flutter test\n'
cd "$MOBILE_DIR"
flutter pub get
python3 -m unittest tools/select_ios_simulator_test.py
flutter test test/auth/auth_flow_test.dart
