---
name: code-flow-map
description: Data-driven architecture maps — packages as collapsible groups, files as nodes, generated package tree strip. Write JSON, render via cytoscape template, verify by screenshot.
---

# code-flow-map — data-driven architecture maps

## Files

- `template.html` — the renderer (cytoscape canvas: pan, wheel zoom, collapsible package groups, edge labels, tree strip). Copy it + `cytoscape.min.js` into the output dir; never edit a copy by hand.
- `schema.md` — full JSON schema for map files.
- `example.json` — minimal example map.
- `cytoscape.min.js` — vendored cytoscape 3.30.4 (no CDN at view time).

## Workflow

1. `cp <skill>/template.html <outdir>/template.html && cp <skill>/cytoscape.min.js <outdir>/`
2. Write `<outdir>/<name>.json` following `schema.md`.
3. Serve (fetch() needs http, file:// won't work):
   ```bash
   cd <outdir> && python3 -m http.server 8765
   ```
4. Open `http://127.0.0.1:8765/template.html?data=<name>.json` in the browser, screenshot, iterate **on the JSON only**.
5. Ship `template.html` + `<name>.json` together. The JSON is the single source of truth.

## Design rules

- **Packages are groups (dashed containers), files are nodes inside them.** A file node's label is the filename, a thin rule, then its core functions (`RunTurn()`, `Stream(model, msgs)`) one per line. The canvas must mirror the tree panel exactly.
- The **tree panel is generated** from the nested `tree` JSON (glyphs, file columns, `(new)` coloring are computed) — never hand-write tree text.
- Keep the dark palette from the template; override per-map via `palette` only for new semantic colors (e.g. a `new` accent).
- Every claim on the map must be verified against the code (real function names, real files). If the map says `AppendRequest()` the code must contain it.
- Proposal maps: `"new": true` on a container colors its title; on a node/line it adds a `＋` prefix in the accent color.
- Node ids may contain `/` or `.` — the renderer sanitizes them, so selectors and edges keep working.
- Layout is `preset`: you give each file node x/y/w/h inside its package; the group auto-sizes around its children. Leave ≥ 8px gaps; iterate on the screenshot.

## Interactions

- Wheel = zoom, gentler than cytoscape default: the template installs a capture-phase `wheel` handler on `body` that intercepts events over `#cy` before cytoscape and applies `ZOOM_PER_TICK` (≈ half the default sensitivity) around the cursor. Drag = pan.
- Click a package group's title band to collapse it to a chip; edges reroute to the group. Click again to expand. Cards inside stay untouched.

## Card text

- Card labels are an HTML overlay (`#labels`), not cytoscape labels: filename in the package accent color, thin rule, function lines in muted `soft`, `new: true` lines in the `new` accent with a `＋` prefix. A line may set `"c": "<palette key>"` for its own color. Overlay syncs on `cy.on("render")` and scales with zoom.
- Cytoscape native labels stay only on containers (collapse chips) and edges. Don't re-enable `label:"data(label)"` on box/list/note styles — labels would double-render.

## Verification

Always screenshot the served page before showing the user. Check: no clipped text, no overlapping boxes, edge labels not colliding, tree fully inside its panel. Iterate the JSON until clean. If you use synthetic events to test zoom/collapse, verify with real (`page.mouse`) events — synthetic ones don't always follow the same path.

## Gotchas

- NEVER set `cy.userZoomingEnabled = true` / `cy.userPanningEnabled = true` as properties: they clobber cytoscape's API methods and the internal wheel handler then dies silently (zoom/pan stop working). Both are enabled by default; don't touch them.
- Don't set `wheelSensitivity` — the default is right and a custom value triggers a deprecation warning.
- Node ids are sanitized before use (`/`, `.`, spaces → `-`); edge `from`/`to` go through the same mapping. Don't rely on raw ids in selectors.
