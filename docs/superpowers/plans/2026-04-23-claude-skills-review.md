# Claude Skills Review & Improvement Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Audit and improve the four skills under `claude-skills/` (go-janitor, go-test-reviewer, gen-master-spec, fallow-review) for correctness, triggerability, progressive disclosure, and maintainability — aligned to Anthropic's current skill-authoring spec.

**Architecture:** Each skill is a self-contained directory with `SKILL.md`. Improvements split into three layers: (1) frontmatter correctness (spec-valid fields, strong descriptions), (2) content hygiene (remove artifacts, tighten prose), (3) progressive disclosure (move large reference material to `references/` files loaded on-demand). No cross-skill refactoring — each skill ships independent.

**Tech Stack:** Markdown + YAML frontmatter. No code. Verified against Anthropic docs: platform.claude.com/docs/en/agents-and-tools/agent-skills/best-practices, code.claude.com/docs/en/skills, github.com/anthropics/skills.

---

## Audit Findings Summary

| Skill | Lines | Issues |
|-------|-------|--------|
| go-janitor | 224 | `.original.md` artifact; no `allowed-tools`; trap table + output template could move to `references/` |
| go-test-reviewer | 167 | Invalid `compatibility` frontmatter field; `.original.md` artifact; output template inline (200+ token block) |
| gen-master-spec | 180 | Invalid `compatibility` field; description lacks trigger-phrase coverage; two full output templates inline (~60 lines); `.original.md` artifact |
| fallow-review | 151 | Depends on `superpowers:brainstorming` / `superpowers:writing-plans` / `superpowers:subagent-driven-development` — verify present; Svelte-only scope could be broadened later |

**Cross-cutting:**
- None of the skills use the `allowed-tools` frontmatter — adding it saves permission prompts.
- `compatibility:` is **not** a valid frontmatter field per the Agent Skills spec. Must remove.
- `.original.md` files are pre-compaction drafts kept as backups — they clutter the plugin and risk being loaded accidentally if Claude globs the dir.
- All four skills are under the 500-line body limit; progressive disclosure is a polish, not a must.
- Description quality varies: go-janitor and go-test-reviewer have rich trigger phrases; gen-master-spec and fallow-review are thinner.

---

## File Structure (After Plan)

```
claude-skills/
├── go-janitor/
│   ├── SKILL.md                       # trimmed body
│   └── references/
│       ├── go-traps.md                # "looks dead but isn't" table
│       └── output-format.md           # summary template
├── go-test-reviewer/
│   ├── SKILL.md
│   └── references/
│       ├── table-driven-example.go    # canonical example
│       └── output-template.md         # review report template
├── gen-master-spec/
│   ├── SKILL.md
│   └── references/
│       ├── backend-template.md
│       └── frontend-template.md
└── fallow-review/
    └── SKILL.md                       # already well-sized
```

No `.original.md` files anywhere. No `scripts/` dirs (no real automation to extract).

---

## Task 1: Delete `.original.md` Artifacts

**Files:**
- Delete: `claude-skills/go-janitor/SKILL.original.md`
- Delete: `claude-skills/go-test-reviewer/SKILL.original.md`
- Delete: `claude-skills/gen-master-spec/SKILL.original.md`

- [ ] **Step 1: Verify no skill references the .original.md files**

Run: `grep -rn "SKILL.original" claude-skills/`
Expected: zero matches.

- [ ] **Step 2: Delete the three artifact files**

```bash
rm claude-skills/go-janitor/SKILL.original.md
rm claude-skills/go-test-reviewer/SKILL.original.md
rm claude-skills/gen-master-spec/SKILL.original.md
```

- [ ] **Step 3: Verify SKILL.md files remain**

Run: `ls claude-skills/*/SKILL*.md`
Expected: only four `SKILL.md` files, no `.original.md`.

- [ ] **Step 4: Commit**

```bash
git add -u claude-skills/
git commit -m "chore(skills): remove pre-compaction SKILL.original.md backups"
```

---

## Task 2: Fix Invalid `compatibility` Frontmatter Field

`compatibility:` is not in the Agent Skills spec and will be ignored by Claude. Replace with `allowed-tools` where it genuinely gates tool access; otherwise delete.

