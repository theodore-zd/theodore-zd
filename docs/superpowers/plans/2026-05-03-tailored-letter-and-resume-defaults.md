# Tailored Letter Route + Resume Tailor Defaults Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Make `/resume/tailor` fall back to default resume data for fields missing from the URL hash, and add a new `/letter/tailor` route that renders a cover letter with consistent visual styling.

**Architecture:** Extract shared CSS tokens into a standalone file imported by both resume and cover-letter Svelte components. Update `ResumeFromHash` to accept a `defaultResume` prop and shallow-merge it with parsed hash data. Add `CoverLetter.svelte` + `CoverLetterFromHash.svelte` mirroring the resume island pattern, and a new `/letter/tailor` Astro page.

**Tech Stack:** Astro 6, Svelte 5, TypeScript, Bun.

**Spec:** `docs/superpowers/specs/2026-05-03-tailored-letter-and-resume-defaults-design.md`

**Working directory for all commands:** `/Users/theo/Desktop/theodore-zd/portfolio`

**Branch:** `feat/tailored-resume` (already current).

---

## File Structure

**New files:**
- `src/components/resume/resume-styles.css` — shared `:root` tokens, `body` reset, `@media print` rules.
- `src/components/resume/CoverLetter.svelte` — presentational cover letter, takes `body: string[]` + `sender: Partial<Resume>`.
- `src/components/resume/CoverLetterFromHash.svelte` — wrapper that reads hash, validates `body`, renders.
- `src/pages/letter/tailor.astro` — page shell; imports `resume` from data, mounts the wrapper.

**Modified files:**
- `src/components/resume/Resume.svelte` — drop the global tokens/reset/print blocks, import the shared CSS file instead.
- `src/components/resume/ResumeFromHash.svelte` — add `defaultResume` prop, drop `name` validation, shallow-merge default + parsed.
- `src/pages/resume/tailor.astro` — import `resume` and pass as `defaultResume` prop.
- `portfolio/docs/tailored-resume.md` — add "Defaults" subsection and a "Cover letter" section.

**Unchanged:**
- `src/pages/resume.astro`
- `src/data/resume.ts`

---

## Task 1: Extract shared CSS file

**Files:**
- Create: `portfolio/src/components/resume/resume-styles.css`
- Modify: `portfolio/src/components/resume/Resume.svelte`

- [ ] **Step 1: Create the shared CSS file**

Create `portfolio/src/components/resume/resume-styles.css` with the global tokens, body reset, and print rules currently inside `Resume.svelte`'s `<style>` block:

```css
:root {
  --text: #111;
  --text-secondary: #333;
  --muted: #555;
  --border: #eee;
  --bg-button: #f7f7f7;
  --border-button: #ccc;

  --font-family: "Inter", -apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif;
  --line-height: 1.15;

  --fs-name: 1.45rem;
  --fs-subtitle: 0.8rem;
  --fs-section-title: 0.8rem;
  --fs-body: 0.8rem;
  --fs-summary: 0.8rem;
  --fs-bullet: 0.8rem;

  --sp-xs: 0.08rem;
  --sp-sm: 0.12rem;
  --sp-md: 0.2rem;
  --sp-lg: 0.3rem;
  --sp-xl: 0.45rem;
  --sp-2xl: 0.5rem;
  --sp-page: 0.6in;
  --sp-mobile: 0.5in;

  --margin-contact: 3px;
  --list-indent: 1rem;
  --list-indent-alt: 0.9rem;
}

body {
  font-family: var(--font-family);
  color: var(--text);
  line-height: var(--line-height);
  background: #fff;
  margin: 0;
}

@media print {
  html, body { margin: 0; padding: 0; background: #fff; }
  .no-print { display: none !important; }
}
```

- [ ] **Step 2: Update `Resume.svelte` to import the shared CSS and drop duplicates**

Open `portfolio/src/components/resume/Resume.svelte`. At the top of the `<script>` block, after the `import type` line, add:

```ts
import './resume-styles.css'
```

