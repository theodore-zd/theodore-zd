# plan-viz concept library

Canonical visual patterns for the algorithms/mechanisms plans typically name. Each entry: **when to use**, **the visual**, **canonical snippet** (adapt — the dashboard template already implements 1–5; these are the reference patterns), **settings to wire**, **labels**.

Compose with the template: keep its CSS/theme/nav/helpers; drop a `.panel` per concept; wire every slider to at least one sim/chart. All sims must be pure functions of the plan's params — use a seeded `rand(seed)` (template helper), never `Math.random` at draw time.

---

## 1. Wavefront / frontier growth (Dijkstra-style spread)

**When**: plans that "grow" a region from sources (roads, seeds) with or without barriers; growth-time fields; city-from-roads.

**Visual**: grid where a front spreads outward from white source cells, blocked by water/river/steep cells; developed cells fill solid, fade-band cells hatch amber, unreached stay dark. A legend + play/pause makes the "spread" concept land.

**Settings to wire**: full radius (`G_MAX`), outer band (`HORIZON`), seed, barrier on/off, fade strength.

**Pattern** (template `simWave`): precompute BFS distance + source-tag once per settings change; animate by revealing cells with `dist <= tick`; `hash2(x, y, seed)` drives the probabilistic fade band. Keep the barrier test a pure function of (x, y) so configs re-run cleanly:

```js
const water = (x, y) => y < 8 || y > H-8 || (x-60)**2 + (y-70)**2 < 90;   // coast + lake
const river = x => x > 30 && x < 34;                                      // river band
// in the BFS relax: if (water(nx,ny) || river(nx)) continue;  → impassable
```

If the plan's growth is slope-cost (cost = distance + slope × Δelev), add a deterministic elevation hash into the relax cost — the front then reads irregular, which is exactly the point. Label the stream: "per-cell jitter, one draw per cell, pinned scan order".

## 2. Longest-edge bisection (split subtrees)

**When**: any "split until target area" subdivision (districts, blocks, some parcels).

**Visual**: one organic blob on canvas; each recursive split draws a cut line through the longest edge's midpoint, perpendicular; the two halves color differently; subdivide deeper on playback. Slider = split budget.

**Pattern** (template `simSplit`): recursive `split(ring, budget)`; longest-edge scan, perpendicular cut through midpoint, filter halves, recurse with `budget>>1 | half`. Mirror the plan's naming (`DISTRICT_TARGET`, `count = clamp(round(area/target), 1, 16)`).

**Labels**: "longest edge → cut → two organic halves"; caption the degenerate-input warning if the plan mentions it ("bisection only looked square because the input was the full-canvas rectangle").

## 3. Voronoi cells (per-district parcels, tessellation)

**When**: Voronoi parcels/sites, "nearest site" segmentation, catchment attribution at parcel scale.

**Visual**: raster nearest-site fill (2-4 px steps) so cells genuinely read as Voronoi; site dots on top. Slider = site count or target area; reseed button.

**Pattern** (template `simVoro`): seeded sites; paint per-pixel nearest site. Add min-angle / floor sliver notes as a checklist chip, not a canvas overlay.

```js
for (let py = 0; py < H; py += 2) for (let px = 0; px < W; px += 2){
  let bi = 0, bd = 1e18;
  for (let i = 0; i < sites.length; i++){ const d = (px-sites[i][0])**2 + (py-sites[i][1])**2; if (d < bd){ bd = d; bi = i; } }
  ctx.fillStyle = pool[bi % pool.length]; ctx.fillRect(px, py, 2, 2);
}
```

**Labels**: "PARCEL_TARGET 30 / FLOOR 14 / MAX 8"; "cells < floor² or < 12° dropped".

## 4. A* / path routing

**When**: roads routed over terrain, any "route a polyline through a field avoiding cost".

**Visual**: canvas grid with an elevation tint; the path drawn as a polyline that bends around high-cost blobs; erode/smooth note (Laplacian passes). Animate the open/closed cells faintly then the final path.

**Pattern**: two-tone cost field via `hash2` blobs; draw straight-ish start/goal, then the smoothed path (offset from straight line where cost is high):

```js
ctx.strokeStyle = '#e8ecf3'; ctx.lineWidth = 2.5;
ctx.beginPath(); pts.forEach((p,i) => i ? ctx.lineTo(p[0],p[1]) : ctx.moveTo(p[0],p[1])); ctx.stroke();
```

**Labels**: "SLOPE_W × Δelevation step cost", "8-dir grid, (f, j, i) tie-break", "SMOOTH_PASSES`.

## 5. fbm / noise octaves

**When**: terrain detail, "more octaves", "higher resolution noise", warping.

**Visual**: a line chart of an fbm signal — draw octave 1..n as progressively smaller-amplitude, higher-frequency curves, then the summed signal; a slider adds octaves live.

**Pattern**: reuse the template's `drawFade` chart plumbing (X/Y helpers); curve per octave:

```js
const oct = (d, n) => { let v = 0; for (let k = 1; k <= n; k++) v += Math.sin(d * k * 2.1) / k; return v; };
// draw with per-octave alpha, then the sum as the bold top curve
```

