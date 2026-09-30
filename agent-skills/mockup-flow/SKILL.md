---
name: mockup-flow
description: |
  Flow-map mockup generator with heavier visuals: multi-screen UI flow maps
  (wireframed screens wired by labeled navigation arrows on one canvas, like a
  game Kickstarter page) and p5.js-powered visual pages — grayscale + exactly
  ONE accent color, shell + numbered pages + variants, served via python
  http.server. Explicit skill call only; it never auto-triggers.
---

# Mockup Flow

- TLDR: Child of `mockup` — same content standards (real domain labels, token data,
  no lorem ipsum, no invented names/numbers), same set structure (shell + numbered
  pages + iframe-swapped variants), same serve one-liner with five-minute auto-stop.
- TLDR: Heavier visuals: pages carry focal p5.js sketches (CDN, pinned version) that
  read the theme CSS variables, so dark/accent variants tint the graphics automatically.
  Grayscale + exactly ONE accent still holds — the punch comes from motion and
  composition, not more colors.
- TLDR: Flow mockups: a page is a flow canvas — screens are wireframed `.frame` cards,
  navigation is drawn by `flow.js` connectors with action labels. The happy path
  (primary edges) uses the accent.
- TLDR: Confirm the flow map (screens, edges, arrow labels, primary path) with the
  user BEFORE generating.

Not for: plain wireframe sets with no flow and no sketches (`mockup`), algorithm/plan
dashboards (`plan-viz`), auditing a running app (`visual-audit`), UX critique of an
existing app (`feral-ux-audit`).

## Standards

- Inherits `mockup` standards wholesale: plain grayscale + exactly ONE accent color
  (default `#e8710a` in theme.css); real domain labels ("Log in", "My Account");
  variable data as tokens (`<user name>`, `×N`); no lorem ipsum, no filler.
- Icons ONLY via the css.gg CDN; NEVER hand-write SVG — connectors included
  (flow.js draws them with plain divs).
- Sketches use ONLY the theme palette via sketch.js (`MK.theme()`: paper/ink/line/
  muted/accent). A sketch that hardcodes hex values breaks every dark/accent variant.
- Frames are plain: 1.5px ink borders, rounded corners, muted header — no shadows,
  no polish above the wireframe bar.

## Set structure

- Assets `assets/shell.html`, `assets/theme.css`, `assets/flow.js`, `assets/sketch.js`
  sit next to SKILL.md; they are COPIED into every mockup set, never referenced in place.
- Target layout: `./mockups/<set-name>/` — shell.html, theme.css, flow.js, sketch.js,
  numbered pages `NN-name.html`, optional state variants `NN-name.variant.html`.
- Two page types, mixed freely in one set:
  - Content page — focal p5 sketch (hero) + sections, like `mockup` pages.
  - Flow page — `.flow-canvas` (position:relative, explicit min-height) holding
    `.frame` screens positioned with inline `style="left:…;top:…"`, wired by connectors.
- Variants: small complete fragment docs — theme.css + one content region, zero JS —
  swapped into view by the shell's iframe; each remains directly openable. Dark +
  accent theming ships as body classes (`body.dark`, `body.dark.violet|cyan|green`).
- Any set with more than one page MUST use the shell; the serve command roots the
  set directory so http.server's directory listing lets any page open directly.

## Frame anatomy (the vocabulary)

- `.frame` — one screen: `.frame-head` (screen name) + `.frame-body`.
- Primitives inside `.frame-body`: `.ph-img` (X-cross image placeholder), `.ph-line`
  (text line; `w60`/`w80` width variants), `.field` (label + input box), `.btn` /
  `.btn.primary` (primary = solid ink), `.chip`, `.avatar`, `.tabs`.
- Phone screens are ~230px wide; desktop frames wider. Give each frame an `id` —
  connectors anchor to it.

## Connectors (flow.js)

- `Flow.connect(fromId, toId, 'Label', opts)` — draws the navigation arrow between
  two frames: orthogonal elbow (`opts.via: 'h' | 'v'`, 'auto' by default), arrowhead,
  and a label chip carrying the action ("Log in", "Sign up", "Video 1st").
- `opts.primary: true` — the happy path: accent line + accent label; everything else
  stays gray. `opts.out` / `opts.in` (0..1) tune the exit/entry point along the edge.
- Connectors recompute on load and resize. Never hand-place connector divs, never
  hardcode their coordinates in CSS.

## Workflow

1. Restate the request as: numbered page list + the flow map (screens, edges, arrow
   labels, which edges are primary) + applicable-state list; confirm with the user
   via `ask` BEFORE generating. User confirms or corrects.
2. Generate the pages and copy the four assets into `./mockups/<set-name>/`.
3. Serve: run and print `timeout 300 python -m http.server <port> -d ./mockups/<set>`
   — five-minute auto-stop, no server script shipped. (macOS has no GNU `timeout`:
   emulate with a background `sleep 300; pkill` watchdog.) Give the shell URL
   `http://localhost:<port>/shell.html`.
4. Iterate on feedback: edit the affected page file only — NEVER regenerate the set.

## Red flags — never

- One massive HTML file for the whole set.
- Lorem ipsum, filler text, invented names/numbers.
- Hand-written inline SVG — icons or connectors.
- Polish: shadows, real design-system styling — anything above the plain bar.
- Frames overlapping, or connectors crossing through frames — reposition the map.
- Sketches hardcoding hex colors instead of the theme palette.
- Auto-triggering: runs only on explicit skill call.
- Generating before the page list + flow map is confirmed.
- Shipping a server script — the one-liner with the five-minute auto-stop is the
  whole server story.
