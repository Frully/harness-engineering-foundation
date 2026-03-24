# Development Workflow Rules

This document defines the default working order for AI and humans in this repository.

## Default development order

Follow this order unless a task clearly requires a justified exception:

1. Read the relevant rule files before changing structure or business code.
2. Identify the target runtime and the correct directory before creating or moving files.
3. Run the smallest relevant local check for the affected workspace before or during implementation whenever practical.
4. Make the smallest useful change in business code.
5. If the change alters durable project knowledge such as APIs, auth, testing strategy, runbooks, or deployment behavior, update `docs/` as part of the same task.
6. If the change exposes a repeated structural problem, update `harness/` as part of the same task.
7. Run `bash harness/scripts/dev.sh` before treating the task as complete.
8. Fix all reported violations before treating the task as complete.

## Workflow notes

- Prefer checks and tests to discover problems early.
- During active development, prefer the smallest relevant workspace check or test over running the full repository gate after every tiny edit.
- Do not treat a change as done if `bash harness/scripts/dev.sh` has not been run after the latest meaningful edit.
- The minimum completion loop is: make the change, run the relevant local checks while iterating, then run `bash harness/scripts/dev.sh` before finishing, and fix any reported violations.
- If a workspace has its own `check.sh`, `test.sh`, or `smoke.sh`, `harness/scripts/dev.sh` must run it as part of the default loop.
- Do not skip a failing check or test by removing it unless the harness itself is being intentionally redesigned and the change is explained.
- If architecture violations happen repeatedly, update the checks or rules in `harness/`.
- If the same class of issue keeps recurring, prefer tightening `harness/` so future runs discover or block it earlier.
- Do not leave durable documentation updates as an implied follow-up when the code change has already changed the repository's public or operational understanding.
