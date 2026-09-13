---
name: visual-audit
description: 'Trigger phrases: "visual audit", "visual pass", "take screenshots", "screenshot the app", "screenshots and annotations", "annotate screenshots", "visual issues", "visual QA", "visual QA pass", "screenshot review", "review the ui visually".'
---

# Visual Audit — screenshot-based UI review → annotated fix plan

Empirical visual QA against a RUNNING app: walk every surface sequentially (auth gate → shell → views → chrome → interaction states), capture deterministic screenshots via Playwright, have vision audits on each cluster, then deliver a markdown plan with the screenshots embedded as references and findings severity-ranked (P0/P1/P2) with suggested fixes.

Not for: heuristic UX critique without a running app / screenshots → `feral-ux-audit`; code-correctness bugs → `feral-audit`; architecture → `backend-arch-review` / `tension-review`.

Generalized from an executed full pass (Sept 2026) whose artifacts lived at `docs/visual-pass/<date>/` in that repo. The workflow is repo-agnostic: every repo-specific fact below is DISCOVERED in Phase 0, never assumed.

## Phase 0 — Recon: discover the repo's audit config (yourself, before writing anything)

1. **Live server(s).** Learn how the app runs: README "getting started", `package.json` scripts, `scripts/`, `docker-compose.yml`. Start the app's own server per its instructions — NEVER start servers/migrations yourself, ask the user. Probe candidate ports: `curl -s -o /dev/null -m 3 -w '%{http_code}\n' http://localhost:<port>/`. ⚠️ A port can be occupied by a DIFFERENT app — confirm the page title/content matches this repo; if the dev port collides, use the repo's other server (e.g. a built SPA served by the API) and note the collision in the report.
2. **Screenshot capability.** Locate the frontend package and Playwright: `test -d <pkg>/node_modules/playwright && echo yes`; browsers `ls ~/.cache/ms-playwright | head`; `ls <pkg>/node_modules/.bin 2>/dev/null | grep -i playwright`. If missing: `bunx playwright install chromium`.
3. **Route map.** Read the router / route table (SPA `router.svelte.ts` or equivalent, Next `app/`/`pages/`, React Router config, SvelteKit `routes/`). List the primary surfaces: auth pages, home/landing, list views, detail views, editors/pages, files, settings. Build the shot list from routes, never guesses.
4. **Auth surface & credentials.** Read the E2E script / CI config for the env-var contract (often `E2E_EMAIL`/`E2E_PASSWORD`), and see which env files those scripts source (an `<app>.env`-style app env, then `.env`). Source the same files when running the harness. Never invent creds; never commit them.
5. **Deterministic corpus.** If the repo has a reset/seed script for the E2E account (e.g. `scripts/reset-e2e.sh`), run it for a deterministic pass — unless real user data is the point.
6. **Seed API.** Read the API routes/server handlers to learn how to create data over `fetch`: entity shapes and the auth header (token from localStorage after UI login).