**Files:**
- Modify: `claude-skills/go-test-reviewer/SKILL.md:1-15`
- Modify: `claude-skills/gen-master-spec/SKILL.md:1-5`

- [ ] **Step 1: Rewrite go-test-reviewer frontmatter**

Replace lines 1–15 with:

```yaml
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
```

- [ ] **Step 2: Rewrite gen-master-spec frontmatter**

Replace lines 1–5 with:

```yaml
---
name: gen-master-spec
description: |
  Create comprehensive master specification files that document a project's architecture, organization, and how all components work together. Generates ./docs/master-spec.md (single-layer) or separate ./docs/master-backend-spec.md + ./docs/master-frontend-spec.md (full-stack) based on detected project structure.
  Trigger on phrases like "generate master spec", "document the architecture", "write a spec for this project", "summarize the codebase", "create a project spec", "architecture overview", or when the user asks for a top-level reference doc describing what the codebase does and how it fits together.
allowed-tools: Glob, Grep, Read, Write
---
```

- [ ] **Step 3: Verify frontmatter parses**

Run: `head -15 claude-skills/go-test-reviewer/SKILL.md && echo --- && head -10 claude-skills/gen-master-spec/SKILL.md`
Expected: valid YAML between `---` fences.

- [ ] **Step 4: Commit**

```bash
git add claude-skills/go-test-reviewer/SKILL.md claude-skills/gen-master-spec/SKILL.md
git commit -m "fix(skills): replace invalid 'compatibility' frontmatter with 'allowed-tools'"
```

---

## Task 3: Add `allowed-tools` to Remaining Skills

**Files:**
- Modify: `claude-skills/go-janitor/SKILL.md:1-6`
- Modify: `claude-skills/fallow-review/SKILL.md:1-4`

- [ ] **Step 1: Update go-janitor frontmatter**

Replace lines 1–6 with:

```yaml
---
name: go-janitor
description: |
  Find and remove dead code in Go codebases: unused functions, exports, imports, variables, constants, and unreachable code paths. Simplifies and consolidates remaining code for a leaner codebase.
  Use this skill whenever the user wants to clean up Go code, find unused functions, remove dead code, audit for unused exports, slim down a package, or asks about code that's not being used. Also trigger when the user mentions "dead code", "unused code", "code cleanup", "go cleanup", "remove unused", "slim down", "lean codebase", "unused functions", "unused exports", or wants to make a Go codebase leaner — even if they don't explicitly ask for a "janitor" or "dead code hunter".
allowed-tools: Bash, Read, Edit, Grep, Glob
---
```

- [ ] **Step 2: Update fallow-review frontmatter**

Replace lines 1–4 with:

```yaml
---
name: fallow-review
description: |
  Use when auditing a plain Svelte + bun + vite frontend for dead code, duplication, and complexity hotspots via fallow. Runs `bunx fallow`, categorizes findings, grep-verifies unused exports, then drives a plan-gated cleanup pass.
  Trigger on phrases like "run fallow", "check dead code" (Svelte projects), "audit frontend for unused code", "dedupe Svelte components", "find duplication", or when the user mentions the fallow tool by name.
allowed-tools: Bash, Read, Edit, Grep, Glob
---
```

- [ ] **Step 3: Commit**

```bash
git add claude-skills/go-janitor/SKILL.md claude-skills/fallow-review/SKILL.md
git commit -m "feat(skills): declare allowed-tools + expand trigger descriptions"
```

---

## Task 4: Extract `go-janitor` Reference Files

The trap table (lines 179–194) and output format (lines 196–223) bloat the main SKILL.md without being read every time. Move to `references/` and link.

**Files:**
- Create: `claude-skills/go-janitor/references/go-traps.md`
- Create: `claude-skills/go-janitor/references/output-format.md`
- Modify: `claude-skills/go-janitor/SKILL.md:177-223`

- [ ] **Step 1: Create `references/go-traps.md`**

```markdown
# Go Patterns That Look Dead But Aren't

Before removing any symbol, check whether it matches one of these patterns. Wrong = broken build or subtle runtime failures.

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
```

- [ ] **Step 2: Create `references/output-format.md`**

