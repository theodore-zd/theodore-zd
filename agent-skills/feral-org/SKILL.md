---
name: feral-org
description: 'Trigger phrases: "feral org", "aggressively organize", "organize this code", "maximize reuse", "componentize this", "dedupe and reuse", "code organization pass", "reuse sweep", "org sweep".'
---

# Feral Org

- TLDR: Aggressive *execution* sweep of whatever target the user names (a file, directory, package, route, feature, or diff) — the org pass, not a critique. Output is applied reorganization plus a design-system doc diff, not a findings report.
- TLDR: Stance: assume the author copy-pasted; every inline duplicate of something shared is guilt until replaced. Reuse before write, componentize toward the project's own components, simplify with a simplicity tax. Nothing is too small to dedupe, nothing is too sacred to move.
- TLDR: Contract: obey the repo's organization conventions first (AGENTS.md, then design docs / component catalog); where conventions are missing, STOP and brainstorm them with the user before organizing (see Rules below). Rules are the point — every recurring uncovered pattern becomes a new AGENTS.md rule the user approves.
- TLDR: Execution: orient → map the target AND repo-wide duplication for its patterns → parallel per-layer organizer subagents (frontend / backend) → merge their move-proposals into a ledger → approve themed batches (strip-style) → apply + verify each → sync the design-system doc → prompt new rules per discovery → hand deterministic rules to feral-lang.

Not for: bug hunting (`feral-audit`), deleting dead weight (`strip` — if feral-org finds dead/unreferenced code it flags it and recommends the user run strip; it never deletes), review-only component structure (`component-structure-review`), architecture/layering (`backend-arch-review`), tension hunting (`tension-review`), standalone lint/format setup (`feral-lang`).

## Stance — the organizer rule

1. **The author copy-pasted.** Any 2nd occurrence of ~90%-similar logic, markup, or state shape is duplication until proven otherwise.
2. **Reuse before write**: if a shared component/util already exists that satisfies the need, replace the inline copy even at ONE site (no rule-of-three for existing assets). API mismatch is not an excuse — adapt the callsite; if the shared thing is wrong for all sites, that is a RULE-NEW candidate, not license to fork it.
3. **Extract at first duplication**: a NEW abstraction is created only when the SAME logic/markup appears 2+ times in the target slice or its repo-wide siblings (see Dispatch). 2nd occurrence → extract; never extract a singleton into a helper with one caller (that is a simplification, see below, not an extraction).
4. **Componentize toward own components**: markup matching a lib/component's contract is swapped in; repeated view markup patterns (empty states, loading/error scaffolding, row actions, list headers) are extracted into the repo's shared component dir; new components are named and shaped per the repo's design doc conventions.
   - **Raw controls are guilt until proven otherwise**: a raw `<button>` / `<input>` / `<textarea>` / `<select>` rendered in view/component/shell code while the repo's component catalog ships a primitive for it (Button, IconButton, Input, MenuRow, TabBar, Select, Checkbox, …) is a REUSE row even at ONE site — swap the catalog primitive in, transferring the site's class string BYTE-FOR-BYTE through the primitive's `class` prop (see `frontend-organizer.md` checklist family 9). The primitive's own variants are the override mechanism — chromeless button variants (`link`/`chip`/`field`) and `Input variant="plain"` contribute no conflicting geometry/colors, so sites pass their full original class string verbatim; never fight a base class by appending a different value for the same property (Tailwind v4 resolves same-property conflicts by compiled stylesheet order, not class-attribute order — the base class wins).
   - **Where raw elements are legal**: inside the catalog primitives' own internals (they are the extraction home — e.g. Button/Input themselves, Select's `<option>`s, DatePicker's roving day-cells), plus a documented KEEP-raw whitelist of non-control structural elements — overlay backdrops/click-catchers, hidden file inputs, upload dropzones, roving calendar-grid day cells, complex per-kind tree rows, row-card `<div role="button">`s. Anything outside that whitelist converts in the same run; whitelist items get a `<!-- KEEP-raw: reason -->` comment where sensible.