Then in the `<style>` block, **remove** these blocks (they now live in the CSS file):

- The entire `:global(:root) { ... }` block
- The entire `:global(body) { ... }` block
- The `@media print { ... }` block

Keep all component-scoped styles (`.resume-page`, `.name`, `.title`, `.contact`, `.section`, `.separator`, `ul`, `.experience-bullets`, `li`, `.summary-text`, `.experience-items`, `.experience-header`, `.experience-description`, `.skill-list`, the `@media (max-width: 600px)` block).

After the edits, the `<style>` block in `Resume.svelte` should start with `.resume-page { ... }` (no `:global(...)` and no print block).

- [ ] **Step 3: Verify build still works**

```bash
bun run typecheck
```
Expected: no NEW errors (only the pre-existing `BasicCard.astro` issue).

```bash
bun run build
```
Expected: clean build, both `dist/resume/index.html` and `dist/resume/tailor/index.html` present.

- [ ] **Step 4: Spot-check the rendered output**

Run `bun run preview --port 4322` in the background:

```bash
bun run preview --port 4322 &
sleep 3
curl -s http://localhost:4322/resume/tailor | grep -E "Inter|--text:" | head -3
```

Expected: the `:root` tokens still appear in the rendered HTML's `<style>` (they should be injected via the shared CSS import). Stop the preview server (`kill %1` or `pkill -f astro`).

- [ ] **Step 5: Commit**

```bash
git add portfolio/src/components/resume/resume-styles.css portfolio/src/components/resume/Resume.svelte
git commit -m "refactor(resume): extract shared CSS tokens into resume-styles.css"
```

---

## Task 2: Resume defaults — `defaultResume` prop and shallow merge

**Files:**
- Modify: `portfolio/src/components/resume/ResumeFromHash.svelte`
- Modify: `portfolio/src/pages/resume/tailor.astro`

- [ ] **Step 1: Update `ResumeFromHash.svelte`**

Replace the entire contents of `portfolio/src/components/resume/ResumeFromHash.svelte` with:

```svelte
<script lang="ts">
  import { onMount } from 'svelte'
  import type { Resume } from '../../data/resume'
  import ResumeView from './Resume.svelte'

  export let defaultResume: Partial<Resume> = {}

  let resume: Partial<Resume> = defaultResume
  let error: string | null = null
  let ready = false

  function decodeHash(hash: string): Partial<Resume> | null {
    const trimmed = hash.startsWith('#') ? hash.slice(1) : hash
    if (!trimmed) return null
    const params = new URLSearchParams(trimmed)
    const raw = params.get('data')
    if (raw == null) return null
    let parsed: unknown
    try {
      parsed = JSON.parse(decodeURIComponent(raw))
    } catch {
      throw new Error('Hash data is not valid JSON')
    }
    if (!parsed || typeof parsed !== 'object' || Array.isArray(parsed)) {
      throw new Error('Hash data must be a JSON object')
    }
    return parsed as Partial<Resume>
  }

  onMount(() => {
    try {
      const overrides = decodeHash(window.location.hash)
      resume = overrides ? { ...defaultResume, ...overrides } : defaultResume
    } catch (e) {
      error = e instanceof Error ? e.message : String(e)
      console.error('[resume/tailor] failed to load tailored resume from hash:', e)
    } finally {
      ready = true
    }
  })
</script>

{#if !ready}
  <main class="status" aria-busy="true">Loading…</main>
{:else if error}
  <main class="status" role="alert">
    <h1>Could not load tailored resume</h1>
    <p>Error: {error}</p>
    <p>Open this page with valid tailored resume data in the URL hash, or with no hash to see the default resume.</p>
  </main>
{:else}
  <ResumeView {resume} />
{/if}

<style>
  .status {
    font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif;
    padding: 2rem;
    max-width: 40rem;
    margin: 0 auto;
    color: #333;
  }
  .status h1 { font-size: 1.2rem; margin: 0 0 0.5rem 0; }
  .status p { margin: 0.25rem 0; font-size: 0.9rem; }
</style>
```

