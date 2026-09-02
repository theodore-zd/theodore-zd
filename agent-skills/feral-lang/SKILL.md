---
name: feral-lang
description: 'Trigger phrases: "enforce code style deterministically", "add linting", "configure linting", "set up biome", "set up eslint", "set up prettier", "configure golangci", "lock down code standards", "deterministic enforcement", "make the linter enforce it".'
---

# Feral Lang

- TLDR: Adds/configures per-language deterministic enforcement so code-organization standards are machine-checked, not just written in AGENTS.md. Runs standalone on any repo OR as feral-org's enforcement phase.
- TLDR: Stance: a rule that can be enforced by a tool is not a convention — it is a config. Standards that cannot be enforced deterministically stay as AGENTS.md rules + review checklist items, and the skill says which is which.
- TLDR: Contract: never invent a parallel toolchain — detect what exists, extend the repo's documented verification order, and for known stacks install the canonical tooling when none exists.
- TLDR: Execution: detect stack → per-language decision table → install/config → wire into the repo's verification order (AGENTS.md/README scripts) → run gates → report an enforced-vs-convention matrix.

Not for: code stripping (`strip`), aggressive reorganization sweeps (`feral-org` — when the user wants org moves plus enforcement, feral-org runs and hands its LINT-ENFORCE rules here), bug hunting (`feral-audit`), or review-only conventions (a standard with no tool mapping is a convention; say so and keep it in AGENTS.md).

## Stance

Determinism over doctrine: the goal is that violations fail a command. Idempotent, incremental, zero-false-positive configs only; anything flaky stays convention. Toolchain follows the repo: extend existing config/scripts, never create a second parallel one. Where the repo's AGENTS.md/README declares a verification order, extend that exact order with the new gates.

## Dispatch

**1. Detect the stack.**
- Languages present (globs): `*.go`, `*.svelte`/`*.ts`, `*.sql`, `*.py`, `*.rs`, etc.
- Package manager (`bun`/`npm`/`pnpm` — Atluo is bun).
- Existing tooling: config files, devDeps, scripts, CI.

**2. Known-stack decision table** (install by default when the tool is absent — user-confirmed preference; flag installs in the report):

| Language | Tooling to install/configure | Gate commands to wire |
|---|---|---|
| Go | `golangci-lint` (if missing, install via the repo's preferred method; config `.golangci.yml` enabling `gofmt`, `govet`, `staticcheck`, `errcheck`) + keep `go vet`/`go fmt` in the order | `golangci-lint run ./...` added after `go vet ./...` |
| Svelte 5 / TS (bun) | `.editorconfig` at repo root (indent 2/4 per stack, utf-8, lf); devDeps: `prettier` + `prettier-plugin-svelte` + `eslint` + `eslint-plugin-svelte` + `typescript-eslint` + `eslint-config-prettier`; `.prettierrc` (plugin svelte, svelteSortOrder, overrides for svelte) + `.prettierignore`; `eslint.config.js` flat config (svelte plugin w/ typescript-eslint parser, prettier conflict rules off); package.json scripts `lint` (`eslint .`) and `format` (`prettier --write .`) and `format:check` | `bun run lint` and `bun run format:check` appended to the `check` script chain or to the documented order |
| SQL / Postgres | `sqlfluff` with `dialect: postgres` config (`.sqlfluff`) — ONLY when the user asks or a feral-lang standalone run targets SQL; not auto-installed with feral-org runs | `sqlfluff lint db/` (optional) |
| Unknown language | Load `skill://feral-lang/generic-language-adapter.md` and follow it | per adapter |

**3. Existing tooling?** Extend it (add the missing rule/plugin), do not reinstall or duplicate.

**4. Wire gates** into the repo's documented verification order (AGENTS.md + README when both carry it — Atluo has the same 4-command block in both; update both) and add the new scripts to package.json beside `check`. Do NOT gate `scripts/dev.sh` unless the user asks (watch-loop gates churn).

**5. Run every new gate;** they must pass on the current tree (or report the pre-existing violations as a list, never silently fix unrelated code).

## Rules-in → enforcement-out

Given a list of `LINT-ENFORCE` rules (from feral-org) or user-stated standards: map each to a tool rule where one exists:

| Rule kind | Tool rule |
|---|---|
| formatting | prettier/biome |
| import order | eslint/import or prettier plugin |
| banned API | eslint no-restricted-syntax / golangci forbidigo |
| naming | eslint naming-convention |
| file layout | editorconfig/per-project ignores |

Rules with no tool mapping are returned as convention-only with a one-line reason.

## Report format

```
## Feral Lang — {REPO}
### Stack detected / tooling before→after
### Configs written (paths) / scripts added / verification order diff
### Gate results (each command, pass/fail)
### Enforced-vs-convention matrix (rule → tool rule or 'convention only' + why)
```

## Red flags — never

- Invent a second config beside an existing one.
- Reinstall a present tool.
- Add a gate that fails on the current clean tree without reporting it.
- Run formatters across the repo unprompted (format only files the config touches when the user asked for setup — `format:check` validates, `--write` only on explicit request or within a feral-org-approved batch).
- Touch CI that does not exist (Atluo has none).
- Edit SQL migrations.
