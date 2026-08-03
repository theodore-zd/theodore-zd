---
name: go-janitor
description: |
  Find and remove dead code in Go codebases. Primary flow drives `deadcode` (`golang.org/x/tools/cmd/deadcode`) to locate unreachable functions/methods, trap-verifies against dynamic-dispatch patterns, and runs a plan-gated cleanup. Secondary manual sweep covers unused package vars/consts, struct fields, blank imports, commented-out code, unreachable statements, and dead files.
  Use this skill whenever the user wants to clean up Go code, run deadcode, find unreachable or unused functions, audit unused exports, slim down a package, or asks about code that's not being used. Triggers: "dead code", "run deadcode", "unreachable functions", "unused functions", "unused exports", "go cleanup", "remove unused", "slim down", "lean codebase", "audit Go", "dead Go code".
allowed-tools: Bash, Read, Edit, Grep, Glob
---

# Dead Code Hunter (Go)

Two-phase flow. Phase 1 drives `deadcode` to find unreachable functions and methods, plan-gated like `fallow-review`. Phase 2 manually sweeps categories `deadcode` doesn't handle (vars, consts, struct fields, blank imports, commented-out code, unreachable statements, dead files). User wants lean — unused = gone, but every removal must survive trap-verification first.

## Scope

Go projects (module detected via `go.mod`). Skip if not Go.

## Phase 1 — `deadcode`-driven (primary)

### 1. Locate module root

Order:
1. Current dir if `go.mod` present
2. `./server/go.mod`
3. `./backend/go.mod`
4. Else ask user

Multi-module repo: ask which module to run against, or run from repo root with `./...`.

Run all `deadcode` and verification commands from the chosen module root.

### 2. Check / install `deadcode`

Policy: ask-then-install. Never install silently.

```bash
command -v deadcode
```

If missing, tell the user:

> `deadcode` not installed. Install with `go install golang.org/x/tools/cmd/deadcode@latest`. Run it?

- Yes → run the install, continue Phase 1.
- No → skip to Phase 2 only. Note to the user that unreachable-function detection will be best-effort without `deadcode`.

### 3. Run `deadcode`

```bash
deadcode -test ./... 2>&1 | head -400
```

`-test` ON by default so `go test`-only reachable funcs don't get flagged as dead. See `references/deadcode-flags.md` for `-filter`, `-whylive`, `-json`, `-generated`.

### 4. Categorize findings

`deadcode` emits one kind of line (unreachable func or method). Sub-classify before deciding action:

| Sub-class | Risk | Default action |
|-----------|------|----------------|
| Plain func in leaf package | Low | Remove after trap-grep |
| Method on a type instantiated elsewhere | Medium — likely interface impl | Verify interface contract before remove |
| Func matching dynamic-dispatch names (`MarshalJSON`, `UnmarshalJSON`, `String`, `Error`, `Scan`, `Value`, CGo `//export`) | High | Trap-verify, default keep |
| Func in `_test.go` with `-test` on | Low | Remove, or keep if test helper used across test files |

### 5. Trap-verify

Consult `references/go-traps.md` — table of patterns that look dead but aren't.

For each candidate not in a trap category, grep for dynamic callers static analysis can miss:

```bash
# linkname targets
grep -rn "//go:linkname" . --include='*.go'

# CGo exports
grep -rn "//export " . --include='*.go'

# reflection by name
grep -rn "MethodByName\|FieldByName\|reflect.ValueOf\|reflect.TypeOf" . --include='*.go'

# symbol referenced as bare string (reflection, registries, DI)
grep -rn '"<SymbolName>"' . --include='*.go'
```

When `deadcode` says a symbol IS live and you disagree, run:

```bash
deadcode -whylive=module/path.Symbol ./...
```

It prints the call chain. If the chain passes through code you know is dead, that code needs to go in a separate task first — then re-run `deadcode`.

Soundness reminder: `deadcode` covers static, interface, and reflection-over-instantiated-types dispatch. It does NOT cover assembly callers or `//go:linkname` targets.

### 6. Brainstorm scope

Present menu (defaults bolded):

- **Scope:** **all flagged** / exclude test-only / exclude methods / whitelist packages
- **Verify depth:** trust deadcode / **trap-grep all** / hybrid (funcs trusted, methods trap-grepped)
- **Gate per task:** `go build ./...` + `go vet ./...` / **+ `go test ./...`** / + manual smoke
- **Commit granularity:** **per-package** / per-symbol / squashed

Use `superpowers:brainstorming` for the Q&A.

### 7. Write plan, then execute