Key changes:
- Added `export let defaultResume: Partial<Resume> = {}`.
- `decodeHash` now returns `null` for empty hash and `Partial<Resume>` for valid object payloads. Throws only on `JSON.parse` failure or non-object payload.
- Dropped the `name` required-field validation (defaults provide a name).
- On `null` from decoder → render defaults. On parsed object → shallow-merge `{...defaultResume, ...overrides}`. On thrown error → render error message.

- [ ] **Step 2: Update `src/pages/resume/tailor.astro` to pass defaults**

Replace the file contents with:

```astro
---
import ResumeFromHash from '../../components/resume/ResumeFromHash.svelte'
import { resume } from '../../data/resume'
---
<html lang="en">
  <head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <meta name="robots" content="noindex,nofollow" />
    <title>Tailored Resume</title>
  </head>
  <body>
    <ResumeFromHash client:only="svelte" defaultResume={resume} />
  </body>
</html>
```

- [ ] **Step 3: Verify**

```bash
bun run typecheck
```
Expected: no new errors.

```bash
bun run build
```
Expected: clean build. The pre-existing `"default" is not exported by "src/data/resume.ts"` warning (from `resume.astro`) may persist — unrelated.

- [ ] **Step 4: Functional smoke test**

```bash
bun run preview --port 4322 &
sleep 3
# Empty hash: page should now serve a real props blob containing the default name
curl -s http://localhost:4322/resume/tailor | grep -oE 'props="[^"]{1,80}"' | head -1
pkill -f "astro preview"
```
Expected: the `props=` attribute on `<astro-island>` is no longer empty `{}` — it contains a JSON blob with `defaultResume`.

- [ ] **Step 5: Commit**

```bash
git add portfolio/src/components/resume/ResumeFromHash.svelte portfolio/src/pages/resume/tailor.astro
git commit -m "feat(resume): merge tailor hash with default resume.ts data"
```

---

## Task 3: `CoverLetter.svelte` presentational component

**Files:**
- Create: `portfolio/src/components/resume/CoverLetter.svelte`

- [ ] **Step 1: Create the component**

Create `portfolio/src/components/resume/CoverLetter.svelte`:

```svelte
<script lang="ts">
  import type { Resume } from '../../data/resume'
  import './resume-styles.css'

  export let body: string[] = []
  export let sender: Partial<Resume> = {}

  const today = new Date().toLocaleDateString('en-US', {
    year: 'numeric',
    month: 'long',
    day: 'numeric',
  })

  $: paragraphs = body.map((p) => p.trim()).filter((p) => p.length > 0)
</script>

<svelte:head>
  <link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Inter:wght@400;600;700&display=swap" />
  <title>Cover Letter — {sender?.name ?? ''}</title>
</svelte:head>

<main class="letter-page" aria-label="Cover letter">
  <header>
    <h1 class="name">{sender?.name ?? ''}</h1>
    <div class="contact">
      {#if sender?.location}<span>{sender.location}</span>{/if}
      {#if sender?.email}<span>•</span><a href={`mailto:${sender.email}`}>{sender.email}</a>{/if}
      {#if sender?.linkedin}<span>•</span><a href={sender.linkedin} target="_blank" rel="noopener noreferrer">LinkedIn</a>{/if}
      {#if sender?.portfolioUrl}<span>•</span><a href={sender.portfolioUrl} target="_blank" rel="noopener noreferrer">Portfolio</a>{/if}
    </div>
  </header>

  <hr class="separator" aria-label="section separator" />

  <p class="date">{today}</p>

  <p class="salutation">Dear Hiring Manager,</p>

  <div class="body">
    {#each paragraphs as para}
      <p>{para}</p>
    {/each}
  </div>

  <p class="closing">Sincerely,</p>
  <p class="signature">{sender?.name ?? ''}</p>
</main>

<style>
  .letter-page {
    width: 100%;
    padding: var(--sp-page);
    margin: 0 auto;
    box-sizing: border-box;
    max-width: 7.5in;
  }

  header { margin-bottom: var(--sp-md); }

  .name {
    font-size: var(--fs-name);
    font-weight: 700;
    margin: 0;
    line-height: 1;
  }

  .contact {
    margin-top: var(--margin-contact);
    font-size: var(--fs-body);
    color: var(--muted);
    line-height: 1.1;
  }

  .contact a { color: #0969da; text-decoration: none; }
  .contact a:hover { text-decoration: underline; }

  .separator {
    height: 1px;
    background: var(--border);
    margin: var(--sp-md) 0;
    border: 0;
  }

  .date {
    margin: var(--sp-xl) 0 var(--sp-lg) 0;
    font-size: var(--fs-body);
    color: var(--text-secondary);
  }

  .salutation {
    margin: 0 0 var(--sp-md) 0;
    font-size: var(--fs-body);
  }

  .body p {
    margin: 0 0 var(--sp-md) 0;
    font-size: var(--fs-body);
    line-height: 1.4;
    color: var(--text);
  }

  .closing {
    margin: var(--sp-lg) 0 var(--sp-md) 0;
    font-size: var(--fs-body);
  }

  .signature {
    margin: 0;
    font-size: var(--fs-body);
    font-weight: 600;
  }

  @media (max-width: 600px) {
    .letter-page { padding: var(--sp-mobile); }
  }
</style>
```

