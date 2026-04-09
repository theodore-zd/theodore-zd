---
name: dead-code-hunter
description: "Deep Go code cleaning skill that finds and removes dead code in Go codebases: unused functions, exports, imports, variables, entire dead files, and unreachable code paths. Also simplifies and consolidates remaining code. Use this skill whenever the user asks to clean up Go code, remove dead code, find unused functions or exports, simplify a Go codebase, reduce code bloat, or mentions anything about unused/orphaned/stale code. Trigger this even if the user just says 'clean this up' or 'trim the fat' — those are dead code hunting requests."
---

# Dead Code Hunter (Go)

You are performing a deep, aggressive code audit of a Go codebase focused on finding and removing dead code. The user wants their codebase lean — if something isn't being used, it goes. This isn't about style or formatting; it's about eliminating code that serves no purpose.

## What you're hunting for

In priority order:

### 1. Dead files

Files that nothing imports or references. These are the biggest wins — entire files the project doesn't need.

**How to find them:**
- Grep for the package name + symbol usage across the project
- Check if the file's package is imported anywhere (for non-`main` packages)
- For files in a `main` package, check if any symbols defined in the file are used by other files in the same package

**Watch out for:**
- Files that only contain `init()` — these run on import and may have side effects
- Files with `//go:build` tags — they may only compile on certain platforms or with certain tags
- Files ending in `_test.go` — test files are used by `go test`, not imports
- Files matching `*_generated.go` or containing `// Code generated` — these are managed by generators, not humans
- `doc.go` files that exist only for package documentation
- Files containing `//go:embed` directives that other files reference
- `main.go` and other entry points under `cmd/`

### 2. Unused exported symbols

Exported functions, types, constants, or variables (capitalized names) that nothing outside the package uses. These are particularly insidious because the compiler won't catch them — Go only errors on unused *imports* and *local variables*, not unused exports.

**How to find them:**
- For each exported symbol, grep the entire project for `packagename.SymbolName`
- Check for indirect usage: type assertions (`x.(MyType)`), composite literals (`MyStruct{}`), embedded types
- Search for usage in `_test.go` files in *other* packages (external test packages like `package foo_test`)

**Watch out for:**
- Symbols that satisfy an interface — a method might look unused but could be required by `io.Reader`, `http.Handler`, `sort.Interface`, `encoding.TextMarshaler`, or a project-specific interface. Before removing a method, check if the receiver type is ever used where an interface is expected
- Symbols used via reflection (`reflect.ValueOf`, `reflect.TypeOf`) — grep for the symbol name as a string too
- Symbols referenced in struct tags (e.g., `json:"field"`, `mapstructure:"field"`, `validate:"required"`)
- Symbols used in `//go:linkname` directives
- Symbols that are part of the public API of a library package (if the project is a library, exported symbols *are* the product)
- Symbols registered as handlers: HTTP handlers (`http.HandleFunc`), gRPC service registrations, CLI command registrations (cobra, urfave/cli)
- Symbols used in wire/fx dependency injection containers
- Protobuf/gRPC generated code — don't touch generated files

### 3. Unused unexported functions and methods

Unexported (lowercase) functions defined but never called within their package.

**How to find them:**
- Search within the package directory for call sites: `functionName(`
- For methods, search for `.methodName(`
- Check if the function is passed as a value: `http.HandlerFunc(myFunc)`, `sort.Slice(s, myLessFunc)`, goroutine launches `go myFunc()`

**Watch out for:**
- Functions used as arguments to higher-order functions
- Functions assigned to variables or struct fields (function values)
- Methods that satisfy unexported interfaces within the package
- Test helpers in `_test.go` files that are only called from tests
- Functions used in `go:linkname` directives

### 4. Unused variables and constants

Declared but never read. Go catches unused *local* variables at compile time, so what you're looking for here is:

- **Package-level variables** (`var x = ...` at file scope) that nothing reads
- **Package-level constants** defined "for later" that later never came
- **Struct fields** that nothing reads or writes — be cautious here, as fields may be populated via JSON unmarshaling, database scanning, or reflection
- **Enum-style const blocks** where some values are never referenced

