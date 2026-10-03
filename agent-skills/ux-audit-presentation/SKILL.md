---
name: ux-audit-presentation
description: 'Runs a component-level feral UX audit and renders each proposed fix as a before/after page in a mockup-redesign presentation set. Chains feral-ux-audit and mockup-redesign. Invoked by explicit skill call only; it never auto-triggers.'
---

# UX Audit → Presentation

- TLDR: Audit the target's custom components in parallel feral subagents, merge into one severity-ranked findings report, then — only after the user approves the page list — render every proposed fix as a before/after page in a real-fidelity mockup set.
- TLDR: Two existing skills do the heavy lifting; this skill chains them and owns the glue: `skill://feral-ux-audit` (evidence rules, battery, report format, auditor templates) and `skill://mockup-redesign` (fidelity bar, set structure, comparability contract).
- TLDR: Read BOTH chained skills before running. This file is the pipeline; they are the standards.

## When to use / not for

- Use for: "review our components/screens for UX improvements" where the user also wants to SEE the proposed changes as before/after examples.
- Not for: fixing code (implement later from the report), visual polish/aesthetics (`design-audit` territory), whole-app journey audits without a mockup deliverable (plain `feral-ux-audit`), or greenfield mockups with nothing to compare against (`mockup`).

## Pipeline

### 1. Orient + surface map (main agent, before any dispatch)

- Inventory the target components from the repo layout (e.g. custom buckets vs stock library dirs — never audit the stock `ui/` component library; it is untouched by convention).
- Cheap grounding: frontend typecheck command, the route/view table, where each component is used.
- Decide `WALK_OK`: browser available? If subagents cannot drive a browser, run the whole audit as static state-trace (`evidence: static`) and spot-verify the top findings yourself afterward.
- Split the inventory into 2–4 balanced slices with EXPLICIT boundaries so nothing is audited twice (e.g. list & row primitives / dialogs, creation & command surface / settings, panels & chrome).

### 2. Dispatch auditors in parallel (one subagent per slice, same message)

- Read-only agents (scout-type). Per-slice task text = the auditor template at `skill://feral-ux-audit/component-auditor.md` filled in: `{SCOPE}` (the slice), `{SURFACE_MAP}` (component list with paths), `{STACK}`, `{USER_CONCERN}`, `{WALK_OK}` or the static-trace directive.
- Shared context block for every agent: worst-user mindset, judge against conventions + the app's OWN patterns, aesthetics out of scope, do-not-audit boundary (stock library, views), evidence rules, and the required six-section output format (see template).
- Call out likely failure modes per slice in the task text (e.g. hover-reveal affordances, keyboard-only entry paths, aria naming, state-set coverage).

### 3. Merge + verify (main agent)

- Dedupe cross-slice findings; group recurring failures into one cross-cutting theme (e.g. "hover-only affordances lack keyboard/touch fallbacks").
- Severity-rank: Proven UX bugs → Important → Minor → Convention violations → Unproven → Gratuitous Gold (use the feral-ux-audit report format).
- Spot-verify the top Proven findings in source (read the cited file:line yourself) before reporting. Unverified suspicion stays in "Unproven".
- Deliver the merged report. STOP here unless the user asked for the presentation up front.

### 4. Confirm the page list (`ask`, before generating anything)

- One page per proposal; show the numbered list with one-line descriptions; offer 3 scope options (all findings / proven bugs only / most-visible N). Never generate before confirmation.

### 5. Generate the presentation set (mockup-redesign workflow)

- Target `./mockups/<set-name>/`; copy `assets/shell.html` from the mockup-redesign skill; build `theme.css` by extracting the app's REAL tokens verbatim (token block + status palette + the exact class recipes of every component a proposal touches: rows, buttons, chips, badges, inputs, alerts, skeletons) with source-file comments. Never invent values.
- Page skeleton: plain grayscale chrome (finding citation with `file:line` at top, two labeled columns "Before — current" / "After — proposed", same data/layout in both, one-line fix note under AFTER). Only the proposed surfaces carry app fidelity.
- Icons ONLY via css.gg CDN. GOTCHA: `https://cdn.jsdelivr.net/npm/css.gg` serves JS — use `https://cdn.jsdelivr.net/npm/css.gg/icons/icons.css`.
- Verify before hand-off: screenshot at least two pages (one icon-bearing) with a headless browser; fix rendering; check shell lists all pages over HTTP.
- Serve with the one-liner + timeout in a labeled long-lived tab per repo rules: `timeout 600 python -m http.server <port> -d ./mockups/<set>`. Hand off `http://localhost:<port>/shell.html` and note the auto-stop + relaunch command.
- Iterate on feedback by editing the affected page file only — never regenerate the set.

## Red flags — never

- Auditing the stock component library or letting auditors fix code.
- Reporting a Proven finding you did not verify (code-read or browser walk).
- Generating pages before the user confirms the list.
- One-sided AFTER pages, different data between BEFORE and AFTER, invented token values, hand-written SVG — all violate the mockup-redesign contract.
- A mega one-file deck — one proposal per numbered page, shell for navigation.

## Defaults

- Slice size: ~15–20 components per auditor; 3 auditors covers a ~50-component library in ~5 min wall time.
- Presentation set name: `mockups/ux-audit-fixes/` for the general case; name by target for scoped runs.
- Page order: Proven bugs first (as ranked in the report), then Important, then high-value Minor.