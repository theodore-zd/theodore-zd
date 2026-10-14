---
name: runed
description: Use when writing or reviewing Svelte 5 code — catalogues every runed utility (v0.37.1) with when-to-use guidance and prefers runed utilities over hand-rolled vanilla-rune patterns (side-effect watching with $effect, manual debounce, ad-hoc Symbol context, onMount fetch, hand-rolled listeners); vanilla runes remain fine where runed adds nothing
---

# Runed

Runed is a collection of reactive utilities for Svelte 5, built on top of runes. Verified against runed 0.37.1; re-verify exports against `node_modules/runed/dist/utilities/` after version bumps. Docs: https://runed.dev/docs

## When to use (recommended, not mandatory)

- Writing reactive logic in a Svelte 5 component (watching values, debouncing, fetching, observing elements, persisting state).
- Reviewing a diff that hand-rolls something runed already covers — see the preference table below.
- Onboarding to a codebase that uses runed, to avoid re-implementing utilities that already exist.

## Standards (soft preference)

Reach for runed first when it clearly covers the need. Plain `$state`/`$derived`/`$effect` stay correct when runed adds nothing — e.g. a one-liner derived. Never wrap a trivial case in a runed class just to use runed.

| Instead of… | Prefer… |
|---|---|
| `$effect` used only to react to values and run a side effect | `watch` |
| `$state` + `onMount`/`$effect` manual async fetch | `resource` |
| `Symbol()` + `setContext`/`getContext` boilerplate | `Context` |
| hand-rolled `setTimeout` debounce | `Debounced` / `useDebounce` |
| `addEventListener` + `onMount` return cleanup | `useEventListener` |
| manual `localStorage` read/write + `$state` sync | `PersistedState` |
| `ResizeObserver` / `IntersectionObserver` boilerplate | `ElementSize`, `ElementRect`, `IsInViewport`, `useIntersectionObserver`, `useResizeObserver` |
| manual previous-value tracking (`$state` copy inside `$effect`) | `Previous` |
| manual URL search-param sync via `$page` | `useSearchParams` |
| `document.visibilityState` listeners | `IsDocumentVisible` |
| click-outside handling via document listener | `onClickOutside` |
| throttle via timestamp bookkeeping | `Throttled` / `useThrottle` |

## Utilities index

Full list of exports. Signatures and detail for each: [references/utilities.md](references/utilities.md).

| Export | Purpose | Docs |
|---|---|---|
| `activeElement` | Reactive `document.activeElement` | [Docs](https://runed.dev/docs/utilities/active-element) |
| `AnimationFrames` | `requestAnimationFrame` loop with pause/resume and fps limiting | [Docs](https://runed.dev/docs/utilities/animation-frames) |
| `boolAttr` | Value → `""`/`undefined` for boolean-style HTML attributes | [Docs](https://runed.dev/docs/utilities/bool-attr) |
| `Context` | Typed, reusable `setContext`/`getContext` wrapper | [Docs](https://runed.dev/docs/utilities/context) |
| `Debounced` | Debounced reactive state from a getter | [Docs](https://runed.dev/docs/utilities/debounced) |
| `ElementRect` | Reactive element bounding rect | [Docs](https://runed.dev/docs/utilities/element-rect) |
| `ElementSize` | Reactive element width/height | [Docs](https://runed.dev/docs/utilities/element-size) |
| `extract` | Resolve a value-or-getter (`MaybeGetter<T>`) | [Docs](https://runed.dev/docs/utilities/extract) |
| `FiniteStateMachine` | Strongly-typed finite state machine | [Docs](https://runed.dev/docs/utilities/finite-state-machine) |
| `IsDocumentVisible` | Reactive `document.visibilityState` | [Docs](https://runed.dev/docs/utilities/is-document-visible) |
| `IsFocusWithin` | Whether focus is inside an element | [Docs](https://runed.dev/docs/utilities/is-focus-within) |
| `IsIdle` | Whether the user is inactive | [Docs](https://runed.dev/docs/utilities/is-idle) |
| `IsInViewport` | Whether an element is in the viewport | [Docs](https://runed.dev/docs/utilities/is-in-viewport) |
| `IsMounted` | Whether the component has mounted | [Docs](https://runed.dev/docs/utilities/is-mounted) |
| `onCleanup` | Register cleanup for the current effect context | [Docs](https://runed.dev/docs/utilities/on-cleanup) |
| `onClickOutside` | Callback on clicks outside an element | [Docs](https://runed.dev/docs/utilities/on-click-outside) |
| `PersistedState` | `$state` persisted to localStorage/sessionStorage | [Docs](https://runed.dev/docs/utilities/persisted-state) |
| `PressedKeys` | Track pressed keys / key combos | [Docs](https://runed.dev/docs/utilities/pressed-keys) |
| `Previous` | Previous value of a getter | [Docs](https://runed.dev/docs/utilities/previous) |
| `resource` | Reactive async data fetching with cancellation | [Docs](https://runed.dev/docs/utilities/resource) |
| `ScrollState` | Scroll position, direction, edge arrival | [Docs](https://runed.dev/docs/utilities/scroll-state) |
| `StateHistory` | Undo/redo history for a value | [Docs](https://runed.dev/docs/utilities/state-history) |
| `TextareaAutosize` | Auto-growing textarea | [Docs](https://runed.dev/docs/utilities/textarea-autosize) |
| `Throttled` | Throttled reactive state from a getter | [Docs](https://runed.dev/docs/utilities/throttled) |
| `useDebounce` | Debounced version of a callback | [Docs](https://runed.dev/docs/utilities/use-debounce) |
| `useEventListener` | Auto-cleaned-up event listener | [Docs](https://runed.dev/docs/utilities/use-event-listener) |
| `useGeolocation` | Reactive Geolocation API | [Docs](https://runed.dev/docs/utilities/use-geolocation) |
| `useIntersectionObserver` | IntersectionObserver wrapper | [Docs](https://runed.dev/docs/utilities/use-intersection-observer) |
| `useInterval` | `setInterval` with pause/resume/reset | [Docs](https://runed.dev/docs/utilities/use-interval) |
| `useMutationObserver` | MutationObserver wrapper | [Docs](https://runed.dev/docs/utilities/use-mutation-observer) |
| `useResizeObserver` | ResizeObserver wrapper | [Docs](https://runed.dev/docs/utilities/use-resize-observer) |
| `useSearchParams` | Typed, schema-validated URL search params | [Docs](https://runed.dev/docs/utilities/use-search-params) |
| `useThrottle` | Throttled version of a callback | [Docs](https://runed.dev/docs/utilities/use-throttle) |
| `watch` | Explicit source tracking for side effects (also `watch.pre`, `watchOnce`) | [Docs](https://runed.dev/docs/utilities/watch) |

Note: a `runed/kit` subpath export also exists (internal building blocks like types and configurable globals) — see https://runed.dev/docs.