Rules: NEVER start servers/migrations yourself — ask the user. NEVER kill an unknown process owning a port (someone else's app may be on it).

## Phase 1 — Capture harness (throwaway script, deleted after the pass)

Write `<frontend-pkg>/.visual-pass.mjs`: `import { chromium } from 'playwright'` (resolves from the package's node_modules; run with `bun` from that dir).

- Viewport 1440×900, `deviceScaleFactor: 2` (crisp 2880×1800 PNGs).
- `OUT = <repo>/docs/visual-pass/<YYYY-MM-DD>/screens/`; `mkdirSync(OUT, { recursive: true })`; `shot(name)` → `NN-name.png` (zero-padded sequence). The md plan lives beside `screens/` in the same date dir.
- `BASE` = the live server from Phase 0; API = same origin.
- Login via the UI (discovered selectors, e.g. `input[type="email"]` / `input[type="password"]`, submit, wait for shell) — captures the real auth surface; grab the token from localStorage for seeding.
- Seed a deterministic corpus via Node `fetch` with `Authorization: Bearer`, shaped by the app's own API: entities across every state the visuals need. Example from the source pass (a task app): a project; tasks across all statuses with due dates overdue/today/upcoming; subtasks; tags; docs with query-embeds + wikilinks; folders; a comment; dated items. Date-only fields: `YYYY-MM-DD`. Seed failures: log and continue — a missing surface becomes a legitimate empty-state shot.
- Sequential capture with explicit waits (fixed delays + locator visibility; avoid `networkidle` under HMR). Wrap EVERY interaction block in try/catch → log `SKIP` and continue: one bad state must never kill the tail.
- Run: `set -a; source <repo app/E2E env files> 2>/dev/null; set +a; E2E_EMAIL="$E2E_EMAIL" E2E_PASSWORD="$E2E_PASSWORD" bun .visual-pass.mjs` (cwd = frontend pkg). Source the app/E2E env files the repo's scripts use, not storage-only env files (they can carry empty overrides of `E2E_*`).

## Phase 2 — Surface coverage (shot list)

Sequential and thorough, following the Phase 0 route map through this generic sequence: auth gate (empty login, filled login, signup) → landing/home (stats, recent, sections) → list views (full) → interaction states on the primary list: quick-add/search dropdown open, filter menu open, row hover (`mouse.move`), datepicker open (due-date trigger), status chip menu, keyboard `Tab` until a row's `:focus-visible` ring → detail (sub-items, chips, comments) → documents (editor with embeds, tree drawer open, dirty/save-chip state, second doc) → files (folders + empty state + drill-in) → settings → chrome: project/workspace switcher open, command palette (⌘K) open, create menu (⌘N) open. Target 20–30 shots. Capturing states beats capturing the same page twice.

If a design-system story server exists, cover it when it's already running; otherwise note it as a follow-up — don't start it.

## Phase 3 — Vision annotation (parallel fan-out)

- Fan out `scout` subagents in ONE `task` batch, each auditing a cluster (4–7 images) with a self-contained prompt: the screens dir path, exact filenames, the focus lens (e.g. auth/field grammar; interactions/focus rings; docs/files/embeds; chrome consistency), and the rule to read each image via `read <path>?q=<specific question>` (vision-over-text works on any model). Ask for: issue → exact location on screen → severity → suggested fix, AND what looks GOOD (so fixed/correct work isn't re-litigated).
- While agents run, spot-check the most plan-critical screenshots yourself via `read …?q=` (e.g. focus ring, save chip, hover states).
- Cross-validate before filing: an auditor's "defect" may be intended design or a misread — when code can settle it cheaply, verify (read the cited source lines) and mark code-verified claims. Disproven auditor claims are dropped, not shipped.

## Phase 4 — Deliverable

Write `docs/visual-pass/<YYYY-MM-DD>/plan.md`:

1. **TLDR** bullets: what was captured (count, surfaces), what holds up, top real defects, env caveats.
2. **Environment & capture notes** table: app URL, port collisions, seed corpus, not-captured surfaces + why, resolution.
3. **Verified-working (no action)** table: state + evidence screenshot.
4. **Findings** severity-ranked: P0 (visual bugs / quick wins), P1 (grammar & consistency), P2 (conscious decisions / nits). Each finding: id, screens, exact location (+ source citation when code-verified), suggested fix. Add a suggested execution order (P0 bundle → P1 bundle → P2).
5. **Screenshot index** table (# | file | shows), then ALL images embedded at the end as `![<name>](screens/NN-name.png)` relative refs so the plan renders from its own dir.
6. Verify the plan renders: every relative image ref resolves from the md's directory.

Screenshots and the plan are repo files the user decides to commit — don't commit unless asked. Delete the throwaway harness script after the pass. A downstream `fixes-plan.md` (findings → per-workstream fix steps with contracts) is what the user typically asks for next.

## Red flags

- Never hand a subagent a cluster without the screens dir path and exact filenames — they start blank.
- Never file an auditor claim without your own cross-check when code can settle it.
- Never let one timed-out interaction kill the capture tail — try/catch every block.
- Never start servers, kill processes, or use unverified credentials.
- Never edit app code during the pass — it is evidence-gathering; fixes come after, driven by the plan.