**Watch out for:**
- Variables used in `init()` functions
- Variables that hold side effects (e.g., `var _ Interface = (*Type)(nil)` for compile-time interface checks — these are intentional)
- Constants used in build-tagged files you might not see
- Struct fields populated by `json.Unmarshal`, `sql.Scan`, `mapstructure.Decode`, or similar

### 5. Dead imports

Go catches unused imports at compile time, so what slips through is subtler:

- **Blank imports** (`_ "package/path"`) that aren't actually needed. These exist for side effects (registering drivers, codecs, etc.). Check if the side effect is still needed — e.g., `_ "image/png"` registers the PNG decoder, but if nothing decodes PNGs anymore, it's dead
- **Dot imports** (`. "package/path"`) — these pollute the namespace and can mask what's actually used
- **Import blocks** in generated files that reference packages no longer needed after manual edits (don't edit generated files — flag them instead)

### 6. Commented-out code blocks

Large blocks of commented-out code are dead code with extra steps. If it's in version control, it's recoverable — the comment serves no purpose. Remove it. Short explanatory comments are fine; the target is commented-out *code* (look for commented lines containing `:=`, `func `, `if `, `for `, `return `, etc.).

### 7. Unreachable code

Code after unconditional `return`, `panic`, `os.Exit`, or `log.Fatal` calls. Also includes:
- Switch/select cases that can never match
- `if false { ... }` blocks or conditions that are always true/false based on constants
- Error handling branches for errors that are impossible given the preceding code

## How to work

### Step 1: Use Go tooling first

Before doing manual analysis, run the tools that can catch things mechanically. This saves time and catches the obvious stuff so you can focus on the harder cross-package analysis.

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

If `staticcheck` or `deadcode` aren't installed, that's fine — note it and proceed with manual analysis. Don't try to install them unless the user asks.

### Step 2: Scope the hunt

- If the user points you at specific files or packages, focus there
- If no specific scope is given, check recently changed files: `git diff --name-only HEAD~10 -- '*.go'`
- For whole-repo sweeps, start with the highest-impact items: dead files and dead packages first, then unused exports, then work down the list

### Step 3: Cross-package analysis

This is where you add value beyond what tools catch. Think like a detective:

1. **Map the package graph.** Understand which packages import which. Start from `cmd/*/main.go` or the main entry points and work outward. Packages that nothing imports (except tests) are candidates for removal.

2. **Grep is your primary weapon.** For every suspect symbol, search the entire project:
   ```
   # Is this exported function used anywhere?
   grep -r "packagename\.FunctionName" --include="*.go" .
   
   # Is this type used anywhere (including type assertions)?
   grep -r "TypeName" --include="*.go" .
   ```

3. **Follow the dependency chain.** Removing one unused function may make others unused too. After each removal, check if anything else became orphaned — especially imports that were only needed for the removed code.

4. **Check the interface contract.** Before removing any method, verify:
   ```
   # Find interfaces this type might implement
   grep -r "interface {" --include="*.go" -A 20 . | grep "MethodName"
   
   # Check if the type is ever assigned to an interface variable
   grep -r "var.*InterfaceName.*=.*&TypeName" --include="*.go" .
   ```

### Step 4: Make changes

Be aggressive but precise:

- **Remove dead code entirely** — don't comment it out, don't leave `// removed: oldFunction` markers
- **Clean up cascading dead imports** — after removing code, `goimports` or `go build` will tell you what imports are now unused
- **Remove dead files completely** — if removing exports from a file leaves it empty or purposeless, delete the file
- **After removing code, run `go build ./...`** to verify everything still compiles
- **Run `go vet ./...`** after changes to catch anything you missed

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

These are the things that look like dead code but aren't. Getting these wrong breaks the build or causes subtle runtime failures:

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

After making changes, provide a concise summary:

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

Keep the summary focused on what was removed and why. The "why" for each removal gives the user confidence that nothing important was deleted.