```markdown
# Dead-Code Removal Summary Format

After changes, emit a concise summary so the user can confirm nothing critical was removed:

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

The per-removal "why" is important — it's the user's confidence signal that nothing important was deleted.
```

- [ ] **Step 3: Replace trap section and output format in SKILL.md**

In `claude-skills/go-janitor/SKILL.md`, replace the block starting at `## Go-specific traps to avoid` (line 177) through end of file with:

```markdown
## Go-specific traps to avoid

Before removing any symbol, consult `references/go-traps.md` — a table of patterns that look dead but are load-bearing (interface compliance, CGo exports, side-effect imports, etc.).

## Output format

After changes, emit a concise summary using the template in `references/output-format.md`.
```

- [ ] **Step 4: Verify line count dropped**

Run: `wc -l claude-skills/go-janitor/SKILL.md`
Expected: ~180 lines (was 224).

- [ ] **Step 5: Commit**

```bash
git add claude-skills/go-janitor/
git commit -m "refactor(go-janitor): move trap table + output template to references/"
```

---

## Task 5: Extract `go-test-reviewer` Reference Files

**Files:**
- Create: `claude-skills/go-test-reviewer/references/table-driven-example.go`
- Create: `claude-skills/go-test-reviewer/references/output-template.md`
- Modify: `claude-skills/go-test-reviewer/SKILL.md:87-166`

- [ ] **Step 1: Create `references/table-driven-example.go`**

```go
// Canonical table-driven test pattern for Go. Recommend whenever a test file
// has three or more tests with the same structure but different inputs.

package example

import "testing"

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

- [ ] **Step 2: Create `references/output-template.md`**

```markdown
# Test Review Output Template

Always use this structure. Skip empty sections, expand full ones.

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
```
```

- [ ] **Step 3: Shrink SKILL.md body**

In `claude-skills/go-test-reviewer/SKILL.md`, replace the inline table-driven example (`**Table-driven tests**` through the code fence, lines ~89–118) with:

```markdown
**Table-driven tests** — Go's most important pattern. Recommend whenever a file has 3+ tests with the same structure. Canonical example in `references/table-driven-example.go`.
```

Replace the `## Output Template` section (lines ~128–166) with:

```markdown
## Output Template

Always use the format in `references/output-template.md`. Skip empty sections, expand full ones — structure keeps review scannable without forcing empty blocks.
```

- [ ] **Step 4: Verify**

Run: `wc -l claude-skills/go-test-reviewer/SKILL.md`
Expected: ~105 lines (was 167).

- [ ] **Step 5: Commit**

```bash
git add claude-skills/go-test-reviewer/
git commit -m "refactor(go-test-reviewer): move example + output template to references/"
```

---

## Task 6: Extract `gen-master-spec` Reference Files

The two spec templates (single-layer and full-stack) are the biggest chunks in this skill. They're only needed at write-time, making them ideal for progressive disclosure.

**Files:**
- Create: `claude-skills/gen-master-spec/references/single-layer-template.md`
- Create: `claude-skills/gen-master-spec/references/backend-template.md`
- Create: `claude-skills/gen-master-spec/references/frontend-template.md`
- Modify: `claude-skills/gen-master-spec/SKILL.md:85-135`

- [ ] **Step 1: Create `references/single-layer-template.md`**

Copy the template currently at SKILL.md lines 87–127 verbatim into this new file, prefixed with:

```markdown
# Single-Layer Master Spec Template

Use this when the project is ONLY backend or ONLY frontend. Save output to `./docs/master-spec.md`.

---
```

- [ ] **Step 2: Create `references/backend-template.md`**

```markdown
# Backend Master Spec Template

Use this for the backend half of a full-stack project. Save to `./docs/master-backend-spec.md`.

---

# Master Specification - [Project Name] (Backend)

## Table of Contents
- [Overview](#overview)
- [Project Organization](#project-organization)
- [Technology Stack](#technology-stack)
- [Architecture](#architecture)
- [Key Components](#key-components)
- [Data Models](#data-models)
- [API Endpoints](#api-endpoints)
- [Configuration](#configuration)
- [Deployment](#deployment)

## Overview
[2-3 sentences on what the backend does]

## Project Organization
[Directory structure of backend only]

## Technology Stack
[Language, framework, key libraries and versions]

## Architecture
[How the backend is structured, patterns, key decisions]

## Key Components
[Main modules/services and what they do]

## Data Models
[Core entities and their structure]

## API Endpoints
[Main routes, purposes, request/response examples]

## Configuration
[Env vars, config files, secrets management]

## Deployment
[How the backend is built and deployed]
```

