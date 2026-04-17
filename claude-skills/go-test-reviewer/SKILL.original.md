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
compatibility: |
  - Requires Go source code files (*_test.go and the code being tested)
  - Works with any Go module structure
  - No external dependencies needed for analysis
---

# Go Test Reviewer

Review Go tests for gaps, inaccurate assertions, and quality issues. Focus on **accuracy over percentage** — a codebase with 60% coverage of carefully-tested critical paths is healthier than 90% coverage of trivial happy paths.

## Workflow

### Step 1: Discover the code under test

Start by understanding what you're reviewing:

1. Read the `*_test.go` file(s) the user provided (or find all test files in the given directory)
2. Check the `package` declaration — is it the same package (white-box) or `_test` suffix (black-box)?
3. Find the source files being tested:
   - List non-test `.go` files in the same directory
   - Follow function calls in tests back to their definitions using Grep
   - Check imports for internal packages being exercised
4. Read the source files so you understand what the code actually does before judging the tests

### Step 2: Run Go tooling

Before doing manual analysis, get baseline data from Go's built-in tools. This grounds your review in real numbers rather than guesswork.

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

If any command fails, that's a finding. Report it. If coverage is below 50%, call that out prominently.

### Step 3: Build a function-to-test map

This is where you add value beyond what tools catch:

1. List every exported and unexported function/method in the source files
2. For each, search the test files for corresponding test coverage
3. Categorize each function:
   - **Untested** — no test calls it at all
   - **Smoke-tested** — called but results aren't checked, or only happy path
   - **Partially tested** — some paths covered, others missing
   - **Well tested** — happy path, error cases, and edge cases covered
4. Pay special attention to:
   - Functions that return `error` — is the error path tested?
   - Functions with multiple code paths (if/switch) — are all branches exercised?
   - Public API surface — exported functions need more thorough testing

### Step 4: Analyze test quality

For each test function, check:

- **Assertions exist** — does the test actually verify something, or just call code and hope it doesn't panic?
- **Assertions are meaningful** — `if err != nil` is good, but does it also check the returned value?
- **Table-driven test opportunities** — if you see 3+ test functions with the same structure but different inputs, suggest consolidating into a table-driven test
- **`t.Helper()`** — are helper functions marked so failure output points to the right line?
- **`t.Parallel()`** — could independent tests run in parallel for faster feedback?
- **`t.Run()` subtests** — are subtest names descriptive enough to identify failures?
- **`t.Fatal` vs `t.Error`** — is the test continuing after a failure that should abort? (e.g., nil-checking a pointer then dereferencing it)
- **Cleanup** — are resources cleaned up with `t.Cleanup()` or deferred calls?
- **Hardcoded values** — magic numbers/strings that should be named constants or test fixtures

### Step 5: Check Go-specific patterns

Go has strong testing idioms. Flag deviations and suggest improvements:

**Table-driven tests** — Go's most important testing pattern. When appropriate, recommend this structure:

```go
func TestParseSize(t *testing.T) {
    tests := []struct {
        name    string
        input   string
        want    int64
        wantErr bool
    }{
        {"valid bytes", "1024B", 1024, false},
        {"valid kilobytes", "5KB", 5120, false},
        {"empty string", "", 0, true},
        {"negative value", "-1B", 0, true},
        {"no unit", "1024", 0, true},
    }
    for _, tt := range tests {
        t.Run(tt.name, func(t *testing.T) {
            got, err := ParseSize(tt.input)
            if (err != nil) != tt.wantErr {
                t.Errorf("ParseSize(%q) error = %v, wantErr %v", tt.input, err, tt.wantErr)
                return
            }
            if got != tt.want {
                t.Errorf("ParseSize(%q) = %v, want %v", tt.input, got, tt.want)
            }
        })
    }
}
```

**Other patterns to check:**
- **TestMain** — is there setup/teardown that should use `TestMain` instead of being duplicated across tests?
- **Interface compliance** — are there `var _ Interface = (*Type)(nil)` checks for types that must satisfy interfaces?
- **Benchmark tests** — for performance-critical code, are there `Benchmark*` functions?
- **Example tests** — for public APIs, are there `Example*` functions that serve as documentation?
- **Race conditions** — does concurrent code have tests that exercise parallel access?
- **Golden files** — for complex output, are golden file patterns used instead of inline expected strings?

## Output Template

ALWAYS structure your report using this template:

```markdown
# Test Review: [package name]

## Summary
- **Coverage**: [X%] (from `go test -cover`)
- **Test count**: [N] test functions across [M] files
- **Overall health**: [Solid / Needs work / Critical gaps]
- **Top priority**: [one-line description of the most important finding]

## Critical Issues
[Tests that are actively misleading — passing when they shouldn't, asserting wrong things, hiding bugs]

### [Issue title]
- **Location**: `file_test.go:TestFunctionName`
- **Problem**: [what's wrong and why it matters]
- **Impact**: [what could break in production]
- **Fix**:
\`\`\`go
// concrete code showing the fix
\`\`\`

## Coverage Gaps
[Functions or code paths with no test coverage, ordered by risk]

### [Untested function/path]
- **Location**: `file.go:FunctionName`
- **Risk**: [why this needs tests — what breaks if it regresses?]
- **Suggested tests**: [list the specific test cases to add]

## Quality Improvements
[Tests that work but could be better — structure, readability, idioms]

## Quick Wins
[Easiest improvements that deliver the most value, bulleted list]
```

Adapt the template as needed — skip sections that have no findings, expand sections that have many. The structure exists to keep the review scannable, not to force empty sections.
