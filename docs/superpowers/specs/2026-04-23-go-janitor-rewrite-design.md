# go-janitor rewrite: deadcode-driven, plan-gated (lean merged)

## Goal

Rewrite `claude-skills/go-janitor/SKILL.md` so the primary workflow is driven by the `deadcode` tool (`golang.org/x/tools/cmd/deadcode`, described in https://go.dev/blog/deadcode). Keep the existing manual-sweep coverage (struct fields, package-level vars/consts, blank imports, commented-out code, unreachable blocks) as a secondary pass, since `deadcode` only reports unreachable functions/methods.

Model the tool-driven flow after `claude-skills/fallow-review/SKILL.md`: locate project → run tool → categorize → trap-verify → brainstorm scope → write plan → execute with verification gate → commit.

## Scope

**In scope:**

- Rewrite `claude-skills/go-janitor/SKILL.md` end-to-end.
- Update `claude-skills/go-janitor/references/go-traps.md` and `references/output-format.md` as needed (keep location; extend if helpful).
- Add new reference `references/deadcode-flags.md` — cheat-sheet for `-test`, `-filter`, `-whylive`, `-json`, `-generated`, `-f`.
- Description/trigger surface expanded to cover new phrasing ("run deadcode", "unreachable functions", "Go dead function audit") alongside existing triggers.

**Out of scope:**

- New sibling skill. User requested rewrite-in-place.
- Changes to `fallow-review`.
- Installing `deadcode` automatically without asking (install policy A — ask first).
- Any non-Go tooling.

## Install policy

Policy A: detect-then-ask-then-install.

- Check `command -v deadcode`.
- If missing, tell user the install command and ask once: "`go install golang.org/x/tools/cmd/deadcode@latest`. Run it?"
- On yes → run install, continue.
- On no → fall back to manual-only sweep (the existing go-janitor content), flagging that unreachable-function detection will be best-effort without `deadcode`.
- Never install silently.

## Skill shape

`SKILL.md` becomes a two-phase flow:

### Phase 1 — `deadcode`-driven (primary)

Mirrors fallow-review step ordering:

1. **Locate module root.** `go.mod` lookup: current dir → `./server/` → `./backend/` → ask. Multi-module repos: ask which module or run from repo root with `./...`.
2. **Check/install `deadcode`.** Per install policy above. If user declines, skip to Phase 2 only.
3. **Run `deadcode`.** Default: `deadcode -test ./...`. Capture text output. Mention `-json` / `-f` for structured use, and `-whylive=<symbol>` for follow-up diagnosis. `-generated=false` is the tool's default and should stay off unless user asks.
4. **Categorize findings.** `deadcode` emits one kind of finding (unreachable function/method). Sub-classify in the report:
   - Plain funcs in leaf packages — safe-ish candidates.
   - Methods on types that ARE instantiated elsewhere — interface-impl suspects, trap-verify.
   - Funcs matching well-known dynamic-dispatch names (`MarshalJSON`, `UnmarshalJSON`, `String`, `Error`, `Scan`, `Value`, CGo `//export`) — trap suspects.
   - Funcs in `_test.go` — only surface if `-test` was on.
5. **Trap-verify.** Consult `references/go-traps.md`. For each candidate, grep for `//go:linkname`, `//export`, reflection usage (`reflect.ValueOf`, `reflect.TypeOf`, method-name-as-string). Use `deadcode -whylive=<symbol>` to confirm reachability claims when suspicious. Soundness reminder: `deadcode` is sound w.r.t. static + interface + reflection reachability but misses assembly and `go:linkname` callers.
6. **Brainstorm scope.** Menu (default bolded):
   - Scope: **all flagged** / exclude test-only / exclude methods / whitelist packages.
   - Verify depth: trust deadcode / **trap-grep all** / hybrid (funcs trusted, methods trap-grepped).
   - Gate per task: `go build ./...` + `go vet ./...` / **+ `go test ./...`** / + manual smoke.
   - Commit granularity: **per-package** / per-symbol / squashed.
7. **Write plan + execute.** `superpowers:writing-plans` → `superpowers:executing-plans` or `subagent-driven-development`.
8. **Verification gate per task.** `go build ./... && go vet ./...` always. Tests per scope decision.
9. **Commit.** Conventional Commits. Examples: `chore(server): remove deadcode-flagged unreachable funcs`, `refactor(pkg/x): drop unused interface method`.

### Phase 2 — manual sweep (secondary)

Retains current go-janitor coverage for categories `deadcode` doesn't handle:

- Unused package-level vars and constants.
- Unused struct fields (watch reflection/unmarshal — trap-verify).
- Unused blank imports (`_ "..."`) whose side effect is no longer needed.
- Commented-out code blocks.
- Unreachable statements after `return` / `panic` / `os.Exit` / `log.Fatal` (hand off to `go vet` where it catches; manual for the rest).
- Dead files (files whose package + symbols no other file references).

Run after Phase 1 or standalone if user opts out of install. Steps collapsed from current skill; keep the "how to find" and "watch out for" bullets that give signal.

## Red flags

Keep the fallow-review-style red-flags section, Go-flavored:

- Every `main` flagged → wrong entry (ran outside module) or wrong build tags.
- Methods on a widely-used type flagged → likely interface impl. Grep for the interface before deleting.
- Package using CGo or assembly flagged → deadcode soundness gap. Require human eyes.
- Huge list → likely a large sub-module not wired to any `main`. Ask whether that module is a library vs. reachable from a binary.

## Guardrails

Keep current go-janitor guardrails, extended:

- Never modify `// Code generated` files.
- Never strip `init()` functions without confirming no side-effect registration.
- Never remove `//go:embed`, `//go:linkname`, `//go:generate`, `//export`, `//go:build`-guarded content without explicit greenlight.
- Skip refactors outside "remove dead code" scope unless user asks.

## File layout

```
claude-skills/go-janitor/
├── SKILL.md                        # rewritten
└── references/
    ├── go-traps.md                 # existing — extend with deadcode-specific suspects if gap found
    ├── output-format.md            # existing — extend header with Phase 1 vs Phase 2 tally
    └── deadcode-flags.md           # NEW — one-page cheat sheet
```

## Output format

Extend `references/output-format.md` so the summary distinguishes Phase 1 (`deadcode`) from Phase 2 (manual) findings:

```
## Dead Code Removed

### Phase 1 — deadcode (N)
- path/to/file.go:42 `funcName` — unreachable from main, no dynamic callers
- ...

### Phase 2 — manual sweep (N)
- Unused const `MaxFoo` in path/to/file.go — no references
- Removed `_ "image/gif"` from path/to/file.go — no GIF decoding
- ...

### Verification
- [x] `go build ./...` passes
- [x] `go vet ./...` clean
- [x] `go test ./...` passes
```

## `deadcode-flags.md` contents

| Flag | Use |
|------|-----|
| `-test` | Include test binaries (hidden `main`s generated by `go test`). Default on for this skill. |
| `-filter=regexp` | Restrict output to packages matching pattern. Useful for mono-repos. |
| `-whylive=pkg.Symbol` | Print call chain proving a symbol IS reachable. Run when skill-suspected-dead conflicts with deadcode-says-live. |
| `-json` | Machine-readable output for structured triage. |
| `-f=template` | Custom template. Rare. |
| `-generated` | Include generated files. Leave off unless user asks — generated code is owned by its generator. |

Plus the soundness paragraph: deadcode is sound against static calls, interface dispatch, and reflection-based dispatch over instantiated types. It is NOT sound against assembly callers or `go:linkname` targets.

## Triggers (description field)

Merge existing go-janitor triggers with new deadcode-specific phrasing. New descriptor draft:

> Find and remove dead code in Go codebases. Primary flow drives `deadcode` (`golang.org/x/tools/cmd/deadcode`) to locate unreachable functions/methods, trap-verifies against dynamic-dispatch patterns, and runs a plan-gated cleanup. Secondary sweep handles unused package vars/consts, struct fields, blank imports, commented-out code, and unreachable blocks.
> Use when user wants to clean up Go code, run deadcode, find unreachable or unused functions, audit unused exports, slim a package, or asks about code that isn't being used. Triggers: "dead code", "run deadcode", "unreachable functions", "unused functions", "unused exports", "go cleanup", "remove unused", "slim down", "lean codebase".

## Acceptance criteria

- `claude-skills/go-janitor/SKILL.md` rewritten with Phase 1 + Phase 2 flow and install policy A documented.
- `references/deadcode-flags.md` exists.
- `references/go-traps.md` unchanged or extended (no regressions to existing entries).
- `references/output-format.md` reflects Phase 1 / Phase 2 tally.
- Skill frontmatter `description` updated with merged triggers.
- `allowed-tools` stays `Bash, Read, Edit, Grep, Glob`.
- Skill stays self-contained — no cross-skill path references.

## Non-goals

- No new skill file.
- No changes to sibling skills (`fallow-review`, others).
- No installer script.
- No CI integration.
