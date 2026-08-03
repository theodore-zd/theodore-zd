---
name: component-structure-review
description: 'Trigger phrases: "review component structure", "is this component too complex", "simplify this Svelte code", "review state structure", "YAGNI review", "frontend component complexity", props, lifting state, component boundaries.'
---

# Component Structure Review

Dispatch a reviewer subagent that focuses on **reducing complexity, strong component organization, and questioning necessity**. One question above all: *is this code doing more than it needs to?*

Separate from style/linter reviews (props interface rules, runed patterns, import sorting). Use it for architecture, state placement, component boundaries, and simplicity.

## When to Use

- Before merging a new page, component, or store
- A Svelte component or `.svelte.ts` file feels too large or unfocused
- After a refactor that moved state, props, or helpers around
- Suspected over-engineering, premature abstraction, or prop drilling
- PR for a feature with multiple new components

For cross-cutting structural tensions — state ownership ambiguity, prop drilling chains, effect propagation cascades, concern conglomeration — use `tension-review` and specify "check the frontend."

## The Standards

The reviewer enforces 11 structural rules — single responsibility, state colocation, derived-over-synced state, minimal props, no prop drilling, size caps, no premature abstraction, question every state/prop/branch/effect, effect discipline, file organization, template simplicity. Full checklist with per-rule detail at `skill://component-structure-review/reviewer.md` — read before dispatching.

## How to Dispatch

**1. Get git SHAs:**

```bash
BASE_SHA=$(git rev-parse HEAD~1)  # or origin/main
HEAD_SHA=$(git rev-parse HEAD)
```

**2. Dispatch the reviewer subagent:**

Read the prompt template at `skill://component-structure-review/reviewer.md`, fill the placeholders, dispatch.

**Placeholders:**
- `{DESCRIPTION}` — Brief summary of what was built or changed.
- `{PLAN_OR_REQUIREMENTS}` — What it should do.
- `{BASE_SHA}` — Starting commit.
- `{HEAD_SHA}` — Ending commit.

**3. Act on feedback:**
- Fix Critical issues immediately.
- Fix Important issues before proceeding.
- Note Minor issues for later.
- Push back if the reviewer is wrong (with technical reasoning).

## Red Flags

**Never:**
- Skip review because "it's just a small change."
- Leave Critical issues unresolved.
- Add new global state for a single consumer.
- Extract a component/helper for only one caller without a clear reason.
- Add props "for later."

**If reviewer flags something you disagree with:**
- Push back with technical reasoning.
- Show precedent in the codebase.
- If truly conflicted, ask for a second opinion.
