# Shared Code Rules

This document defines how shared code should be handled in the repository.

## Default rule

- Do not introduce cross-runtime shared code by default.
- Keep frontend, backend, and mobile code separate unless a shared boundary is explicit, stable, and worth maintaining.
- Do not create new root-level shared code areas as an ad hoc shortcut.

## Forbidden shared directory drift

The following generic shared-code directory patterns are forbidden by default:

- `shared/`
- `common/`
- `core/`
- `base/`

This applies at the repository root and directly under `workspace/`.

These names are intentionally blocked because AI tends to use them as catch-all buckets, which quickly leads to unclear ownership and mixed responsibilities.

## If cross-runtime sharing becomes necessary

- Do not add cross-runtime sharing casually.
- First decide whether the code is truly stable across runtimes.
- If cross-runtime sharing is justified, update the harness first so the shared boundary is explicit and documented.
- Until that harness update exists, assume that cross-runtime shared code is not allowed.

## Required path for approved sharing

If cross-runtime sharing is approved, use a harness update before adding the code itself.

That harness update should do all of the following:

- define the exact directory name to use
- define which runtimes may depend on it
- define what kinds of code are allowed there
- define what kinds of business logic must remain outside it
- update checks if a simple automated boundary is possible

Do not invent the directory name at implementation time. The shared location should be named and documented by the harness first.

## What should usually stay unshared

- runtime-specific business logic
- UI flow logic
- backend-only service logic
- mobile-only device logic
- frontend-only rendering logic

## What may eventually justify explicit sharing

- stable cross-runtime contracts
- clearly versioned data shapes
- carefully bounded adapters or translators

Even in those cases, add the shared area only after the harness defines its name, scope, and allowed contents.