- [ ] **Step 2: Verify type-check**

```bash
bun run typecheck
```
Expected: no new errors.

- [ ] **Step 3: Commit**

```bash
git add portfolio/src/components/resume/CoverLetter.svelte
git commit -m "feat(letter): add CoverLetter.svelte presentational component"
```

---

## Task 4: `CoverLetterFromHash.svelte` wrapper

**Files:**
- Create: `portfolio/src/components/resume/CoverLetterFromHash.svelte`

- [ ] **Step 1: Create the wrapper**

Create `portfolio/src/components/resume/CoverLetterFromHash.svelte`:

```svelte
<script lang="ts">
  import { onMount } from 'svelte'
  import type { Resume } from '../../data/resume'
  import CoverLetterView from './CoverLetter.svelte'

  export let defaultSender: Partial<Resume> = {}

  let body: string[] | null = null
  let error: string | null = null
  let ready = false

  function decodeHash(hash: string): string[] {
    const trimmed = hash.startsWith('#') ? hash.slice(1) : hash
    if (!trimmed) throw new Error('Open this page with #data= containing a body paragraph array')
    const params = new URLSearchParams(trimmed)
    const raw = params.get('data')
    if (raw == null) throw new Error('Missing "data" parameter in URL hash')
    let parsed: unknown
    try {
      parsed = JSON.parse(decodeURIComponent(raw))
    } catch {
      throw new Error('Hash data is not valid JSON')
    }
    if (!parsed || typeof parsed !== 'object' || Array.isArray(parsed)) {
      throw new Error('Hash data must be a JSON object')
    }
    const obj = parsed as { body?: unknown }
    if (!Array.isArray(obj.body) || obj.body.length === 0) {
      throw new Error('Hash data must include a non-empty "body" array')
    }
    if (!obj.body.every((p) => typeof p === 'string')) {
      throw new Error('All "body" entries must be strings')
    }
    return obj.body as string[]
  }

  onMount(() => {
    try {
      body = decodeHash(window.location.hash)
    } catch (e) {
      error = e instanceof Error ? e.message : String(e)
      console.error('[letter/tailor] failed to load cover letter from hash:', e)
    } finally {
      ready = true
    }
  })
</script>

{#if !ready}
  <main class="status" aria-busy="true">Loading…</main>
{:else if body}
  <CoverLetterView {body} sender={defaultSender} />
{:else}
  <main class="status" role="alert">
    <h1>No cover letter content</h1>
    <p>Open this page with letter content in the URL hash.</p>
    <p>Example: <code>/letter/tailor#data=&#123;"body":["Para 1","Para 2"]&#125;</code> (URL-encoded JSON).</p>
    {#if error}<p class="error">Error: {error}</p>{/if}
  </main>
{/if}

<style>
  .status {
    font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif;
    padding: 2rem;
    max-width: 40rem;
    margin: 0 auto;
    color: #333;
  }
  .status h1 { font-size: 1.2rem; margin: 0 0 0.5rem 0; }
  .status p { margin: 0.25rem 0; font-size: 0.9rem; }
  .status code {
    background: #f4f4f4;
    padding: 0.05rem 0.25rem;
    border-radius: 3px;
    font-size: 0.8rem;
  }
  .error { color: #b00020; margin-top: 0.75rem; }
</style>
```

