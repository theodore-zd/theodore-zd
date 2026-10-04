---
name: mockup
description: |
  Mockup-set generator with three modes over one shared low-fi standard: plain
  (greenfield grayscale wireframes), flow (screen-flow canvases wired by labeled
  connectors plus p5 sketch pages), and redesign (before/after pages of an
  existing app with tokens lifted verbatim from its source). Sets are standalone
  SvelteKit (Svelte 5 + Vite + Tailwind + shadcn-svelte) projects themed to
  grayscale plus exactly one accent color. Invoked by explicit skill call only;
  it never auto-triggers.
---

# Mockup

- TLDR: Three modes over one shared standard — plain (greenfield wireframes), flow
  (screen-flow canvases + p5 sketches), redesign (before/after of an existing app).
- TLDR: Low fidelity is enforced by theming, not by weaker tooling — each set is a
  real Svelte 5 + Vite + Tailwind + shadcn-svelte project themed to grayscale plus
  exactly ONE accent color (default `#e8710a` in `assets/app.css`); deliberately
  plain and self-policed.
- TLDR: Real domain labels ("Projects", "Save") with token data (`<project name>`,
  `×N`); no lorem ipsum, no invented names/numbers, no filler text elements.
- TLDR: Confirm the page list (and the flow map in flow mode) with the user via
  `ask` BEFORE generating. Iterate per page on feedback — never regenerate the set.

