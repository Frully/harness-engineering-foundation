# Testing Rules

This document defines the minimum testing expectations for business code in the repository.

## Core rule

- Business code should not rely on architecture checks alone.
- When a workspace carries real product code, it should also carry real validation for that code.
- `check.sh`, `test.sh`, and `smoke.sh` are the standard workspace entrypoints for that validation.
- Placeholder hooks are acceptable only before a workspace contains real business code.
- Once real business code exists, placeholder-only hooks should be replaced by real checks and tests.

## Business code expectations

- New business logic should come with the smallest useful validation for that logic.
- Bug fixes should add or improve a test that helps catch the same regression next time.
- Backend business logic should be validated with unit, integration, or equivalent service-level checks.
- Backend runtime paths should also have complete smoke coverage for startup, dependency wiring, and the full set of critical request paths in the current service baseline.
- Frontend and mobile business logic should be validated with component, interaction, smoke, or equivalent runtime-level checks.
- Frontend and mobile UI work should rely on automated tests rather than visual inspection alone.
- Key UI states, user interactions, form behavior, loading states, and error states should be covered by automated checks when those paths become part of active product code.
- Frontend and mobile interaction regressions should be captured by automated tests so the same issue is easier to catch next time.
- A workspace that is under active feature development should not depend only on architecture checks for quality control.

## Smoke testing contract

- Every active runtime workspace must provide a real `smoke.sh`.
- Smoke coverage is not complete unless it exercises the full runtime boot path and every critical product journey required for the workspace to be considered operational.
- `smoke.sh` should stay deterministic and CI-friendly, but it must still be complete enough to catch broken startup, broken wiring, broken navigation, and broken core user flows.
- Frontend smoke tests must verify app boot, shell render, route or page entry, and the complete set of primary user journeys that define the current product baseline.
- Mobile smoke tests must verify app boot, first-screen render, navigation readiness, and the complete set of primary user journeys that define the current product baseline.
- Backend smoke tests must verify process boot, core dependency wiring, health or readiness behavior when present, and the complete set of critical request paths that define the current service baseline.
- Prefer production-like wiring with minimal fixtures. Keep `smoke.sh` focused on complete baseline operability, and move non-critical edge-case depth into narrower test suites.

## Workspace testing contract

- `check.sh` should be the default workspace entrypoint for linting, type checks, or build validation.
- `test.sh` should be the default workspace entrypoint for unit, integration, smoke, or equivalent runtime tests.
- `smoke.sh` should be the default workspace entrypoint for complete smoke coverage of the runtime's operational baseline.
- Keep each hook simple and deterministic.
- Make failures actionable and return a non-zero exit code on failure.

## Testing growth rule

- Start with the smallest real test that provides useful protection.
- Prefer one real regression test over broad but low-signal test scaffolding.
- When a problem repeats, strengthen the relevant test coverage instead of relying only on manual caution.

## Current repository state

- `bash harness/scripts/dev.sh` runs all available workspace `check.sh`, `test.sh`, and `smoke.sh` hooks.
- If a workspace does not yet have meaningful real tests, treat that as unfinished quality coverage rather than a completed testing strategy.
