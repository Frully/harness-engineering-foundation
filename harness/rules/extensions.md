# Harness Extension Rules

This document defines how `harness/` should grow over time.

## Evolution principle

`harness/` is expected to evolve. Add new harness files when they reduce repeated mistakes, make AI behavior more consistent, or make review and validation easier.
The current rule set is intentionally minimal, not exhaustive. Add new topic-specific rule files only when a recurring problem justifies them.

## Constraint categories

### Soft constraints

- Use soft constraints when the rule is important but not safely machine-checkable yet.
- Soft constraints should guide AI choices, naming, structure, style, copywriting, and design decisions.
- Typical examples:
  - frontend design style guidance
  - mobile design style guidance
  - frontend architecture guidance
  - backend architecture guidance
  - mobile architecture guidance
  - copywriting and UI text guidance

### Hard constraints

- Use hard constraints when the rule can be checked reliably and should block incorrect changes.
- Hard constraints should be executable and should fail with clear messages.
- Typical examples:
  - architecture checks
  - lint, typecheck, build validation
  - unit, integration, or smoke tests
  - CI gates that call the shared harness entrypoint

## Where new harness files should go

- Put durable rule documents under `harness/` as part of the control layer.
- Keep executable checks in `harness/checks/`.
- Keep helper entrypoints and orchestration scripts in `harness/scripts/`.
- If additional rule documents are needed, prefer a simple subdirectory such as `harness/rules/`.
- Keep the structure minimal. Add a new folder only when it clearly improves clarity.
- Do not treat `docs/` as the primary home for durable AI behavior rules. If a rule is meant to constrain future AI runs, it belongs in `harness/` even if `docs/` also references it.

## Minimum recommended rule document types

- Design guidance:
  - example purpose: constrain frontend and mobile visual and interaction style
  - suggested location: `harness/rules/design.md`
- Architecture guidance:
  - example purpose: define per-runtime architectural expectations and layering rules
  - suggested location: `harness/rules/frontend-architecture.md`
  - suggested location: `harness/rules/backend-architecture.md`
  - suggested location: `harness/rules/mobile-architecture.md`
- Copywriting guidance:
  - example purpose: constrain UI wording, tone, and message style
  - suggested location: `harness/rules/copywriting.md`

Other rule files may also be added when needed, such as testing guidance, API/interface guidance, configuration guidance, dependency policy, security guidance, or observability guidance. Add them only when the problem is recurring, cross-cutting, and worth maintaining as a durable rule.

These documents are soft constraints by default. Promote them into hard checks only when repeated mistakes justify automation and the check can remain simple.

## Future rule candidates

The list below is not a mandatory roadmap. It is a set of likely future rule areas that may become worth adding as the project grows.

- `harness/rules/design.md`
  - for frontend and mobile visual style, interaction style, and layout consistency
- `harness/rules/copywriting.md`
  - for UI wording, tone, and message consistency
- `harness/rules/api.md`
  - for request and response boundaries, adapters, and client/server contract handling
- `harness/rules/config.md`
  - for environment variables, configuration ownership, and secret handling
- `harness/rules/observability.md`
  - for logging, error reporting, metrics, and tracing expectations
- `harness/rules/security.md`
  - for authentication, authorization, validation, and sensitive data handling
- `harness/rules/naming.md`
  - for naming consistency across files, directories, modules, and runtime concepts

Add one of these only when it solves a repeated problem that the current rules no longer cover well.

## Minimum recommended executable constraint types

- Architecture checks in `harness/checks/`
- Workflow and orchestration scripts in `harness/scripts/`
- Workspace-specific `check.sh` and `test.sh` hooks inside each workspace
- CI configuration outside `harness/`, but always calling `bash harness/scripts/dev.sh`

## How to choose the right constraint type

- Add a soft constraint first when the issue is subjective, stylistic, semantic, or still changing.
- Add a hard constraint when the issue is objective, repeated, and cheap to verify automatically.
- Upgrade a soft constraint into a hard constraint when the same violation keeps recurring and the automated check has acceptable false-positive risk.
- Do not force every rule into a script. Prefer the simplest constraint that reliably improves behavior.

## New harness file workflow

1. Identify the repeated problem.
2. Decide whether the problem is best addressed as a soft constraint, a hard constraint, or both.
3. Add the smallest possible harness artifact that solves the problem.
4. Write the rule in plain language and keep the scope explicit.
5. Record why the new rule exists in the rule document itself so future readers can understand the repeated failure it is meant to prevent.
6. If the rule is machine-checkable, add or extend a script in `harness/checks/`.
7. If the rule should run by default, connect it to `bash harness/scripts/dev.sh`.
8. If failure should block integration, keep CI calling the same shared entrypoint.
9. Update rule documentation so the new constraint is discoverable by future AI runs.

## Rules for adding harness constraints

- Prefer modifying an existing rule file before creating a new one when the topic already has a clear home.
- Prefer one small check over a large framework.
- Every hard constraint must produce clear failure output and a non-zero exit code on failure.
- Every new hard constraint should explain what it protects and where the fix should happen.
- Every new rule file should briefly explain what repeated problem caused it to be added.
- Do not put business-specific implementation details into harness unless they are genuinely cross-cutting constraints.
- Do not duplicate the same rule in multiple files unless one file is only a short discovery entrypoint.
- Do not introduce new structural layers just because they are common in other projects. Add a new layer only when a repeated problem clearly justifies it.
