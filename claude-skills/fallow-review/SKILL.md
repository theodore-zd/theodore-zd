---
name: fallow-review
description: |
  Use when auditing a plain Svelte + bun + vite frontend for dead code, duplication, and complexity hotspots via fallow. Runs `bunx fallow`, categorizes findings, grep-verifies unused exports, then drives a plan-gated cleanup pass.
  Trigger on phrases like "run fallow", "check dead code" (Svelte projects), "audit frontend for unused code", "dedupe Svelte components", "find duplication", or when the user mentions the fallow tool by name.
allowed-tools: Bash, Read, Edit, Grep, Glob
---

# Fallow Review

Run fallow on a Svelte + bun + vite project, triage the report, cleanup with verification gates.

## When to Use

- User says "check dead code", "run fallow", "audit frontend"
- After major refactor, before release
- Bundle size or complexity concerns

## Scope

Plain Svelte (not SvelteKit) + bun + vite. Skip if stack differs.

## Process

### 1. Locate project dir

Order:
1. Current dir if `package.json` has `svelte` in deps
2. Else `./frontend/package.json`
3. Else `./client/package.json`
4. Else ask user

Run all subsequent commands from that dir.

### 2. Run fallow

```bash
bunx fallow --format markdown 2>&1 | head -400
```

If `dead-code` script exists in `package.json`, `bun run dead-code` works too.

### 3. Categorize output

Fallow emits five buckets. Group findings:

| Bucket | Risk | Default action |
|--------|------|----------------|
| Unused files | Medium — build tooling configs look unused but are read by vite/svelte | Keep tooling configs (see Guardrails). Delete others after grep-verify |
| Unused exports (funcs) | Low-Medium — may be called dynamically via string keys, route loaders, `<svelte:component>` | **grep-verify each before delete** |
| Unused type exports | Low — static | Safe to delete |
| Duplication (clone families) | — | Dedupe per family, smallest blast radius first |
| Complexity hotspots (high cyclomatic / CRAP) | — | Surface only; do not auto-refactor without explicit user ask |

### 4. Grep-verify functions before delete

Static analysis misses:
- Dynamic access: `api[methodName](...)`
- Route-triggered loads
- Re-exports via barrels
- `<svelte:component this={X}>`

For each unused-export function name:

```bash
grep -rn "<name>" ./src/ --exclude-dir=node_modules
```

Bucket each: **confirmed-dead** (only declaration hit) vs **false-positive** (referenced elsewhere).

#### Grep gotchas

The plain grep above misses these — check them before declaring confirmed-dead:

- **Barrel files** (`index.ts` re-exports): consumer may import via dir name. Grep the barrel's directory too.
- **`<svelte:component this={X}>`**: dynamic mount. Grep the export as a bare identifier, not just in `import` lines.
- **Renamed imports** (`import { Foo as Bar }`): search for `Bar` also if the alias is used locally.
- **Side-effect imports** (`import './foo.svelte.ts'`): stores and runes files often imported for effect only. Grep the bare path, not just the export name.

### 5. Brainstorm scope with user

Do NOT start deleting. Present options. Standard menu:

- **Scope**: dead exports only / + dedupe / + complexity refactor / custom mix
- **Verify depth**: trust fallow / grep-verify all / hybrid (types trusted, funcs verified)
- **Dedupe targets**: which clone families — smallest first, skip families inside files flagged as high-complexity hotspots (touching risky code without a refactor plan)
- **Gate per task**: `bun run check` / + `bun run build` / + manual smoke
- **Commit granularity**: per-task / per-family / squashed

Defaults (from reference workflow): grep-verify all funcs, dedupe all non-risky families, gate `bun run check && bun run build`, per-family commits.

Use `superpowers:brainstorming` for the Q&A flow.

### 6. Write plan, then execute

After scope locked, use `superpowers:writing-plans` then `superpowers:subagent-driven-development` or `superpowers:executing-plans`.

Each task's verification gate runs in project dir:

```bash
bun run check && bun run build
```

`bun run check` = `svelte-check` + `tsc`. `bun run build` catches build-time issues static check misses.

### 7. Commit

Conventional Commits format. Examples:

- `chore(frontend): remove unused exports flagged by fallow`
- `refactor(frontend): extract shared request helper`
- `refactor(frontend): dedupe command palette components`

## Red Flags

If fallow output looks off, stop and diagnose before acting:

- **Route / entry files flagged unused**: fallow entry config wrong or project uses filesystem routing fallow can't trace. Fix config or add to Guardrails; do not delete.
- **`.svelte.ts` store files flagged unused**: likely imported only as side effect. Grep bare path before declaring dead.
- **Everything flagged**: entry glob wrong. Abort, fix, re-run.
- **Zero findings on a large project**: fallow didn't scan `src/`. Check invocation dir and `--include` globs.

## Guardrails

Never delete (fallow may flag but tooling reads them):

- `svelte.config.js`
- `vite.config.ts` / `vite.config.js`
- `tsconfig*.json`
- `index.html`
- `src/main.ts` / `src/main.js`
- `src/App.svelte`

Never refactor high-complexity functions without explicit user greenlight. Surface the CRAP score, stop.

Never skip grep pass on exported functions. Types safe; functions not.

Skip dedupe families whose clones sit inside hotspot files — refactor those only under a separate user-approved plan.

## Output Format

After step 3, report to user:

```
Fallow: N issues
- unused files: X (keep: <tooling>)
- unused exports: F funcs, T types
- duplication: D% (N clone families)
- hotspots: <top 1-2 by CRAP>

Suggested order: prune types → grep-verify + prune funcs → dedupe (smallest first) → flag hotspots for separate pass.
```

Wait for scope decision.
