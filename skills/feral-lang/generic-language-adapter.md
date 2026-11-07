# Generic Language Adapter — Prompt Template

Use when a feral-lang run targets a language not in the known-stack decision table, or when the ecosystem status of a named tool is uncertain. Given a language L + a list of standards, this adapter configures deterministic enforcement for L without over-configuring.

**Placeholders**: `{LANGUAGE}`, `{REPO_ROOT}`, `{STANDARDS}`, `{VERIFICATION_ORDER}`, `{PACKAGE_MANAGER}`.

```
You are configuring deterministic enforcement for language {LANGUAGE} at
{REPO_ROOT}. Package manager: {PACKAGE_MANAGER}.

Standards to enforce (each is a concrete rule from the repo's AGENTS.md or a
feral-org LINT-ENFORCE handoff):
{STANDARDS}

## Procedure

1. **Identify the canonical tooling** for {LANGUAGE}: its linter, formatter, and
   type-checker. Use `librarian` or web research when uncertain about ecosystem
   status — tools change; never guess a config from memory for an unfamiliar
   stack. Prefer the tool the language's official docs recommend.

2. **Install** via {LANGUAGE}'s package manager (the repo's manager when it is
   one — e.g. bun for a JS/TS repo).

3. **Write minimal config** enabling ONLY rules that map to the stated
   standards. Every enabled rule must trace to a standard; nothing opinionated
   beyond them. If a standard has no tool rule in L's ecosystem, leave it out
   and record it as convention-only in the matrix.

4. **Add the gate script** to the repo's verification order ({VERIFICATION_ORDER}
   — extend that exact block; do not create a parallel order). Follow the repo's
   script conventions (package.json beside `check`, Makefile targets, etc.).

5. **Verify the gate passes** on the current tree. If it fails on pre-existing
   violations, report them as a list — never silently fix unrelated code.

6. **Output** the enforced-vs-convention matrix below.

## Output format

### Configs written (paths) / scripts added / verification order diff
### Gate results (each command, pass/fail)
### Enforced-vs-convention matrix
rule → tool rule | 'convention only' + one-line reason

## Don't
- DO NOT over-configure: no opinionated rule sets beyond the stated standards.
- DO NOT edit source files; run formatters with --write across the repo
  unprompted; invent a second toolchain beside one that already exists;
  reinstall a present tool.
- Return ONLY the output sections.
```
