---
name: reorganize-codebase
description: 'Reorganize a codebase end to end: file/folder layout, function moves (including extracting god-files), and symbol renames across all references. Proposes a plan, waits for confirmation, executes, and verifies. Invoked by explicit skill call only; it never auto-triggers.'
---

# Reorganize Codebase

Moves code: files, folders, functions between files, symbol renames across all references, and DRY deduplication of repeated logic, then proves nothing broke. Language-agnostic — never assume a build tool; discover it from the repo.

Not for: architecture design or "what should the structure be" ideation (that is `improve-codebase-architecture`), bug fixes, or style cleanup. This skill executes reorganization, it does not invent architecture.

## Non-negotiable rules

### Governing principles (apply to every move)

1. **Separation of concerns** — every file has one reason to exist. Entry points (cmd/, main, bootstrap) are wiring only: env, flags, HTTP/TTY I/O, dependency construction. Domain logic lives in domain packages and never leaks into wiring; wiring logic never leaks into domain code. Every proposed move must state which boundary it enforces — a move that cannot name its boundary is a guess, not a reorg. When one file is doing two jobs (say, a generation loop that also contains tool execution, entry helpers, and preview formatting), the file is split along those job lines even if the resulting files are smaller than any size heuristic would demand.

2. **Locality of behavior** — code lives next to what it belongs to, grouped by domain/feature rather than by type. A tracer goes in `trace/`, a tool goes in `tools/` with its helpers; never in a grab-bag. Genuinely global utilities — string manipulation, byte/JSON helpers, timestamp formatting — are allowed in a shared utilities package (e.g. `internal/strutil/`, `pkg/textutil/`) when they are generic enough to be needed across two or more packages, now or foreseeably. What is never allowed is a `utils/` or `helpers/` package that functions as a dumping ground for domain-specific code whose real home is a domain package. The test: if the function mentions domain nouns (tasks, spans, requests, tools), it is not a global util — it lives with its domain.

3. **Modularity at file scale** — the practical unit of modularity is the file, not the package. One file ≈ one concern; a reader should be able to say in one sentence what any file does. Split when concerns genuinely diverge — usually visible past ~300–500 lines, but size alone is never the trigger: a 600-line file that is one cohesive widget stays whole, while a 215-line file mixing a tool definition with a pattern engine gets split. The split lines are the seams the concern boundaries make, not arbitrary page breaks.

4. **KISS is the stop signal** — do not extract an interface with one implementation, do not create a config package, do not add a wrapper layer, because an article or checklist suggested it. Single-concern files inside one package beat premature abstraction every time. Before proposing any new abstraction, name the second concrete thing that would use it; if you cannot, KISS says stop.

5. **DRY overrides KISS for shared code** — the KISS stop signal does not apply to duplication. Logic used 2+ times, or genuinely non-specific (a utility), MUST be abstracted into exactly one home: the domain package that owns it, the lowest-level consumer's package as an exported symbol, or a true global-util package per rule 2. Splitting logic across files by concern also improves readability and counts as organization, not decoration. When DRY and KISS conflict, DRY wins; record the conflict in the plan so the user sees the trade-off was deliberate.

1. **Nothing moves before the plan is confirmed.** Propose → user confirms → execute.
2. **Refuse to execute when unsafe:**
   - Dirty worktree (`git status` not clean) → stop, tell the user to commit or stash.
   - Failing build or tests at start → stop.
   - No discoverable build/test commands → produce the plan only; say execution is impossible because it cannot be verified.
   - Create a checkpoint branch (`reorg/<date>`) before the first move.
3. **Done is verified, not assumed.** Zero stale references, green build, green tests.
4. **Commit only after all gates pass.** If verification fails and the problem cannot be fixed, revert the working tree to the pre-run state — never leave a half-reorg, never commit a broken state.
5. **Dead code with zero search references is deleted inline**, without re-confirmation. Zero references by search is the *only* bar: exported symbols, public entry points, anything — if nothing references it by search, delete it and note it in the report.

## Phase 0 — Context (mandatory)

Before proposing anything:

