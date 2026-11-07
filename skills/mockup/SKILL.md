---
name: mockup
description: |
  Mockup-set generator with three purposes: new (fresh screens for something
  that doesn't exist yet), flow (screen-flow canvases wired by labeled
  connectors plus p5 sketch pages), and redesign (before/after pages of an
  existing app with tokens lifted verbatim from its source). ALWAYS opens by
  asking the user what they want (purpose, theme, page list) via the `ask`
  tool before generating anything. Sets are standalone SvelteKit (Svelte 5 +
  Vite + Tailwind + shadcn-svelte) projects in stock shadcn styling by
  default; theme (preset, base color, dark) selectable at scaffold time.
  Invoked by explicit skill call only; it never auto-triggers.
---

# Mockup

- TLDR: Three purposes over one shared standard — new (fresh screens from
  scratch), flow (screen-flow canvases + p5 sketches), redesign (before/after
  of an existing app). ALWAYS open with an `ask` round — purpose, theme, page
  list — before generating anything.
- TLDR: Default styling is stock shadcn-svelte (Vega preset, neutral base color) —
  do NOT re-theme unless the user names a preset/base color, or the mode supplies
  one (redesign uses the target app's real tokens).
- TLDR: Real domain labels ("Projects", "Save") with token data (`<project name>`,
  `×N`); no lorem ipsum, no invented names/numbers, no filler text elements.
- TLDR: Iterate per page on feedback — never regenerate the set.

Not for: auditing a running app (`visual-audit`), UX critique of existing UI
(`feral-ux-audit`). Mode routing is under [Mode routing](#mode-routing).

## On invocation — ask first

NEVER generate from assumptions. The FIRST action of every run is one `ask`
round covering all three:

1. Purpose — what should the set show? Offer the three modes in outcome
   language so the user picks, don't make them parse mode names:
   - `new` — "fresh screens for something that doesn't exist yet"
   - `flow` — "how screens connect: a flow map of the journey"
   - `redesign` — "before/after of an existing app" (requires its source code)
   Guessing the purpose from phrasing is the #1 failure mode — an ambiguous
   request mentioning several screens is still `new` unless the user says flow.
2. Theme — offer: stock shadcn (default; Vega + neutral) / a named preset or
   base color (Theme options) / redesign-real-tokens. Never re-theme silently.
3. Page list — numbered, one line per page (plus the flow map in `flow`, the
   before/after proposal list in `redesign`). User confirms or corrects.

If the user's request already answers some of these (explicit mode, explicit
theme, explicit page list), skip that item — don't re-ask what's already
decided. Everything still ambiguous gets asked.

## Shared core (all modes)

### Standards

- Styling: stock shadcn-svelte, whatever theme the set scaffolded with (default
  Vega + neutral). Do not restyle components ad hoc; theme changes go through
  the token file (`src/routes/layout.css`) — see Theme options.
- Content: real domain labels ("Projects", "Save") — never generic placeholders.
- Variable data as tokens: `<project name>`, `×N`.
- No lorem ipsum, no invented names/numbers, no filler text elements.

### Set structure

- Each set is a STANDALONE SvelteKit project (Svelte 5 + Vite + Tailwind +
  shadcn-svelte) at `./mockups/<set>/` with its own `package.json` and `src/` —
  not loose HTML files.
- One route per numbered page (`src/routes/01-dashboard/+page.svelte`, …),
  each rendering a page component from `src/lib/pages/`. Optional state variants
  are query params on the same route (`/01-dashboard?v=dark,violet`) that set
  body classes — no separate variant files.
- The shell is the root route `src/routes/+page.svelte`: a plain page linking
  every numbered page and every variant. Any set with more than one page MUST
  have it.
- Scaffold (all prompts have safe defaults — run in a pty and answer EVERY prompt
  with Enter; default preset is Vega, default aliases are `#lib`-based):

  ```
  bunx sv create mockups/<set> --template minimal --types ts --no-add-ons --install bun
  cd mockups/<set>
  bunx sv add tailwindcss="plugins:none" --install bun   # or `bunx sv add tailwindcss` + accept defaults
  bunx shadcn-svelte init --css src/routes/layout.css --base-color <base-color>
  ```

  `init` prompts, in order, each answered with Enter: preset (default **Vega**),
  import aliases for lib/components/ui/utils/hooks (defaults `#lib`, `#lib/components`,
  `#lib/components/ui`, `#lib/utils`, `#lib/hooks`), then "Updates to layout.css
  required" → Yes. SvelteKit 3 has no `svelte.config.js` and uses native `#lib`
  subpath imports — no alias configuration needed. Piped stdin does NOT drive the
  preset select (clack needs a pty); the `add` confirm DOES accept piped `y`.

### Theme options

- Default: stock shadcn-svelte = **Vega preset + neutral base color**. Re-theme
  ONLY when the user names a preset or base color (redesign mode overrides with
  the target app's real tokens instead).
- Presets (first `init` prompt): **Vega** — Lucide / Inter, the classic shadcn
  look (default); **Nova** — Lucide / Geist; **Lyra** — Phosphor / JetBrains Mono;
  **Luma** and **Rhea** — Lucide / Inter; **Maia** and **Mira** — Hugeicons;
  **Sera** — Lucide / Noto Sans + Playfair Display.
- Base colors (`--base-color` flag): `neutral` (default), `stone`, `zinc`,
  `mauve`, `olive`, `mist`, `taupe`.
- Dark mode: the generated theme ships a native `.dark` class block — a dark
  variant needs no re-tokening (see Variants).
- Theme changes post-scaffold go through `src/routes/layout.css` (the token
  blocks); never restyle components ad hoc.
- Page routes follow this pattern:

  ```svelte
  <!-- src/routes/01-dashboard/+page.svelte -->
  <script lang="ts">
    import { page } from '$app/state';
    import Dashboard from '#lib/pages/01-dashboard/Dashboard.svelte';

    const v = $derived(page.url.searchParams.get('v') ?? '');
    $effect(() => {
      document.body.className = v;
    });
  </script>
  <Dashboard />
  ```

  Variants: the page route reads the query param and sets it verbatim as the body
  class. The label `dark` maps to shadcn's native `.dark` theme; any other label
  is a free hook for the set's own CSS (e.g. `?v=compact`). (`$effect` is
  client-only — the SSR shell has no variant class; fine for mockups.)

### Serve

- Run and print `cd mockups/<set> && timeout 300 bun run dev --port <port>` —
  five-minute auto-stop; give the shell URL `http://localhost:<port>/` (the root
  route).
- `vite` dev (or `build` + `preview`) IS the server. Never write a custom server
  script. (macOS has no GNU `timeout`: emulate with a background `sleep 300; kill`
  watchdog.)

### Workflow

1. Run the invocation `ask` round (On invocation above) — purpose, theme, and
   page list all confirmed before anything is generated.
2. Scaffold the project (Set structure above — init generates the theme), add
   the components the pages need (`bunx shadcn-svelte add button card …`), and
   copy the mode's assets from this skill's `assets/` into `src/lib/`.
3. Generate the pages.
4. Serve with the bounded one-liner.
5. Iterate on feedback: edit the affected page's component only — NEVER regenerate
   the whole set.

## Mode: new

- Scope: fresh screens for something that doesn't exist yet — full stock
  component fidelity, real labels, no navigation story, no existing app to
  compare against.
- Build pages from stock shadcn-svelte components (Card, Button, Input, Badge,
  Skeleton, Table, Tabs) in the scaffolded theme's palette. Wireframe primitives
  come for free: Skeleton bars are the text-line placeholders, muted Cards are the
  frames.
- Multiple candidate directions are `?v=` variants of the same page so they compare
  directly.

## Mode: flow

- Scope: the navigation story matters — multi-screen UI flow maps (wireframed
  screens wired by labeled connectors on one canvas) and/or pages carrying focal
  p5 sketches. Both page types mix freely in one set.
- Confirm the flow map (screens, edges, arrow labels, which edges are primary)
  with the user BEFORE generating.
- A flow page is a relative-positioned canvas container holding absolutely
  positioned `.frame` screens, wired by connectors from `assets/flow.ts`:

  ```ts
  import { Flow } from '$lib/flow';

  onMount(() => Flow.render());
  ```

  ```svelte
  <div class="flow-canvas" bind:this={canvas}>
    <div class="frame" id="login" style="left: 40px; top: 40px; width: 230px;">…</div>
    <div class="frame" id="list"  style="left: 340px; top: 40px;">…</div>
  </div>
  ```

- Connector vocabulary (kept from the original flow helper):

  - `Flow.connect(fromId, toId, 'Label', { via, primary, out, in })` registers the
    edge; `Flow.render()` draws it as an orthogonal elbow with an arrowhead and a
    label chip carrying the action ("Log in", "Sign up", "Video 1st").
  - `via: 'h' | 'v'` — horizontal or vertical exit/entry sides; default picks the
    dominant delta. `primary: true` — the happy path: primary-colored line + label;
    everything else stays in the theme's border color. If the scaffolded theme's
    primary is too quiet against the connector gray, re-token `--primary` in the
    set's `layout.css` (one variable — still the theme, not ad-hoc restyling).
    `out` / `in` (0..1) tune the exit/entry point along the edge.
  - Connectors recompute on load and resize. Never hand-place connector divs,
    never hardcode their coordinates.
- Frame anatomy: `.frame` = `.frame-head` (screen name) + `.frame-body`; phone
  screens ~230px wide, desktop frames wider; every frame needs an `id` because
  connectors anchor to it. Append this CSS to the flow set's `layout.css`:

  ```css
  .flow-canvas { position: relative; border: 1px solid var(--border); min-height: 420px; }
  .frame { position: absolute; border: 1.5px solid var(--foreground); border-radius: 4px; background: var(--card); }
  .frame-head { padding: 4px 8px; font-size: 10px; text-transform: uppercase; letter-spacing: .06em; color: var(--muted-foreground); border-bottom: 1px solid var(--border); }
  .frame-body { padding: 10px; display: flex; flex-direction: column; gap: 8px; }
  .connector-seg { position: absolute; background: var(--border); }
  .connector-seg.primary { background: var(--primary); }
  .connector-head { position: absolute; width: 0; height: 0; border: 5px solid transparent; border-left: 8px solid var(--border); }
  .connector-head.primary { border-left-color: var(--primary); }
  .connector-label { position: absolute; padding: 0 6px; font-size: 10px; background: var(--card); border: 1px solid var(--border); border-radius: 3px; }
  .connector-label.primary { color: var(--primary); border-color: var(--primary); }
  ```

- Sketch pages: a focal p5@1 sketch (hero) plus ordinary sections. Install
  `p5@1` — never 2.x — and drive it with `assets/sketch.ts` in the page
  component's `onMount`. Instance mode, seeded (no `Math.random`), and colors
  ONLY via `theme()` — a sketch that hardcodes hex values breaks every variant.

## Mode: redesign

- Scope: an existing app's UI is the baseline; the deliverable is before/after
  evidence, not imagination.
- Two fidelity bars:
  - **Skeleton — minimal, always.** Page frames, section wrappers, spacer chrome
    and anything NOT under proposal stay plain stock shadcn (scaffolded theme,
    untouched). The shell carries no design opinion; it only frames the changes.
  - **Proposal surfaces — actual-app fidelity, always.** Every component the
    proposal changes renders with the app's REAL values: its real accent, status
    colors, font sizes, radii, borders, spacing. Polishing ONLY the proposed
    surfaces is the point — that is what makes the proposal legible.
- Fidelity sourcing — never from memory:
  - Extract real values from the app's source into the set's `layout.css` BEFORE
    generating pages: the token block, status/chip recipes, row-card class
    strings, font-size ramp, radius/border scale — each with a source comment
    naming the file it came from (e.g. `/* app.css .mono-overline */`).
  - If a component's look can't be captured by tokens (complex shadow, gradient,
    interaction state), reference the app screenshot next to the mockup instead
    of re-drawing it by hand.
  - Never guess or restyle: an approximation of the app's look invalidates the
    before/after comparison.
- Comparability contract:
  - One proposal per page; the page shows BEFORE and AFTER side by side with
    identical data and layout — only the proposed delta differs.
  - BEFORE must match the app's current rendering — verify against the class
    strings in source, and against a screenshot of the running app when one is
    available; never against a memory of the UI.
  - Multiple candidate values (accents, themes, sizes) are `?v=` variants of the
    same page so candidates compare directly against each other and against
    BEFORE.
  - Label columns explicitly ("Before — current", "After — proposed") and cite
    the finding or code anchor each proposal answers when the set comes from an
    audit.

## Mode routing

- `new` — fresh screens, nothing existing to compare against.
- `flow` — navigation or journey matters, or the page wants a focal visual.
- `redesign` — an existing app's UI is the baseline (needs its source, never
  memory-only).

## Red flags — never

- One massive page for the whole set — one route per page, shell for navigation.
- Lorem ipsum, filler text, invented names/numbers.
- Re-theming a set on your own initiative — stock shadcn (Vega + neutral) is the
  default; theme only on explicit user choice or redesign-mode token extraction.
- Hand-drawing SVG decorations when a stock component or its built-in icon
  already covers the need.
- Polishing skeleton chrome or un-proposed surfaces in redesign.
- Inventing token values, colors or sizes not present in the app's source;
  one-sided AFTER-only pages; before/after pairs with different data or layout.
- Sketches hardcoding colors instead of `theme()`, or using `Math.random`.
- Frames overlapping, or connectors crossing through frames — reposition the map.
- Auto-triggering: runs only on explicit skill call.
- Generating before the invocation `ask` round is answered, or guessing the
  purpose/theme from phrasing instead of asking.
- A custom server script — vite dev/preview behind the five-minute timeout is the
  whole server story.
- Regenerating the whole set on feedback instead of editing the affected page.