- [ ] **Step 2: Verify type-check**

```bash
bun run typecheck
```
Expected: no new errors.

- [ ] **Step 3: Commit**

```bash
git add portfolio/src/components/resume/CoverLetterFromHash.svelte
git commit -m "feat(letter): add CoverLetterFromHash wrapper"
```

---

## Task 5: `/letter/tailor` Astro page

**Files:**
- Create: `portfolio/src/pages/letter/tailor.astro`

- [ ] **Step 1: Create the page**

Create `portfolio/src/pages/letter/tailor.astro`:

```astro
---
import CoverLetterFromHash from '../../components/resume/CoverLetterFromHash.svelte'
import { resume } from '../../data/resume'
---
<html lang="en">
  <head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <meta name="robots" content="noindex,nofollow" />
    <title>Cover Letter</title>
  </head>
  <body>
    <CoverLetterFromHash client:only="svelte" defaultSender={resume} />
  </body>
</html>
```

- [ ] **Step 2: Verify build**

```bash
bun run build
```
Expected: clean build. New `dist/letter/tailor/index.html` exists.

```bash
ls portfolio/dist/letter/tailor/index.html
```
Expected: file exists.

- [ ] **Step 3: Commit**

```bash
git add portfolio/src/pages/letter/tailor.astro
git commit -m "feat(letter): add /letter/tailor route mounting Svelte island"
```

---

## Task 6: Update usage doc

**Files:**
- Modify: `portfolio/docs/tailored-resume.md`

- [ ] **Step 1: Update the doc**

Open `portfolio/docs/tailored-resume.md`. Make two changes:

**Change A:** Insert a new "## Defaults" section right after the "## Schema" section's closing paragraph and before "## Minimal example":

```markdown
## Defaults

Any field omitted from the hash falls back to the default values in `src/data/resume.ts`. So you only need to include the fields you want to override. Opening `/resume/tailor` with no hash at all renders the full default resume.

The merge is shallow at the top level: `skills`, `experiences`, and `achievements` are replaced wholesale when present in the hash, not deep-merged. To rewrite a single bullet inside an experience, send the entire `experiences` array.
```

**Change B:** Append a new top-level section at the end of the file:

```markdown
---

# Cover Letter — Usage

A static page at `/letter/tailor` that renders a cover letter from a list of paragraphs encoded into the URL hash. Sender contact info, today's date, "Dear Hiring Manager,", and the "Sincerely," signature are static — only the body paragraphs come from the hash.

## URL format

```
https://<site>/letter/tailor#data=<encodeURIComponent(JSON.stringify({ body: ["...", "..."] }))>
```

## Schema

| Field  | Type       | Notes                                |
| ------ | ---------- | ------------------------------------ |
| `body` | `string[]` | Paragraphs, ≥1, required. Each is rendered as its own `<p>`. |

Any other fields in the hash are ignored.

## Minimal example

```json
{
  "body": [
    "I'm writing to apply for the Senior Backend Engineer role at Acme. Your work on the data ingestion platform overlaps directly with what I spent the last two years building at my current role.",
    "Over the past nine years I've shipped Go and TypeScript services with strong reliability targets, including a Node→Go migration that cut p99 latency 40% and infra cost 20%. The numbers in your latest engineering blog suggest you're tackling similar problems at a different scale, and I'd like to help.",
    "I'd be glad to walk through specifics of the migration work, the design system I built, or anything else that's relevant. Thanks for your time."
  ]
}
```

## Build the URL — JavaScript

```js
const data = { body: ["Paragraph 1…", "Paragraph 2…"] };
const url = `https://zurek-dunne.dev/letter/tailor#data=${encodeURIComponent(JSON.stringify(data))}`;
```

## Build the URL — shell

```bash
DATA=$(cat letter.json | jq -c .)
ENC=$(printf '%s' "$DATA" | jq -sRr @uri)
echo "https://zurek-dunne.dev/letter/tailor#data=${ENC}"
```

## Print to PDF — agent

Same flow as the resume:

```bash
chrome --headless --disable-gpu --print-to-pdf=cover-letter.pdf "<URL>"
```

## Fallback behavior

The page renders an instructional fallback (and logs to console) when:

- The hash is missing or has no `data=` param.
- `data=` cannot be `JSON.parse`d.
- The parsed value is not an object.
- `body` is missing, not an array, or empty.
- Any element in `body` is not a string.
```

