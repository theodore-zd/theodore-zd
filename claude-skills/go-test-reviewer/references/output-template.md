# Test Review Output Template

Always use this structure. Skip empty sections, expand full ones.

~~~markdown
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
```go
// concrete code showing the fix
```

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
~~~
