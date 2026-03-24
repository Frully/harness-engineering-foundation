# Product Interface Design Direction

This document defines the shared visual system for the product interface across web and mobile.

It exists to preserve the design point of view as the product evolves so future UI work does not drift back toward generic dashboard, auth-template, or default mobile-app styling.

## Scope

This document is the shared source of truth for:

- product interface mood
- cross-runtime visual identity
- core design principles
- shared design tokens
- component-role expectations
- redesign boundaries

This document does not try to define:

- marketing-site design
- illustration systems outside the product shell
- pixel-perfect parity between web and mobile
- every implementation detail of every component

## Design Thesis

The product interface should feel like a tactile terminal command chamber rather than a commodity SaaS shell.

The interface is not trying to look merely tasteful, neutral, or template-polished. It should feel:

- warm
- tactile
- precise
- composed
- dominant
- dramatic
- technically literate

The memorable trait is the contrast between:

- a paper-and-ink editorial atmosphere
- a TUI-inspired control grammar
- monumental information hierarchy
- a modern authenticated control surface with ceremonial weight

That tension is the identity.

## Experience Goals

The interface should communicate:

- trust without looking sterile
- operational clarity without looking corporate
- craftsmanship without looking decorative for its own sake

A user should remember:

- the parchment-like environment
- the oversized serif headlines
- the amber command accents
- the sense of entering a live desk with authority, not a template
- the feeling that the interface is operated, not merely browsed

## Core Principles

- Shared identity matters more than literal layout parity.
- The interface should feel editorial, not app-store generic.
- Warmth should come from controlled materials and typography, not novelty effects.
- Bold hierarchy is required. The interface should have a clear dominant visual beat, not evenly weighted modules.
- A narrow palette is still preferred, but it should be used with stronger contrast and more decisive emphasis.
- Panels and shells should feel architectural and curated, not template-driven.
- Calm does not mean timid. The product should feel composed and forceful at the same time.
- TUI influence should show up in structure, labeling, state clarity, and data rhythm, not in fake terminal cosplay.
- Geek fluency must never reduce usability. Inputs, navigation, focus states, and task completion should remain modern and accessible.
- Repeated visual values should become tokens rather than remain scattered magic numbers.

## Runtime Translation

The design language is shared across web and mobile, but each runtime should express it through its native strengths.

### Web

- Use unapologetically strong asymmetry and editorial split layouts.
- Let monumental type, atmospheric backgrounds, panel layering, and command-pane segmentation carry much of the identity.
- Express hierarchy through hero-versus-utility separation, scale contrast, and areas of intentional emptiness.
- Use terminal-like partitioning, status bars, and instrument labels where they sharpen orientation.

### Mobile

- Preserve the same editorial mood in a denser handheld form.
- Translate split layouts into stacked sections with strong opening hierarchy and sectional drama.
- Keep the same material system, color mood, and type roles even when the composition becomes linear.
- Use compact control groups, status blocks, and command-like labels without making the screen feel cramped or retro-gimmicky.

### Consistency rule

- Web and mobile should share identity, not literal layout parity.
- The web runtime is the canonical visual reference for the product language.
- Mobile should translate the web reference into handheld interaction, not reinterpret it into a second near-match style.
- If a value or pattern must diverge by runtime, keep the role, hierarchy, and material intent the same even if the exact measurement changes.
- Avoid "close but different" drift such as matching palette but changing surface grammar, matching copy tone but changing hierarchy, or matching token names but inventing a different component language.

## Visual System

### Tone

- Editorial, not app-store generic
- Warm, not cold
- Human, not toy-like
- Dramatic, not polite
- Modern, but with print, archive, terminal, and command-room references

### Spatial model