Not for: auditing a running app (`visual-audit`), UX critique of existing UI
(`feral-ux-audit`). Mode routing is under [Mode routing](#mode-routing).

## Shared core (all modes)

### Standards

- Fidelity: deliberately plain, self-policed. Grayscale + exactly ONE accent color
  (default `#e8710a` in `assets/app.css`); the punch comes from layout, labels and
  motion — never from more colors.
- Icons ONLY via the css.gg CDN — `<link rel="stylesheet"
  href="https://cdn.jsdelivr.net/npm/css.gg/icons/icons.css">` in every page entry.
  GOTCHA: bare `https://cdn.jsdelivr.net/npm/css.gg` serves JS, not CSS.
- NEVER hand-write SVG and never use lucide or any icon component that embeds SVG
  markup — css.gg class names only.
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
- Scaffold (proven headless sequence; `sv` prompts interactively when run
  without the answer syntax):

  ```
  bunx sv create mockups/<set> --template minimal --types ts --no-add-ons --install bun
  cd mockups/<set>
  bunx sv add tailwindcss="plugins:none" --install bun   # or `bunx sv add tailwindcss` + accept defaults
  ```

  SvelteKit 3 removed `$lib` — re-add it inside the `sveltekit()` plugin in
  `vite.config.ts` (there is no `svelte.config.js` anymore):

  ```ts
  sveltekit({
    alias: { '$lib': 'src/lib', '$lib/*': 'src/lib/*' },
    // …keep the generated compilerOptions/adapter options
  })
  ```

  Then configure shadcn-svelte manually (its `init` is interactive; this is the
  deterministic equivalent):

  ```json
  // components.json
  {
    "$schema": "https://shadcn-svelte.com/schema.json",
    "tailwind": { "css": "src/routes/layout.css", "baseColor": "neutral" },
    "aliases": {
      "components": "$lib/components",
      "utils": "$lib/utils",
      "ui": "$lib/components/ui",
      "hooks": "$lib/hooks",
      "lib": "$lib"
    },
    "typescript": true,
    "registry": "https://shadcn-svelte.com/registry"
  }
  ```

  ```ts
  // src/lib/utils.ts
  import { clsx, type ClassValue } from 'clsx';
  import { twMerge } from 'tailwind-merge';

  export function cn(...inputs: ClassValue[]) {
    return twMerge(clsx(inputs));
  }
  ```

  ```
  bun add clsx tailwind-merge
  bunx shadcn-svelte add button card badge input skeleton table tabs separator
  ```

  `add` asks "Ready to install components and dependencies?" — confirm it (pipe
  `printf 'y\n' |` in front when running non-interactive).
- Theming: replace `src/routes/layout.css` with `assets/app.css`, keeping
  `@import "tailwindcss";` as the first line. `assets/app.css` IS the whole
  theme — the grayscale + one-accent CSS variables AND the `@theme inline`
  mapping that turns them into utilities. Stock shadcn-svelte ui components
  then render in the grayscale palette. Re-token the palette file; never restyle
  components ad hoc.
- Icons: add the css.gg CDN link to the `<head>` in `src/app.html` — never
  lucide or any SVG-embedding icon component.
- Page routes follow this pattern (Tailwind classes stay low-fi):

  ```svelte
  <!-- src/routes/01-dashboard/+page.svelte -->
  <script lang="ts">
    import { page } from '$app/state';
    import Dashboard from '$lib/pages/01-dashboard/Dashboard.svelte';

    const v = $derived(page.url.searchParams.get('v') ?? '');
    $effect(() => {
      document.body.className = v
        ? v.split(',').map((label) => `variant-${label}`).join(' ')
        : '';
    });
  </script>
  <Dashboard />
  ```

  Variants: the page route reads the query param and sets body classes, which
  `app.css` maps to palette overrides. (`$effect` is client-only — the SSR shell
  has no variant class; fine for mockups.)

### Serve

- Run and print `cd mockups/<set> && timeout 300 bun run dev --port <port>` —
  five-minute auto-stop; give the shell URL `http://localhost:<port>/` (the root
  route).
- `vite` dev (or `build` + `preview`) IS the server. Never write a custom server
  script. (macOS has no GNU `timeout`: emulate with a background `sleep 300; kill`
  watchdog.)

### Workflow

1. Restate the request as a numbered page list (plus the mode-specific plan: flow
   map in flow mode, before/after proposal list in redesign) + applicable-state
   list; confirm with the user via `ask` BEFORE generating. User confirms or
   corrects.
2. Scaffold the project, theme it with `assets/app.css`, and copy the mode's
   assets from this skill's `assets/` into `src/lib/`.
3. Generate the pages.
4. Serve with the bounded one-liner.
5. Iterate on feedback: edit the affected page's component only — NEVER regenerate
   the whole set.

## Mode: plain

- Scope: greenfield low-fi wireframes — no navigation story to tell, no existing
  app to compare against.
- Build pages from stock shadcn-svelte components (Card, Button, Input, Badge,
  Skeleton, Table, Tabs) rendered in the grayscale palette. Wireframe primitives
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
    dominant delta. `primary: true` — the happy path: accent line + accent label;
    everything else stays gray. `out` / `in` (0..1) tune the exit/entry point
    along the edge.
  - Connectors recompute on load and resize. Never hand-place connector divs,
    never hardcode their coordinates.
- Frame anatomy: `.frame` = `.frame-head` (screen name) + `.frame-body`; phone
  screens ~230px wide, desktop frames wider; every frame needs an `id` because
  connectors anchor to it. Copy this CSS into the flow set's `app.css`:

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
    and anything NOT under proposal stay plain: grayscale, hairlines, no polish.
    The shell carries no design opinion; it only frames the changes.
  - **Proposal surfaces — actual-app fidelity, always.** Every component the
    proposal changes renders with the app's REAL values: its real accent, status
    colors, font sizes, radii, borders, spacing. Polishing ONLY the proposed
    surfaces is the point — that is what makes the proposal legible.
- Fidelity sourcing — never from memory:
  - Extract real values from the app's source into the set's `app.css` BEFORE
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

- `plain` — greenfield, no navigation story to show.
- `flow` — navigation or journey matters, or the page wants a focal visual.
- `redesign` — an existing app's UI is the baseline (needs its source, never
  memory-only).

## Red flags — never

- One massive page for the whole set — one route per page, shell for navigation.
- Lorem ipsum, filler text, invented names/numbers.
- Hand-written inline SVG; lucide or any SVG-embedding icon component.
- Polish above the plain bar in plain/flow; polishing skeleton chrome or
  un-proposed surfaces in redesign.
- Inventing token values, colors or sizes not present in the app's source;
  one-sided AFTER-only pages; before/after pairs with different data or layout.
- Sketches hardcoding hex colors instead of `theme()`, or using `Math.random`.
- Frames overlapping, or connectors crossing through frames — reposition the map.
- Auto-triggering: runs only on explicit skill call.
- Generating before the page list (and flow map) is confirmed.
- A custom server script — vite dev/preview behind the five-minute timeout is the
  whole server story.
- Regenerating the whole set on feedback instead of editing the affected page.
