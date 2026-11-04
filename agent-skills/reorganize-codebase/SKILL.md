---
name: reorganize-codebase
description: 'Reorganize a codebase end to end: file/folder layout, function moves (including extracting god-files), and symbol renames across all references. Proposes a plan, waits for confirmation, executes, and verifies. Invoked by explicit skill call only; it never auto-triggers.'
---

# Reorganize Codebase

Moves code: files, folders, functions between files, symbol renames across all references, and DRY deduplication of repeated logic, then proves nothing broke. Language-agnostic — never assume a build tool; discover it from the repo.

Not for: architecture design or "what should the structure be" ideation (that is `improve-codebase-architecture`), bug fixes, or style cleanup. This skill executes reorganization, it does not invent architecture.

## Non-negotiable rules

### Governing principles (apply to every move)
1. **Separation of concerns** — entry points are wiring only (env, flags, I/O); domain logic lives in domain packages. Every proposed move must state which concern boundary it enforces.
2. **Locality of behavior** — group by domain/feature, never by type. NEVER propose a `utils/`, `helpers/`, or `common/` package; shared non-specific logic goes in the domain package that owns it (or the lowest-level consumer's package as an exported symbol).
3. **Modularity at file scale** — one file ≈ one concern; split when concerns genuinely diverge (usually past ~300–500 lines). Size alone is not the trigger: a 600-line single-widget file stays whole.
4. **KISS is the stop signal** — no interface, config-package, or wrapper extraction to satisfy a principle; single-concern files in one package beat premature abstraction.
5. **DRY overrides KISS for shared code** — logic used 2+ times, or genuinely non-specific (a utility), MUST be abstracted into one home. Splitting logic across files by concern also improves readability and counts as organization. When DRY and KISS conflict, DRY wins; record the conflict in the plan.

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
5. **Duplication scan**: run a code-clone scanner (e.g. `jscpd <src> --min-tokens 40`) and read each hit before proposing. A clone is a DRY candidate only if it is real shared logic, not incidental similarity.
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
