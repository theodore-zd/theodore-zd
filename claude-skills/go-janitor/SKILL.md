---
name: go-janitor
description: |
  Find and remove dead code in Go codebases: unused functions, exports, imports, variables, constants, and unreachable code paths. Simplifies and consolidates remaining code for a leaner codebase.
  Use this skill whenever the user wants to clean up Go code, find unused functions, remove dead code, audit for unused exports, slim down a package, or asks about code that's not being used. Also trigger when the user mentions "dead code", "unused code", "code cleanup", "go cleanup", "remove unused", "slim down", "lean codebase", "unused functions", "unused exports", or wants to make a Go codebase leaner — even if they don't explicitly ask for a "janitor" or "dead code hunter".
---

# Dead Code Hunter (Go)

Deep aggressive audit of Go codebase. Hunt dead code. User want lean — unused = gone. Not style/formatting; eliminate purposeless code.

## What you're hunting for

Priority order:

### 1. Dead files

Files nothing imports or references. Biggest wins — whole files project no need.

**How to find them:**
- Grep package name + symbol usage across project
- Check if file's package imported anywhere (non-`main` packages)
- For `main` package files, check if symbols used by other files in same package

**Watch out for:**
- Files only containing `init()` — run on import, side effects possible
- Files with `//go:build` tags — may only compile on certain platforms/tags
- Files ending `_test.go` — used by `go test`, not imports
- Files matching `*_generated.go` or containing `// Code generated` — generator-managed
- `doc.go` files — exist for package docs only
- Files with `//go:embed` directives other files reference
- `main.go` and entry points under `cmd/`

### 2. Unused exported symbols

Exported functions, types, constants, variables (capitalized) nothing outside package uses. Insidious — compiler no catch. Go errors on unused *imports* and *local variables* only, not exports.

**How to find them:**
- For each exported symbol, grep project for `packagename.SymbolName`
- Check indirect usage: type assertions (`x.(MyType)`), composite literals (`MyStruct{}`), embedded types
- Search usage in `_test.go` files in *other* packages (external test packages like `package foo_test`)

**Watch out for:**
- Symbols satisfying interface — method may look unused but required by `io.Reader`, `http.Handler`, `sort.Interface`, `encoding.TextMarshaler`, or project interface. Before remove method, check if receiver type used where interface expected
- Symbols used via reflection (`reflect.ValueOf`, `reflect.TypeOf`) — grep symbol name as string too
- Symbols in struct tags (e.g., `json:"field"`, `mapstructure:"field"`, `validate:"required"`)
- Symbols in `//go:linkname` directives
- Symbols part of public API of library package (if project is library, exported symbols *are* the product)
- Symbols registered as handlers: HTTP (`http.HandleFunc`), gRPC service, CLI command (cobra, urfave/cli)
- Symbols in wire/fx DI containers
- Protobuf/gRPC generated code — no touch generated files

### 3. Unused unexported functions and methods

Unexported (lowercase) functions defined but never called within package.

**How to find them:**
- Search package dir for call sites: `functionName(`
- Methods: search `.methodName(`
- Check if passed as value: `http.HandlerFunc(myFunc)`, `sort.Slice(s, myLessFunc)`, goroutine `go myFunc()`

**Watch out for:**
- Functions as args to higher-order functions
- Functions assigned to variables or struct fields (function values)
- Methods satisfying unexported interfaces within package
- Test helpers in `_test.go` only called from tests
- Functions in `go:linkname` directives

### 4. Unused variables and constants

Declared but never read. Go catches unused *local* variables at compile time, so target:

- **Package-level variables** (`var x = ...` at file scope) nothing reads
- **Package-level constants** defined "for later" that never came
- **Struct fields** nothing reads/writes — careful, may be populated via JSON unmarshal, DB scan, reflection
- **Enum-style const blocks** where some values never referenced

**Watch out for:**
- Variables used in `init()` functions
- Variables holding side effects (e.g., `var _ Interface = (*Type)(nil)` for compile-time interface checks — intentional)
- Constants in build-tagged files you might not see
- Struct fields populated by `json.Unmarshal`, `sql.Scan`, `mapstructure.Decode`, similar

### 5. Dead imports

Go catches unused imports at compile time; subtler slips through:

- **Blank imports** (`_ "package/path"`) not actually needed. Exist for side effects (registering drivers, codecs). Check side effect still needed — e.g., `_ "image/png"` registers PNG decoder, but if nothing decodes PNGs, dead
- **Dot imports** (`. "package/path"`) — pollute namespace, mask what's actually used
- **Import blocks** in generated files referencing packages no longer needed after manual edits (no edit generated files — flag instead)

### 6. Commented-out code blocks

Big commented-out blocks = dead code with extra steps. Version control = recoverable; comment serves no purpose. Remove. Short explanatory comments fine; target commented-out *code* (look for commented lines containing `:=`, `func `, `if `, `for `, `return `, etc.).

### 7. Unreachable code