5. **Simplify with a tax**: every simplification (dead arg, redundant branch, collapse, merge) must carry a simplicity tax — lines/abstractions removed vs added. Simplifications that remove code beat extractions that add layers; when a rule conflicts, prefer fewer total moving parts.
6. Nothing is above reorganization — stores, api modules, shell chrome, services, db helpers. But NEVER delete code (that's strip's job) and NEVER change behavior or public API shape without flagging it in the proposal (see Contract).

## Contract — what "organized" means

1. Repo conventions come first: `AGENTS.md` (auto-loaded; may also be `CLAUDE.md`) and repo docs (design system, `docs/`, `api.md`, README). The skill applies the organization the repo already declared.
2. Infer per-directory homes from the existing layout (where do utils live, which dir holds shared components, is there an api layer) — mirror it; never invent a second convention beside an existing one.
3. **If the conventions are missing or ambiguous for what the target needs** (e.g. no utils home, no component catalog, no rule covering the pattern), do NOT guess: run one batched `ask` presenting (a) drafted conventions to adopt, or (b) a default layout to use for this run only. Only after the user answers does organizing proceed. Brainstorming conventions is part of the job, not a failure.
4. Proposals that change a public/exported API or observable behavior are marked `API:` in the ledger and their batch label names it, so approval is explicit.

## Dispatch

**1. Orient (main agent).** Read the target: file list, entry points. Cheap grounding: `go vet ./... 2>&1 | head -30` and `cd frontend && bun run check` only if the target touches those trees (targeted runs may not need full-repo checks; the gate commands in Approval run regardless).

**2. Map the target + repo-wide duplication scan.** From the target's files, list every function/component/store/markup pattern present. For each pattern that looks shared-able, run the repo-wide sibling scan (grep/ast_grep for identical or near-identical bodies; search the utils home and components dir for an existing equivalent FIRST). Produce a **coverage map**: every file in the target, every pattern, plus where each pattern's siblings live.

**3. Slice per layer, dispatch in parallel.** One organizer subagent per layer the target touches: frontend → `skill://feral-org/frontend-organizer.md`, backend → `skill://feral-org/backend-organizer.md`. Give each its exact file slice (non-overlapping), the repo conventions summary, the repo-wide sibling findings, and the rule: PROPOSALS ONLY, never edit. Coverage must be explicit so no file is organized twice and none skipped.

**4. Assemble (main agent).** Merge returned move-proposals into one **move ledger** (rows as specified below), dedupe overlaps, link cross-layer moves, group into themed batches.

**Move ledger row format** (each row is one concrete, reviewable move):
`TYPE | file:line | what exists now → what it becomes | reuse target (existing symbol or new) | simplicity tax (+X/-Y lines) | gate needed`
Types: `REUSE` (swap inline → existing shared), `EXTRACT` (new util/component from 2+ sites), `SIMPLIFY` (delete/merge/collapse), `COMPONENTIZE` (new component), `DOC-SYNC` (design-doc entry), `RULE-NEW` (AGENTS.md rule proposal), `LINT-ENFORCE` (hand to feral-lang), `API:` prefix when exported shape/behavior changes.

**REUSE default**: when a finding's remedy could be either reuse of an existing
shared asset or a new abstraction, propose the REUSE row — even at one site —
and let `EXTRACT` fall out only where the target slice shows 2+ occurrences of
a pattern with no shared home. Reuse rows need no rule-of-three; the catalog or
utils home is the extraction home already done.

## Approval — batched, strip-style

