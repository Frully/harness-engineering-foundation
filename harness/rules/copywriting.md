# Copywriting Rules

This document defines user-facing copy constraints for product UI.

It exists because UI wording can easily drift into filler, tone-first phrasing, or extra explanation that makes the interface less clear.

## Core rule

- Keep copy brief.
- Copy must accurately reflect the actual function, state, or required action.
- Do not include extra information that is not needed for the current task.
- Clarity and accuracy take priority over tone or stylistic flavor.
- For the same feature, action, state, or message across web and mobile, frontend copy is the source of truth.
- Do not let equivalent frontend and mobile UI copy drift into different wording for the same meaning.

## Scope

- This rule applies to frontend and mobile user-facing UI copy such as labels, buttons, helper text, empty states, status messages, and validation messages.
- This rule also applies to page titles, section headings, navigation labels, tab names, modal titles, confirmation text, toast messages, banners, placeholders, tooltips, and accessibility-facing labels.
- This rule applies to onboarding text, permission prompts, error recovery guidance, and other user-facing product guidance inside active flows.
- This rule does not require product documentation or long-form operational docs to be unnaturally short. Use the shortest form that still preserves the needed meaning for the context.

## Preferred writing style

- Prefer direct nouns and verbs over decorative phrasing.
- Prefer the shortest wording that remains accurate.
- Keep each piece of UI copy focused on one job: label the control, describe the state, or tell the user what to do next.
- Use helper text only when it changes the user's decision or helps them complete or recover from the task.
- Keep call-to-action text aligned with the real outcome of the action.
- Keep validation and status text specific enough to explain what failed, what succeeded, or what is needed next.
- Let tone show up only after the wording is already clear, brief, and functionally correct.
- When frontend and mobile expose the same user-facing function in the same product position, reuse the frontend wording instead of rewriting it separately for mobile.

## Necessary exceptions

- Add more context when the user could otherwise make a high-risk mistake.
- Destructive actions, security warnings, permission requests, billing consequences, irreversible state changes, and compliance-sensitive flows may require more explicit copy.
- In these cases, include the minimum extra detail needed to prevent misunderstanding or unsafe action.
- Do not shorten critical warnings so aggressively that the user loses decision-making context.
- If platform constraints make exact wording impossible, keep the meaning, action, and key nouns aligned with frontend wording and minimize the difference.

## Prohibitions

- Do not add promotional wording, emotional filler, or narrative flavor that does not improve task completion.
- Do not add implementation details, internal reasoning, or future promises to product UI copy.
- Do not stack multiple ideas into one short label or message when a simpler phrase can express the same function.
- Do not use vague wording that sounds polished but hides what the interface actually does.
- Do not use extra explanatory text to compensate for weak interaction design when the UI itself should be clarified instead.

## Review heuristic

- If removing part of the text does not change the user's ability to understand the function, remove it.
- If the wording could describe multiple different behaviors, make it more specific.
- If a shorter phrase is equally accurate, choose the shorter phrase.
