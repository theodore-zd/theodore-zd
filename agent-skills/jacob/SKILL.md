---
name: jacob
description: Use when you want a code review applying Jacob's (jacobtread) specific frontend/TypeScript standards — Props patterns, runed over raw, typing hygiene, $derived over $state, codebase consistency, and ruthless rejection of redundant/duplicated code
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

The reviewer enforces these specific rules compiled from Jacob's PR feedback (source: PRs #29 #444 #453 #462 #464 #481 #496 #506 #518 #525 #533 #536 #542 #549 #623 #663 #701 #771 #780 #816):

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
26. **Reuse existing components & libraries before re-implementing** — bits-ui `Portal`, an existing `MonthSelect`, the `uuid` `v4()` for generated ids — if the abstraction exists in the codebase or a dependency, use it. (Large mappings/extractions belong in a dedicated file.) The same rule applies to **logic**: never copy a helper, block, or file and tweak identifiers — extract the shared part and use it twice.
27. **CSS consistency** — Single layout mode per element (not `display: flex` + `display: grid`). Prefer utility classes/`class` over inline `<style>`.
28. **Import sorting** — Enforce `perfectionist/sort-imports` conventions per the project's ESLint config.

### Edge-Correctness & Perf

29. **Trust the types — no dead defensive guards** — Don't null-check fields the type defines as non-nullable (e.g. `created_at`). A runtime guard that can never fire is dead code and masks type drift.
30. **Guard divisions derived from array lengths** — Column-width math that divides by `columns.length`/`rows.length` needs an empty-array guard; `Infinity`/`NaN` widths break table layout silently.
31. **Stable keys: know the uniqueness domain** — For legacy entities, prefer the runtime-assigned globally-unique field (`interaction.index`); keep only key segments that protect against real historical collisions (a timestamp when pre-merge data can duplicate indexes) and drop decorative ones (slugs).
32. **Reuse project helpers over inline re-implementations** — Before writing an inline conversion (e.g. `new Date(ts * 1000)` or a manual try/catch parse), look for the existing helper (`mapInteractionCreatedAt(interaction)`, `parseDecimalOrNull`) and use it.
33. **No per-call allocation in hot paths** — Don't rebuild formatter/parser functions or closures inside functions called per-row/per-cell; hoist them to module scope.

### Component Hierarchy

34. **Place components at the lowest level that fits** — Search `domain/` → `organisms/` → `molecules/` → `atoms/` → `ui/` before creating anything new, and put a component in the level that its content dictates (reference tree below). A pure primitive with design tokens only is an atom; a small reusable renderer is a molecule; a composed structure with shared context is an organism; a feature-scoped piece belongs in `domain/<feature>/`. **Atoms are structural — no business logic, no data fetching, no domain imports.**
35. **No duplicated logic across sibling files — write it once, use it twice** — When near-identical routes/pages need the same logic (sibling loaders, report variants), extract a shared parameterized helper and keep the per-variant files thin. A diff that **adds the same block a second time** is the opposite of reuse: it doubles the maintenance surface and every future fix must be applied twice. This is not premature abstraction (Rule of Three) — a file that is a >80%-identical copy of a sibling is already-compounded debt, and a diff that adds the second copy is merge-blocking regardless of per-file quality. Concretely: normalize per-variant identifiers (report names, titles, data paths) and diff the siblings; if only a handful of lines differ, flag it and require extraction.

### Central Systems & Cross-Boundary

36. **Route through central resolvers — never re-implement their contract at call sites** — When a concern has a central resolver (variation lookups: `variation()` client-side and `resolveDarklyVariation` server-side — both fold `DEV_FLAG_OVERRIDES`; fetches: `clientFetch`/`jsonFetchApi`; decimals: `safeParseDecimal`/`parseDecimalOrNull`), call sites call the resolver with plain arguments and nothing more. A call site that adds `DEV_FLAG_OVERRIDES[key] === true || await resolveDarklyVariation(...)` copies a slice of the resolver's behavior: it re-derives what the resolver already owns, drifts independently when the resolver contract changes, and teaches future readers there are two sources of truth. If a call site needs override-aware or special behavior, extend the resolver — don't bolt a second copy beside the call.
37. **Cross-boundary string constants must stay in lockstep (or be single-sourced)** — Feature flags appear in both `clientFeatureFlags.ts` (`CLIENT_FEATURE_FLAGS`) and `serverFeatureFlags.server.ts` (`SERVER_FEATURE_FLAGS`); the dev-override map is keyed on the **client** enum while server-side lookups use the **server** enum. The override system silently breaks if the string values diverge (dev behaves like prod, no error). When a diff adds/renames a flag used on both sides, or touches the override map, reviewer MUST verify the strings stay identical in both enums; prefer deriving one enum from the other (or a shared constants module) when realistic.

### Server Loads & Organization

