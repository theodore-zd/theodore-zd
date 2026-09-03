---
name: jacob
description: Use when you want a code review applying Jacob's (jacobtread) specific frontend/TypeScript standards — Props patterns, runed over raw, typing hygiene, $derived over $state, and codebase consistency
---

# Jacob Code Review

Dispatch a "Jacob" reviewer subagent that applies the same standards Jacob uses in PR reviews. This ensures code consistency, catches pattern violations early, and keeps the codebase aligned with the practices he established.

**Core principle:** Code consistency beats cleverness. Every exception is a future refactor.

## When to Use

**Mandatory:**

- Before merging anything to `main`
- Before creating a PR
- After completing a significant feature or refactor

**Recommended:**

- When starting a new component or module
- Before your own PR review cycle
- When onboarding or delegating to another contributor

## The Jacob Standards

The reviewer enforces these specific rules compiled from Jacob's PR feedback:

1.  **`interface Props` over `type Props`** — Never use `type Props = { ... }` or inline `$props<{}>()`. Always `interface Props { ... }` with `let { ... }: Props = $props()`.
2.  **Runed over raw** — Use `Context` from runed, not raw `getContext`/`setContext`. Use `PersistedState` from runed, not hand-rolled localStorage. Use `watch` from runed, not bare `$effect` with unused deps.
3.  **No non-null assertions scattered** — Consolidate with `$derived.by()` instead of sprinkling `!` everywhere.
4.  **No unnecessary casts** — No `as Record<string, unknown>`, no `Array.isArray()` on correctly-typed data. No `as any` when a preceding `if` guard already narrows the type — let the narrowing do the work.
    - **Exception:** Casts on `Snippet` props passed to a context-registration function are **required** when the consumer's signature uses a different generic. Svelte's `Snippet<P>` is contravariant in `P`, so `Snippet<[{ row: Row }]>` cannot structurally match `Snippet<[{ row: unknown }]>`. Either cast to the context's type or change the context to `DataTableColumnRegistration<any>`.
5.  **Exhaustive switch defaults** — Every discriminant union switch needs a `default:` that throws.
6.  **`$derived` over `$state`** — Computed values should use `$derived` or `$derived.by`, not `$state` with manual sync.
7.  **Avoid `$effect` when possible** — Prefer explicit functions (e.g. `finishEdit()`) over `$effect` reacting to state.
8.  **No stray comments** — Remove TODO comments, HTML comments, commented-out code before committing.
9.  **Hoist complex logic** — Inline processing in templates should be extracted to named functions or `$derived.by`.
10. **File organization** — No single-function files. Colocate helpers with their constants or use a shared helpers file. All interfaces (not just `Props`) belong at the top of the `<script>` block, before state and derived declarations.
11. **No nested ternaries** — A ternary is fine for a simple two-way choice, but when branches nest or grow past one expression (data loading, render logic, column configs — anywhere), use `if`/`else` statements, or extract the whole choice into a named function that uses early returns. Not inline ternary chains.
12. **CSS consistency** — Single layout mode per element (not `display: flex` + `display: grid`). Prefer utility classes/`class` over inline `<style>`.
13. **Import sorting** — Enforce `perfectionist/sort-imports` conventions per the project's ESLint config.
14. **Use framework helpers, not manual flag setting** — Never set `locals.inAPI = true` directly; use the `fetchApi` helper from `$lib/server/api`. Never reach for low-level primitives when a project-level abstraction exists.
15. **Runed `resource` for async component data** — When a component fetches data, use `resource(source, fetcher, { signal })` from `runed`, not a `$effect` + raw `fetch` + hand-rolled `cancelled` flag. The abort `signal` replaces the flag; `.current`/`.loading`/`.error` give a clean surface.
16. **No raw `fetch` in components** — Use `clientFetch`/`clientFetchJson` from `$lib/fetch`: they normalize error bodies into `HttpResponseError`/`CodedError` and redirect to login on `LOGIN_REQUIRED`. A bare `fetch` that only checks `response.ok` drops all of that.
17. **Server-first: prefer page loads over API routes** — Data that only feeds one page belongs in `+page.server.ts` as a `streamedResult`; do not add `/api/*` GET routes for page-only data (they duplicate server work, add an auth/error surface, and need `fetchApi` to behave). Only introduce an API route when genuinely shared or action-driven.
18. **`{@render children?.()}` for optional snippets** — An optional `children?: Snippet` prop renders with `{@render children?.()}`, not `{#if children}{@render children()}{/if}`.
19. **Trust the types — no dead defensive guards** — Don't null-check fields the type defines as non-nullable (e.g. `created_at`). A runtime guard that can never fire is dead code and masks type drift. Align guards with the type definition, not paranoia.
20. **Reuse project helpers over inline re-implementations** — Before writing an inline conversion (e.g. `new Date(ts * 1000)`), look for the existing helper (`mapInteractionCreatedAt(interaction)`) and use it.
21. **Component placement mirrors what it serves** — A storybook-only provider that stubs app-level context belongs next to the module it stubs (e.g. `$lib/launchDarkly/`), not in a feature/domain folder.
22. **Guard divisions derived from array lengths** — Column-width math that divides by `columns.length`/`rows.length` needs an empty-array guard; `Infinity`/`NaN` widths break table layout silently.
23. **Stable keys: know the uniqueness domain** — For legacy entities, prefer the runtime-assigned globally-unique field (`interaction.index`); keep only key segments that protect against real historical collisions (a timestamp when pre-merge data can duplicate indexes) and drop decorative ones (slugs).

## How to Dispatch

**1. Get git SHAs:**

```bash
BASE_SHA=$(git rev-parse HEAD~1)  # or origin/main
HEAD_SHA=$(git rev-parse HEAD)
```

**2. Dispatch the Jacob reviewer subagent:**

Use a `general-purpose` subagent, filling the template at [jacob-reviewer.md](jacob-reviewer.md).

**Placeholders:**

- `{DESCRIPTION}` — Brief summary of what was built
- `{PLAN_OR_REQUIREMENTS}` — What it should do
- `{BASE_SHA}` — Starting commit
- `{HEAD_SHA}` — Ending commit

**3. Act on feedback:**

- Fix Critical issues immediately
- Fix Important issues before proceeding
- Note Minor issues for later
- Push back if the reviewer is wrong (with technical reasoning)

## Red Flags

**Never:**

- Skip review because "it's just a small change"
- Leave Critical issues unresolved
- Introduce new `type Props` or inline `$props<{}>` violations
- Add new `getContext`/`setContext` without runed

**If reviewer flags something you disagree with:**

- Push back with technical reasoning
- Show precedent in the codebase
- If truly conflicted, ask for a second opinion
