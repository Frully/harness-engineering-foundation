# Backend Architecture Rules

This document defines backend-specific architecture constraints.

## Recommended backend structure

- `types/`
- `config/`
- `repo/`
- `service/`
- `composition/`
- `runtime/`

Start with this lightweight layered structure inside `workspace/backend/`. When backend features become too scattered across global layers, evolve inside backend toward feature-first grouping with clear internal layers, rather than changing the repository top level.

## Preferred dependency structure

Interpret backend dependencies as three coordinated parts, not one linear chain:

- Core business layers: `types -> config -> repo -> service`
- Composition root: `composition -> runtime + types/config/repo/service`
- Runtime edge: `runtime` receives wired dependencies from `composition` and should not import `composition`, `repo`, or `service` directly

- `types/` defines shared types and contracts and should not depend on higher business layers.
- `config/` may depend on `types/`, but should not depend on `repo/`, `service/`, `composition/`, or `runtime/`.
- `repo/` may depend on `types/` and `config/`, but should not depend on `service/`, `composition/`, or `runtime/`.
- `service/` may depend on `types/`, `config/`, and `repo/`, but should not depend on `composition/` or `runtime/`.
- `composition/` is the backend composition root. It may depend on `runtime/`, `types/`, `config/`, `repo/`, and `service/`, and should build the wired objects that make the runtime executable.
- `runtime/` should stay focused on transport and process concerns. It may depend on `types/` and `config/`, but should not import `composition/`, `repo/`, or `service/` directly.

This is the preferred dependency model for backend code. Keep exceptions rare and well justified.

## Backend layers to add when needed

- `integrations/`
  - add when external services, queues, storage providers, or third-party APIs become a recurring concern
- `jobs/`
  - add when async workflows, background processing, or event-driven behavior becomes a first-class part of the backend
- `domain/`
  - add when business rules become too large for a simple `service/` layer and need clearer application or domain separation
- `features/`
  - add when a backend feature repeatedly spans `repo/`, `service/`, and `runtime/` and becomes hard to maintain across only global layers

Do not add these layers preemptively. Add them only when they make the backend easier to understand and maintain.

## Backend prohibitions

- Do not access the database outside `repo/`.
- Do not mix backend composition or dependency wiring into `repo/`, `service/`, or `runtime/`. Keep that code in `composition/`.
- Do not put core business logic in `runtime/`, handlers, or controllers.
- Do not let `types/` depend on `config/`, `repo/`, `service/`, `composition/`, or `runtime/`.
- Do not let `config/` depend on `repo/`, `service/`, `composition/`, or `runtime/`.
- Do not let `repo/` depend on `service/`, `composition/`, or `runtime/`.
- Do not let `service/` depend on `composition/` or `runtime/`.
- Do not let `runtime/` depend on `composition/`, `repo/`, or `service/` directly.
