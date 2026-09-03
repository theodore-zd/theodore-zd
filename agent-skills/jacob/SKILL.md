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

The reviewer enforces these specific rules compiled from Jacob's PR feedback (source: PRs #29 #444 #453 #462 #464 #481 #496 #506 #518 #525 #533 #536 #542 #549 #623 #663 #701 #771 #780):

### Props & Typing

1.  **`interface Props` over `type Props`** — Never use `type Props = { ... }` or inline `$props<{}>()`. Always `interface Props { ... }` with `let { ... }: Props = $props()`. For components that wrap or style a native element, follow the established pattern `interface Props extends WithElementRef<HTMLAttributes<HTMLElement>> { ... }`. Context/registration types must also be interfaces, pulled out of the component file into their own module.
2.  **No unnecessary casts** — No `as Record<string, unknown>`, no `Array.isArray()` on correctly-typed data. No `as any`/`as never` when a preceding `if` guard or the type definition already constrains the value — let the narrowing do the work.
    - **Exception:** Casts on `Snippet` props passed to a context-registration function are **required** when the consumer's signature uses a different generic. Svelte's `Snippet<P>` is contravariant in `P`, so `Snippet<[{ row: Row }]>` cannot structurally match `Snippet<[{ row: unknown }]>`. Either cast to the context's type or change the context to `DataTableColumnRegistration<any>`.
3.  **No non-null assertions scattered** — Consolidate with `$derived.by()` instead of sprinkling `!` everywhere.
4.  **Exhaustive switch defaults** — Every discriminant union switch needs a `default:` that throws.
5.  **Dedicated named types** — Define named `interface`s for shapes (context data, query/action payloads) instead of inline anonymous types, and put reusable domain/GraphQL types in their `$lib/types` module. Don't carry unused props/fields.

### State & Reactivity (Svelte 5 + runed)

6.  **`$derived` over `$state`** — Computed values should use `$derived` or `$derived.by`, not `$state` with manual sync. Note `$derived` is still reassignable — use it to fix "state referenced locally" warnings rather than switching to `$state`.
7.  **Avoid `$effect` when possible** — Prefer explicit functions (e.g. `finishEdit()`) over `$effect` reacting to state.
8.  **Runed `Context` over raw `getContext`/`setContext`** — Import `Context` from runed for typed contexts. `.get()` **throws** when unset: use `.getOr(undefined)` (or the runed pattern the file already uses) when the context is genuinely optional. Where a prop may be a plain value or a getter, accept `MaybeGetter<T>` and resolve with `extract(...)` from runed.
9.  **Runed `PersistedState`** — Not hand-rolled localStorage.
10. **Runed `watch`** — Not bare `$effect` with unused deps; explicit dependency makes intent clear.
11. **Runed `resource` for async component data** — Use `resource(source, fetcher, { signal })`, not `$effect` + fetch + hand-rolled `cancelled` flag. The abort `signal` replaces the flag; `.current`/`.loading`/`.error` give a clean surface.
12. **`{@render children?.()}` for optional snippets** — An optional `children?: Snippet` prop renders with `{@render children?.()}`, not `{#if children}{@render children()}{/if}`.

### Money & Numeric Precision

13. **Decimal everywhere, never floats** — Financial/money/percentage math must use `Decimal` via `safeParseDecimal`/`parseDecimalOrNull` (from `$lib/parsing/decimal.ts`); never `parseFloat`/`Number(...)` for financial values. Don't round-trip a `Decimal` through `asNumber` just to `String()` it — call `.toString()` on the Decimal directly.

### Fetching, Errors & Data

