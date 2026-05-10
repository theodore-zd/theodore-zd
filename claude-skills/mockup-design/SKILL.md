---
name: mockup-design
description: Generate a new design concept for the portfolio as a self-contained HTML mockup at `mockups/<iteration>.html`, grounded in the current Astro UI. Interactive — interviews the user about target page, design direction, and references before generating. Use when the user says "new mockup", "design concept", "try a redesign", "explore a new look", "iterate on the UI", or asks to mock up a section of the portfolio.
user_invocable: true
---

# Mockup Design

Act as a design partner for the portfolio in this repo. Produce a single self-contained HTML file that explores a new visual direction for an existing page or section, grounded in the current implementation so the concept is realistic, not generic.

The output is a *concept*, not production code. It lives in `mockups/` (relative to the repo root) and is meant to be opened in a browser, reviewed, and iterated on. Do not modify the live Astro source during this skill.

Before starting, confirm you're operating from the repo root (the directory containing both `portfolio/` and `mockups/`). If the working directory is elsewhere, prefix paths accordingly — but never write the mockup outside `mockups/`.

## Operating principles

1. **Ground the design in the current UI.** Before generating anything, read the relevant Astro page(s), the components they use, and `portfolio/src/styles/global.css` for design tokens. The mockup should feel like *this* portfolio, evolved — not a stock template.
2. **Interview first, generate second.** Use `AskUserQuestion` to pin down target, direction, and constraints before writing HTML. One batch, multiple questions.
3. **Self-contained output.** Single `.html` file. Inline CSS in `<style>`, inline any small JS in `<script>`. No build step, no external imports beyond CDN fonts/icons. Must open correctly via `file://`.
4. **One concept per file.** Don't cram multiple directions into one mockup; each iteration is a distinct exploration.
5. **Iterate by adding, not overwriting.** Each run produces a new numbered file so prior concepts remain reviewable.

## Workflow

### Phase 1 — Interview

The goal of this phase is to gather *just enough* signal to make a focused mockup, without grinding through a fixed questionnaire. You decide which questions to ask based on (a) what the user already said in their prompt and (b) what the current UI is doing.

Before asking, do a **fast orientation read** — just enough to make the question options concrete and grounded:

- `portfolio/src/styles/global.css` (palette, fonts, radii — the current vibe)
- `portfolio/src/pages/index.astro` and `portfolio/src/layouts/main.astro` (overall structure)

Don't deep-read components yet — that happens in Phase 2 once the target is known.

Hard rules for the interview:

- Default to **a single `AskUserQuestion` call** covering all chosen questions in one batch. Only make a follow-up call if an "Other" free-form answer introduces a critical ambiguity that blocks generation.
- Cap at **4 questions** per call. If you have more candidates, drop the lowest-leverage ones; assume reasonable defaults for the rest and state them up front.
- **Always** include the *Target* question unless the user explicitly named a page/section.
- **Always** include the *Design direction* question unless the user explicitly named a vibe.
- Every question must offer concrete options with a recommended default. Reserve free-form ("Other") for genuinely open inputs (references, must-haves).
- Don't ask about file naming, framework choice, or anything answerable by reading the repo.

#### Question pool

Pick from this pool — don't ask all of them. Choose the 2–4 most decision-shaping for *this* request, and tailor option lists to the current UI so the choices feel concrete (e.g. don't suggest "switch to dark mode" if the user is already viewing dark; don't list "keep JetBrains Mono" as a contrast option).

**Almost always relevant**
- **Target**: which page or section? Options derived from `portfolio/src/pages/` (Home, Resume, Letter, Projects, Blog) plus "brand-new page".
- **Design direction**: 3–4 vibes that would *contrast meaningfully* with what the current UI is doing. Generate options based on the current style — e.g. if the site is mono-terminal-ish, offer editorial/serif, glassy-dark-neon, Swiss-grid-minimal, magazine-collage. Always include "stay close to current style, refine details" as the safe default.
- **Scope**: full-page concept · single hero/section · component variations grid.

**Often relevant — include if the request leaves them open**
- **Theme**: light · dark · both side-by-side · auto-toggle.
- **Density**: airy/spacious · balanced · information-dense (good when the page is content-heavy like Resume).
- **Tone / personality**: playful · serious-professional · technical-archival · editorial-confident.
- **Typography intent**: keep current mono · pair mono with serif display · new sans system · bespoke serif-led.
- **Color move**: same palette refined · shift accent hue · introduce a second accent · monochrome restraint · high-contrast inversion.

**Situational — include only when the request hints at them**
- **Motion**: static mockup · subtle hover/scroll polish · expressive motion (parallax, marquee, transitions).
- **Imagery**: text-only · minimal photo/illustration · heavy imagery / hero art · abstract generative.
- **Layout system**: classic vertical sections · asymmetric grid · sidebar/anchored nav · split-screen · single long scroll vs. paginated.
- **Inspiration / references**: free-form site/designer/aesthetic the user wants pulled in.
- **Must-haves & no-gos**: anything to preserve (a brand color, a quote, a section) or avoid.
- **Audience hint**: recruiters · engineering peers · design-led companies · general public — shapes which content to foreground.
- **Viewport priority**: desktop-first · mobile-first · both equally.
- **Content liberties**: stick strictly to existing copy · OK to invent plausible additional copy/sections.

