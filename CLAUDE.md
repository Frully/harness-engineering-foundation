# Claude Code Entry

Read this file before making changes in this repository.

## Hard requirements

- Put business code only under `workspace/`.
- Do not put business logic in the repository root, `docs/`, `deploy/`, or `harness/`.
- After every code change, run `bash harness/scripts/verify.sh`.
- A task is not complete until `bash harness/scripts/verify.sh` passes locally and in CI.

## Detailed rules

Use `harness/AGENTS.md` as the rule index.
Use `harness/rules/` for the detailed architecture, quality, testing, and extension rules.
