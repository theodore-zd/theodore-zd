# Tailored Resume — Design Spec

**Date:** 2026-05-03
**Status:** Approved for planning

## Goal

Let an external agent (e.g. Claude Code on the author's machine) generate a job-tailored resume by opening a URL whose hash carries the tailored resume data. The page renders that data using the same visual design as the existing static `/resume` page. The agent then prints the page to PDF via headless browser. No backend, no authentication, no API keys.

## Non-goals

- LLM calls from the site itself (tailoring is done by the calling agent before the URL is built).
- Server-side rendering, Cloudflare Pages Functions, or any backend state.
- Persistence, sharing, or analytics of tailored resumes.
- Search-engine indexing of tailored resumes.

## User flow

1. Author asks an agent (Claude Code, etc.) to tailor the resume for a specific job description.
2. Agent reads `src/data/resume.ts` (locally or from the repo), produces a tailored `Resume`-shaped JSON object.
3. Agent constructs `https://<site>/resume/tailor#data=<urlencoded-json>` and opens it in a headless browser.
4. Page hydrates, decodes the hash, and renders the tailored resume using the same component as `/resume`.
5. Agent prints the rendered page to PDF.

## Architecture

### Route layout

- `/resume` — existing static Astro page. Continues to import `src/data/resume.ts` at build time. Unchanged behavior.
- `/resume/tailor` — new Astro page. Empty shell that mounts a Svelte island, which reads `window.location.hash`, decodes the JSON, and renders the resume.

### Component layout

`/resume.astro` stays untouched — same static Astro page, same inline markup and CSS, same build-time data import. We only add a parallel Svelte island for the tailor route.

- New file: `src/components/resume/Resume.svelte`
  - Props: `resume: Resume` (typed against the existing `Resume` interface in `src/data/resume.ts`).
  - Mirrors the DOM structure and CSS currently in `resume.astro` (header, summary, favorite tools, experiences, achievements). The CSS lives inside the Svelte component as scoped styles.
  - Drift risk acknowledged: if `/resume.astro` markup changes, this component needs the same change. Accepted trade-off in exchange for not touching the existing static page.
- New file: `src/components/resume/ResumeFromHash.svelte`
  - On mount: reads `window.location.hash`, parses `#data=<...>`, `decodeURIComponent`, `JSON.parse`.
  - On success: renders `<Resume resume={parsed} />`.
  - On failure / missing hash: renders a small "no tailored resume data provided" message with instructions.
- New file: `src/pages/resume/tailor.astro`
  - Thin Astro page that mounts `<ResumeFromHash client:only="svelte" />`.
  - Includes `<meta name="robots" content="noindex,nofollow">`.

### Svelte integration

Svelte is not currently in the project. Add:

- Dependencies: `@astrojs/svelte`, `svelte` (use latest stable Svelte 5).
- `astro.config.mjs`: add `svelte()` to the `integrations` array alongside the existing `react()` and `mdx()`.
- TypeScript: `@astrojs/svelte` registers types automatically via Astro; verify `astro check` passes.
- ESLint: leave existing config untouched for the first pass; if Svelte lint becomes desirable later, add `eslint-plugin-svelte` separately.

Both React and Svelte runtimes will coexist. Bundle cost is acceptable: the resume pages only ship the Svelte runtime, and existing React islands ship only React. Astro handles per-page islands independently.

### Hash encoding

- Hash format: `#data=<encodeURIComponent(JSON.stringify(resume))>`.
- No compression in the first pass. The current `Resume` JSON is well under typical browser URL limits (most browsers tolerate ≥64KB in the URL bar, and the hash is not subject to server/CDN limits since it never leaves the client).
- If future tailored payloads exceed ~30KB or interop issues appear, revisit by adding `CompressionStream`-based gzip + base64url. Out of scope for v1.

### Data contract

The hash payload MUST conform to the existing `Resume` interface exported from `src/data/resume.ts`. The agent is responsible for producing a valid object. The page does minimal runtime validation:

- Required: `name` (string). If absent, render the "invalid data" fallback.
- All other fields are optional and rendered defensively (the existing `resume.astro` already does this with `?.` and `??` fallbacks).
- No schema enforcement library — keep it lightweight; the agent is trusted.

### Failure modes

- **No hash present** → render fallback message: "Open this page with tailored resume data in the URL hash. Example: `/resume/tailor#data={...}`."
- **Malformed JSON** → render fallback message + show error in console.
- **Missing required `name`** → fallback message.
- **Hash too large for browser** → out of scope; if encountered, switch to compression (see Hash encoding).

## File changes

**New:**
- `src/components/resume/Resume.svelte` — extracted resume component, takes `resume: Resume` as prop.
- `src/components/resume/ResumeFromHash.svelte` — wrapper that reads hash, decodes, and renders `Resume`.
- `src/pages/resume/tailor.astro` — thin Astro page hosting `ResumeFromHash` with `noindex` meta.

**Modified:**
- `astro.config.mjs` — add `svelte()` integration.
- `package.json` — add `@astrojs/svelte` and `svelte` deps.

**Unchanged:**
- `src/pages/resume.astro` — stays as-is.
- `src/data/resume.ts` — `Resume` interface and existing data remain authoritative.

## Testing

Manual verification in this order:

1. `bun run typecheck` (`astro check`) passes.
2. `bun run dev`, visit `/resume` — visually identical to current static page.
3. Construct a tailored payload locally, build hash URL, visit `/resume/tailor#data=...` — renders correctly.
4. Visit `/resume/tailor` with no hash — fallback message renders.
5. Visit `/resume/tailor#data=not-json` — fallback message renders, error logged.
6. Print preview on `/resume/tailor` — same print layout as `/resume`.
7. `bun run build` produces output for both routes; `/resume/tailor` does not break static deploy on Cloudflare Pages.

## Open questions / future work

- Compression layer if payloads grow.
- A small CLI helper in `personal-scripts` that takes a tailored JSON file and prints the corresponding URL — convenience only, not required for v1.
- Print-to-PDF automation script for the agent — separate task, lives outside `portfolio/`.