1. Group ledger rows into themed batches (e.g. "Extract view loading/error helper", "Reuse EmptyState in shell", "Promote uuid parse helper", "Simplify X", "Sync components.md", "New rule: X"). Each batch = one `ask` entry with a grouped multi-select (mirror strip's pattern: one question listing batches, multi-select on).
2. Apply ONLY approved batches, in order. After EACH batch, run its gate before touching the next:
   - Frontend touches: `cd frontend && bun run check` (+ `bun run build` when a new component/asset ships).
   - Backend touches: `go build ./...`, `go vet ./...`, and `go test ./...` (or the affected package's tests when the touch is package-local).
   - Both: both gates.
3. A failed gate on a batch = revert that batch's edits (git restore of touched paths), report, and continue with remaining approved batches. Never commit a batch that fails its gate.
4. Unapproved rows are NOT applied and are reported in "Remaining".

## Design-system doc sync

The components list is a deliverable, not an afterthought.

1. Discover the design-system doc by glob, in this order, first hit wins: `docs/design/components.md`, `docs/design-system.md`, `docs/components.md`, `components.md`, `**/components.md` under a docs dir. (Atluo: `docs/design/components.md`.)
2. After each batch that touches shared components/utils: add or update entries for every component or shared util the batch created or changed, following the doc's existing format (Atluo: `### Name.svelte` + Props table for primitives, table row for shared components — mirror the doc, do not invent a format). Shared utilities live in their own "Shared utilities" section listing the canonical helper home + exported names, IF the doc has no such section (Atluo has none — add it, mirroring §2's table style).
3. Doc drift found during the run (shared components with no entry, props missing from tables) becomes its own `DOC-SYNC` ledger batch for approval, matching the repo rule "add it to the catalog when it ships".
4. If NO design doc exists anywhere and the run created shared components/utils: propose creating `docs/design/components.md` (minimal: the repo's own format) as a `DOC-SYNC` batch — approval-gated like everything else.
5. Docs are updated in the SAME commit/batch as the code that changed them (repo rule).

## Rules — prompt per discovery

1. Whenever the ledger or the run surfaces a recurring pattern NOT covered by an existing AGENTS.md rule — extraction homes, component conventions, api-boundary rules, state-shape rules, naming — STOP mid-run and ask with a drafted rule: `ask` presenting the exact rule text (concrete, imperative, in the style of the repo's existing AGENTS.md bullets), its suggested section/location, and approve / edit / reject. One batched ask can hold several drafted rules; do not batch a rule prompt together with unrelated approval questions.
2. Approved rules are appended to the repo's conventions file (AGENTS.md, or CLAUDE.md if that is the repo's bible; create AGENTS.md only if neither exists and the user approves). Keep the file's existing heading style.
3. If the rule is deterministically machine-enforceable (formatting, import order, banned API, file layout, naming pattern), mark it `LINT-ENFORCE` in the ledger and collect it for the feral-lang handoff (Enforcement handoff below). Non-enforceable rules stay as conventions the organizer itself obeys next run.

## Report format

```
## Feral Org — {TARGET}
### Trigger / Scope / Coverage
### Applied — per batch: rows + gate results
### Reuse & extraction ledger (counts by TYPE)
### Simplifications (simplicity tax each)
### Design-system doc diff (components.md changes)
### Rules — new/changed in AGENTS.md (verbatim)
### Enforcement handed to feral-lang (LINT-ENFORCE list)
### Remaining (unapproved/deferred rows)
### Gate results (final full check state)
```

## Enforcement handoff

If ≥1 `LINT-ENFORCE` rule was approved, the final phase loads `skill://feral-lang/SKILL.md` and dispatches the deterministic-enforcement work with the rule list. If skill:// cross-skill resolution fails, fall back to reading `/home/theo/.omp/agent/skills/feral-lang/SKILL.md` directly and following it. If zero rules, this phase is skipped silently.

## Red flags — never

- Run without a user-named target (targeted-only is the contract; never self-select whole-repo scope).
- Reorganize before the user approves a batch — proposals only until then.
- Skip the repo-wide sibling scan before declaring a pattern unique or duplicated.
- Create a new abstraction where an existing shared component/util already satisfies the need.
- Extract a singleton (one caller) into a helper.
- Leave a raw `<button>`/`<input>`/`<textarea>`/`<select>` in view/shell/component code when the repo's catalog already ships the primitive (swap it; controls outside primitives and the KEEP-raw whitelist are guilt until replaced).
- Convert something on the KEEP-raw whitelist (backdrops, hidden file inputs, dropzones, roving grid cells, complex tree rows, row-card divs) or "fix" a primitive's internals — those are the extraction home, not violations.
- Edit without running the batch gate; commit a batch that failed its gate.
- Leave the design doc stale after touching shared components (DOC-SYNC is mandatory, not optional).
- Delete or rewrite dead code — flag it and defer to `strip`.
- Invent a second convention beside an existing one (second utils home, second empty-state pattern, second api-call path).
- Dispatch per-layer organizers serially — parallel or not at all.
- Let a subagent edit production code — subagents propose; the main agent applies approved batches only.
