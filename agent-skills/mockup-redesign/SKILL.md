---
name: mockup-redesign
description: |
  Mockup generator for redesigning an existing app: keeps the low-fi shell
  skeleton but renders every proposed component at the real app's fidelity —
  tokens, chips and row grammar lifted verbatim from the app's source — laid
  out before/after so each change is directly comparable against the existing
  UI. Invoked by explicit skill call only; it never auto-triggers.
---

# Mockup redesign

- TLDR: Minimal skeleton, real-fidelity proposals — the page chrome around a
  change stays deliberately plain; every component the proposal touches renders
  with the app's ACTUAL tokens, copied verbatim from source, never invented.
- TLDR: Every proposal is a before/after pair on one page: same data, same
  layout, adjacent columns — only the delta differs, so each change is judged
  against the existing UI, not against imagination.
- TLDR: Fidelity comes from the app source (token blocks, chip recipes, row
  grammar, real accent), extracted into the set's theme.css — the mockup never
  approximates the app's look from memory.
- TLDR: Same set mechanics as `mockup` — shell.html with numbered pages +
  iframe-swapped variants, copied assets, one-liner serve, iterate per page.

Not for: greenfield mockups with no existing UI to compare against (`mockup`),
auditing a running app (`visual-audit`), UX critique without proposals
(`feral-ux-audit`).

## The two fidelity bars

- **Skeleton — minimal, always.** Page frames, section wrappers, spacer chrome
  and anything NOT under proposal stay plain: grayscale, hairlines, no polish.
  The shell carries no design opinion; it only frames the changes.
- **Proposal surfaces — actual-app fidelity, always.** Every component the
  proposal changes (rows, chips, buttons, menus, meta columns, ramps) renders
  with the app's real values: its real accent, status colors, font sizes,
  radii, borders, spacing. Polishing ONLY the proposed surfaces is the point —
  that is what makes the proposal legible.

## Fidelity sourcing — never from memory

- Extract real values from the app's source into the set's `theme.css` before
  generating pages: the token block (`@theme`/`:root` CSS vars), status/chip
  recipes, row-card class strings, font-size ramp, radius/border scale.
- Component recipes are copied verbatim from source (the actual class strings
  or their CSS-variable equivalents), with a source comment naming the file
  they came from (e.g. `/* app.css .mono-overline */`).
- If a component's look can't be captured by tokens (complex shadow, gradient,
  interaction state), reference the app screenshot next to the mockup instead
  of re-drawing it by hand.
- Never guess or restyle: an approximation of the app's look invalidates the
  before/after comparison.

## Comparability contract

- One proposal per page; the page shows BEFORE and AFTER side by side with
  identical data and layout, only the proposed delta applied in the AFTER.
- BEFORE must match the app's current rendering — verify against the class
  strings in source, and against a screenshot of the running app when one is
  available; never against a memory of the UI.
- Multiple candidate values (accents, themes, sizes) are state VARIANTS of the
  same page (`NN-name.variant.html`) so candidates compare directly against
  each other and against BEFORE.
- Label columns explicitly ("Before — current", "After — proposed") and cite
  the finding or code anchor each proposal answers when the set comes from an
  audit.

## Content standards (carried from `mockup`)

- Real domain labels ("Projects", "Save") — never generic placeholders.
- Variable data as tokens: `<project name>`, `×N`.
- No lorem ipsum, no invented names/numbers, no filler text elements.
- Icons ONLY via the css.gg CDN (https://cdn.jsdelivr.net/npm/css.gg); NEVER
  hand-write SVG.

## Set structure

- Assets `assets/shell.html` + `assets/theme.css` sit next to SKILL.md; they
  are COPIED into every set, never referenced in place. `theme.css` ships as
  the plain skeleton base — the workflow re-tokens it with the app's real
  values in step 2.
- Target layout: `./mockups/<set-name>/` — shell.html, theme.css, numbered
  pages `NN-name.html`, optional state variants `NN-name.variant.html`.
- Any set with more than one page MUST use the shell; serve roots the set
  directory so every page opens directly.

## Workflow

1. Restate the request as a numbered page list (one proposal per page, each
   with a before/after pair) + applicable-state list; confirm with the user
   via `ask` BEFORE generating.
2. Extract the app's real tokens/recipes from source into the set's
   `theme.css` (with source-file comments).
3. Generate pages + copy assets into `./mockups/<set-name>/`.
4. Serve: run and print `timeout 300 python -m http.server <port> -d
   ./mockups/<set>` — port = python's default or a free one; give the shell
   URL `http://localhost:<port>/shell.html`.
5. Iterate on feedback: edit the affected page file only — NEVER regenerate
   the whole set.

## Red flags — never

- Inventing token values, colors or sizes not present in the app's source.
- One-sided AFTER-only pages — no BEFORE means the change isn't comparable.
- Polishing the skeleton chrome or un-proposed surfaces.
- Before/after pairs with different data or layout — the delta must be the
  ONLY difference.
- Lorem ipsum, filler text, invented names/numbers.
- Hand-written inline SVG.
- One massive HTML file for the whole set.
- Auto-triggering: runs only on explicit skill call.
- Generating before the page list is confirmed.
- Shipping a server script — the one-liner with the five-minute auto-stop is
  the whole server story.