After scope locked: `superpowers:writing-plans` → `superpowers:subagent-driven-development` or `superpowers:executing-plans`.

### 8. Verification gate per task

Always:

```bash
go build ./... && go vet ./...
```

If tests were included in the gate:

```bash
go test ./...
```

### 9. Commit

Conventional Commits. Examples:

- `chore(server): remove deadcode-flagged unreachable funcs`
- `refactor(pkg/foo): drop unused interface method`
- `chore(internal/x): prune dead methods after handler removal`

## Phase 2 — manual sweep (secondary)

Runs after Phase 1, or standalone if user declined the `deadcode` install. Covers categories `deadcode` doesn't emit.

Priority order:

### 2a. Dead files

Files nothing imports or references.

**Find:**
- Grep package name + symbol usage across the repo
- Check whether the file's package is imported anywhere (non-`main` packages)
- For `main` package files, check whether the file's symbols are used by other files in the same package

**Watch out:**
- Files with only `init()` — run on import, side effects
- `//go:build` tags — may only compile on certain platforms
- `_test.go` — used by `go test`, not by imports
- `*_generated.go` / `// Code generated` — generator-managed, do not touch
- `doc.go` — package docs only
- `//go:embed` target files referenced from elsewhere
- `main.go` and `cmd/` entry points

### 2b. Unused package-level vars and consts

Go's compiler catches unused *local* vars; package-level ones slip through.

**Find:**
- Grep the symbol name project-wide
- Check struct-tag references (`json:"name"`, `mapstructure:"name"`, etc.)
- Enum-style const blocks — some values may genuinely be unreachable

**Watch out:**
- `var _ Interface = (*Type)(nil)` — compile-time interface check, intentional
- Vars referenced only in `init()`
- Consts used by generated code that doesn't yet exist in this branch

### 2c. Unused struct fields

**Find:**
- Grep `.fieldName` within the package and callers
- Grep struct literals that populate the field

**Watch out:**
- Fields populated by `json.Unmarshal`, `sql.Scan`, `mapstructure.Decode`, protobuf
- Fields with struct tags — reflection-driven writers
- Fields in types passed to `reflect` APIs

### 2d. Dead blank imports

`_ "pkg/path"` — imported for side effects (driver registration, codec registration, etc.).

**Find:**
- For each blank import, determine the side effect (check the package's `init()`)
- Confirm the project still exercises that side effect

Examples:
- `_ "image/png"` — only needed if something decodes PNGs
- `_ "github.com/lib/pq"` — only needed if `sql.Open("postgres", ...)` is called

### 2e. Commented-out code blocks

Multi-line comments containing `:=`, `func `, `if `, `for `, `return `. Version control recovers them — the comment adds nothing. Short explanatory comments stay.

### 2f. Unreachable statements

Code after unconditional `return`, `panic`, `os.Exit`, `log.Fatal`. `go vet` catches some; manual scan for the rest. Also:

- Switch/select cases that can never match
- `if false { ... }` blocks
- Error branches for impossible errors given preceding code

### 2g. Tooling help

Run before / alongside manual sweep — cheap, catches obvious things:

```bash
# Compile errors surface unused imports and unused local vars
go build ./...

# Vet catches unreachable code, dead assignments
go vet ./...

# staticcheck (optional, ask before installing)
staticcheck ./... 2>/dev/null || echo "staticcheck not installed"
```

Do not install staticcheck unless the user asks.

## Red flags

If the `deadcode` output looks off, stop and diagnose before acting:

- **Every `main` flagged** → ran outside module or wrong build tags. Fix invocation.
- **Method on a widely-used type flagged** → likely interface impl. Grep the interface definition before deleting.
- **Package using CGo or assembly flagged** → deadcode soundness gap. Human review required.
- **Huge list on a sub-module** → that module may be a library not wired to any `main`. Ask whether the user treats it as a library (exports ARE the product) vs. reachable from a binary.
- **Zero findings on a repo with obvious dead code** → wrong entry. Retry with `-test` and check module root.

## Guardrails

Never:

- Modify `// Code generated` files
- Strip `init()` without confirming the side effect is no longer needed
- Remove `//go:embed`, `//go:linkname`, `//go:generate`, `//export`, `//go:build`-guarded content without explicit user greenlight
- Refactor beyond "remove dead code" unless user asks
- Install `deadcode` or `staticcheck` silently — always ask first

## Output format

After changes, use the template in `references/output-format.md`. Split Phase 1 and Phase 2 removals. Include a "Skipped (trap matches)" section even when empty — it proves trap-verification ran.