Code after unconditional `return`, `panic`, `os.Exit`, `log.Fatal`. Also:
- Switch/select cases that never match
- `if false { ... }` blocks or conditions always true/false based on constants
- Error handling branches for impossible errors given preceding code

## How to work

### Step 1: Use Go tooling first

Before manual analysis, run tools that catch things mechanically. Saves time, catches obvious stuff, lets you focus on harder cross-package work.

```bash
# Compile check — catches unused imports and variables
go build ./...

# Vet — catches some unreachable code, dead assignments
go vet ./...

# If staticcheck is available, it's the single best tool for dead code
# It catches unused functions, unused parameters, unused results, and more
staticcheck ./... 2>/dev/null || echo "staticcheck not installed"

# deadcode from golang.org/x/tools finds unreachable functions
# by analyzing from main/test entry points
deadcode ./... 2>/dev/null || echo "deadcode not installed"
```

`staticcheck` or `deadcode` not installed? Fine — note it, proceed manually. No install unless user asks.

### Step 2: Scope the hunt

- User points at specific files/packages → focus there
- No scope given → check recently changed files: `git diff --name-only HEAD~10 -- '*.go'`
- Whole-repo sweeps → highest-impact first: dead files and packages, then unused exports, then down the list

### Step 3: Cross-package analysis

Where you add value beyond tools. Think detective:

1. **Map package graph.** Understand which packages import which. Start from `cmd/*/main.go` or main entry points, work outward. Packages nothing imports (except tests) = removal candidates.

2. **Grep tool = primary weapon.** For every suspect symbol, search whole project with Grep tool (not raw `grep` in bash — Grep tool handles permissions correctly):
   - Search `packagename\.FunctionName` with glob `*.go` for exported function usage
   - Search `TypeName` with glob `*.go` for type usage (including type assertions and composite literals)
   - Search symbol name as plain string too — may be referenced via reflection or struct tags

3. **Use `gopls` if LSP tool available.** LSP `references` and `implementations` queries more reliable than text search for finding callers/implementors — they understand Go's type system. Fall back to Grep when LSP unavailable.

4. **Follow dependency chain.** Removing one unused function may orphan others. After each removal, check what became orphaned — especially imports only needed for removed code.

5. **Check interface contract.** Before removing method, verify with Grep:
   - Search `interface \{` with glob `*.go`, check surrounding lines for `MethodName`
   - Search assignments where type used as interface: `var.*InterfaceName.*=.*&TypeName`

### Step 4: Make changes

Aggressive but precise:

- **Remove dead code entirely** — no comment out, no `// removed: oldFunction` markers
- **Clean cascading dead imports** — after removing code, `goimports` or `go build` reveal newly unused imports
- **Remove dead files completely** — if removing exports leaves file empty/purposeless, delete file
- **After removing code, run `go build ./...`** to verify still compiles
- **Run `go vet ./...`** after changes to catch misses

### Step 5: Verify

After all changes:

```bash
# Must compile
go build ./...

# Must pass vet
go vet ./...

# Run tests if the user wants full verification
# go test ./...
```

## Go-specific traps to avoid

Things that look dead but aren't. Wrong = broken build or subtle runtime failures:

| Pattern | Why it's not dead |
|---------|-------------------|
| `var _ Interface = (*Type)(nil)` | Compile-time interface check |
| `func init() { ... }` | Runs on package import, no explicit caller |
| `_ "database/sql/driver"` | Side-effect import, registers a driver |
| `//go:embed files/*` | Compiler directive, referenced at build time |
| `//go:generate ...` | Build tooling directive |
| `//go:linkname localName pkg.remoteName` | Links to unexported symbol in another package |
| `//export FuncName` | CGo export, called from C code |
| `func (t *Type) MarshalJSON() ...` | Called by `encoding/json` via interface, never explicitly |
| `func (t *Type) String() string` | Called by `fmt` via `Stringer` interface |
| `func (t *Type) Error() string` | Called by error handling via `error` interface |
| Methods matching `Scan`, `Value` | Called by `database/sql` via interfaces |
| Unexported fields with struct tags | Populated by reflection-based unmarshalers |

## Output format

After changes, concise summary:

```
## Dead Code Removed

### Files removed (N)
- path/to/dead_file.go — package `foo`, never imported

### Unused exports removed (N)
- `ExportedFunc` from path/to/file.go — no callers outside package `bar`
- `HelperType` from path/to/types.go — no references found

### Unused functions removed (N)
- `helperFunc` in path/to/file.go — no call sites in package

### Dead imports cleaned (N)
- Removed `_ "image/gif"` from path/to/file.go — no GIF decoding in project

### Other cleanup (N)
- Removed 15 lines of commented-out code from path/to/old.go

### Verification
- [x] `go build ./...` passes
- [x] `go vet ./...` clean
- [ ] `go test ./...` (run to confirm)
```

Summary focused on what removed and why. "Why" per removal = confidence nothing important deleted.