# code-flow-map JSON schema

The template renders with **cytoscape.js** (vendored as `cytoscape.min.js` —
no CDN at view time): canvas rendering with built-in pan (drag) and wheel
zoom (0.05–4×), bezier edges with arrowheads and labels, compound (parent)
nodes for package groups, and click-to-collapse on every group. Node labels
are multiline wrapped (left-justified): filename, a thin `─` rule, then the
function lines. `new: true` lines get a `＋` prefix in the `new` accent;
`badge: true` adds a `◐ ` prefix to the title. The package tree renders as a
generated HTML strip below the canvas.

Top level:

```json
{
  "title": "example — service map",
  "subtitle": "· what this map shows, one line",
  "palette": { "new": "#73daca" },
  "nodes": [ ... ],
  "edges": [ ... ],
  "tree": [ ... ]
}
```

`palette` overrides/extends the default colors. Default palette keys:
your own color names (e.g. `"palette": {"api":"#7aa2f7", ...}`) — referenced by nodes, edges, tree rows and panels; the template ships neutral defaults `c1..c10` (ten separated hues) plus `fg muted soft line panel panelbg new badge`. Container backgrounds get an automatic tint derived from the accent color.
Node ids may contain `/`, `.`, spaces — the renderer sanitizes them
(`[^\\w-]` → `-`) for selectors; edge `from`/`to` go through the same mapping.

## Nodes

Each node has `kind`. All coordinates are canvas units (1 ≈ 1px). Node
heights are content-driven: the renderer adds the rule-line height
automatically, so `h` only needs to cover title + lines at ~16px/line.

### `box` — one file, with its core functions
```json
{"id":"client/http.go","kind":"box","x":600,"y":60,"w":200,"h":66,
 "color":"client","title":"http.go",
 "lines":["Get() · Post()","retry() — backoff"]}
   {"t":"Stream(model, msgs) — one call"},
   {"t":"SSE chunk decode"},
   {"t":"per-call model param","new":true}
 ]}
```
- `id` required (edges reference it). `color` = palette key.
- `title` is the filename; the renderer draws the `─` rule under it.
- `new: true` on the node → `＋ ` prefix on the title.
- `lines`: `t` = text; `new: true` → `＋ ` prefix in the `new` accent; `c` = palette key to color just that line (default: muted `soft`).

### `tree` + `changes` — bottom strip

- The bottom strip is a flex row: the file tree (left) plus any number of `panels` (`data.panels = [{title, items|lines, color?}]`, lines formatted like card lines). These info panels live here, not on the canvas. `data.changes` is accepted as a single-panel shorthand.
- Tree rows support `files` (truncated at 46 chars with `…`), `desc` (third column, muted — one-line package purpose), `color` (palette key for the path), and `new` (`＋ ` prefix in the `new` accent). The desc column renders when any row has one.
- Click the tree title to collapse/expand the rows.

### `container` — one package (dashed group), children = its files
```json
{"id":"store","kind":"container","color":"store","title":"internal/store",
   "children":[
    {"id":"store/db.go","kind":"box","x":330,"y":262,"w":210,"h":66,
    "color":"store","title":"db.go","lines":["Open() — pool","Migrate()"]}
 ]}
```
- Child coordinates are absolute (same canvas space); the group auto-sizes
  around its children plus its padding. Don't set x/y/w/h on containers.
- `new: true` on a container colors its title with the `new` accent.
- Edges may reference the container id or any child id.
- Collapsed by click: children hide, group shrinks to a chip, edges reroute
  to the group. No JSON needed — it's runtime interaction.

### `list` — card listing items (e.g. a registry of types)
```json
{"id":"specs","kind":"list","x":40,"y":740,"w":210,"h":110,
 "color":"api","title":"Notes",
 "items":["george — curious · no write/edit",
          "planner — plan doc · read-only"]}
```

### `note` — plain panel with title + lines ("What changes")
```json
{"id":"changes","kind":"note","x":330,"y":470,"w":320,"h":96,
 "title":"What changes",
 "lines":["handlers validate then call the store",
          "one turn loop unchanged"]}
```

## Edges

```json
{"from":"api/handler.go","to":"client/http.go","label":"outbound",
 "color":"client","dash":true}
 "lx":300,"ly":128,"color":"agents","dash":true}
```
- `from`/`to`: node ids (sanitized like node ids).
- Bezier curve with a triangle arrowhead; `dash: true` → dashed.
- `label` renders at the curve midpoint; `lx`/`ly` override the label
  position when the midpoint collides with a node or another label.
- `color` (palette key) colors the line, arrowhead, and label.

## Tree

`tree` is an array of roots; each renders as one column of the bottom strip.

```json
"tree": [
 {"name":"example/",
  "children":[
    {"name":"cmd/","files":"main.go","color":"api","desc":"wiring"},
    {"name":"internal/agent/","files":"loop registry types sink"},
    {"name":"internal/api/","new":true,"files":"server.go handler.go",
     "children":[
       {"name":"default/","files":"spec.go","new":true},
       {"name":"george/","files":"spec.go","new":true}
     ]},
    {"name":"internal/","files":"tui webserve logging secrets scaffold"}
  ]}
]
```
- Glyphs (`├─`, `└─`, `│`) computed by the template; `name` at depth 0 renders bare.
- `files` is placed in a column aligned to the widest path in that root.
- `new: true` → `new` palette color.
- One row per directory, matching the canvas groups. `files` lists real file
  names; proposed files get `"new": true` on the row.
- Strip title is fixed: "Package structure — real tree, (new) = proposed".
