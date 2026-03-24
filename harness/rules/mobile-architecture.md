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

## Mobile visual direction

- Preserve the current editorial control-room direction unless the task explicitly calls for a redesign.
- Treat mobile as the handheld expression of the same warm, tactile, high-trust command surface used on web.
- Keep the visual language intentional and distinctive. Do not drift toward generic default mobile-auth or dashboard styling.
- Use [docs/product-interface-design.md](/Users/Frully/Projects/harness-engineering-foundation/docs/product-interface-design.md) as the shared cross-runtime design source of truth when changing mobile styling, layout, motion, or copy tone.

## Mobile design constraints

- Mobile must preserve shared identity with the web runtime while translating it through handheld density and stacked composition.
- Mobile should treat the current web runtime as the canonical visual reference and converge toward its hierarchy, surface grammar, command language, and token usage.
- Mobile styling must use shared design tokens for color, type, spacing, radius, border, shadow, and motion instead of scattering repeated raw values across unrelated screens and components.
- Mobile should preserve the editorial material language: warm paper surfaces, deep ink text, oversized hierarchy, amber-led emphasis, visible borders, restrained but forceful motion, and selective TUI-inspired control grammar.
- Mobile should preserve narrative-first hierarchy instead of collapsing into default platform-auth or dashboard styling.
- Mobile should not invent a second near-match visual language. If web and mobile feel merely similar but not clearly of one system, mobile is too far from the reference.
- Repeated mobile visual primitives should be promoted into shared runtime styling such as theme constants, theme extensions, or reusable structural components instead of being recopied screen by screen.
- If a mobile change introduces a repeated new visual value, a durable component role, or a material shift in tone, update `docs/product-interface-design.md` in the same task.

## Mobile design prohibitions

- Do not revert to generic fonts such as Inter, Arial, Roboto, SF Pro defaults, or default system stacks as the primary visual identity.
- Do not introduce default Material-looking auth screens, list-heavy dashboard styling, or other out-of-the-box mobile UI aesthetics without deliberate restyling.
- Do not add visual elements that fight the editorial direction unless the whole direction is being intentionally redesigned.
- Do not let one-off screen styling bypass the shared visual tokens and fragment the cross-runtime interface.