1. Read repo context files (`AGENTS.md`, `CLAUDE.md`, `README.md`, existing structure). The repo's own conventions outrank generic "best practices".
2. Map the current structure: packages/directories, the god-files, the orphaned files.
3. Discover the verification gates: build command, test command (from manifests, CI files, Makefiles, task runners). Record them — they drive Phase 4. Note whether committing runs hooks that re-run gates; budget the commit's runtime accordingly.
4. Discover non-code references to paths: CI workflows, Makefiles, Dockerfiles, configs, scripts, doc links. Any moved path must chase these.
5. **Duplication scan**: run a code-clone scanner and read each hit before proposing. A clone is a DRY candidate only if it is real shared logic, not incidental similarity. Useful scanners (pick per stack):
   - `jscpd` — language-agnostic clone detection (`--min-tokens 40` catches small helpers)
   - `ast-grep` — structural pattern search; good for finding near-identical function bodies
   - `ts-prune` (TS), `vulture` (Python), `deadcode` (Go) — unused exports, pairs with deletions
   - `knip` (TS/JS), `go vet`/`golangci-lint` (Go) — unused code, import cycles, dead wiring
   - `madge`/`dependency-cruiser` (JS), `go list -deps`/`go mod graph` (Go) — dependency direction, cycle detection for locality decisions
   - `scc`/`cloc` — size overview to spot god-files quickly
6. **Scratch inventory**: list untracked/gitignored directories and files. These are flagged in the plan and NEVER deleted without explicit user say-so — untracked means unrecoverable. Tracked deletions are different: recoverable from git history, so propose them normally.

## Phase 1 — Plan

Analyze and write `reorg-plan.md` (repo root unless the repo specifies a location). The file is kept permanently as a record of the reorganization. Sections:

```markdown
# Reorg Plan — <date>

## Governing principles
<Principles confirmed with the user before execution (from the section above, plus
any user-specific directives). They resolve conflicts between plan items.>

## Moves
1. `cmd/main.go:ParseConfig` → `internal/config/config.go`
2. `src/render.go` → `src/render/{canvas.go,color.go}` (extract 400-line file)

## DRY abstractions
<From the duplication scan. For each: the two+ locations, the extracted symbol's
name and home (a domain package — never utils/), and whether it is production or
test-helper extraction.>

## Renames
1. `verifyToken` → `ValidateToken` (23 references)

## Deletions
1. `src/old_parser.go` (0 references found)

## Scratch (untouched)
<Untracked/ignored dirs flagged in Phase 0 — listed here so the user can opt in to
deleting any of them; default is leave alone.>

## Non-code reference updates
1. `.github/workflows/ci.yml`: build path `src/render.go` → `src/render/`
2. `README.md`: import example updated

## Verification gates
- build: `<command>`
- tests: `<command>`

## Order & risks
<execution order; anything risky called out>
```

End the turn with a chat summary: counts per section plus the single riskiest item. Wait for confirmation. The user may edit the plan file — re-read it after they say go.

## Phase 2 — Execute

In plan order, one logical move at a time:

1. Move/rename with `git mv` (or the filesystem equivalent) to preserve history.
2. Move functions between files; split god-files into focused files.
3. Rename symbols; update every reference found by search (or LSP where available).
4. Update non-code references from the plan.
5. Delete dead code found along the way (zero-reference bar, see rules).
6. **Stage only planned files** (`git add <paths>`). Never `git add -A` or `git add .` —
   build artifacts live in repos. Before committing, check `git status` and reject any
   binary or large file the plan did not name.
7. **New-file collisions**: before creating a file, verify the name does not already
   exist in the package; on collision pick an adjacent name and report it.
8. **Deviations**: when execution differs from the plan (name collision, changed
   signature, moved item dropped), report the deviation and the reason — never silently.

Commit **once** at the end, only after Phase 4 passes:

```
reorganize: <short summary>

Moves:
- <list>
Renames:
- <list with reference counts>
Deletions:
- <list>
```

## Phase 3 — Sweep for stale references

Exhaustive, not best-effort. Search (and LSP if available) for:

- Old symbol names → 0 hits expected.
- Old file paths / old import paths → 0 hits in code, configs, CI, docs.

Any hit is a bug in the execution. Fix and re-sweep.

## Phase 4 — Verify

1. Run the build command recorded in Phase 0. Must pass.
2. Run the tests. Must pass.
3. Confirm the sweep from Phase 3 is clean.

If a gate fails and it cannot be fixed: `git restore` the working tree to the pre-run state, delete the checkpoint branch, and report exactly what failed. The plan file survives (it is a record and an input to the next attempt).

## Final report

End with:

- What moved / renamed / abstracted / deleted (concrete lists — the commit body mirrors
  this), including every deviation from the plan and its reason.
- Proof: gate commands run and their results.
- The plan file's location, kept as a record.
