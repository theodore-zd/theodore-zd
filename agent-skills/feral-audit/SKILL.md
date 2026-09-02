---
name: feral-audit
description: 'Trigger phrases: "audit this code", "hyper-critical review", "assume nothing works", "hunt for bugs", "prove this code", "written by a dumb child", "is this code broken", "show me what is wrong", "feral audit".'
---

# Feral Audit

- TLDR: Deep adversarial audit of the complete execution flow of whatever it is pointed at — a file, a package, a route, a feature, a diff, or the whole repo. Every function is treated as guilty until proven otherwise. No code is above question.
- TLDR: Stance: assume the author was a dumb child who never handled edge cases, errors, concurrency, auth, or cost. Bugs must be proven (throwaway repro where cheap); improvements are argued by reasoning with a simplicity tax.
- TLDR: Contract: infer what each function "should do" from api.md / docs / AGENTS.md / migrations / tests / callers; if that fails, ask the user mid-audit with a batched `ask`. Asking is good.
- TLDR: Execution: orient → map the full call graph (coverage map with boundaries) → dispatch one feral subagent per layer (Go, Svelte, SQL) in parallel → merge into one severity-ranked report.

Not for: architecture/layering reviews (`backend-arch-review`), cross-cutting tension hunting (`tension-review`), frontend component structure (`component-structure-review`), style/lint (`go vet` / `go fmt`), test-suite QA (`test-audit`), or code stripping (`strip`).

## Stance — the feral rule

1. **Assume nothing works.** The author was a dumb child: they did not handle
   empty/nil/zero/duplicate/malformed input, did not think about failure paths,
   forgot auth, ignored cost, and mutated state they did not own. Every function
   must *survive the battery* before you may call it sound.
2. **Bugs are proven, not asserted.** Every Critical and Important bug finding
   carries a concrete input, the caller path, and — when cheap — a run,
   throwaway reproduction (e.g. `*_feral_repro_test.go`) that is deleted before
   finishing. Suspicion without proof goes to the **Unproven** section; it is
   never presented as fact.
3. **Improvements are reasoned.** A simpler/faster alternative only needs an
   argument that it is correct plus a **simplicity tax** estimate: lines and
   abstractions added vs removed.
4. **Nothing is above question.** A function that looks fine must have survived
   the battery, not been glanced at. (Auditors occasionally return "Gratuitous
   Gold" — a function the battery could not break. That is the only valid
   positive verdict.)

## Contract — what "supposed to do" means

1. Infer from local docs first: `api.md`, `AGENTS.md`, `docs/`, migration
   `db/migrations/*.sql`, handler tests, route definitions in `internal/routes.go`.
2. Infer from callers: how the function is invoked, what callers assume about
   return values and side effects (caller expectations are contracts too).
3. If behavior still cannot be inferred **with confidence**, stop and ask the
   user mid-audit (batch all open questions into one `ask`: "what is X supposed
   to do?"). Do not guess-check-verify; asking is good.
4. Findings whose contract came from inference are stamped `contract: inferred`.

## Dispatch

**1. Orient (main agent, not subagents).**
- Identify the target: file / package / route / feature / diff / whole repo.
- Cheap grounding: `go list -m`, `go vet ./... 2>&1 | head -30` (Go),
  `cd frontend && bun run check` (target FE), `ls db/migrations/` (SQL).
- Look at `api.md` and the route table when the target touches an endpoint.

**2. Map the execution flow.**
- From the target's entry points, trace the full call graph (callers AND
  callees) using `lsp references` / `ast_grep` — never an eyeball guess.
- Produce a **coverage map**: every repo-authored function in the flow, plus the
  **boundary** where the flow leaves repo code (external deps, stdlib, S3,
  pgx — those are graded as "called correctly?", not re-audited).

**3. Slice per layer, dispatch in parallel.**
- One feral subagent per layer involved: Go backend, Svelte 5 frontend, SQL/DB.
- Give each subagent its template (`skill://feral-audit/go-auditor.md`,
  `skill://feral-audit/svelte-auditor.md`, `skill://feral-audit/sql-auditor.md`),
  its exact coverage slice, the boundaries, and the repro-harness rules.
- Slice boundaries MUST be explicit so no function is audited twice and none is
  skipped. Same for frontier: what each subagent may/should not touch.

**4. Assemble (main agent).**
- Merge the returned findings, drop cross-layer duplicates, link layer-spanning
  issues (e.g. the DB index that's missing because a handler loops a query).
- Apply severity ranking, produce the report in the format below.

## Fault battery — the dumb child never survives this

Run every audited function against each family:

- **Inputs**: empty / nil / zero / negative / max-size / unicode / surrounding
  spaces / duplicates / partially missing fields / `0` and `1` and `-1`.
- **State**: missing rows (including soft-deleted!), stale rows, conflicting
  rows, mid-life failure, concurrent invocation of a non-thread-safe function,
  repeated invocation (idempotency), order-of-conditions (auth checked before
  privilege/ownership).
- **Failures**: lower-layer call fails mid-flow (step 2 fails after step 1
  committed — partial state?), timeout / context cancel / client disconnect /
  network and S3 outages, panic with no recovery, swallowed errors (`_ =`,
  empty catch, `defer` rewriting a result).
- **Auth**: route middleware in place; tier checks where they belong (owner-only
  at handler, membership in DB SQL); services performing auth (NEVER allowed);
  anything reachable without auth.
- **Efficiency**: queries inside loops (N+1), re-querying the same data,
  re-alloc/re-copy on hot paths, per-request reads of static config, pagination
  without count, unbounded lists.
- **Simplicity**: does this function deserve to exist? stdlib already does it?
  abstraction paying rent? duplicated pattern that should be unified? args the
  caller doesn't need?

## Side-effect ledger

For every audited function, note what is true (roll up per layer and per report):

- mutates inputs (slices/maps/structs, `$state` in-place)
- mutates global/module state (stores, config, singletons, pools)
- persists something (DB write, S3, file, email)
- reads data that a later write silently depends on (order dependence)
- swallows errors / ignores return values
- spawns goroutines / timers / listeners / subscriptions without owner cleanup
- assumes single-flight or caller-held locks without documenting it

## Report format

```
## Feral Audit — {TARGET}

### Trigger / Scope
- target, user's ask, coverage map summary (audited files + boundaries + exclusions)

### Bugs — Proven
[layer] [file:line] what breaks with which input/call path; impact; repro evidence

### Important — Wrong or Risky
[layer] [file:line] why it matters, what actually happens; one-sentence fix

### Minor — Efficiency & Simplicity
[layer] [file:line] suggested change, simplicity tax (+X/-Y lines, +0/-1 abstraction)

### Unproven candidates
[layer] [file:line] the suspicion, why not (yet) proven

### Verdict
one line: "clear", "broken in N places", "worse than a dumb child", etc.
```

## Red flags — never

- Run the audit without orientation or without a coverage map.
- Dispatch per-layer auditors serially — parallel or not at all.
- Re-summarize subagent findings instead of integrating them verbatim.
- Let a subagent edit production code — throwaway repro files only, deleted
  before returning, never left behind, never committed.
- Present unproven suspicion as a bug; that is what "Unproven" is for.
- Skip the auth ladder (handler roles, DB membership, zero auth in services).
- Say "looks fine" without showing the battery result that supports it.
- Fuse auditors' scope or double-flag a shared finding without merging them.