---
name: go-test-reviewer
description: |
  Comprehensive Go test quality and coverage analysis. Use this skill whenever the user wants to:
  - Review Go test files for gaps, weaknesses, or inaccurate assertions
  - Improve test coverage with a focus on quality (not just percentage)
  - Audit test suite structure, patterns, and Go idioms
  - Find missing edge cases, error paths, or concurrency test gaps
  - Check if tests actually verify behavior or just run code without assertions
  Trigger on phrases like "review my Go tests", "test coverage", "test quality", "what am I missing in my tests", "audit tests", "improve tests", "test gaps", or any request involving *_test.go files. Also trigger when the user shares Go test code and asks for feedback, even if they don't explicitly say "review".
allowed-tools: Bash, Read, Grep, Glob
---

# Go Test Reviewer

Review Go tests for gaps, wrong assertions, quality issues. Focus **accuracy over percentage** — 60% coverage of critical paths healthier than 90% of trivial happy paths.

## Workflow

### Step 1: Discover the code under test

Understand what you review:

1. Read `*_test.go` file(s) user gave (or find all test files in directory)
2. Check `package` decl — same package (white-box) or `_test` suffix (black-box)?
3. Find source files tested:
   - List non-test `.go` files in same directory
   - Follow function calls in tests back to definitions via Grep
   - Check imports for internal packages exercised
4. Read source files before judging tests

### Step 2: Run Go tooling

Get baseline from Go built-in tools before manual analysis. Grounds review in real numbers.

```bash
# Coverage baseline — what percentage of statements are exercised?
go test -cover ./path/to/package/...

# Static analysis — catches unreachable code, bad format strings, etc.
go vet ./path/to/package/...

# Race detector — surfaces data races that tests might be hiding
go test -race ./path/to/package/... -count=1

# If the tests even pass at all — a failing test suite is finding #1
go test ./path/to/package/...
```

Any command fails → finding. Report it. Coverage below 50% → call out loud.

### Step 3: Build a function-to-test map

Where you add value beyond tools:

1. List every exported/unexported function/method in source
2. For each, search tests for coverage
3. Categorize:
   - **Untested** — no test calls it
   - **Smoke-tested** — called but results unchecked, or only happy path
   - **Partially tested** — some paths covered, others missing
   - **Well tested** — happy path, errors, edge cases covered
4. Watch:
   - Functions returning `error` — error path tested?
   - Functions with multiple paths (if/switch) — all branches hit?
   - Public API — exported functions need thorough tests

### Step 4: Analyze test quality

For each test, check:

- **Assertions exist** — test verifies something, or just runs code hoping no panic?
- **Assertions meaningful** — `if err != nil` good, but return value also checked?
- **Table-driven opportunities** — 3+ tests same structure, different inputs → consolidate
- **`t.Helper()`** — helpers marked so failure points to right line?
- **`t.Parallel()`** — independent tests run parallel for faster feedback?
- **`t.Run()` subtests** — subtest names descriptive enough to ID failures?
- **`t.Fatal` vs `t.Error`** — test continuing after failure that should abort? (e.g. nil-check pointer then deref)
- **Cleanup** — resources cleaned via `t.Cleanup()` or defer?
- **Hardcoded values** — magic numbers/strings should be named constants or fixtures

### Step 5: Check Go-specific patterns

Go strong test idioms. Flag deviations, suggest fixes:

**Table-driven tests** — Go's most important pattern. Recommend whenever a file has 3+ tests with the same structure. Canonical example in `references/table-driven-example.go`.

**Other patterns:**
- **TestMain** — setup/teardown duplicated across tests should use `TestMain`?
- **Interface compliance** — `var _ Interface = (*Type)(nil)` checks for types needing interfaces?
- **Benchmark tests** — perf-critical code has `Benchmark*` functions?
- **Example tests** — public APIs have `Example*` as docs?
- **Race conditions** — concurrent code tested with parallel access?
- **Golden files** — complex output uses golden files vs inline expected strings?

## Output Template

Always use the format in `references/output-template.md`. Skip empty sections, expand full ones — structure keeps review scannable without forcing empty blocks.