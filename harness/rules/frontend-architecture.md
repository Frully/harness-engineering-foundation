# Frontend Architecture Rules

This document defines frontend-specific architecture constraints.

## Recommended frontend structure

- `components/`
- `pages/`
- `services/`
- `types/`

Start with this lightweight layered structure inside `workspace/frontend/`. When real features become too scattered across only global layers, evolve inside frontend toward feature-first grouping without changing the repository top level.

## Preferred dependency model

- `types/` defines shared UI and service-facing contracts.
- `services/` handles frontend-side API calls or external data access logic.
- `pages/` compose feature flows, page state, and page-level interaction logic.
- `components/` should stay focused on reusable UI building blocks and local presentation behavior.
- `services/` may depend on `types/`.
- `components/` may depend on `types/`, but should not depend on `pages/`.
- `pages/` may depend on `types/`, `services/`, and `components/`.

This is a preferred structure guideline, not a UI framework mandate. Keep frontend logic easy to follow and avoid unnecessary abstraction.

## Frontend business responsibilities

- `pages/` should own page-level orchestration.
- `pages/` should coordinate data loading, mutation flows, and page-level state transitions.
- `pages/` should assemble loading states, error states, empty states, and form submission flows.
- `components/` should focus on reusable presentation and local interaction behavior.
- `components/` should not become the main home of cross-page business workflows.
- `services/` should be the home of request logic and other frontend-side external side effects.
- Repeated business state or workflow logic should be lifted out of reusable components and coordinated at the page level.

## Frontend state and side-effect rules

- Keep local UI state close to the component only when it is truly local presentation state.
- Keep page-level business state in `pages/` or page-level feature composition logic.
- Do not scatter the same business state across multiple components without a clear owner.
- Do not place request logic directly in reusable UI components.
- Prefer `services/` as the boundary for API calls and external side effects.
- UI should not rely on manual checking alone to validate important interaction flows.

## Frontend layers to add when needed

- `features/`
  - add when a business feature repeatedly spans multiple pages, components, services, and tests and becomes hard to track in only global layers
- `hooks/`
  - add when reusable UI logic, async orchestration, or stateful interaction behavior repeats across pages or components
- `state/`
  - add when long-lived shared client state becomes too large to keep only in page-level state
- `adapters/`
  - add when backend response models need explicit transformation before reaching UI state and rendering

Do not add these layers preemptively. Add them only when they reduce repeated confusion or duplication.

## Frontend prohibitions

- Do not mix backend or mobile code into frontend.
- Do not put backend-only logic into frontend services.
- Do not let `services/` depend on `pages/` or `components/`.
- Do not let reusable `components/` depend on `pages/` or contain page-level request logic.
- Do not rely on manual visual checking alone for active UI and interaction code.
- Do not let reusable UI components become the hidden home of unrelated business workflows.
- Do not introduce `screens/` as a parallel page-container concept in frontend. Use `pages/` consistently.

## Frontend visual direction

- Preserve the current editorial control-room direction unless the task explicitly calls for a redesign.
- Treat the frontend as a warm, tactile, high-trust command surface rather than a generic SaaS dashboard.
- Keep the visual language intentional and distinctive. Do not drift toward interchangeable startup UI patterns.
- Use [docs/product-interface-design.md](/Users/Frully/Projects/harness-engineering-foundation/docs/product-interface-design.md) as the shared cross-runtime design source of truth when changing frontend styling, layout, motion, or copy tone.

## Frontend design constraints

- Frontend must preserve shared identity with the mobile runtime while translating it through web-native layout and interaction patterns.
- Frontend is the current canonical visual reference for the shared product language unless an intentional full redesign says otherwise.
- Frontend styling must use shared design tokens for color, type, spacing, radius, border, shadow, and motion instead of scattering repeated raw values across unrelated components.
- Frontend should preserve the editorial material language: warm paper surfaces, deep ink text, oversized hierarchy, amber-led emphasis, visible borders, restrained but forceful motion, and selective TUI-inspired control grammar.
- Frontend should favor dominant editorial composition over generic centered auth cards or interchangeable dashboard blocks.
- Repeated frontend visual primitives should be promoted into shared runtime styling such as CSS custom properties, theme layers, or reusable structural components instead of being recopied per page.
- If a frontend change introduces a repeated new visual value, a durable component role, or a material shift in tone, update `docs/product-interface-design.md` in the same task.

## Frontend design prohibitions

- Do not revert to generic fonts such as Inter, Arial, Roboto, or default system stacks as the primary visual identity.
- Do not introduce purple-gradient-on-white, default glassmorphism, or generic AI-dashboard styling.
- Do not add visual elements that fight the editorial direction unless the whole direction is being intentionally redesigned.
- Do not let one-off component styling bypass the shared visual tokens and fragment the interface.
