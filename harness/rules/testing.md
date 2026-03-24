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
- Once a feature becomes part of the repository baseline, its tests should be grouped by feature instead of being left in generic catch-all files such as `app.test`, `widget_test`, or equivalent all-purpose buckets.
- Prefer feature-named test locations such as `auth/`, `billing/`, or `profile/` inside the runtime's normal test area.
- Active baseline features and their required scenarios should be declared in a repository-local feature test policy so the harness can verify test presence without hardcoding a specific business feature into the check itself.
- Feature tests should cover the full set of public paths that define the feature's current baseline behavior, not only one happy-path slice of that feature.
- When a feature exposes multiple meaningful user or request paths, the test suite should make those paths explicit instead of relying on one broad smoke test to imply the rest.
- Backend business logic should be validated with unit, integration, or equivalent service-level checks.
- Backend runtime paths should also have complete smoke coverage for startup, dependency wiring, and the full set of critical request paths in the current service baseline.
- Frontend and mobile business logic should be validated with component, interaction, smoke, or equivalent runtime-level checks.
- Frontend and mobile UI work should rely on automated tests rather than visual inspection alone.
- Key UI states, user interactions, form behavior, loading states, and error states should be covered by automated checks when those paths become part of active product code.
- Frontend and mobile interaction regressions should be captured by automated tests so the same issue is easier to catch next time.
- For active baseline features, tests should cover both correct behavior and failure behavior.
- Important edge cases should be tested once they become part of the expected product contract, especially validation boundaries, missing prerequisites, expired state, duplicate input, empty input, and transport or authorization failures.
- A workspace that is under active feature development should not depend only on architecture checks for quality control.

## Smoke testing contract

- Every active runtime workspace must provide a real `smoke.sh`.
- Smoke coverage is not complete unless it exercises the full runtime boot path and every critical product journey required for the workspace to be considered operational.
- `smoke.sh` should stay deterministic and CI-friendly, but it must still be complete enough to catch broken startup, broken wiring, broken navigation, and broken core user flows.
- If a smoke suite boots stateful infrastructure such as a database, cache, queue, or local data directory, it should create an isolated temporary state area for that run instead of reusing a shared development instance.
- Smoke suites must not depend on a developer's long-lived local database or any leftover state from an earlier run.
- Frontend smoke tests must verify app boot, shell render, route or page entry, and the complete set of primary user journeys that define the current product baseline.
- Mobile smoke tests must verify app boot, first-screen render, navigation readiness, and the complete set of primary user journeys that define the current product baseline.
- Backend smoke tests must verify process boot, core dependency wiring, health or readiness behavior when present, and the complete set of critical request paths that define the current service baseline.
- Prefer production-like wiring with minimal fixtures. Keep `smoke.sh` focused on complete baseline operability, and move non-critical edge-case depth into narrower test suites.
- Feature smoke coverage is incomplete if the current baseline feature only verifies a subset of its public journey.
- Scenario completeness for an active feature should be judged against the repository's declared feature test policy rather than ad hoc reviewer memory.
- Complete feature coverage means the repository should exercise success paths, expected failure paths, and important edge conditions across the combined test suite, even when not every one of those cases belongs in `smoke.sh`.

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
- The active baseline features for this repository are declared in `harness/checks/feature_test_policy.json`, and their tests should be visible as first-class testing units in each affected runtime.
