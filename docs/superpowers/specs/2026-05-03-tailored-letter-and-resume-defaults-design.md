# Tailored Letter Route + Resume Tailor Defaults — Design Spec

**Date:** 2026-05-03
**Status:** Approved for planning
**Builds on:** `2026-05-03-tailored-resume-design.md`

## Goals

1. `/resume/tailor` falls back to the static `src/data/resume.ts` content for any field not provided in the URL hash. Opening the page with no hash renders the full default resume.
2. New route `/letter/tailor` renders a cover letter with the same look and feel as `/resume`. The hash payload is minimal — only the letter body. Sender info, salutation, closing, and signature are static from the project data.

## Non-goals

- LLM calls from the site, backend state, or auth.
- Per-application recipient/company fields. The body paragraphs naturally reference the company; the letter frame stays generic ("Dear Hiring Manager,").
- Deep merging of nested resume fields. Top-level shallow merge only.
- A dedicated `tailored-letter.md`. Documentation lives alongside the resume usage doc.

## Spec 1 — `/resume/tailor` defaults from `resume.ts`

### Behavior

- On mount, the page reads `window.location.hash`, decodes a `data=` parameter as URL-encoded JSON (existing logic), then **shallow-merges** it onto the full default resume:
  ```ts
  finalResume = { ...defaultResume, ...parsedFromHash }
  ```
- Each top-level field is fully overridden by the hash value if present, otherwise falls back to the default. No deep merging — `skills`, `experiences`, and `achievements` are replaced wholesale when present in the hash.
- Empty hash (no `data=`): `parsedFromHash` is `{}`, so the page renders the full default resume.
- Malformed hash: same fallback error message as today (the hash is opted-in but broken, so we surface the error rather than silently rendering defaults).

### Component changes

- `src/pages/resume/tailor.astro`: import `resume` from `src/data/resume.ts` at build time and pass it as a prop:
  ```astro
  ---
  import ResumeFromHash from '../../components/resume/ResumeFromHash.svelte'
  import { resume } from '../../data/resume'
  ---
  <ResumeFromHash client:only="svelte" defaultResume={resume} />
  ```
- `src/components/resume/ResumeFromHash.svelte`: accept a new prop `defaultResume: Partial<Resume>`. After successfully decoding the hash, merge: `resume = { ...defaultResume, ...parsedFromHash }`. On missing hash (`raw == null`), set `resume = defaultResume`. On malformed hash, keep current behaviour (set `error`, render fallback).

### Edge cases

| Hash state                  | Rendered output                                          |
| --------------------------- | -------------------------------------------------------- |
| No hash                     | Full default resume.                                     |
| `#data=<valid partial JSON>` | Default resume with hash fields replacing matching keys. |
| `#data=<not json>`          | Fallback error message ("Hash data is not valid JSON").  |
| `#data=<JSON without name>` | If `defaultResume.name` exists, render with default name (the `name` validation is dropped — see Validation below). |

### Validation change

Drop the "missing required `name`" validation from `decodeHash`. With defaults available, an empty or partial hash is no longer an error — only `JSON.parse` failures and non-object payloads are. The fallback error UI still surfaces those.

## Spec 2 — `/letter/tailor` cover letter route

### Hash schema

Minimal, to keep URLs short and the contract obvious:

```ts
{
  body: string[]   // ≥1 paragraph required
}
```

Anything else in the hash payload is ignored.

### Static frame (built from `src/data/resume.ts`)

- **Header** (same as `/resume`): `name`, `location`, `email`, `linkedin`, `portfolioUrl`.
- **Date**: rendered client-side via:
  ```ts
  new Date().toLocaleDateString('en-US', { year: 'numeric', month: 'long', day: 'numeric' })
  ```
  Always current at render time. Not in the hash, not configurable.
- **Salutation**: literal string `"Dear Hiring Manager,"`.
- **Body**: paragraphs from `body[]`, each rendered as a separate `<p>`.
- **Closing**: literal string `"Sincerely,"` followed by `name` from default resume data on the next line.

No company name, recipient name, or company address fields. The body paragraphs reference the company directly.

### Visual consistency

The cover letter uses the same typography, colors, spacing tokens, and print rules as the resume. To avoid style drift between two Svelte components:

- Extract the shared `:root` CSS variables and `body` reset rules from `Resume.svelte` into a new file `src/components/resume/resume-styles.css`.
- Both `Resume.svelte` and the new `CoverLetter.svelte` import that file (Svelte/Vite handles the global CSS injection).
- Component-scoped styles (e.g. `.resume-page`, `.cover-letter-page`) stay inside each component's `<style>` block.

### Components

- `src/components/resume/resume-styles.css` — extracted shared tokens + body reset + print rules.
- `src/components/resume/CoverLetter.svelte` — presentational. Props: `body: string[]`, `sender: Partial<Resume>`. Renders header, date, salutation, paragraphs, closing.
- `src/components/resume/CoverLetterFromHash.svelte` — wrapper. Props: `defaultSender: Partial<Resume>`. On mount: read `window.location.hash`, parse `data=`, validate `body` is a non-empty `string[]`. On success render `CoverLetter`. On failure render fallback message (mirrors `ResumeFromHash`).
- `src/pages/letter/tailor.astro` — page shell. Imports `resume` from `src/data/resume.ts`. Mounts `<CoverLetterFromHash client:only="svelte" defaultSender={resume} />`. Includes `<meta name="robots" content="noindex,nofollow">`.

### Validation

- `body` must be an array of strings with at least one element.
- Empty paragraphs (whitespace-only) are filtered before render.
- All other fields in the hash payload are ignored.

### Failure modes

| Hash state            | Rendered output                                  |
| --------------------- | ------------------------------------------------ |
| No hash               | Fallback: "Open with `#data=` containing a `body` paragraph array." |
| Malformed JSON        | Fallback with error message.                     |
| `body` missing/empty  | Fallback with "must include a non-empty `body` array".              |
| Non-string entries    | Fallback with "all `body` entries must be strings".                 |

### Print

`@media print` rules in `resume-styles.css` apply identically. PDF rendering via headless browser produces a single-page (or paginated, if body is long) letter with consistent typography.

## Documentation

Update `portfolio/docs/tailored-resume.md`:

- Add a "Defaults" subsection under the existing schema explaining `/resume/tailor` now merges with `src/data/resume.ts`.
- Add a top-level "Cover letter" section with the schema, minimal example, URL builder, and print command. Same structure as the resume sections.

## Out of scope (future work)

- Compression of hash payload.
- Per-recipient fields (company name, hiring manager, address). If needed later, add as optional top-level fields with the same merge semantics as the resume.
- Multiple letter templates / tone variants.
