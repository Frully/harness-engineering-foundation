#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
POLICY_PATH="$ROOT_DIR/harness/checks/feature_test_policy.json"

python3 - <<'PY' "$ROOT_DIR" "$POLICY_PATH"
import json
import pathlib
import re
import sys

root = pathlib.Path(sys.argv[1])
policy = json.loads(pathlib.Path(sys.argv[2]).read_text())
errors = []

for feature_name, feature_policy in policy["features"].items():
    for runtime_name, runtime_policy in feature_policy["runtimes"].items():
        matches = []
        for pattern in runtime_policy["path_patterns"]:
            matches.extend(root.glob(pattern))

        files = sorted({match for match in matches if match.is_file()})
        if not files:
            errors.append(
                f"{runtime_name} feature '{feature_name}' must have tests under one of: {', '.join(runtime_policy['path_patterns'])}"
            )
            continue

        content = "\n".join(file.read_text(encoding="utf-8") for file in files)
        for scenario_name, scenario_pattern in runtime_policy["scenario_patterns"].items():
            if re.search(scenario_pattern, content, re.IGNORECASE | re.MULTILINE) is None:
                errors.append(
                    f"{runtime_name} feature '{feature_name}' must explicitly cover scenario '{scenario_name}'"
                )

if errors:
    for message in errors:
        print(f"ERROR: {message}", file=sys.stderr)
    print(f"Feature test check failed with {len(errors)} issue(s).", file=sys.stderr)
    sys.exit(1)

print("Feature test check passed.")
PY