- Use a two-part composition when the screen allows it: one expressive narrative panel and one utility or form panel.
- Prefer asymmetry over perfectly centered sameness.
- Use dominant-vs-supporting scale contrast rather than evenly weighted sections.
- Keep generous breathing room around major content blocks, but let negative space feel deliberate and cinematic rather than merely spacious.
- Let important panels feel architectural through padding, border, depth, and overlap pressure.
- Use pane logic, rails, and sectional separation to make the interface feel operated and inspectable.
- Web may express this most clearly through split panels.
- Mobile should preserve the same hierarchy through stacked sections, spacing rhythm, and panel contrast instead of copying desktop layout literally.

### Surface model

- Backgrounds should feel layered, atmospheric, and slightly theatrical.
- Use parchment, dust, radial washes, pressure gradients, and faint grid or print textures rather than flat color fills.
- Panels should read as physical sheets or command plates above the background rather than opaque blocks.
- Borders should stay visible and refined, but with enough contrast to define structure from a distance.
- Surface treatment may borrow from terminal panes, console housings, and instrument plates, but should stay premium and readable.

### Shape language

- Use large radii for primary shells and cards.
- Keep controls rounded but not bubbly.
- Favor elongated pills for primary actions and compact rounded rectangles for fields and status modules.
- Primary surfaces should feel substantial and wide-shouldered rather than delicate.
- Secondary surfaces may be a bit more squared-off or plate-like when doing so strengthens the TUI grammar.
- Mobile controls may use slightly tighter spacing, but should not fall back to default Material-looking geometry.

### Typography

- Display typography should use a serif with visible character and editorial authority.
- Body typography should use a clean but not overused sans.
- Command, status, and data-heavy areas should use a restrained monospace layer.
- Avoid default startup typography.
- Headlines should carry dramatic weight, strong scale jumps, and tight line-height.
- Supporting copy should stay quieter and more linear.
- Small labels should use uppercase tracking for instrument-panel flavor.
- Code or API references may inherit the display family when doing so strengthens the editorial tone.
- Mobile may reduce display scale, but should preserve the same type-role contrast.

### Color

- The palette should remain narrow and disciplined.
- Use paper background tones, deep ink text, burnt amber accents, and one muted cool counterweight.
- Accent color should be concentrated in actions, focus, and high-importance structural emphasis.
- Do not distribute many competing accent colors across the interface.
- Neutral text should remain warm rather than pure gray.
- Contrast should be assertive enough that the interface reads from a distance and from a glance.
- Darker command surfaces, status strips, or inset modules are allowed when they create stronger control contrast without collapsing into hacker cliché.
- Error states should be readable and integrated, not violently saturated.

### Motion

- Motion should be sparse, deliberate, and high-impact.
- Prefer page-load staging, panel transitions, reveal sequences, and strong state confirmations.
- Avoid playful bounce, high-frequency micro-motion, or motion that competes with task completion.
- Motion should support command presence, not novelty.
- State changes should feel like mode switches, reveals, and confirmations rather than soft decorative fades.

### Copy tone

- Keep copy confident and specific.
- Avoid over-cheerful product voice.
- Favor phrases that support the editorial-console identity.
- Prefer language with authority and intent over generic product blandness.
- Short command-like labels and operator-facing cues are encouraged when they improve clarity.
- Labels and supporting copy should feel deliberate, not placeholder-generic.

## Design Tokens

These tokens define the shared base system. Web and mobile should implement equivalents even when the syntax differs.

### Color tokens

- `paper.base`
  - role: main parchment surface
  - target value: `#F5EBDD`
- `paper.wash`
  - role: lighter paper highlight and gradient lift
  - target value: `#FFF9EF`
- `paper.deep`
  - role: warmer secondary background depth
  - target value: `#EADCC9`
- `ink.base`
  - role: primary text
  - target value: `#1A120F`
- `ink.muted`
  - role: secondary text
  - target value: `rgba(26, 18, 15, 0.72)`
- `line.soft`
  - role: panel and field border
  - target value: `rgba(26, 18, 15, 0.18)`
- `accent.primary`
  - role: primary actions and focus emphasis
  - target value: `#C3561B`
- `accent.primary.deep`
  - role: darker action gradient or pressed state
  - target value: `#8F3810`
