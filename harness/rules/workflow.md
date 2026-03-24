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
7. When adding or materially changing UI, capture screenshots from the changed runtime and review them for design drift, layout breakage, and interaction issues before treating the work as complete.
8. Use screenshot findings as feedback to refine the implementation instead of treating the first visually plausible result as done.
9. Run `bash harness/scripts/verify.sh` before treating the task as complete.
10. Fix all reported violations before treating the task as complete.

## Workflow notes

- Prefer checks and tests to discover problems early.
- During active development, prefer the smallest relevant workspace check or test over running the full repository gate after every tiny edit.
- Prefer running the runtime's formatter or format-check command early when editing files so formatting drift is caught before the final quality gate.
- UI work should not rely on code inspection alone. Use screenshots or equivalent visual captures to verify shared design language, spacing, hierarchy, and major interaction states.
- Screenshot review is a feedback loop, not a one-time artifact dump. If screenshots reveal design mismatch, broken layout, clipped states, or obvious interaction issues, iterate on the implementation in the same task.
- Do not treat a change as done if `bash harness/scripts/verify.sh` has not been run after the latest meaningful edit.
- The minimum completion loop is: make the change, run the relevant local checks while iterating, then run `bash harness/scripts/verify.sh` before finishing, and fix any reported violations.
- Pure documentation updates under `docs/` do not require `bash harness/scripts/verify.sh` by default.
- Pure rule-document updates under `harness/rules/` do not require `bash harness/scripts/verify.sh` by default.
- Changes to business code, tests, CI configuration, executable harness files, or runtime behavior still require the full `bash harness/scripts/verify.sh` gate before completion.
- If a workspace has its own `check.sh`, `test.sh`, or `smoke.sh`, `harness/scripts/verify.sh` must run it as part of the default loop.
- Do not skip a failing check or test by removing it unless the harness itself is being intentionally redesigned and the change is explained.
- If architecture violations happen repeatedly, update the checks or rules in `harness/`.
- If the same class of issue keeps recurring, prefer tightening `harness/` so future runs discover or block it earlier.
- Do not leave durable documentation updates as an implied follow-up when the code change has already changed the repository's public or operational understanding.
