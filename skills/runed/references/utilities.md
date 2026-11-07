# Runed utilities reference

All 34 exports of runed 0.37.1, alphabetical. Signatures copied from the installed package (`node_modules/runed/dist/utilities/`). Doc links use the utility's directory name as the slug.

Already used in abby-fe: `Context`, `Debounced`, `IsInViewport`, `PersistedState`, `resource`, `watch`.

### AnimationFrames
Wrapper over `requestAnimationFrame` with controls for pausing/resuming, reactive tracking, and optional fps limiting.

```ts
class AnimationFrames {
  constructor(callback: (params: { delta: number; timestamp: DOMHighResTimeStamp }) => void, options?: AnimationFramesOptions);
  start(): void;
  stop(): void;
  toggle(): void;
  get fps(): number;
  get running(): boolean;
}
```
[Docs](https://runed.dev/docs/utilities/animation-frames)

### Context
Typed, reusable context wrapper over `setContext`/`getContext` — no ad-hoc `Symbol()` keys. `.get()` throws when unset; use `.getOr(fallback)` for optional contexts.

```ts
class Context<TContext> {
  constructor(name: string);
  get key(): symbol;
  exists(): boolean;
  get(): TContext;
  getOr<TFallback>(fallback: TFallback): TContext | TFallback;
  set(context: TContext): TContext;
}
```
Prefer over: `Symbol()` + `setContext`/`getContext` boilerplate. [Docs](https://runed.dev/docs/utilities/context)

### Debounced
Debounced reactive state: takes a getter, restarts a timer on every change, updates `.current` when the timer ends. Already used in abby-fe.

```ts
class Debounced<T> {
  constructor(getter: Getter<T>, wait?: MaybeGetter<number>); // wait defaults to 250ms
  get current(): T;
  get pending(): boolean;
  cancel(): void;
  updateImmediately(): Promise<void>;
  setImmediately(v: T): void;
}
```
Prefer over: hand-rolled `setTimeout` debounce around a `$state` copy. [Docs](https://runed.dev/docs/utilities/debounced)

### ElementRect
Reactive bounding rect of an element (`x`, `y`, `width`, `height`, `top`, `right`, `bottom`, `left`, and full rect via `.current`).

```ts
class ElementRect {
  constructor(node: MaybeElementGetter, options?: ElementRectOptions);
  get x(): number;
  get y(): number;
  get width(): number;
  get height(): number;
  get top(): number;
  get right(): number;
  get bottom(): number;
  get left(): number;
  get current(): Rect;
}
```
Prefer over: manual `getBoundingClientRect()` + `ResizeObserver` wiring. [Docs](https://runed.dev/docs/utilities/element-rect)

### ElementSize
Reactive `width`/`height` of an element via ResizeObserver.

```ts
class ElementSize {
  constructor(node: MaybeElementGetter, options?: ElementSizeOptions);
  get current(): { width: number; height: number };
  get width(): number;
  get height(): number;
}
```
Prefer over: hand-rolled `ResizeObserver` + `onMount` cleanup. [Docs](https://runed.dev/docs/utilities/element-size)

### FiniteStateMachine
Strongly-typed finite state machine with per-state event handlers and enter/exit lifecycle functions.

```ts
class FiniteStateMachine<StatesT extends string, EventsT extends string> {
  readonly states: Transition<StatesT, EventsT>;
  constructor(initial: StatesT, states: Transition<StatesT, EventsT>);
  send(event: EventsT, ...args: unknown[]): StatesT;
  debounce(wait: number | undefined, event: EventsT, ...args: unknown[]): Promise<StatesT>;
  get current(): StatesT;
}
```
Prefer over: hand-rolled `$state` string + `if`-chain transitions. [Docs](https://runed.dev/docs/utilities/finite-state-machine)

### IsDocumentVisible
Reactive `document.visibilityState` — listens to `visibilitychange` and updates.

```ts
class IsDocumentVisible {
  constructor(options?: IsDocumentVisibleOptions);
  get current(): boolean;
}
```
Prefer over: `document.visibilityState` listeners wired by hand. [Docs](https://runed.dev/docs/utilities/is-document-visible)

### IsFocusWithin
Tracks whether focus is within a target element.

```ts
class IsFocusWithin {
  constructor(node: MaybeElementGetter, options?: IsFocusWithinOptions);
  readonly current: boolean;
}
```
Prefer over: `:focus-within` can't drive JS logic; hand-rolled focusin/focusout listeners instead. [Docs](https://runed.dev/docs/utilities/is-focus-within)

### IsIdle
Tracks user inactivity via configurable activity events and timeout (default 60s).

```ts
class IsIdle {
  constructor(options?: IsIdleOptions);
  get current(): boolean;
  get lastActive(): number;
}
```
Prefer over: hand-rolled idle timers across mousemove/keydown/etc. [Docs](https://runed.dev/docs/utilities/is-idle)

### IsInViewport
Tracks whether an element is visible in the viewport (IntersectionObserver under the hood). Already used in abby-fe.

```ts
class IsInViewport {
  constructor(node: MaybeElementGetter, options?: IsInViewportOptions);
  get current(): boolean;
  get observer(): { readonly isActive: boolean; stop: () => void; pause(): void; resume(): void };
}
```
Prefer over: hand-rolled `IntersectionObserver` + cleanup. [Docs](https://runed.dev/docs/utilities/is-in-viewport)

### IsMounted
Whether the invoking component has mounted.

```ts
class IsMounted {
  constructor();
  get current(): boolean;
}
```
Prefer over: `$state(false)` + `onMount(() => mounted = true)`. [Docs](https://runed.dev/docs/utilities/is-mounted)

### Previous
Holds the previous value of a getter.

```ts
class Previous<T> {
  constructor(getter: Getter<T>, initialValue?: T);
  get current(): T | undefined;
}
```
Prefer over: manual previous-value tracking (a `$state` copy updated inside `$effect`). [Docs](https://runed.dev/docs/utilities/previous)

### PressedKeys
Tracks which keys are currently pressed, with combo callbacks.

```ts
class PressedKeys {
  constructor(options?: PressedKeysOptions);
  has(...keys: string[]): boolean;
  get all(): string[];
  onKeys(keys: string | string[], callback: () => void): void;
}
```
Prefer over: hand-rolled keydown/keyup listeners with a held-key set. [Docs](https://runed.dev/docs/utilities/pressed-keys)

### ScrollState
Reactive scroll position, direction, and edge-arrival states, plus programmatic scrolling.

```ts
class ScrollState {
  constructor(options: ScrollStateOptions);
  get x(): number;
  set x(v: number);
  get y(): number;
  set y(v: number);
  isScrolling: boolean;
  arrived: { left: boolean; right: boolean; top: boolean; bottom: boolean };
  directions: { left: boolean; right: boolean; top: boolean; bottom: boolean };
  progress: { x: number; y: number };
  scrollTo(x: number | undefined, y: number | undefined): void;
  scrollToTop(): void;
  scrollToBottom(): void;
}
```
Prefer over: manual scroll event listeners + position bookkeeping. [Docs](https://runed.dev/docs/utilities/scroll-state)

### StateHistory
Tracks the change history of a value with undo/redo.

```ts
class StateHistory<T> {
  log: { snapshot: T; timestamp: number }[];
  readonly canUndo: boolean;
  readonly canRedo: boolean;
  constructor(value: MaybeGetter<T>, set: Setter<T>, options?: StateHistoryOptions);
  undo(): void;
  redo(): void;
  clear(): void;
}
```
Prefer over: hand-rolled undo stacks. [Docs](https://runed.dev/docs/utilities/state-history)

### TextareaAutosize
Automatically resizes a textarea based on content and width, using a hidden clone for measurement.

```ts
class TextareaAutosize {
  constructor(options: TextareaAutosizeOptions);
  element: HTMLElement | undefined;
  input: string;
  styleProp: "height" | "minHeight";
  maxHeight: number | undefined;
  textareaHeight: number;
  triggerResize: () => void;
}
```
Prefer over: hand-rolled auto-resize height math. [Docs](https://runed.dev/docs/utilities/textarea-autosize)

### Throttled
Throttled reactive state from a getter (debounce's sibling: updates at most once per interval).

```ts
class Throttled<T> {
  constructor(getter: Getter<T>, wait?: MaybeGetter<number>);
  get current(): T;
  cancel(): void;
  setImmediately(v: T): void;
}
```
Prefer over: throttle via timestamp bookkeeping. [Docs](https://runed.dev/docs/utilities/throttled)

### activeElement
An object holding a reactive value equal to `document.activeElement` (also exported as the class `ActiveElement` for a custom document/shadow root).

```ts
export const activeElement: ActiveElement;

class ActiveElement {
  constructor(options?: ActiveElementOptions);
  get current(): Element | null;
}
```
Prefer over: `document.activeElement` reads that don't update reactively. [Docs](https://runed.dev/docs/utilities/active-element)

### boolAttr
Transforms any value into `""` or `undefined` for boolean-style HTML/data attributes.

```ts
function boolAttr(value: unknown): "" | undefined;
```
Prefer over: `attr={value ? "" : undefined}` inline conditionals. [Docs](https://runed.dev/docs/utilities/bool-attr)

### extract
Resolves a value that may be a getter function or a direct value (`MaybeGetter<T>`).

```ts
function extract<T>(value: MaybeGetter<T>): T;
function extract<T>(value: MaybeGetter<T | undefined>, defaultValue: T): T;
```
Prefer over: `typeof value === 'function' ? value() : value` checks at every call site. [Docs](https://runed.dev/docs/utilities/extract)

### onCleanup
Registers a cleanup function for the current effect context (component teardown or root effect disposal).

```ts
function onCleanup(cb: () => void): void;
```
Prefer over: `$effect(() => { …; return () => cleanup(); })` when you only need teardown. [Docs](https://runed.dev/docs/utilities/on-cleanup)

### onClickOutside
Calls a callback when a click lands outside the given element; start/stop controls included.

```ts
function onClickOutside<T extends Element = HTMLElement>(
  container: MaybeElementGetter<T>,
  callback: (event: PointerEvent | FocusEvent) => void,
  opts?: OnClickOutsideOptions
): { stop: () => boolean; start: () => boolean; readonly enabled: boolean };
```
Prefer over: click-outside handling via a hand-wired document listener. [Docs](https://runed.dev/docs/utilities/on-click-outside)

### PersistedState
Reactive state persisted to Web Storage (localStorage/sessionStorage) with cross-tab sync, custom serializers, and connect/disconnect control. Already used in abby-fe.

```ts
class PersistedState<T> {
  constructor(key: string, initialValue: T, options?: PersistedStateOptions<T>);
  get current(): T;
  set current(newValue: T);
  get connected(): boolean;
  connect(): void;
  disconnect(): void;
}
```
Prefer over: manual `localStorage` read/write + `$state` sync. [Docs](https://runed.dev/docs/utilities/persisted-state)

### resource
Reactive async data fetching with automatic request cancellation on dependency change, built-in loading/error state, lazy/once/debounce/throttle options. Already used in abby-fe. Array-of-getters sources supported; `resource.pre(...)` runs before render.

```ts
function resource<Source, RefetchInfo = unknown, Fetcher extends ResourceFetcher<Source, Awaited<ReturnType<Fetcher>>, RefetchInfo> = ResourceFetcher<Source, any, RefetchInfo>>(
  source: Getter<Source>,
  fetcher: Fetcher,
  options?: Omit<ResourceOptions<Awaited<ReturnType<Fetcher>>>, "initialValue">
): ResourceReturn<Awaited<ReturnType<Fetcher>>, RefetchInfo, false>;
// + overload with `initialValue` (non-optional .current), + array-of-getters overloads
```
Prefer over: `$state` + `onMount`/`$effect` manual async fetch with a hand-rolled cancelled flag. [Docs](https://runed.dev/docs/utilities/resource)

### useDebounce
Debounced version of a callback; awaitable, with cancel/pending controls.

```ts
function useDebounce<Args extends unknown[], Return>(
  callback: (...args: Args) => Return,
  wait?: MaybeGetter<number | undefined> // defaults to 250ms
): ((this: unknown, ...args: Args) => Promise<Return>) & {
  cancel: () => void;
  runScheduledNow: () => Promise<void>;
  pending: boolean;
};
```
Prefer over: hand-rolled `setTimeout` debounce. [Docs](https://runed.dev/docs/utilities/use-debounce)

### useEventListener
Adds event listeners with automatic cleanup on component teardown. Overloads for Window, Document, HTMLElement, MediaQueryList, and generic EventTarget.

```ts
function useEventListener<TEvent extends keyof WindowEventMap>(
  target: MaybeGetter<Window | null | undefined>,
  event: MaybeGetter<TEvent | TEvent[]>,
  handler: EventHandler<WindowEventMap[TEvent], Window>,
  options?: AddEventListenerOptions
): void;
// + overloads for Document, HTMLElement, MediaQueryList, generic EventTarget
```
Prefer over: `addEventListener` + `onMount` return cleanup. [Docs](https://runed.dev/docs/utilities/use-event-listener)

### useGeolocation
Reactive access to the browser's Geolocation API.

```ts
function useGeolocation(options?: UseGeolocationOptions): {
  readonly isSupported: boolean;
  readonly position: UseGeolocationPosition;
  readonly error: GeolocationPositionError | null;
  readonly isPaused: boolean;
  resume: () => void;
  pause: () => void;
};
```
Prefer over: hand-rolled `navigator.geolocation.watchPosition` wiring. [Docs](https://runed.dev/docs/utilities/use-geolocation)

### useIntersectionObserver
IntersectionObserver wrapper with pause/resume/stop and optional once.

```ts
function useIntersectionObserver(
  target: MaybeGetter<HTMLElement | HTMLElement[] | null | undefined>,
  callback: IntersectionObserverCallback,
  options?: UseIntersectionObserverOptions
): { readonly isActive: boolean; stop: () => void; pause(): void; resume(): void };
```
Prefer over: hand-rolled `IntersectionObserver` + cleanup. [Docs](https://runed.dev/docs/utilities/use-intersection-observer)

### useInterval
`setInterval` wrapper with pause/resume/reset and a tick counter.

```ts
function useInterval(delay: MaybeGetter<number>, options?: UseIntervalOptions): {
  pause: () => void;
  resume: () => void;
  reset: () => void;
  readonly isActive: boolean;
  readonly counter: number;
};
```
Prefer over: bare `setInterval` + `clearInterval` in `onMount`. [Docs](https://runed.dev/docs/utilities/use-interval)

### useMutationObserver
MutationObserver wrapper for watching DOM tree changes.

```ts
function useMutationObserver(
  target: MaybeGetter<HTMLElement | HTMLElement[] | null | undefined>,
  callback: MutationCallback,
  options?: UseMutationObserverOptions
): { stop: () => void; takeRecords(): MutationRecord[] | undefined };
```
Prefer over: hand-rolled `MutationObserver` + cleanup. [Docs](https://runed.dev/docs/utilities/use-mutation-observer)

### useResizeObserver
ResizeObserver wrapper for element dimension changes.

```ts
function useResizeObserver(
  target: MaybeGetter<HTMLElement | HTMLElement[] | null | undefined>,
  callback: ResizeObserverCallback,
  options?: UseResizeObserverOptions
): { stop: () => void };
```
Prefer over: hand-rolled `ResizeObserver` + cleanup. [Docs](https://runed.dev/docs/utilities/use-resize-observer)

### useSearchParams
Typed, schema-validated URL search params that reactively sync with the URL. Helpers: `createSearchParamsSchema` (no external validation lib needed), `validateSearchParams` (server-side/load-function validation).

```ts
function useSearchParams<Schema extends StandardSchemaV1>(
  schema: Schema,
  options?: SearchParamsOptions
): ReturnUseSearchParams<Schema>;

function createSearchParamsSchema<T extends Record<string, SchemaTypeConfig>>(
  schema: T
): StandardSchemaV1<unknown, { /* inferred param types */ }>;

function validateSearchParams<Schema extends StandardSchemaV1>(
  url: URL,
  schema: Schema,
  options?: { compressedParamName?: string; dateFormats?: Record<string, "date" | "datetime"> }
): { searchParams: URLSearchParams; data: StandardSchemaV1.InferOutput<Schema> };
```
Prefer over: manual URL search-param sync via `$page`/`goto`. [Docs](https://runed.dev/docs/utilities/use-search-params)

### useThrottle
Throttled version of a callback with cancel/pending controls.

```ts
function useThrottle<Args extends unknown[], Return>(
  callback: (...args: Args) => Return,
  interval?: MaybeGetter<number>
): ((this: unknown, ...args: Args) => Promise<Return>) & {
  cancel: () => void;
  pending: boolean;
};
```
Prefer over: throttle via timestamp bookkeeping. [Docs](https://runed.dev/docs/utilities/use-throttle)

### watch
Explicit dependency tracking for side effects — runs the effect when sources change, passes new and previous values, optional `lazy`. `watch.pre(...)` runs before render; `watchOnce(...)` runs a single time (also `.pre`). Already used in abby-fe.

```ts
function watch<T>(
  source: Getter<T>,
  effect: (value: T, previousValue: T | undefined) => void | VoidFunction,
  options?: WatchOptions
): void;
function watch<T extends Array<unknown>>(
  sources: { [K in keyof T]: Getter<T[K]> },
  effect: (values: T, previousValues: { [K in keyof T]: T[K] | undefined }) => void | VoidFunction,
  options?: WatchOptions
): void;
// also: watch.pre(...), watchOnce(...), watchOnce.pre(...)
```
Prefer over: `$effect` used only to react to values and run a side effect. [Docs](https://runed.dev/docs/utilities/watch)