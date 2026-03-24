# Harness Engineering Foundation

[简体中文说明](./README.zh.md)

A runnable reference project showing how to prevent a product from gradually falling apart under AI-driven development.

The project contains a backend, a web frontend, and a mobile client, plus a control layer around them. The control layer uses architecture checks, automated tests, smoke verification, and UI review to ensure every AI change preserves existing structure, behavior, and design. It provides an improvable architectural foundation, not a final solution.

## The problem

When AI is the primary implementation engine, human memory and reviewer vigilance are not enough. AI can move fast, touch many files, and repeat the same structural mistake with perfect consistency. Without boundaries encoded as automated checks, common failures accumulate quickly:

- Code lands in the wrong place; runtime boundaries blur
- Lower-level modules depend on higher-level ones
- Tests stay shallow or fake
- "Done" means different things to different agents and CI jobs
- UI copy and design drift while the code still compiles
- Important knowledge stays trapped in chat history instead of becoming durable

**Harness Engineering** solves this by building an explicit control layer around the product.

## Project structure

| Directory | Responsibility |
|-----------|---------------|
| `workspace/` | Product code only. Backend, frontend, and mobile are kept separate. |
| `harness/` | Control layer: rules, executable checks, shared scripts. |
| `docs/` | Durable project knowledge: system behavior, public contracts, design language. |
| `deploy/` | Deployment assets and release infrastructure. |

Changing `workspace/` changes the product. Changing `harness/` changes the constraints around the product. Changing `docs/` preserves knowledge that future AI runs must read and maintain. When a behavior, contract, or design decision becomes stable, it should be extracted from chat history or code comments into `docs/` so the knowledge outlives the conversation.

## What is enforced

The control layer works at two levels. **Soft constraints** are text rules (`harness/AGENTS.md`, `harness/rules/`) that AI reads before making changes, reducing the chance of mistakes. **Hard constraints** are automated check scripts that reject changes when rules are violated. Soft constraints lower error rates; hard constraints catch what slips through.

### Architecture checks

The harness reads real manifests (`go.mod`, `package.json`, `pubspec.yaml`) and from there ensures dependencies between layers flow in the correct direction, blocks cross-runtime imports, and checks that code is placed in the right location.

### Per-runtime checks

In addition to harness-level architecture checks, each runtime has three of its own check hooks:

| Hook | Purpose |
|------|---------|
| `check.sh` | Fast quality gates: formatting, lint, type checking, static analysis, successful builds. |
| `test.sh` | Feature behavior: unit, component, widget, integration, or API-level tests. |
| `smoke.sh` | Starts real services and runs the full baseline business flows end-to-end. |

The project-wide final gate combines all of the above:

```bash
bash harness/scripts/verify.sh
```

### UI as an engineering constraint

The control layer also governs unified interface design standards and copy guidelines, the frontend as the visual baseline, mobile alignment to the same standards, and screenshot review for new or materially changed UI. Technically valid but visually drifted UI does not pass.

## How the human fits in

The human does not sit at the end of the pipeline catching every AI mistake by hand. The higher-leverage role is:

1. Spot repeated failure modes.
2. Decide what should become a rule, check, workflow, or document.
3. Use AI to implement those improvements in `workspace/`, `harness/`, and `docs/`.

No control layer is perfect from the start. The value of the harness is not in catching every problem on day one, but in encoding each new failure mode into a rule or check so the same class of problem does not recur. Improving the harness is not a side task. It is a central part of development.

## Current demo baseline

The current runnable baseline is a small auth flow covering registration, login, logout, and session restore. It exists to give the harness a real cross-runtime workflow to exercise.