- `accent.primary.light`
  - role: lifted amber gradient or secondary accent
  - target value: `#E08F49`
- `accent.soft`
  - role: subtle accent background
  - target value: `rgba(195, 86, 27, 0.14)`
- `accent.cool`
  - role: secondary atmospheric counterweight only
  - target reference tone: `rgba(36, 70, 118, 0.18)`
- `surface.card`
  - role: elevated card fill
  - target value: `rgba(255, 250, 242, 0.84)`
- `surface.command`
  - role: darkened command strip, status plate, or inset control area
  - target value: `rgba(27, 20, 18, 0.88)`
- `surface.command.text`
  - role: foreground on command surfaces
  - target value: `#F7EEDD`
- `state.error.bg`
  - role: error surface fill
  - current value: `rgba(173, 33, 33, 0.08)`
- `state.error.border`
  - role: error outline
  - current value: `rgba(173, 33, 33, 0.24)`
- `state.error.text`
  - role: error copy
  - current value: `#882D17`

### Type tokens

- `font.display`
  - role: display family
  - current family: `Fraunces`
- `font.body`
  - role: body family
  - current family: `IBM Plex Sans`
- `font.mono`
  - role: command, status, and data family
  - target family: `IBM Plex Mono`
- `type.display.hero`
  - role: primary shell headline
  - web target: `clamp(3.4rem, 5vw, 6.4rem)`
  - mobile target: `42px-48px`
  - line-height target: `0.88-0.98`
- `type.body.base`
  - role: default explanatory copy
  - target size: `1rem-1.05rem`
  - line-height target: `1.5-1.6`
- `type.label.instrument`
  - role: small uppercase metadata label
  - target size: `0.72rem-0.78rem`
  - letter-spacing target: `0.24em-0.3em`
- `type.small.meta`
  - role: footer, support, and helper copy
  - target size: `0.92rem-0.95rem`

### Spacing tokens

- `space.2`
  - value: `0.5rem`
- `space.3`
  - value: `0.75rem`
- `space.4`
  - value: `1rem`
- `space.6`
  - value: `1.5rem`
- `space.8`
  - value: `2rem`
- `space.10`
  - value: `2.5rem`
- `space.12`
  - value: `3rem`

Use these as role tokens, not as a command to force one exact numeric scale in every implementation. Mobile may compress one step where density requires it, but should stay on the same rhythm.

### Radius tokens

- `radius.field`
  - current reference: `1rem`
- `radius.section`
  - target reference: `1.5rem`
- `radius.panel`
  - target reference: `2rem`
- `radius.shell`
  - target mobile reference: `30px`
- `radius.pill`
  - current reference: `999px`

### Border and shadow tokens

- `border.default`
  - role: standard panel and field border
  - use `1px solid line.soft` or the equivalent runtime token
- `border.command`
  - role: command strip or inset module border
  - target reference: `1px solid rgba(247, 238, 221, 0.12)`
- `shadow.panel`
  - role: primary panel depth
  - target web reference: `0 32px 96px rgba(46, 27, 13, 0.16)`
- `shadow.action`
  - role: primary action depth
  - target web reference: `0 20px 42px rgba(143, 56, 16, 0.32)`
- `blur.surface`
  - role: glass-like surface lift when appropriate
  - target web reference: `18px`

### Motion tokens

- `motion.fast`
  - default: `170ms`
  - allowed range: `150ms-190ms`
  - use for: hover, focus, and small state feedback
- `motion.base`
  - default: `280ms`
  - allowed range: `250ms-320ms`
  - use for: panel transitions, form state changes, and view swaps
- `motion.slow`
  - default: `460ms`
  - allowed range: `420ms-520ms`
  - use for: page-load staging, shell-level transitions, and dramatic section reveals
- `easing.standard`
  - default: `cubic-bezier(0.22, 1, 0.36, 1)`
  - use for: most entrances and state transitions
- `easing.exit`
  - default: `cubic-bezier(0.4, 0, 1, 1)`
  - use for: restrained exit motion
