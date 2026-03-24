# Harness Rules

This file defines the working rules for AI and humans in this repository.
Root `AGENTS.md` and `CLAUDE.md` are entry files for agent discovery. This file is the rule index and top-level harness contract.

## 1. Code placement rules

- All business code must live under `workspace/`.
- Frontend code goes in `workspace/frontend/`.
- Backend code goes in `workspace/backend/`.
- Mobile code goes in `workspace/mobile/`.
- Documentation belongs in `docs/`.
- Deployment-related files belong in `deploy/`.
- Do not create business logic files in the repository root.

## 2. Harness modification rules

- AI is allowed to modify `harness/`.
- If the same class of mistake appears repeatedly, prefer improving `harness/` instead of repeatedly patching business code only.
- Changes to rules, checks, and scripts should stay simple, clear, and explainable.
- If a document in `docs/` starts acting like a durable AI behavior rule, move or mirror the normative rule into `harness/`.

## 3. Cross-runtime architecture rules

- Keep the repository root minimal.
- The root may contain discovery files such as `AGENTS.md`, `CLAUDE.md`, the project `README.md`, platform CI config, and top-level folders.
- Do not place business logic, feature code, or app runtime files in the root.
- `workspace/` is the only area for product and application code.
- Keep the top-level business layout runtime-first: `frontend/`, `backend/`, and `mobile/` stay separate at the top level.
- Do not replace the top-level runtime split with a repository-wide feature-first layout.
- `harness/` is the control layer for AI and development workflow.
- `docs/` is for project and business documentation, not AI rule enforcement.
- `deploy/` is for deployment-related assets only.
- Do not mix frontend, backend, and mobile code across runtime directories.
- Do not mix harness logic into business code.
- Do not put business code into `docs/` or `deploy/`.
- Within a runtime, start with the smallest useful layered structure and evolve toward feature-first organization only when repeated feature complexity justifies it.
- Do not create root-level `shared/`, `common/`, or equivalent cross-runtime code areas by default. Add cross-runtime sharing only when the shared boundary is explicit and durable.

## 4. Rule precedence

When multiple rule sources apply, use this order:

1. Root `AGENTS.md` and `CLAUDE.md` for discovery-time entry constraints.
2. `harness/AGENTS.md` for repository-wide harness contract.
3. Topic-specific files under `harness/rules/` for detailed expectations.
4. Executable checks and scripts under `harness/checks/` and `harness/scripts/` for enforced gates.

If two sources appear inconsistent, prefer the more specific source unless an executable check defines the active enforced boundary.

## 5. Definition of done

Use `harness/rules/quality.md` as the source of truth for the full definition of done and the quality gate.
Follow the default development order in `harness/rules/workflow.md` unless a task clearly requires a justified exception.

## 6. Detailed rule files

- Backend-specific architecture: `harness/rules/backend-architecture.md`
- Frontend-specific architecture: `harness/rules/frontend-architecture.md`
- Mobile-specific architecture: `harness/rules/mobile-architecture.md`
- Documentation ownership and update expectations: `harness/rules/documentation.md`
- Copywriting rules for user-facing UI text: `harness/rules/copywriting.md`
- Shared-code policy and drift prevention: `harness/rules/sharing.md`
- Default development order and working method: `harness/rules/workflow.md`
- Quality loop, checks, CI boundary, and current rule coverage: `harness/rules/quality.md`
- Testing baseline and placeholder-to-real-test transition: `harness/rules/testing.md`
- Harness growth model and how to add new rules or checks: `harness/rules/extensions.md`

Read the relevant detailed rule files before making structural or harness changes.
