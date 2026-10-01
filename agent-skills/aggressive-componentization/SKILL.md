---
name: aggressive-componentization
description: 'Trigger phrases: "componentize", "aggressive componentization", "extract component", "extract this pattern", "dedupe markup", "this markup is duplicated", "these classes are copy-pasted", "make this a component", "turn this into a variant". Scope: Svelte + Tailwind frontend in this repo.'
---

# Aggressive Componentization

Extract duplicated **logic, markup, and class strings** into shared components. Duplicated styles count exactly as much as duplicated code: a repeated Tailwind class run is a first-class extraction signal. Variants are managed with the same system shadcn uses — `tailwind-variants` (`tv`) with `VariantProps`.

## Activation — trigger only

This skill does NOT auto-apply during feature work. It runs only when the user invokes a trigger phrase above. Two modes:

- **Audit mode** ("componentize", "aggressive componentization", optionally naming a view/directory): scan the target, report a candidate table — pattern · occurrences · files · proposed component or variant — then apply and verify.
- **Targeted mode** ("extract this", "make this a component"): extract only the named markup/logic.

## What counts as duplication

Scan three axes, not just code:

1. **Logic** — the same state/effect/handler chain repeated across files.
2. **Template structure** — the same DOM shape (row card, header row, form field row, dialog footer) repeated with different content.
3. **Class strings** — the same Tailwind class run appearing in multiple places. Extract on the class run even when surrounding markup differs: `rounded-lg border border-border bg-card` on a `div` and on a `button` can be the same element (a list row).

Compare rendered intent, not source text.

## Extraction bar

### Second-occurrence rule

Any element, pattern, or logic chain appearing in **two or more places** in the codebase becomes a shared component. The second sighting is extracted, not copied. Search `frontend/src/lib/` for existing occurrences before writing anything new.

### Named patterns — always components, even at first use

These exist in the repo already; when writing one inline, stop and use (or extend) the existing component instead:

| Pattern | Component |
|---|---|
| Status / tag chips | `atoms/StatusChip.svelte`, `atoms/TagChip.svelte` |
| Empty states | `molecules/ListEmptyState.svelte` (repo rule R2: ONE render driven by a `$derived.by` descriptor — never per-branch `{#if}` chains) |
| Confirm dialogs | `molecules/ConfirmDialog.svelte` |
| Row action buttons | `atoms/RowAction.svelte` |
| List rows | `theme.ts` grammar: `ROW_CARD`, `LIST_GRID`, `LIST_GRID_HEAD` |
| Detail / section headers | `molecules/DetailHeader.svelte` |
| Keyboard hints | `atoms/Kbd.svelte` |
| Skeleton / loading rows | `atoms/SkeletonRows.svelte`, `atoms/LoadingState.svelte` |
| Error banners | `atoms/ErrorBanner.svelte` |
| Search / filter inputs | `molecules/SearchInput.svelte`, `molecules/FilterMenu.svelte` |
| Page shells | `atoms/PageContainer.svelte` |
| Property rows | `atoms/PropertyRow.svelte` |

New patterns not in this table become components on their second appearance; a genuinely one-off element with no pattern name stays inline.

## Placement and file shape

- **Bucket by behavior, not size** (AGENTS.md taxonomy): `atoms/` = indivisible primitives (chip, kbd, banner), `molecules/` = atoms composed into one behavior (dialog, menu, field), `organisms/` = domain-wired (command palette).
- **Flat layout for bucket components**: `frontend/src/lib/components/<bucket>/<Name>.svelte` (PascalCase). The variant object lives in a sibling kebab-case file: `<bucket>/<kebab-name>-variants.ts` (e.g. `atoms/status-chip-variants.ts`). No barrel folders in buckets.
- **`ui/` is stock shadcn-svelte — never edit it.** Extracted components compose over `ui/` primitives (e.g. a chip wraps `Badge`), they do not restyle them via class blobs.
- **`class` prop is layout-only adjustment** — the `class: extra = ''` passthrough. It is never the mechanism callers use to restyle a component; differing restyling is what variants are for.

## Variant system (shadcn mechanics)

Every extracted component that has more than one visual state gets a `tv()` object. Exact pattern:

```ts
// frontend/src/lib/components/atoms/tag-chip-variants.ts
import { type VariantProps, tv } from "tailwind-variants";

export const tagChipVariants = tv({
  base: "inline-flex items-center gap-1 rounded-full px-1.5 py-0.5 text-caption font-normal",
  variants: {
    variant: {
      default: "border-border bg-card text-foreground",
      destructive: "border-destructive/30 bg-destructive/10 text-destructive",
    },
    size: {
      sm: "px-1.5 py-0.5 text-caption",
      md: "px-2.5 py-1 text-sm",
    },
  },
  compoundVariants: [
    // e.g. [{ variant: 'destructive', size: 'md', class: '...' }]
  ],
  defaultVariants: { variant: "default", size: "sm" },
});

export type TagChipVariant = VariantProps<typeof tagChipVariants>["variant"];
```

Consumer (matches `ui/button/button.svelte`):

```svelte
<script lang="ts">
  import { cn } from "$lib/utils.js";
  import { tagChipVariants, type TagChipVariant } from "./tag-chip-variants";

  let {
    variant = "default",
    size = "sm",
    class: className,
    children,
  }: { variant?: TagChipVariant; size?: "sm" | "md"; class?: string; children: Snippet } = $props();
</script>

<span class={cn(tagChipVariants({ variant, size }), className)}>{@render children?.()}</span>
```

Rules:

- Import `cn` from `$lib/utils.js`. Merge the caller's `class` last: `cn(xVariants({ ... }), className)`.
- Conditional styling goes in `variants` / `compoundVariants` — never ternary template literals (`class={cond ? 'a' : 'b'}` is a defect).
- All class values are literal strings (Tailwind v4 JIT scans source text; never interpolated).
- **Second component differing from the first only in classes is a variant of the first, not a new component.** When you find such a pair, merge them behind variant keys and migrate both callers.
- Cross-component domain maps in `theme.ts` (`STATUS_META`, `DOT_CLASSES`, `PROJECT_COLORS`, `ROW_CARD`, `CRUMB`, `LIST_GRID*`) stay as data maps. A variant slot may consume them, but never duplicate their values inline.

## Anti-patterns (named — avoid)

- **Sibling copy** of an existing component with two tweaked classes → add a variant to the original instead.
- **Ternary class soup** inline in views → a variant.
- **Editing `frontend/src/lib/components/ui/**`** → compose, don't modify.
- **Wiring wrappers** — a "component" that forwards one prop to one child and adds nothing.
- **Restyling via `class` blobs** from callers → a variant.
- **Violating R1/R2**: extraction must not introduce raw `request` imports (R1) or per-branch empty states (R2).

## Verify (every run)

```bash
cd frontend && bun run check   # svelte-check + tsc + lint-client-boundary
cd frontend && bun run build
```

Then visually verify the touched views in the running app (repo dev flow: `./scripts/dev.sh` → :3001, or two-terminal flow on :5173).

## Related skills

- `component-structure-review` — the counterweight: if extraction starts feeling excessive, run it before adding another component.
- `shadcn-svelte` — inventory of stock `ui/` components to compose instead of building new.
- `jacob` — Svelte/TypeScript pattern enforcement that still applies to extracted components.