38. **Named input/output types on exported server functions** — A server function or loader helper takes a named `interface XInput` and returns a named interface, never inline object literals (`input: { ... }` / `Promise<{ ... }>`). Existing named types for the same shape are reused, not duplicated (precedent: `FinancialStatementReviewInput`/`FinancialStatementReviewData` in `financialStatementReview.ts`).
39. **Return objects are results-only** — In `load` functions and actions, every promise chain (`Promise.all(...).then(...)`) is hoisted into a named const above the `return`; the return statement only assembles results.
40. **Route files stay thin** — `+page.server.ts` contains load/actions and wiring only; multi-step transforms (row synthesis, map rekeying, ID↔code mapping) live in a sibling module under `src/lib/server/<domain>/`, never at the bottom of a route file.
41. **Decompose orchestrators** — A pipeline function that both coordinates and constructs (flag resolution, document resolution, collection building, per-pipeline computation) extracts each concern into a focused named helper; target under ~60 lines per function.

## Component Structure Reference

The component tree under `src/lib/components/` (deep table rules live in `src/lib/components/organisms/tables/references.md` + `docs/agent/references/table-styling.md`):

```
src/lib/components/
├── ui/                    # Vendored generic primitives (shadcn/bits-ui wrappers)
│   ├── button/ dialog/ select/ form/ field/ popover/ sheet/ skeleton/ …
│   └── table/  ← deprecated; use atoms/table
├── atoms/                 # Pure primitives — structure & design tokens ONLY
│   ├── table/             # HTML table primitives: Root, Header, Body, Row, Cell,
│   │                      #   HeadCell, Caption, Footer + context/token modules
│   ├── text/              # Heading
│   ├── inputs/            # input/ link-tabs/ upload/
│   ├── media/avatar/      # avatar
│   ├── layout/            # ContentContainer
│   ├── card/ card-list/ pill/ status-icon/ indicator/ tooltip/ context-menu/
│   └── client/            # ClientOnly
├── molecules/             # Reusable compositions — formatting + interaction, no structure
│   ├── table/
│   │   ├── cells/         # TextCell, CurrencyCell, NumericCell, DateCell, SelectCell, …
│   │   └── SortableHeader, CellShell, CommentCellPopover, XeroAccountCell, …
│   ├── feedback/          # empty/ error/ hint/ info/ loading/ progress/ streamed/
│   ├── surfaces/card/     # card surfaces (skeleton, status)
│   ├── markdown/ stats/ breadcrumbs/ checklist/ xlsx/
├── organisms/             # Large composed structures, shared context
│   ├── tables/            # base-table/ editable-table/ tree-table/
│   │                      #   reconciliation-table/ workpaper/ + TablePagination
│   ├── app/               # sidebar/ page/ app-banner/ demo-tools/ debug/ Logo
│   ├── charts/            # Trend* charts + trend utils
│   ├── auth/ search/ marketing/
└── domain/                # Feature-scoped, one folder per product domain
    ├── exception-report/  # ExceptionReportRow, TrafficLightLegend, … (stories/tests colocated)
    ├── workpapers/ worksheets/ gather/ general-ledger/ chart-of-accounts/
    ├── review/ review-checklist/ client-queries/ shareholders/ gst/ insights/
    └── jobs/              # list/ print/ sections/ single/
```

**Rules of thumb**

- **Lowest level that fits.** Domain page → `domain/` or compose in the route. Reusable across pages → `organisms/`. Small shared renderer → `molecules/`. HTML/design-token primitive → `atoms/`. Vendored generic → `ui/`.
- **Atoms stay structural** — no business logic, no data fetching, no domain imports.
- **Storybook providers/context stubs live next to the module they stub** (standard 24), never in the feature folder.
- **Stories & tests colocate** with their component (`X.stories.svelte`, `x.test.ts`); route fixtures live under the route's `__fixtures__/`.
- **Tables**: structure from `atoms/table`, reusable cell renderers from `molecules/table/cells`, context shells from `organisms/tables/*`, columns defined per page/domain. Never raw `<td>` in rows, never wrapper row components; `ui/table` is deprecated.
- **Non-component logic mirrors the same grouping**: feature logic in `src/lib/job/`, `src/lib/workpapers/`, `src/lib/worksheets/`…; server-only code under `src/lib/server/` (`server/job/review/`…); GraphQL per domain in `server/graphql/` (`jobs.ts`, `tax.ts`, `client.ts`); shared client types in `src/lib/types/<domain>.ts`; feature flags + flag helpers + `LaunchDarklyStoryProvider` in `src/lib/launchDarkly/`; generic helpers in `src/lib/utils/` (`date.ts`, `format.ts`, `url.ts`); `CodedError`s in `src/lib/errors/`.

## How to Dispatch

**1. Get git SHAs:**

```bash
BASE_SHA=$(git rev-parse HEAD~1)  # or origin/main
HEAD_SHA=$(git rev-parse HEAD)
```

**2. Dispatch the Jacob reviewer subagent:**

Use the harness `reviewer` subagent (or a general-purpose subagent), filling the template at [jacob-reviewer.md](jacob-reviewer.md).

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
- Let a PR ship the same new logic twice (two sibling loaders/pages differing only by report-type identifiers) — duplicated code is code that will be fixed twice
- Let a call site re-implement central resolver behavior (`DEV_FLAG_OVERRIDES` copies next to `resolveDarklyVariation`) — redundant code that drifts and gets fixed N times
- Let client/server flag-key strings drift apart — dev overrides silently stop working
- File duplication as "Minor / nice-to-have" — it is merge-blocking whenever the diff itself adds the second copy

**If reviewer flags something you disagree with:**

- Push back with technical reasoning
- Show precedent in the codebase
- If truly conflicted, ask for a second opinion
