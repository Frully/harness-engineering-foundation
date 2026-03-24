# Quality Gate Rules

This document defines the repository quality gate and completion boundary.

## Quality gate

- `bash harness/scripts/dev.sh` is the final repository quality gate for task completion, not the required command after every tiny intermediate edit.
- Treat `bash harness/scripts/dev.sh` as the shared baseline verification entrypoint, not as a smoke test by itself. Its coverage is only as strong as the checks and workspace hooks it runs.
- Pure documentation updates under `docs/` do not require the full `dev.sh` gate by default.
- Pure rule-document updates under `harness/rules/` do not require the full `dev.sh` gate by default.
- Changes to executable harness files, CI behavior, business code, tests, or runtime behavior still require the full `dev.sh` gate.
- If a workspace has its own `check.sh`, `test.sh`, or `smoke.sh`, `harness/scripts/dev.sh` must run it as part of the default loop.
- Workspace `check.sh` hooks should include formatting verification that matches the runtime toolchain instead of relying on manual editor formatting.
- Do not skip a failing check or test by removing it unless the harness itself is being intentionally redesigned and the change is explained.
- Placeholder workspace hooks are allowed only while the workspace has no real business code yet.
- Once a workspace starts carrying real business code, placeholder hooks are no longer acceptable and the quality gate should fail until real checks and tests replace them.
- CI should call the same `bash harness/scripts/dev.sh` entrypoint instead of duplicating logic in platform-specific config.
- If `dev.sh` or required workspace hooks fail, the change is not complete.
- If CI fails on the same entrypoint, the change is not complete even if the local edit appears correct.
- If architecture violations happen repeatedly, update the checks or rules in `harness/`.
- Once a workspace enters real feature development, treat real `check.sh` and `test.sh` coverage as part of the repository baseline for that workspace, not as an optional follow-up.
- During development, use the smallest relevant local check or test to iterate quickly, then run the full `dev.sh` gate before finishing.

## Definition of done

- The default development order in `harness/rules/workflow.md` has been followed unless the task required a justified exception.
- The code is placed in the correct directory.
- If the task changed business code, tests, CI behavior, executable harness files, or runtime behavior, `bash harness/scripts/dev.sh` has been run after the latest meaningful edit.
- When `bash harness/scripts/dev.sh` is required for the task type, it exits successfully.
- Any available workspace `check.sh`, `test.sh`, and `smoke.sh` hooks pass.
- Each workspace `check.sh` that validates real business code includes formatting verification appropriate to that runtime, such as `gofmt`, `biome format --check`, or `dart format --set-exit-if-changed`.
- If a workspace contains real business code, its `check.sh`, `test.sh`, and `smoke.sh` must not remain placeholder-only hooks.
- If a workspace contains real business code, its `smoke.sh` must represent complete smoke coverage for that workspace's current operational baseline.
- If the task changed durable project knowledge such as auth behavior, API contracts, testing strategy, run paths, or release flow, the relevant `docs/` content has been updated in the same task.
- If a repeated mistake is detected, prefer improving `harness/` so the mistake is easier to prevent next time.

## Rule coverage

### Automated today

- No business source files in the repository root.
- No business source files in `docs/`.
- No business source files in `deploy/`.
- Forbidden generic shared-code directories are not allowed at the repository root or directly under `workspace/`.
- `workspace/backend/service/` must not implement direct database access.
- `workspace/backend/service/` must not depend on `composition/` or `runtime/`.
- `workspace/backend/runtime/` must not depend on `composition/`, `repo/`, or `service/` directly.
- `workspace/backend/repo/` must not depend on `service/`, `composition/`, or `runtime/`.
- `workspace/backend/config/` must not depend on `repo/`, `service/`, `composition/`, or `runtime/`.
- `workspace/backend/types/` must not depend on higher backend layers.
- `workspace/frontend/` must not import backend or mobile code directly.
- `workspace/frontend/services/` must not depend on `pages/` or `components/`.
- `workspace/frontend/components/` must not depend on `pages/`.
- `workspace/mobile/` must not import backend or frontend code directly.
- `workspace/mobile/services/` must not depend on `screens/` or `components/`.
- `workspace/mobile/components/` must not depend on `screens/`.
- Placeholder-only workspace `check.sh`, `test.sh`, and `smoke.sh` hooks are rejected once real business code exists in that workspace.
- Active baseline feature tests must be grouped by feature instead of hidden in generic catch-all test files.
- Active feature scenario coverage is enforced through the repository's feature test policy instead of hardcoded feature names inside the harness script.

### Documented but still manual

- Whether `runtime/`, handlers, or controllers contain core business logic.
- Whether harness logic has been mixed into business code.
- Whether a new shared boundary has been justified well enough to exist.
- Whether a rule document placed in `docs/` should be promoted into `harness/`.
- Whether each workspace's smoke suite is complete for the current operational baseline and uses enough production realism.

### Natural next candidates for stronger enforcement

- Real testing coverage quality once a workspace enters active feature development.
- API and data contract discipline between runtimes.
- Configuration ownership and environment variable discipline.
- Observability requirements for important runtime paths.

When a manual rule causes repeated mistakes, convert it into a simple check in `harness/checks/`.