- [ ] **Step 2: Commit**

```bash
git add portfolio/docs/tailored-resume.md
git commit -m "docs(resume): document defaults merge and /letter/tailor route"
```

---

## Task 7: Manual verification

**Files:** none (verification only).

- [ ] **Step 1: Build and start preview**

```bash
bun run build
bun run preview --port 4322 &
sleep 3
```

- [ ] **Step 2: `/resume/tailor` no hash → default resume renders**

Open `http://localhost:4322/resume/tailor`. Expected: the full default resume renders, identical to `/resume`.

- [ ] **Step 3: `/resume/tailor` partial hash → merge applied**

Build a partial-override URL:

```bash
bun -e '
const partial = { professionalSummary: "TAILORED summary text used for verification." };
const url = "http://localhost:4322/resume/tailor#data=" + encodeURIComponent(JSON.stringify(partial));
console.log(url);
'
```

Open the URL. Expected: the summary paragraph reads "TAILORED summary text used for verification." but every other section (contact, skills, experience, achievements) shows the default content.

- [ ] **Step 4: `/resume/tailor` malformed hash → error fallback**

Open `http://localhost:4322/resume/tailor#data=not-json`. Expected: error message renders, browser console logs the error.

- [ ] **Step 5: `/letter/tailor` no hash → fallback**

Open `http://localhost:4322/letter/tailor`. Expected: "No cover letter content" message + URL example.

- [ ] **Step 6: `/letter/tailor` valid body → cover letter renders**

```bash
bun -e '
const data = {
  body: [
    "Paragraph one for verification.",
    "Paragraph two with more detail to confirm spacing.",
    "Closing paragraph."
  ]
};
const url = "http://localhost:4322/letter/tailor#data=" + encodeURIComponent(JSON.stringify(data));
console.log(url);
'
```

Open the URL. Expected:
- Header shows the default name + contact line (location, email, linkedin, portfolio).
- Today's date below the separator.
- "Dear Hiring Manager," salutation.
- Three body paragraphs.
- "Sincerely," + name signature.

- [ ] **Step 7: `/letter/tailor` invalid body → fallback**

Open `http://localhost:4322/letter/tailor#data=%7B%22body%22%3A%5B%5D%7D` (an empty `body` array). Expected: fallback message with "must include a non-empty `body` array" error.

- [ ] **Step 8: Print parity**

With both `/resume/tailor` and `/letter/tailor` open with valid hashes, trigger the print preview (Cmd+P) on each. Expected: same fonts, same margins, same overall typography. Letter has no resume-specific section headers; otherwise consistent.

- [ ] **Step 9: Stop preview**

```bash
pkill -f "astro preview"
```

No commit for this task.

---

## Rollout

After all tasks pass, the branch is ready to merge.

## Out of scope

- Compression of hash payload.
- Per-recipient cover letter fields (recipient name, company name, address).
- Multi-template support (different letter tones, formats).
