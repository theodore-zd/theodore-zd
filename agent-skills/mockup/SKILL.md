---
name: mockup
description: |
  Low-fidelity HTML mockup generator with defined fidelity and content standards:
  plain grayscale multi-page sets with exactly one accent color, real domain labels
  with token data, served via python http.server. Invoked by explicit skill call
  only; it never auto-triggers.
---

# Mockup

- TLDR: Low fidelity is enforced by plainness, not tooling — grayscale + exactly ONE
  accent color (default `#e8710a` in theme.css); deliberately plain and self-policed.
- TLDR: Real labels ("Projects", "Save") with token data (`<project name>`, `×N`);
  no lorem ipsum, no invented names/numbers, no filler text elements.
- TLDR: Multi-page sets over monolithic HTML; any set with more than one page uses
  the shell (shell.html) with numbered pages and iframe-swapped state variants.
- TLDR: Served with `timeout 300 python -m http.server <port> -d ./mockups/<set>`
  — five-minute auto-stop, no server script shipped.

Not for: algorithm/plan dashboards (`plan-viz`), auditing a running app
(`visual-audit`), UX critique of existing UI (`feral-ux-audit`).

## Standards

- Fidelity: deliberately plain, self-policed. Grayscale + exactly ONE accent color
  (default `#e8710a` in theme.css); gradients and icons allowed.
- Icons ONLY via the css.gg CDN (https://cdn.jsdelivr.net/npm/css.gg); NEVER hand-write SVG.
- Content: real domain labels ("Projects", "Save") — never generic placeholders.
- Variable data as tokens: `<project name>`, `×N`.
- No lorem ipsum, no invented names/numbers, no filler text elements.

## Set structure

- Assets `assets/shell.html` + `assets/theme.css` sit next to SKILL.md; they are COPIED
  into every mockup set, never referenced in place.
- Target layout: `./mockups/<set-name>/` — shell.html, theme.css, numbered pages
  `NN-name.html`, optional state variants `NN-name.variant.html`.
- Variants: small complete fragment docs — theme.css + one content region, zero JS —
  swapped into view by the shell's iframe (each remains directly openable).
- Any set with more than one page MUST use the shell; the serve command roots the
  set directory so http.server's directory listing lets any page open directly.

## Workflow

1. Restate the request as a numbered page list + applicable-state list; confirm with
   the user via `ask` BEFORE generating. User confirms or corrects.
2. Generate the pages and copy `assets/shell.html` + `assets/theme.css` into
   `./mockups/<set-name>/`.
3. Serve: run and print `timeout 300 python -m http.server <port> -d ./mockups/<set>`
   — port = python's default or a free one; give the shell URL
   `http://localhost:<port>/shell.html`.
4. Iterate on feedback: edit the affected page file only — NEVER regenerate the whole set.

## Red flags — never

- One massive HTML file for the whole set.
- Lorem ipsum, filler text, invented names/numbers.
- Hand-written inline SVG.
- Polish: shadows, real design-system styling — anything above the plain bar.
- Auto-triggering: runs only on explicit skill call.
- Generating before the page list is confirmed.
- Shipping a server script — the one-liner with the five-minute auto-stop is the
  whole server story.