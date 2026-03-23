# Mobile Architecture Rules

This document defines mobile-specific architecture constraints.

## Recommended mobile structure

- `screens/`
- `components/`
- `services/`
- `types/`

Start with this lightweight layered structure inside `workspace/mobile/`. When real features become too scattered across only global layers, evolve inside mobile toward feature-first grouping without changing the repository top level.

## Preferred dependency model

- `types/` defines shared contracts for screens, services, and mobile-side data.
- `services/` handles API calls, device-facing service coordination, or mobile-side data access logic.
- `screens/` compose screen-level flows, navigation-facing logic, and user interaction state.
- `components/` should stay focused on reusable mobile UI building blocks and local presentation behavior.
- `services/` may depend on `types/`.
- `components/` may depend on `types/`, but should not depend on `screens/`.
- `screens/` may depend on `types/`, `services/`, and `components/`.

This is a preferred structure guideline, not a framework mandate. Keep mobile logic easy to follow and avoid unnecessary abstraction.

## Mobile business responsibilities

- `screens/` should own screen-level orchestration.
- `screens/` should coordinate navigation-facing flows, data loading, mutation flows, and screen-level state transitions.
- `screens/` should assemble loading states, error states, empty states, and form-like interaction flows.
- `components/` should focus on reusable mobile presentation and local interaction behavior.
- `components/` should not become the main home of cross-screen business workflows.
- `services/` should be the home of request logic and other mobile-side external side effects.
- Repeated business state or workflow logic should be lifted out of reusable components and coordinated at the screen level.

## Mobile state and side-effect rules

- Keep local UI state close to the component only when it is truly local presentation state.
- Keep screen-level business state in `screens/` or screen-level feature composition logic.
- Do not scatter the same business state across multiple components without a clear owner.
- Do not place request logic directly in reusable UI components.
- Prefer `services/` as the boundary for API calls, device coordination, and external side effects.
- UI should not rely on manual checking alone to validate important interaction flows.

## Mobile layers to add when needed

- `features/`
  - add when a business feature repeatedly spans multiple screens, components, services, and tests and becomes hard to track in only global layers
- `hooks/`
  - add when reusable UI logic, async orchestration, or stateful interaction behavior repeats across screens or components
- `state/`
  - add when long-lived shared mobile state becomes too large to keep only in screen-level state
- `adapters/`
  - add when backend response models or device-facing data need explicit transformation before reaching screen state and rendering

Do not add these layers preemptively. Add them only when they reduce repeated confusion or duplication.

## Mobile prohibitions

- Do not mix frontend web code or backend server code into mobile.
- Do not put backend-only logic into mobile services.
- Do not let `services/` depend on `screens/` or `components/`.
- Do not let reusable `components/` depend on `screens/` or contain screen-level request logic.
- Do not rely on manual visual checking alone for active UI and interaction code.
- Do not let reusable mobile components become the hidden home of unrelated screen workflows.