#### How to choose

1. After reading the user's prompt, list the candidate questions internally. Mark each as: *answered already* / *high-leverage* / *low-leverage*.
2. Drop *answered* and *low-leverage* candidates. From the remaining, pick the top 4 by impact on the visual outcome.
3. For each picked question, generate options grounded in the current UI (not generic). Recommended option goes first and is labeled clearly.
4. State any assumed defaults for skipped questions in the message accompanying the `AskUserQuestion` call, so the user can override if you guessed wrong.

### Phase 2 — Ground in the current UI

Once direction is set, read the relevant source so the mockup reuses real content and structure:

1. **Tokens**: read `portfolio/src/styles/global.css` to capture the current palette, radii, fonts. Carry these forward (or deliberately depart from them — and say which).
2. **Target page**: read `portfolio/src/pages/<target>.astro` (and its layout `portfolio/src/layouts/main.astro`) to understand what's actually on the page.
3. **Components in use**: read the components the page imports (e.g. `Hero.astro`, `Experience.astro`, `Projects.astro`) so the mockup's content sections match reality.
4. **Real content, not lorem**: pull headings, role names, project titles, copy from the actual files where reasonable. The user should recognize their own portfolio in the mockup.
5. **Note any constraints** (existing fonts loaded, existing icon set, brand color the user is attached to) before designing away from them.

If the page is large, focus reads on the target section; you don't need to read every component on the site.

### Phase 3 — Pick the iteration filename

Mockups live at `mockups/<iteration>.html`.

1. List existing files: ``ls mockups/``. If the directory doesn't exist, create it and start at `01`.
2. Pick the next filename using this scheme: `NN-<short-slug>.html` where `NN` is zero-padded two digits, increments past the highest existing number, and `<short-slug>` is a 2–4 word kebab-case description of the concept (e.g. `03-editorial-serif.html`, `04-brutalist-terminal.html`).
3. If the user explicitly named the iteration, honor that — but still prefix with the next `NN-` so ordering stays clean.

### Phase 4 — Generate the mockup

Write a single self-contained `.html` file. Structure:

- `<!doctype html>` + `<html lang="en">`
- `<head>`:
  - `<meta charset>`, `<meta viewport>`
  - `<title>` naming the concept
  - Optional `<link>` for Google Fonts / fontsource CDN if the direction calls for a typeface not already loaded
  - One `<style>` block holding all CSS. Define design tokens as CSS custom properties at `:root`. If the user asked for both themes, include a `.dark` selector and a small toggle.
- `<body>`:
  - Real content sourced from the Astro pages — headings, role, projects, links.
  - Sections reflecting the chosen scope (full page, single section, or component grid).
  - For side-by-side themes: a CSS grid with two column wrappers, each scoped to its own theme class (`.theme-light` / `.theme-dark`) so both render in one document. For "auto-toggle", use `prefers-color-scheme` plus a manual toggle button.
- Optional `<script>` for theme toggle or small interactions only. No frameworks.

Quality bar:

- **Typographic hierarchy** is deliberate — distinct sizes, weights, and rhythm; not all 16px sans.
- **Spacing system** is consistent (use a scale, not arbitrary px).
- **No generic AI aesthetic**: avoid centered hero + three-card grid + gradient blob unless the user asked for that. Lean into the chosen direction.
- **Responsive at desktop and 375px-wide phone.** Don't ship a mockup that breaks at small viewports.
- **Interactive states**: visible hover, focus, and active states on links/buttons. Focus ring must be keyboard-visible.
- **Theme parity**: if both themes are shown, both must look intentional — dark isn't just "light with inverted colors".
- **Accessibility basics**: correct heading order, sufficient contrast (WCAG AA), alt text on any imagery.

For execution craft on ambitious visual directions, draw on the principles documented in the `frontend-design` skill (distinctive design, avoiding generic patterns) — but stay in this skill; do not invoke another skill mid-run. The deliverable belongs in `mockups/`.

### Phase 5 — Hand off

After writing the file:

1. Print the absolute path and a one-line description of what's in it.
2. Suggest the user open it: `open mockups/<file>.html` (macOS) — offer to run it if they want.
3. Ask whether to iterate (next numbered file, refining direction) or stop. Don't assume.

## Things you must not do

- Do **not** modify files under `portfolio/src/` while running this skill. Mockups only.
- Do **not** generate placeholder lorem ipsum when real content exists in the Astro pages — read it.
- Do **not** overwrite existing mockups. Always add a new numbered file.
- Do **not** introduce a build step, npm install, or framework runtime in the mockup. One HTML file, opens via double-click.
- Do **not** skip the interview unless the user's prompt already specifies target + direction + scope clearly.

## Output cadence

- One short message after the interview, naming the target and direction in plain words.
- One short message after reading source files, calling out anything constraint-shaped (e.g. "keeping JetBrains Mono since it's loaded site-wide").
- The mockup file written via `Write`.
- One short closing message with the path and an offer to iterate.
