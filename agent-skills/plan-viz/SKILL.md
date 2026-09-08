---
name: plan-viz
description: |
  Turn a markdown plan (or brainstorm/ducky output) into a single-file, ADHD-friendly interactive HTML dashboard: big-visual TLDR cards, animated visualizations of every algorithm/concept the plan uses, an interactive settings explorer showing the real effect of each tunable, before/after expected-outcome schematics, and a clickable verification checklist. Self-contained (inline CSS/JS/SVG, no network), renders from file://.
  Trigger phrases: "adhd friendly html version of the plan", "visualize the plan", "make the plan visual", "plan viz", "interactive plan", "html dashboard for the plan", "show me the concepts", "visualize the algorithms", "turn the plan into a page".
allowed-tools: Read, Write, Glob, Grep, Ask, Eval
---

# plan-viz — visual plan dashboard

Produce a single self-contained HTML file that makes a markdown plan scannable, interactive, and memorable for an ADHD reader. The deliverable is the `.html` — everything else is scaffolding.

## Output contract

- **ONE file**: `<plan-name>-viz.html` next to the input plan (mirror the name + `-viz`). Everything inline: CSS, JS, SVG/canvas — no fonts, no CDN, no network. Must render from `file://` in any modern browser.
- **Zero text walls**: every concept is a card (icon + label + one-line caption; details behind a click-to-expand).
- **Every algorithm/concept in the plan gets a visual**: canvas or inline SVG that moves or responds (play / hover / slider). Static is the last resort.
- **Interactive settings explorer**: a slider/toggle per tunable constant that visibly changes the visuals/charts.
- **Before/after expected-outcome schematic** + the plan's evidence numbers (probes, pins, count deltas) as big metric chips.
- **Verification checklist** from the plan's Verification section — working checkboxes, persisted in localStorage.
- **Header**: title, status chip (review/approved/executing), source-plan link, per-section "~N min" chips, dark/light toggle, sticky section progress rail.
- **Keyboard**: arrow keys step through sections; every control tab-reachable; `prefers-reduced-motion` honored.

## ADHD design rules (non-negotiable)

1. **TLDR first, always**: first screen = title + 3–6 one-line outcome cards. No paragraphs before visuals.
2. **One idea per card**; captions ≤ 12 words. Expand for detail; never start expanded.
3. **Color = state, not decoration**: accents on interactive/active, green = ok, red = blocked, amber = changes behaviour. Max two accent hues + neutrals.
4. **Motion is purposeful and bounded**: growth/flow animations on play, progress fills, hover reveals. Nothing loops forever; everything has a pause.
5. **Numbers are visible**: every tunable shows its live value; metrics are big chips with units.
6. **Every section shows its cost**: a "~N min" chip and a skip affordance.
7. **Progress**: sticky rail + scroll progress + per-section done checkboxes. Finishing feels tangible.

## Process

1. **Read the plan** (the given markdown). Extract to a working map:
   - `title`, `status`, `date`
   - `outcomes` — TLDR/decisions, one bullet each
   - `pipeline` — the ordered steps/mechanisms the plan builds
   - `concepts` — the algorithms/structures named (e.g. wavefront Dijkstra, longest-edge bisection, Voronoi, A*, fbm octaves, seam chain, gates, rivers, fade-out)
   - `settings` — every tunable constant: name, default, range/step (infer ranges from the plan's pins; ask the user only if a range is genuinely ambiguous AND material)
   - `expected` — what output SHOULD look like (before/after description, probe numbers, pins, count deltas)
   - `verify` — the Verification steps + gates
   - `assumptions` — the plan's Assumptions/contingencies (become a Risks/Notes section)
2. **Match concepts to the library** (`references/concept-library.md`): each concept gets its canonical visual pattern (canvas sim or parameterized SVG). Adapt parameters from the plan's pins. Concepts not in the library → design a new visual following the same pattern.
3. **Assemble from `references/dashboard-template.html`**: keep the CSS/theme/nav/helpers; replace the demo content with the plan's cards/sims/settings; fill the settings explorer with the plan's REAL tunables wired to the sim delegates. The template's demo sims (wavefront, bisection, voronoi, fade chart) are the canonical patterns — adapt, don't delete, unless the plan's algorithm is fundamentally different.
4. **Settings-wiring rule**: every setting in the panel MUST drive at least one visual (sim OR chart OR metric). A dead slider is a bug — remove it or wire it.
5. **Sanity-check the file**: parse it (balanced tags, no stray `</script>`, unique section ids, every `SETTINGS` id handled by an `onChange`). When a browser tool is available, open `file://` + screenshot; fix anything broken. No external fetches.
6. **Deliver**: report the file path, what's inside (sections), headline numbers/chips, and how to open it. Do not dump the file into chat.

## Settings extraction rules

- Scan the plan for constants: `const X = N`, "pin N", tables with defaults, "tunables" lists, "range" mentions.
- For each: `{id, label, min, max, step, value(default), unit, effect}` — `effect` is the one-line what-changes ("higher = wider fade band").
- Ranges: default ± a sensible span; step ≈ 1/8 of the range; enums (e.g. stage 1..4) become list-selects.
- If the plan has no tunables section, settings come from its pipeline constants.

## Expected-outcome schematics

- **Before** — from the plan's "current/probe" evidence: draw the actual current output shape (grid rectangles + sliver column if that's the complaint; chunky terrain; no coastline).
- **After** — from the plan's intent: organic blobs, coast, rivers, hamlets, fringe.
- Label both with 3–5 metric chips (counts, areas) from the plan where they exist.
- If the plan only has prose, the schematic is clearly stylized — never invent numbers.

## Verification checklist

- One checkbox per gate/smoke assert from the plan's Verification; group by Backend / Frontend / Runtime. Click → persisted (localStorage key = `location.pathname + '#' + id`).
- Add a "Definition of done" group from the plan's tests list.

## File placement

- Default: same directory as the input plan, named `<plan-name>-viz.html`.
- User can override with a path — follow it.