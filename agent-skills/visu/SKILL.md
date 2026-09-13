---
name: visu
description: |
  Turn a markdown plan (or brainstorm/ducky output) into a single-file, clean interactive HTML page: TLDR, steps, interactive visualizations for the plan's advanced algorithms and data structures, and a verification checklist. Default output is minimal — complexity is spent only where a concept genuinely needs a visual. One external dependency — p5.js from jsDelivr CDN — everything else inline; renders from file://.
  Trigger phrases: "visu", "visualize the plan", "plan viz", "make the plan visual", "interactive plan", "html page for the plan", "show me the concepts", "visualize the algorithms", "adhd friendly html version of the plan".
allowed-tools: Read, Write, Glob, Grep, Ask, Eval
---

# visu — visual plan page

Produce ONE self-contained HTML file: `<plan-name>-visu.html`, next to the input plan (mirror the plan's name + `-visu`). The file is the entire deliverable; everything else is scaffolding.

## Page shape

Sections in order; omit a section only when the plan has nothing for it:

1. **Header** — plan title (h1), one-line description, link to the source plan file.
2. **TLDR** — one card per outcome/decision: title (≤ 8 words) + caption (≤ 12 words). No paragraphs before visuals.
3. **Steps** — the plan's ordered pipeline as numbered steps, one line each. Skip if the plan has no ordered pipeline.
4. **Concepts** — interactive visualizations (threshold and rules below).
5. **Verification** — one checkbox per gate/assert from the plan's Verification section, grouped Backend / Frontend / Runtime; add a "Definition of done" group from the plan's tests list. Checkboxes persist in `localStorage`, key = `location.pathname + '#' + id`.

Hard rules:
- One external dependency only: p5.js from jsDelivr (`<script src="https://cdn.jsdelivr.net/npm/p5@1/lib/p5.min.js">`). Everything else inline: CSS, JS, SVG/canvas. No fonts, no other CDNs, no network beyond that one script. Must render from `file://` in any modern browser.
- Dark theme only. No nav rail, no theme toggle, no per-section time chips, no skip buttons, no progress bars, no risks/notes section, no before/after schematic, no global settings panel.
- Captions ≤ 12 words; detail lives behind `<details>`, never expanded by default.
- Numbers shown come from the plan. Never invent metrics; if the plan has no numbers, show none.
- `prefers-reduced-motion` honored; every animation has play/pause, nothing loops forever.

## Concept visualizations

A concept earns a visualization ONLY if its mechanics are non-obvious — algorithms, data structures, simulations. Simple mechanics (config change, CRUD, rename, wiring) get none; the TLDR covers them.

Per viz:
- Built with p5.js in instance mode: one `new p5(sketch, holder)` per panel (holder = a div inside the panel). Never global mode — two sketches on one page collide.
- It moves or responds: play button, hover, or an inline slider. Static SVG is the last resort.
- An inline slider per viz only when it materially changes understanding (element count, octaves, speed). No dead controls.
- Deterministic: seeded `rand(seed)` (skeleton helper) or p5 `randomSeed(seed)`, never `Math.random` at draw time.
- Caption states the mechanism in one line; `<details>` carries the plan's parameters/pins.

Patterns (adapt as p5 instance sketches; canvas or inline SVG; params from the plan):

| Concept | Visual |
|---|---|
| BFS / Dijkstra wavefront | grid, front spreads from sources, barriers block |
| A* / pathfinding | cost-field tint + path bending around high cost |
| Recursive split / bisection | blob, cut through longest edge, recurse on play |
| Voronoi / tessellation | raster nearest-site fill + site dots |
| Sorting | bars, one comparison/swap per tick |
| Tree / heap / BST | nodes + edges, insert/traverse animation |
| Graph traversal (DFS/BFS) | nodes, frontier lights up stepwise |
| DP table / edit distance | grid filling cell-by-cell |
| Hash map / buckets | keys hashing into buckets, collisions shown |
| Stack / queue | push/pop or enqueue/dequeue animation |
| State machine | nodes + transitions, token walks on play |
| Noise / fbm octaves | octave curves summed live, slider adds octaves |

No pattern matches → design a viz in the same idiom (p5 sketch panel, caption, controls).

## Process

1. Read the plan. Extract: title, one-liner, outcomes, ordered steps (if any), advanced concepts with their parameters/pins, verification steps.
2. Build the page from `references/page.html`: keep the theme/helpers and the p5.js script tag, fill the `<!-- @slot:… -->` markers, delete sections the plan doesn't need.
3. Wire: every viz has working controls; every id referenced by JS exists in the markup; no orphan JS.
4. Sanity-check: balanced tags, no stray `</script>`, unique ids; when a browser tool is available, open `file://` + screenshot and fix what's broken.
5. Report the file path and its sections. Do not dump the file into chat.