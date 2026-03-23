# Quality Gate Rules

This document defines the repository quality gate and completion boundary.

## Quality gate

- After every code change, run `bash harness/scripts/dev.sh` before considering the task complete.
- If a workspace has its own `check.sh` or `test.sh`, `harness/scripts/dev.sh` must run it as part of the default loop.
- Do not skip a failing check or test by removing it unless the harness itself is being intentionally redesigned and the change is explained.
- Placeholder workspace hooks are allowed only while the workspace has no real business code yet.
- Once a workspace starts carrying real business code, placeholder hooks are no longer acceptable and the quality gate should fail until real checks and tests replace them.
- CI should call the same `bash harness/scripts/dev.sh` entrypoint instead of duplicating logic in platform-specific config.
- If `dev.sh` or required workspace hooks fail, the change is not complete.
- If CI fails on the same entrypoint, the change is not complete even if the local edit appears correct.
- If architecture violations happen repeatedly, update the checks or rules in `harness/`.
- Once a workspace enters real feature development, treat real `check.sh` and `test.sh` coverage as part of the repository baseline for that workspace, not as an optional follow-up.

## Definition of done

- The default development order in `harness/rules/workflow.md` has been followed unless the task required a justified exception.
- The code is placed in the correct directory.
- `bash harness/scripts/dev.sh` has been run after the latest edit.
- `bash harness/scripts/dev.sh` exits successfully.
- Any available workspace `check.sh` and `test.sh` hooks pass.
- If a workspace contains real business code, its `check.sh` and `test.sh` must not remain placeholder-only hooks.
- If a repeated mistake is detected, prefer improving `harness/` so the mistake is easier to prevent next time.

## Rule coverage

### Automated today

- No business source files in the repository root.
- No business source files in `docs/`.
- No business source files in `deploy/`.
- Forbidden generic shared-code directories are not allowed at the repository root or directly under `workspace/`.
- `workspace/backend/service/` must not implement direct database access.
- `workspace/backend/runtime/` must not depend on `repo/` directly.
- `workspace/backend/repo/` must not depend on `service/` or `runtime/`.
- `workspace/backend/config/` must not depend on `repo/`, `service/`, or `runtime/`.
- `workspace/backend/types/` must not depend on higher backend layers.
- `workspace/frontend/` must not import backend or mobile code directly.
- `workspace/frontend/services/` must not depend on `pages/` or `components/`.
- `workspace/frontend/components/` must not depend on `pages/`.
- `workspace/mobile/` must not import backend or frontend code directly.
- `workspace/mobile/services/` must not depend on `screens/` or `components/`.
- `workspace/mobile/components/` must not depend on `screens/`.
- Placeholder-only workspace hooks are rejected once real business code exists in that workspace.

### Documented but still manual

- Whether `runtime/`, handlers, or controllers contain core business logic.
- Whether harness logic has been mixed into business code.
- Whether a new shared boundary has been justified well enough to exist.
- Whether a rule document placed in `docs/` should be promoted into `harness/`.

### Natural next candidates for stronger enforcement

- Real testing coverage quality once a workspace enters active feature development.
- API and data contract discipline between runtimes.
- Configuration ownership and environment variable discipline.
- Observability requirements for important runtime paths.

When a manual rule causes repeated mistakes, convert it into a simple check in `harness/checks/`.