14. **No raw `fetch` in components** — Use `clientFetch`/`clientFetchJson` from `$lib/fetch`: they normalize error bodies into `HttpResponseError`/`CodedError` and redirect to login on `LOGIN_REQUIRED`. A bare `fetch` that only checks `response.ok` drops all of that.
15. **API routes & actions use the project wrappers** — Never hand-roll body parsing/validation or set `locals.inAPI` manually: use `jsonFetchApi(schema, handler)` / `fetchApi` from `$lib/server/api` (zod-validated, proper `CodedError`s) and `superFormAction` for form actions. Client-side, catch errors properly — log via `logger.error` and surface any error ref/requestId instead of swallowing.
16. **Server-first: prefer page loads over API routes** — Data that only feeds one page belongs in `+page.server.ts`; don't add `/api/*` GET routes for page-only data. Pass the promise through **unawaited** as `streamedResult(...)` so the client gets loading states, and pass loading state down to children rendering async data (a component that isn't told it's loading renders an empty list). Only introduce an API route when genuinely shared or action-driven.
17. **Invalidate page/layout data with `invalidateAll()` / targeted `invalidate(...)`** — TanStack Query's `.refetch()` does not reload SvelteKit SSR-provided page data.
18. **Route URLs via `resolve` from `$app/paths`** — Not hand-built template strings.
19. **GraphQL fragments for repeated field sets** — Reuse a fragment instead of spelling the same fields out twice.

### Clean Code & Organization

20. **No stray comments** — Remove TODO comments, HTML comments, commented-out code, and leftover documentation churn before committing.
21. **Hoist complex logic** — Inline processing in templates should be extracted to named functions, `{@const}`, or `$derived.by`.
22. **No nested ternaries** — A ternary is fine for a simple two-way choice, but when branches nest or grow past one expression (data loading, render logic, column configs — anywhere), use `if`/`else` statements, or extract the whole choice into a named function that uses early returns. Not inline ternary chains.
23. **File organization** — No single-function files. Colocate helpers with their constants (flag helpers next to `CLIENT_FEATURE_FLAGS`) or use a shared helpers file. All interfaces (not just `Props`) belong at the top of the `<script>` block, before state and derived declarations.
24. **Component placement mirrors what it serves** — A storybook-only provider that stubs app-level context belongs next to the module it stubs (e.g. `$lib/launchDarkly/`), not in a feature/domain folder.
25. **Defaults hygiene** — Only keep defaults that provide genuine fallback value; drop `= undefined` on optional props; fields required by a context must not be given defaults. A component with a single call site shouldn't be parameterized — bake the props in.
26. **Reuse existing components & libraries before re-implementing** — bits-ui `Portal`, an existing `MonthSelect`, the `uuid` `v4()` for generated ids — if the abstraction exists in the codebase or a dependency, use it. (Large mappings/extractions belong in a dedicated file.)
27. **CSS consistency** — Single layout mode per element (not `display: flex` + `display: grid`). Prefer utility classes/`class` over inline `<style>`.
28. **Import sorting** — Enforce `perfectionist/sort-imports` conventions per the project's ESLint config.

### Edge-Correctness & Perf

29. **Trust the types — no dead defensive guards** — Don't null-check fields the type defines as non-nullable (e.g. `created_at`). A runtime guard that can never fire is dead code and masks type drift.
30. **Guard divisions derived from array lengths** — Column-width math that divides by `columns.length`/`rows.length` needs an empty-array guard; `Infinity`/`NaN` widths break table layout silently.
31. **Stable keys: know the uniqueness domain** — For legacy entities, prefer the runtime-assigned globally-unique field (`interaction.index`); keep only key segments that protect against real historical collisions (a timestamp when pre-merge data can duplicate indexes) and drop decorative ones (slugs).
32. **Reuse project helpers over inline re-implementations** — Before writing an inline conversion (e.g. `new Date(ts * 1000)` or a manual try/catch parse), look for the existing helper (`mapInteractionCreatedAt(interaction)`, `parseDecimalOrNull`) and use it.
33. **No per-call allocation in hot paths** — Don't rebuild formatter/parser functions or closures inside functions called per-row/per-cell; hoist them to module scope.

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
