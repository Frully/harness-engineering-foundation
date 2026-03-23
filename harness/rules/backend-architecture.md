# Backend Architecture Rules

This document defines backend-specific architecture constraints.

## Recommended backend structure

- `types/`
- `config/`
- `repo/`
- `service/`
- `runtime/`

Start with this lightweight layered structure inside `workspace/backend/`. When backend features become too scattered across global layers, evolve inside backend toward feature-first grouping with clear internal layers, rather than changing the repository top level.

## Preferred dependency direction

`types -> config -> repo -> service -> runtime`

Interpret this as the main dependency flow for backend business code:

- `types/` defines shared types and contracts and should not depend on higher business layers.
- `config/` may depend on `types/`, but should not depend on `repo/`, `service/`, or `runtime/`.
- `repo/` may depend on `types/` and `config/`, but should not depend on `service/` or `runtime/`.
- `service/` may depend on `types/`, `config/`, and `repo/`, but should not depend on `runtime/`.
- `runtime/` may depend on `types/`, `config/`, and `service/`, but should not depend on `repo/` directly.

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
- Do not put core business logic in `runtime/`, handlers, or controllers.
- Do not let `types/` depend on `config/`, `repo/`, `service/`, or `runtime/`.
- Do not let `config/` depend on `repo/`, `service/`, or `runtime/`.
- Do not let `repo/` depend on `service/` or `runtime/`.
- Do not let `service/` depend on `runtime/`.
- Do not let `runtime/` depend on `repo/` directly.
