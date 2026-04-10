---
name: go-test-reviewer
description: "Analyzes Go test files for gaps, inaccurate assertions, and quality issues. Provides structured recommendations to improve coverage, identify missing test cases, and strengthen test suite accuracy."
compatibility: |
  - Requires Go source code files (*_test.go and the code being tested)
  - Works with any Go module structure
  - No external dependencies needed for analysis
---

# Go Test Reviewer

Review Go tests for gaps, inaccurate assertions, and quality issues. This skill performs deep analysis of test files and provides structured recommendations to improve test coverage and accuracy.

## How to Use

Provide either:
1. **Test file(s)** — one or more `*_test.go` files to review
2. **Package directory** — a path to a Go package with tests, and the skill will analyze all test files and the code they test

The skill will analyze:
- **Coverage gaps**: Functions with no tests or incomplete test cases
- **Edge cases**: Missing boundary conditions, error scenarios, nil/empty input handling
- **Assertion accuracy**: Insufficient or inaccurate verifications; tests that run code without checking results
- **Test structure**: Opportunities for table-driven tests, clearer test organization, better naming
- **Concurrency issues**: Untested goroutines, race conditions, synchronization gaps
- **Mocking quality**: Over-mocking, missing interface tests, brittle test doubles

## Output Format

The skill produces a **severity-grouped markdown report** with:

1. **Executive Summary** — overall test health, key metrics, top priorities
2. **Critical Issues** — bugs in tests, assertions that always pass, untested critical paths
3. **High Priority** — significant coverage gaps, risky patterns, common test antipatterns
4. **Medium Priority** — quality improvements (structure, readability, maintainability)
5. **Low Priority** — nice-to-have refactors (test organization, naming)
6. **Recommendations** — concrete code examples showing how to fix issues
7. **Quick Wins** — easiest improvements to tackle first

Each issue includes:
- **Location** — file name, test function, or code being tested
- **Problem** — what's wrong and why it matters
- **Impact** — what could break if not fixed
- **Fix** — example code or pattern showing the solution

## Analysis Approach

The skill reads your test files and the code they test (by examining imports and function calls), then:

1. **Parses the code** to find functions and test functions
2. **Maps tests to functions** — which functions are tested, how thoroughly
3. **Detects test patterns** — identifies table-driven tests, parameterized testing, setup/teardown
4. **Analyzes assertions** — checks if tests verify behavior or just run code
5. **Identifies gaps** — missing test cases, edge cases, error paths
6. **Checks structure** — suggests refactoring opportunities (table-driven, helper functions, etc.)

The skill focuses on **accuracy over percentage** — a codebase with 60% coverage of carefully-tested critical paths is healthier than 90% coverage of trivial happy paths.

## Example Analysis

Given a test like:

```go
func TestUserCreate(t *testing.T) {
    user := CreateUser("alice@example.com", "password123")
    // No assertion - test runs but doesn't verify anything
}
```

The skill identifies:
- **Issue**: Test has no assertions (doesn't verify anything happened)
- **Why it matters**: Test passes even if CreateUser silently fails
- **Fix**: Add assertions checking returned user, error state, database changes

## Running the Skill

Simply ask Claude:
```
Review these Go tests and identify quality issues
[attach test files or provide directory path]
```

Or:
```
Audit the test coverage in my API package for gaps
```

Or point to a specific concern:
```
My CreateUser tests are too simple — what cases am I missing?
```

The skill handles the rest — analysis, discovery of related code, and detailed recommendations.
