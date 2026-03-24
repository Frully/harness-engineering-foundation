# Documentation Rules

This document defines what should be documented in `docs/` and when AI should create or update documentation as part of a change.

## Core rule

- `docs/` is the home for durable project knowledge, product behavior, interface behavior, operating instructions, and architectural decisions that a future reader should be able to learn without reverse-engineering the code.
- `harness/` is the home for durable AI and workflow constraints.
- If a fact is mainly telling future AI what it must do, it belongs in `harness/`.
- If a fact is mainly telling humans and future maintainers how the system works, what it exposes, or how to operate it, it belongs in `docs/`.

## When documentation is required

- Update or add documentation when a change introduces or materially changes a public API, request or response contract, authentication flow, session model, security behavior, deployment path, operational workflow, or testing strategy.
- Update or add documentation when a change creates a new runtime workspace, a new top-level feature baseline, or a new user-visible flow that future work will need to understand.
- Update or add documentation when a cross-runtime contract or shared product behavior changes and the expected behavior is no longer obvious from existing docs.
- Update or add documentation when the code introduces a non-obvious constraint, limitation, or decision that future contributors would otherwise rediscover by reading implementation details.
- Update or add documentation when a new local run path, CI path, smoke path, or release path becomes part of the repository baseline.

## What belongs in docs

- Product and feature behavior summaries.
- Authentication and authorization behavior.
- API and interface contracts.
- Runtime-specific local run instructions.
- Deployment and release instructions.
- Testing strategy, coverage scope, and runner expectations.
- Important architectural decisions that affect future changes across more than one file or runtime.

## What usually does not need docs

- Small internal refactors with no behavior change.
- Pure naming cleanups that do not affect public or operational understanding.
- Mechanical formatting or dependency updates with no meaningful workflow or behavior change.
- Constraints that only exist to control AI behavior and are already captured in `harness/`.

## Documentation shape guidance

- Prefer one focused document per durable topic instead of one large catch-all document.
- Prefer stable topic names such as `docs/auth.md`, `docs/api.md`, `docs/testing-strategy.md`, or `docs/development.md`.
- Keep documents high-signal: describe the contract, behavior, and operational implications, not every implementation detail.
- When behavior differs by runtime, state the shared rule first and then the runtime-specific differences.
- Document names should match their real scope. If a document grows from one runtime or feature into a broader cross-runtime or cross-feature source of truth, rename the file and update all references in the same task instead of leaving a misleading narrow name in place.

## AI responsibilities

- If a task changes durable project knowledge, AI should update the relevant document in the same task rather than leaving docs as a follow-up.
- If no suitable document exists, AI should create the smallest clear document in `docs/` instead of overloading an unrelated file.
- If a detail must exist both as a project explanation and as an AI constraint, put the explanatory version in `docs/` and the normative rule in `harness/`.