**Labels**: "persistence ½", "8 octaves vs 5 → finer relief at every zoom", "domain warp stretches space".

## 6. Island / coast ring (distance field + edge buffer)

**When**: land/water, coastline, islands, city-bounded-by-coast.

**Visual**: radial distance falloff chart (0 center → 1 border) with a sea-level line; the "coast ring" drawn as an SVG bezier blob with the 4 arc extrema marked (N/E/S/W dots) — this is also the gate mapping visual.

**Pattern**: reuse the fade chart for the distance falloff:

```js
// e = raw * (1-mix) + (1-d) * mix ; water where e < seaLevel
const mix = 0.7, sea = 0.5;
const curve = d => (1 - d) * mix; // schematic: raw ≈ 0.5
```

**Labels**: "edge-buffer water ring → ragged coast, no straight edges", "corners are water".

## 7. Gates on coast arcs

**When**: gates/endpoints reinterpreted against the coast, seams between cities/roads.

**Visual**: the coast ring SVG with 4 arcs between the N/E/S/W extrema; a draggable `t` marker (0..1) on one arc and a live road line to the opposite arc; the same-arc case shown hatched ("may hug the coast").

**Pattern**: inline-SVG ring path + per-fraction point helper:

```js
const ptOnRing = (ringPts, frac) => { /* walk ring edges, interpolate at frac */ };
```

**Labels**: "edge 0..3 = N/E/S/W arc, t = fraction along the arc", "gated endpoints consume zero draws".

## 8. River steepest descent

**When**: rivers, valley carving, water barriers.

**Visual**: small elevation field (hash blobs); a dot marking the high-land seed; the descent path drawn cell-by-cell to the coast; then the river band highlighted as a wall; a bridge dot where a road crosses.

**Pattern**: greedy descent on a coarse grid:

```js
let x = sx, y = sy; const path = [[x,y]];
while (!coastNear(x,y)){ // pick neighbor with min elevation (tie: lower y, then x)
  const n = neighbors(x,y).sort(byElev)[0]; x = n.x; y = n.y; path.push([x,y]);
}
```

**Labels**: "seeds: elev ≥ 0.72, ≥ 160 from coast, ≥ 384 apart", "band RIVER_HALF impassable", "road crossing → is_bridge: true".

## 9. Fade-out / hamlet clumps

**When**: rural fringe, gradual fade, scattered outskirts.

**Visual**: the fade curve chart (template `drawFade`) PLUS a scatter of hamlet dots just beyond the developed edge in the wavefront canvas; slider shifts the band and the scatter.

**Pattern**: curving `1 - ((d-GM)/(HZ-GM)) * 0.95 * K` (template); hamlet dots = rand() points drawn only inside `(G_MAX, HORIZON]` band.

**Labels**: "fringe cells ≥ 3×PARCEL_FLOOR² become hamlet districts; smaller → countryside".

## 10. Stage prefix / truncation

**When**: stage params, previews, "every stage is a prefix of the last".

**Visual**: four stacked horizontal layers (roads, districts, parcels, buildings); a slider/step buttons light layers 1..4 — each lit set is a prefix; empty layers shown as `[]` chips.

**Pattern**: four divs, toggle `on` class; or a canvas bar. One line each:

```js
const on = n => { ['roads','districts','parcels','buildings'].forEach((k,i)=> $('#'+k).classList.toggle('on', i < n)); };
```

**Labels**: "stage 1-4, default 4", "empty layers are [] never null".

## 11. Seam chain / shared-edge snapping

**When**: "shared edges bit-exact", seam snap, dust cleanup.

**Visual**: two adjacent polygons whose shared edge is highlighted as one dashed line (matching endpoints), a marker showing where a vertex snapped onto the neighbor's edge.

**Pattern**: simple SVG; highlight the shared segment with `stroke-dasharray`; caption "seams collapse to bit-exact shared vertices".

**Labels**: "nearest-point repair", "only cross-parcel candidates (j != i)".

## 12. Before/after schematic

**When**: always, in the Expected section (template `.ba`).

**Visual**: two side-by-side SVG map mockups — Before drawn from the plan's probe evidence (grid rectangles, sliver column, chunky grid), After from its intent (organic blobs, coast, rivers, hamlets). Metric chips under each (3–5 numbers from the plan).

**Pattern**: template's `.ba` block; hand-tune two inline SVGs. Never invent numbers; caption "schematic" if the plan lacks probes.

**Labels**: chips = counts/areas/widths from the plan's evidence.

---

## Assembly checklist

- Every plan concept matched to an entry above (or a new `.panel` in the same idiom).
- Every setting drives ≥ 1 visual; no dead sliders.
- Every visual is pure-w.r.t. params: `rand(seed)` for randomness, never draw-time `Math.random`.
- Captions ≤ 12 words; details behind `<details>`.
- Chips carry real plan numbers; verification checklists mirror the plan's Verifications section.
- Reduced-motion + keyboard nav preserved (template defaults).