- `stagger.base`
  - default: `55ms`
  - allowed range: `40ms-75ms`
  - use for: small staged entrances across sibling elements
- `motion.reduced`
  - default behavior: disable non-essential staged motion and reduce transitions to the minimum needed for state clarity

### Density tokens

- `density.command`
  - role: compact status, metrics, and operator metadata blocks
  - target: tighter than base content, but never so dense that touch or scanability suffers

## Component Roles

These define the current expected component-level roles. New components should map to one of these roles before inventing new styling language.

### Shell

- role: outermost page or screen environment
- background: layered paper field with warm radial pressure and one cool atmospheric counterweight
- padding desktop target: `2.25rem-3rem`
- padding mobile target: `24px-28px`
- gap target: `1.5rem-2rem`

### Panel

- role: primary structural block for auth, dashboard, or status content
- fill: translucent paper or card fill with stronger edge definition
- border: shared border token
- primary web padding target: `3rem-3.5rem`
- secondary web padding target: `2rem-2.4rem`
- mobile padding target: `28px-32px`
- may contain inset command strips, status bars, or instrument rows

### Field

- role: text input and direct form interaction surface
- padding reference: `0.95rem 1rem`
- radius reference: `1rem`
- focus treatment: softened amber emphasis rather than default blue unless accessibility requires a platform override

### Button

- role: primary action trigger
- padding target: `0.95rem 1.6rem`
- fill: amber-led gradient with clear tonal pressure
- text: light paper-toned foreground
- radius: pill geometry

### Chip or status rail item

- role: compact metadata, mode, or status indicator
- padding reference: `0.75rem 0.9rem`
- fill: soft translucent paper highlight
- border: shared border token

### Command strip

- role: compact mode, state, or operator context band
- background: command surface token or equivalent high-contrast inset surface
- text: monospace or instrument-label treatment
- behavior: should improve orientation and data legibility, not become decorative chrome

## Do / Don’t

### Do

- preserve the editorial command-chamber identity
- use shared tokens before inventing new raw values
- keep web and mobile visibly related
- preserve warm paper surfaces, oversized hierarchy, and amber-led action emphasis
- use monospace and command-strip grammar selectively to strengthen operator clarity
- update this document when shared visual roles or tokens change

### Don’t

- revert to plain white app shells with no atmosphere
- introduce purple-first gradient branding
- use generic startup fonts as the primary identity
- scatter one-off visual values across components
- let web and mobile drift into different product identities
- copy default component-library aesthetics without deliberate restyling
- normalize all hierarchy so every panel and section feels equally important
- imitate a raw terminal so literally that forms, navigation, or touch targets become awkward

## Implementation Discipline

- Shared tokens should exist as concrete implementation tokens in each runtime.
- Web should expose them through CSS custom properties or an equivalent central theme layer.
- Mobile should expose them through theme constants, theme extensions, or an equivalent central token layer.
- If one runtime already expresses the shared language more clearly, treat that runtime as the reference implementation and translate from it rather than redesigning from scratch.
- Web is the current reference implementation for shell composition, panel grammar, command strips, type hierarchy, and accent distribution.
- New components should use the shared token roles before introducing new raw values.
- Repeated magic numbers should be promoted into shared tokens once they appear in more than one component or screen.
- Runtime-specific adaptations are allowed, but they should be documented as runtime mappings of the same shared role rather than ad hoc local styling.
- Repeated visual structures should be promoted into reusable runtime theme or design-system primitives instead of being recopied screen by screen.
- When a new visual pattern becomes durable, add or update the corresponding token definition here instead of leaving it implicit in code.

## Change Protocol

- If a task changes the core aesthetic direction, explicitly redefine tone, typography, palette, spatial composition, surface model, and motion style.
- If a task expands a token beyond one component or one runtime, add or update the token definition here in the same task.
- If a task changes cross-runtime identity, update both runtime-specific rule files in the same task.
- If a task introduces a new durable component role, add it under `Component Roles`.