- [ ] **Step 3: Create `references/frontend-template.md`**

```markdown
# Frontend Master Spec Template

Use this for the frontend half of a full-stack project. Save to `./docs/master-frontend-spec.md`.

---

# Master Specification - [Project Name] (Frontend)

## Table of Contents
- [Overview](#overview)
- [Project Organization](#project-organization)
- [Technology Stack](#technology-stack)
- [Architecture](#architecture)
- [Key Components](#key-components)
- [Routing](#routing)
- [State Management](#state-management)
- [Backend Communication](#backend-communication)
- [Styling](#styling)
- [Build & Deployment](#build--deployment)

## Overview
[2-3 sentences on what the frontend does]

## Project Organization
[Directory structure of frontend only]

## Technology Stack
[Framework, build tool, key libraries and versions]

## Architecture
[Component model, patterns, key decisions]

## Key Components
[Main pages/views/components and what they do]

## Routing
[How navigation is structured]

## State Management
[Redux, Context, Zustand, Svelte stores, etc.]

## Backend Communication
[REST/GraphQL clients, API layer, auth token handling]

## Styling
[Tailwind, CSS modules, styled-components, etc.]

## Build & Deployment
[Dev/prod setup, hosting, CI]
```

- [ ] **Step 4: Shrink SKILL.md**

In `claude-skills/gen-master-spec/SKILL.md`, replace lines 85–135 (everything from `### If ONLY Backend or ONLY Frontend` through the end of the full-stack section) with:

```markdown
### If ONLY Backend or ONLY Frontend

Use the template in `references/single-layer-template.md`. Save output to `./docs/master-spec.md`.

### If BOTH Frontend and Backend

Create two specs using:
- `references/backend-template.md` → save as `./docs/master-backend-spec.md`
- `references/frontend-template.md` → save as `./docs/master-frontend-spec.md`

Each focuses on its own layer; do not duplicate content between the two.
```

- [ ] **Step 5: Verify**

Run: `wc -l claude-skills/gen-master-spec/SKILL.md`
Expected: ~130 lines (was 180).

- [ ] **Step 6: Commit**

```bash
git add claude-skills/gen-master-spec/
git commit -m "refactor(gen-master-spec): extract three spec templates to references/"
```

---

## Task 7: Verify `fallow-review` External Skill References

`fallow-review` calls `superpowers:brainstorming`, `superpowers:writing-plans`, and `superpowers:subagent-driven-development`. If the superpowers plugin is not installed, these invocations fail silently at runtime.

**Files:**
- Verify: `~/.claude/plugins/cache/claude-plugins-official/superpowers/` exists
- Potentially modify: `claude-skills/fallow-review/SKILL.md:77,91`

- [ ] **Step 1: Check superpowers plugin is present**

Run: `ls ~/.claude/plugins/cache/claude-plugins-official/superpowers/*/skills/ 2>/dev/null | head -20`
Expected: directory listing including `brainstorming`, `writing-plans`, `subagent-driven-development`.

- [ ] **Step 2: If superpowers missing**

Add a note at the top of `claude-skills/fallow-review/SKILL.md` directly below the frontmatter:

```markdown
> **Dependency:** This skill delegates to `superpowers:brainstorming`, `superpowers:writing-plans`, and `superpowers:subagent-driven-development`. Ensure the Superpowers plugin is installed before running.
```

Otherwise skip this step.

- [ ] **Step 3: Commit (only if modified)**

```bash
git add claude-skills/fallow-review/SKILL.md
git commit -m "docs(fallow-review): note superpowers plugin dependency"
```

---

## Task 8: Normalize Prose Voice in Skills

