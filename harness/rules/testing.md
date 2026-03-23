# Testing Rules

This document defines the minimum testing expectations for business code in the repository.

## Core rule

- Business code should not rely on architecture checks alone.
- When a workspace carries real product code, it should also carry real validation for that code.
- `check.sh` and `test.sh` are the standard workspace entrypoints for that validation.
- Placeholder hooks are acceptable only before a workspace contains real business code.
- Once real business code exists, placeholder-only hooks should be replaced by real checks and tests.

## Business code expectations

- New business logic should come with the smallest useful validation for that logic.
- Bug fixes should add or improve a test that helps catch the same regression next time.
- Backend business logic should be validated with unit, integration, or equivalent service-level checks.
- Frontend and mobile business logic should be validated with component, interaction, smoke, or equivalent runtime-level checks.
- Frontend and mobile UI work should rely on automated tests rather than visual inspection alone.
- Key UI states, user interactions, form behavior, loading states, and error states should be covered by automated checks when those paths become part of active product code.
- Frontend and mobile interaction regressions should be captured by automated tests so the same issue is easier to catch next time.
- A workspace that is under active feature development should not depend only on architecture checks for quality control.

## Workspace testing contract

- `check.sh` should be the default workspace entrypoint for linting, type checks, or build validation.
- `test.sh` should be the default workspace entrypoint for unit, integration, smoke, or equivalent runtime tests.
- Keep each hook simple and deterministic.
- Make failures actionable and return a non-zero exit code on failure.

## Testing growth rule

- Start with the smallest real test that provides useful protection.
- Prefer one real regression test over broad but low-signal test scaffolding.
- When a problem repeats, strengthen the relevant test coverage instead of relying only on manual caution.

## Current repository state

- `bash harness/scripts/dev.sh` runs all available workspace `check.sh` and `test.sh` hooks.
- If a workspace does not yet have meaningful real tests, treat that as unfinished quality coverage rather than a completed testing strategy.
