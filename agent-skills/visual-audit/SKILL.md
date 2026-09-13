---
name: visual-audit
description: 'Trigger phrases: "visual audit", "visual pass", "take screenshots", "screenshot the app", "screenshots and annotations", "annotate screenshots", "visual issues", "visual QA", "visual QA pass", "screenshot review", "review the ui visually".'
---

# Visual Audit — screenshot-based UI review → annotated fix plan

Empirical visual QA against a RUNNING app: walk every surface sequentially (auth gate → shell → views → chrome → interaction states), capture deterministic screenshots via Playwright, have vision audits on each cluster, then deliver a markdown plan with the screenshots embedded as references and findings severity-ranked (P0/P1/P2) with suggested fixes.

Not for: heuristic UX critique without a running app / screenshots → `feral-ux-audit`; code-correctness bugs → `feral-audit`; architecture → `backend-arch-review` / `tension-review`.

Proven end-to-end on the Atluo app — complete worked example at `/home/theo/Work/Atluo/docs/visual-pass/2026-09-12/` (`plan.md`, `fixes-plan.md`, `screens/`). Atluo-specific defaults are marked below; adapt ports/credentials/routes per repo.

## Phase 0 — Survey (yourself, before writing anything)

1. Verify servers: `for p in 5173 3001 3993; do echo -n "$p: "; curl -s -o /dev/null -m 3 -w '%{http_code}\n' http://localhost:$p/ || echo down; done` (Atluo: Go API+SPA `:3001`, Vite dev `:5173`, Storylite design system `:3993`). ⚠️ A port can be occupied by a DIFFERENT app — if `:5173` doesn't serve the repo's app (check the page title/content), use the repo's own server (Atluo: `:3001` serves the built SPA) and note the collision in the report.
2. Screenshot capability: `test -d frontend/node_modules/playwright && echo yes`; browsers `ls ~/.cache/ms-playwright | head`; `ls frontend/node_modules/.bin 2>/dev/null | grep -i playwright`. If missing: `bunx playwright install chromium`.
3. Map routes by reading the router (Atluo: `frontend/src/lib/router.svelte.ts` — `/`, `/login`, `/signup`, `/p/:uuid`, `/p/:uuid/tasks`, `/p/:uuid/docs/:doc`, `/p/:uuid/settings`). Build the shot list from routes, never guesses.
4. Credentials: read the E2E script for the env-var contract (Atluo: `scripts/test-e2e.sh` requires `E2E_EMAIL`/`E2E_PASSWORD`, sourced from `atluo.env` then `.env`). Never invent creds; never commit them.
5. Reset the E2E account for a deterministic corpus (Atluo: `./scripts/reset-e2e.sh`), unless real user data is the point of the pass.

Rules: NEVER start servers/migrations yourself — ask the user. NEVER kill an unknown process owning a port (someone else's app may be on it).

## Phase 1 — Capture harness (throwaway script, deleted after the pass)

Write `<repo>/frontend/.visual-pass.mjs`: `import { chromium } from 'playwright'` (resolves from frontend/node_modules; run with `bun` from the frontend dir).

- Viewport 1440×900, `deviceScaleFactor: 2` (crisp 2880×1800 PNGs).
- `OUT = docs/visual-pass/<YYYY-MM-DD>/screens/`; `mkdirSync(OUT, { recursive: true })`; `shot(name)` → `NN-name.png` (zero-padded sequence). md lives beside `screens/` in the same date dir.
- BASE = the repo's live server (Atluo: `http://localhost:3001`); API = same origin.
- Login via the UI (`input[type="email"]` / `input[type="password"]`, submit, wait for shell) — captures the real auth surface; grab the token from localStorage for seeding.
- Seed a deterministic corpus via Node `fetch` with `Authorization: Bearer` (Atluo: project; 9 tasks across 5 statuses with due dates overdue/today/upcoming, subtasks, tags; 2 docs with `task_query` embeds + wikilinks; folders; a comment; daily tasks). Seed failures: log and continue — a missing surface becomes a legitimate empty-state shot.
- Sequential capture with explicit waits (fixed delays + locator visibility; avoid `networkidle` under HMR). Wrap EVERY interaction block in try/catch → log `SKIP` and continue: one bad state must never kill the tail.
- Run: `set -a; source <repo>/atluo.env 2>/dev/null; source <repo>/.env 2>/dev/null; set +a; E2E_EMAIL="$E2E_EMAIL" E2E_PASSWORD="$E2E_PASSWORD" bun .visual-pass.mjs` (cwd frontend). Source the app/E2E env files, not storage-only env files (they can carry empty overrides of `E2E_*`).

## Phase 2 — Surface coverage (shot list)

Sequential and thorough: auth gate (empty login, filled login, signup) → landing (home: stats, heatmap, Today, Recent) → list views (full) → interaction states on the primary list: quick-add/search dropdown open, filter menu open (status + tags), row hover (`mouse.move`), datepicker open (due-date trigger), status chip menu, keyboard `Tab` until a row's `:focus-visible` ring → detail (subtasks, chips, comments) → documents (editor with embeds, tree drawer open, dirty/save-chip state, second doc) → files (folders + empty state + folder drill) → settings → chrome: project switcher open, command palette (⌘K) open, create menu (⌘N) open. Target 20–30 shots. Capturing states beats capturing the same page twice.

If a design-system story server exists (Atluo: Storylite `:3993`), cover it when it's already running; otherwise note it as a follow-up — don't start it.

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