Skills currently mix normal English with caveman-style compression ("project no need", "Biggest wins — whole files project no need"). Caveman is fine in tight ops contexts but hurts skills that future maintainers read. Rule: **caveman OK for bullet-point ops steps, normal English for explanations and frontmatter descriptions.**

Do not rewrite whole skills — only fix sentences that become ambiguous when compressed.

**Files:**
- Review: all four `SKILL.md` files

- [ ] **Step 1: Scan go-janitor for ambiguous caveman**

Run: `grep -nE "(no need|no catch|no touch|no install)" claude-skills/go-janitor/SKILL.md`

For each match, decide: does dropping the verb make the meaning ambiguous? If yes, restore. Examples:
- Line 18: "Biggest wins — whole files project no need." → "Biggest wins — whole files the project doesn't need."
- Line 36: "compiler no catch" → "compiler won't catch this"
- Line 51: "Protobuf/gRPC generated code — no touch generated files" → "Protobuf/gRPC generated code — don't touch generated files"
- Line 125: "No install unless user asks." → "Do not install unless the user asks."

- [ ] **Step 2: Scan gen-master-spec for ambiguous caveman**

Run: `grep -nE "(Skill |project do|fit together)" claude-skills/gen-master-spec/SKILL.md`

Fix the top of body (line 10): "Skill analyze whole codebase..." → "This skill analyzes the whole codebase..." Describing a skill in English is clearer than the compressed form for the reader landing here cold.

- [ ] **Step 3: Leave go-test-reviewer and fallow-review as-is**

Both read cleanly already. No changes.

- [ ] **Step 4: Commit**

```bash
git add claude-skills/go-janitor/SKILL.md claude-skills/gen-master-spec/SKILL.md
git commit -m "style(skills): restore clarity in prose where caveman was ambiguous"
```

---

## Task 9: Validate Skills Load Correctly

After all edits, confirm each skill still parses and loads.

- [ ] **Step 1: YAML frontmatter check**

For each skill, extract the frontmatter block and validate:

```bash
for f in claude-skills/*/SKILL.md; do
  echo "=== $f ==="
  awk '/^---$/{c++; if(c==2) exit} c>=1' "$f" | head -20
done
```

Expected: each block is between two `---` fences, with `name:`, `description:`, and `allowed-tools:` keys only. No `compatibility:`.

- [ ] **Step 2: Line-count sanity check**

Run: `wc -l claude-skills/*/SKILL.md`

Expected ranges:
- go-janitor: ~180 (was 224)
- go-test-reviewer: ~105 (was 167)
- gen-master-spec: ~130 (was 180)
- fallow-review: ~151 (unchanged; already good)

- [ ] **Step 3: References check**

Run: `find claude-skills -type f | sort`

Expected tree matches the "File Structure (After Plan)" section above — four SKILL.md, seven reference files, zero `.original.md`.

- [ ] **Step 4: Invoke each skill manually as a smoke test**

Outside the plan execution, in a fresh Claude Code session, invoke each skill by name or trigger phrase and confirm:
- The skill loads without YAML errors.
- Reference files are read on-demand, not loaded at skill entry.
- Output still matches expected format.

---

## Out of Scope (Deferred)

- **Broadening `fallow-review` beyond plain Svelte.** Current scope is deliberate; broadening needs its own research pass on fallow's multi-framework support.
- **Scripts/ automation.** None of the four skills has logic that would benefit from a bundled script today. Revisit if `gen-master-spec`'s project-type detection grows.
- **`disable-model-invocation` for any skill.** All four are genuinely model-invocable — users describe the task, Claude picks the skill. No manual-only workflows here.
- **Argument hints.** None of the skills take positional arguments.

---

## Self-Review Notes

- **Spec coverage:** All four skills have dedicated tasks for frontmatter (T2, T3), content hygiene (T1, T8), and progressive disclosure (T4–T6). `fallow-review` has fewer changes because it is the newest and cleanest.
- **Placeholder scan:** No "TBD"/"implement later"/"add appropriate X" language. Every step shows exact paths, exact edits, exact commands.
- **Type consistency:** Reference filenames (`go-traps.md`, `output-format.md`, `output-template.md`, `single-layer-template.md`, `backend-template.md`, `frontend-template.md`) are referenced identically in both the file-structure section and the per-task steps.
