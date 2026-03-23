# Development Workflow Rules

This document defines the default working order for AI and humans in this repository.

## Default development order

Follow this order unless a task clearly requires a justified exception:

1. Read the relevant rule files before changing structure or business code.
2. Identify the target runtime and the correct directory before creating or moving files.
3. Make the smallest useful change in business code.
4. If the change exposes a repeated structural problem, update `harness/` as part of the same task.
5. Run `bash harness/scripts/dev.sh`.
6. Fix all reported violations before treating the task as complete.

## Workflow notes

- Prefer checks and tests to discover problems early.
- Do not treat a change as done if `bash harness/scripts/dev.sh` has not been run after the latest edit.
- The minimum completion loop is: make the change, run `bash harness/scripts/dev.sh`, then fix any reported violations before continuing.
- If a workspace has its own `check.sh` or `test.sh`, `harness/scripts/dev.sh` must run it as part of the default loop.
- Do not skip a failing check or test by removing it unless the harness itself is being intentionally redesigned and the change is explained.
- If architecture violations happen repeatedly, update the checks or rules in `harness/`.
