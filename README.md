# Harness Engineering Foundation

[简体中文说明](./README.zh.md)

This repository is a foundation for long-term AI-driven product development. It is meant for projects where AI is expected to keep building, modifying, and repairing the product over time.

Its layout stays intentionally small:

- business code lives in `workspace/`
- the AI control layer lives in `harness/`
- product and project documentation lives in `docs/`
- deployment assets live in `deploy/`

The goal is to keep a growing repository understandable, enforceable, and evolvable when AI is one of the main contributors.

## What this foundation is

This repository is a foundation for Harness Engineering, not a framework or a boilerplate-heavy scaffold.

It is designed for teams that want:

- one product repository
- frontend, backend, and mobile in the same project
- an explicit control layer for AI work
- a repeatable way to turn recurring mistakes into shared rules and checks

It does not try to pre-build every future abstraction. It provides a stable repository shape that AI can keep working in without steadily degrading its structure.

## Why this project exists

### Traditional projects

Traditional projects often rely on people to hold the system together:

- engineers remember conventions
- reviewers notice structural drift
- teams carry important rules in tacit knowledge

That model can work when change mostly moves at a human review pace.

### Current AI-driven projects

AI-driven projects run into a different set of problems. AI can move much faster than human review, and it needs much clearer boundaries around its work.

The most important failure modes usually fall into three groups.

Structural boundaries drift:

- code gets placed in the wrong part of the repository
- frontend, backend, and mobile concerns drift into each other
- layer dependencies move in the wrong direction
- the same architectural mistake gets repeated across many files

There is no shared, executable definition of done:

- code changes are treated as complete before required checks have run
- local development and CI do not enforce the same completion boundary
- different humans or agents operate with different ideas of what "done" means

Rule governance stays weak:

- rules remain implicit, so every fix has to be rediscovered by hand

### Harness Engineering

Harness Engineering is the practice of adding an explicit control layer around AI-driven software development.

It separates product code from the rules, checks, scripts, and workflows that keep AI work aligned over time.

With that control layer in place, the repository can make key boundaries explicit:

- where code belongs
- which architectural lines matter
- which checks define completion
- how the repository should respond when the same mistake keeps happening

This project is a concrete foundation for that approach.

## Core design decisions

### Business code and harness are separate

The repository makes a hard distinction between product code and control code.

- `workspace/` is for the product
- `harness/` is for the rules that shape how the product is built

That separation matters because repeated errors often need a repository-level fix, not just another business-code patch. When AI keeps making the same mistake, the long-term fix is often to improve a rule, add a check, strengthen a script, or tighten the quality gate.

### The repository is designed to be readable by both humans and agents

AI can only work from what it can discover in the repository, and humans need the same repository to stay understandable over time.

That means important project knowledge should live in versioned repository artifacts rather than in chat history, memory, or scattered external documents. This foundation therefore favors:

- predictable directory boundaries
- explicit rule locations
- repository-local documentation
- small entry files that point to the right source of truth
- clear boundaries and invariants instead of excessive implementation micromanagement

The goal is to reduce guesswork and keep the working context visible, durable, and reviewable.

### Frontend, backend, and mobile live together but stay separate

This project keeps `frontend/`, `backend/`, and `mobile/` in one repository on purpose.

AI-driven product work often spans multiple runtimes at the same time:

- a backend change affects frontend and mobile behavior
- product documentation should stay close to all runtimes
- rules and checks should apply consistently across the whole product

Keeping them together gives the project one place for product context, coordinated cross-runtime changes, documentation, and quality gates. The runtimes still stay separate inside `workspace/`, so each one keeps a clear boundary.

### Soft constraints and hard constraints work together

Harness Engineering uses two kinds of constraints.

Soft constraints are written guidance for decisions that still involve judgment.

Examples:

- architecture guidance
- design guidance
- copywriting guidance
- responsibilities of pages, services, components, screens, or backend layers

Hard constraints are executable gates for boundaries that can be checked reliably.

Examples:

- architecture check scripts
- lint, formatting, type checks, and tests
- the shared development check entrypoint
- CI enforcing the same gate

Both matter. Soft constraints help AI make better decisions before it drifts. Hard constraints stop AI from silently crossing objective boundaries.

### Structural checks are especially important here

Traditional projects already rely on formatting, lint, type checks, and tests. Those remain necessary here.

AI-driven development adds another kind of risk: code can be locally valid while still pushing the repository in the wrong structural direction.

Typical examples are:

- directory drift
- layer dependency drift
- cross-runtime mixing
- shared-code drift through generic catch-all folders

Traditional checks rarely catch those problems well on their own. That is why this project treats structural checks as first-class quality gates alongside tests, lint, formatting, and type checks.

## Directory design

```text
.
├── AGENTS.md
├── CLAUDE.md
├── deploy/
├── docs/
├── workspace/
│   ├── frontend/
│   ├── backend/
│   └── mobile/
├── harness/
│   ├── AGENTS.md
│   ├── checks/
│   ├── rules/
│   └── scripts/
├── README.md
└── README.zh.md
```

### `workspace/`

This is the main product area.

- `workspace/frontend/` is for web UI and frontend-side logic
- `workspace/backend/` is for backend runtime code and business logic
- `workspace/mobile/` is for mobile UI and mobile-side logic

This keeps product code in one predictable place while still separating runtimes cleanly.

### `harness/`

This is the control layer.

- `harness/AGENTS.md` is the top-level rule index
- `harness/rules/` holds detailed rule documents
- `harness/checks/` holds executable structural checks
- `harness/scripts/` holds development entrypoints and helper scripts

The harness exists so the repository can improve its own guardrails over time.

### `docs/`

This is for product and project documentation.

The harness defines control rules; `docs/` explains the product, decisions, and implementation context.

### `deploy/`

This is for deployment-related assets.

It stays separate from both business code and harness logic so deployment concerns do not become a hidden place for application logic.

### Root files

The root stays intentionally small so project intent stays visible without turning the root into a dumping ground.

## How the project evolves

This foundation starts small on purpose.

It does not assume every future layer, feature grouping, or rule document on day one. The project evolves in response to real pressure:

- when architecture mistakes repeat, strengthen the harness
- when a runtime becomes more complex, add the minimum useful structure inside that runtime
- when a rule becomes objective enough to enforce, turn it into a check

That is why the project favors:

- runtime-first top-level organization
- lightweight initial layering inside each runtime
- new rule files only when they solve repeated, cross-cutting problems

As the product grows, the harness may expand into new rule areas such as design consistency, copywriting, API boundaries, configuration discipline, security, or observability. Those rules should be added only when they solve repeated problems that the current harness no longer covers well.

The project should grow by clarifying boundaries and adding structure only when it is justified.
