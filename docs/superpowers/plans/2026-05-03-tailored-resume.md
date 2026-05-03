# Tailored Resume Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add a `/resume/tailor` route that renders a job-tailored resume from JSON encoded into the URL hash, using a Svelte island that mirrors the existing static `/resume` page.

**Architecture:** Add Svelte to the Astro project. Create two Svelte components — `Resume.svelte` (presentational, takes `resume: Resume` prop) and `ResumeFromHash.svelte` (reads `window.location.hash`, decodes JSON, renders `Resume`). Mount the hash-reading component on a new `/resume/tailor` Astro page with `noindex`. The existing `/resume.astro` is not modified.

**Tech Stack:** Astro 6, Svelte 5, `@astrojs/svelte`, TypeScript, Bun.

**Spec:** `docs/superpowers/specs/2026-05-03-tailored-resume-design.md`

**Note on testing:** This project has no unit test framework configured. Verification is manual via `bun run typecheck` and `bun run dev` + browser. Tasks reflect that.

**Working directory for all commands:** `/Users/theo/Desktop/theodore-zd/portfolio`

---

## File Structure

**New files:**
- `src/components/resume/Resume.svelte` — presentational resume component, takes `resume: Resume` prop, contains scoped CSS mirroring `resume.astro`.
- `src/components/resume/ResumeFromHash.svelte` — wrapper that reads `window.location.hash`, decodes JSON, renders `Resume` or fallback message.
- `src/pages/resume/tailor.astro` — Astro page that mounts `<ResumeFromHash client:only="svelte" />` with `noindex` meta.

**Modified files:**
- `astro.config.mjs` — add `svelte()` integration.
- `package.json` / `bun.lock` — add `@astrojs/svelte` and `svelte` dependencies.

**Unchanged:**
- `src/pages/resume.astro`
- `src/data/resume.ts`

---

## Task 1: Install Svelte integration

**Files:**
- Modify: `portfolio/package.json`
- Modify: `portfolio/bun.lock`
- Modify: `portfolio/astro.config.mjs`

- [ ] **Step 1: Install dependencies**

Run from `portfolio/`:

```bash
bun add @astrojs/svelte svelte
```

Expected: `package.json` gains `@astrojs/svelte` and `svelte` under `dependencies`. `bun.lock` updates.

- [ ] **Step 2: Update `astro.config.mjs` to register the Svelte integration**

Replace the file contents with:

```js
// @ts-check

import tailwindcss from "@tailwindcss/vite"
import { defineConfig } from "astro/config"
import react from "@astrojs/react"
import svelte from "@astrojs/svelte"
import mdx from "@astrojs/mdx"

// https://astro.build/config
export default defineConfig({
  vite: {
    plugins: [tailwindcss()],
  },
  integrations: [react(), svelte(), mdx()],
})
```

- [ ] **Step 3: Verify the project still type-checks and builds**

Run:

```bash
bun run typecheck
```

Expected: zero errors.

```bash
bun run build
```

Expected: build succeeds with no Svelte-related warnings.

- [ ] **Step 4: Commit**

```bash
git add portfolio/package.json portfolio/bun.lock portfolio/astro.config.mjs
git commit -m "chore(portfolio): add @astrojs/svelte integration"
```

---

## Task 2: Create `Resume.svelte` presentational component

**Files:**
- Create: `portfolio/src/components/resume/Resume.svelte`

- [ ] **Step 1: Create the component file**

Create `portfolio/src/components/resume/Resume.svelte` with the following contents. The markup and CSS mirror `src/pages/resume.astro` exactly so the tailored page renders identically to the static page.

```svelte
<script lang="ts">
  import type { Resume } from '../../data/resume'

  export let resume: Partial<Resume> = {}
</script>

<svelte:head>
  <link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Inter:wght@400;600;700&display=swap" />
  <title>Printable Resume — {resume?.name ?? 'Resume'}</title>
</svelte:head>

<main class="resume-page" aria-label="Printable resume">
  <header>
    <h1 class="name">{resume?.name ?? ''}</h1>
    <div class="title">{resume?.seniority ?? ''} | {resume?.yearsExperience ?? ''}</div>
    <div class="contact">
      {#if resume?.location}<span>{resume.location}</span>{/if}
      {#if resume?.email}<span>•</span><a href={`mailto:${resume.email}`}>{resume.email}</a>{/if}
      {#if resume?.linkedin}<span>•</span><a href={resume.linkedin} target="_blank" rel="noopener noreferrer">LinkedIn</a>{/if}
      {#if resume?.portfolioUrl}<span>•</span><a href={resume.portfolioUrl} target="_blank" rel="noopener noreferrer">Portfolio</a>{/if}
    </div>
  </header>

  {#if resume?.professionalSummary}
    <section class="section" aria-label="Professional summary">
      <p class="summary-text">{resume.professionalSummary}</p>
    </section>
    <hr class="separator" aria-label="section separator" />
  {/if}

  {#if resume?.skills?.favorite?.length}
    <section class="section" aria-label="Skills">
      <h3>Favorite Tools</h3>
      <p class="skill-list">{resume.skills.favorite.slice(0, 12).join(', ')}</p>
    </section>
    <hr class="separator" aria-label="section separator" />
  {/if}

  {#if resume?.experiences?.length}
    <section class="section" aria-label="Experience">
      <h3>Experience</h3>
      <div class="experience-items">
        {#each resume.experiences as e}
          <div>
            <div class="experience-header">{e.title} — {e.role} <span class="experience-description">({e.desc})</span></div>
            <ul class="experience-bullets">
              {#each e.info ?? [] as bullet}
                <li>{bullet}</li>
              {/each}
            </ul>
          </div>
        {/each}
      </div>
    </section>
    <hr class="separator" aria-label="section separator" />
  {/if}

  {#if resume?.achievements?.length}
    <section class="section" aria-label="Achievements">
      <h3>Achievements</h3>
      <ul class="skill-list">
        {#each resume.achievements as a}
          <li>{a}</li>
        {/each}
      </ul>
    </section>
  {/if}
</main>

<style>
  :global(:root) {
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

  @media print {
    :global(html), :global(body) { margin: 0; padding: 0; background: #fff; }
    .resume-page { margin: 0 auto; }
    :global(.no-print) { display: none !important; }
  }

  :global(body) {
    font-family: var(--font-family);
    color: var(--text);
    line-height: var(--line-height);
    background: #fff;
  }

  .resume-page {
    width: 100%;
    padding: var(--sp-page);
    margin: 0 auto;
    box-sizing: border-box;
  }

  header { margin-bottom: var(--sp-md); }

  .name {
    font-size: var(--fs-name);
    font-weight: 700;
    margin: 0;
    line-height: 1;
  }

  .title {
    font-size: var(--fs-subtitle);
    color: var(--text-secondary);
    margin: var(--sp-xs) 0 0 0;
    line-height: 1.1;
  }

  .contact {
    margin-top: var(--margin-contact);
    font-size: var(--fs-body);
    color: var(--muted);
    line-height: 1.1;
  }

  .contact a { color: #0969da; text-decoration: none; }
  .contact a:hover { text-decoration: underline; }

  .section { margin-top: var(--sp-xl); }

  .section h3 {
    font-size: var(--fs-section-title);
    margin: 0 0 var(--sp-sm) 0;
    font-weight: 600;
  }

  .section p { font-size: var(--fs-summary); margin: 0; }

  .separator {
    height: 1px;
    background: var(--border);
    margin: var(--sp-md) 0;
    border: 0;
  }

  ul { margin: 0; padding-left: var(--list-indent); }

  .experience-bullets {
    margin: var(--sp-xs) 0;
    padding-left: var(--list-indent);
  }

  li {
    margin: var(--sp-xs) 0;
    font-size: var(--fs-bullet);
    line-height: 1.2;
  }

  .summary-text {
    margin: 0;
    font-size: var(--fs-summary);
    color: var(--text-secondary);
    line-height: 1.15;
  }

  .experience-items {
    display: flex;
    flex-direction: column;
    gap: var(--sp-lg);
  }

  .experience-header {
    font-weight: 600;
    margin-bottom: var(--sp-xs);
    line-height: 1.1;
  }

  .experience-description {
    color: var(--muted);
    font-weight: 400;
    font-size: 0.75rem;
  }

  .skill-list { margin: 0; font-size: var(--fs-body); }

  @media (max-width: 600px) {
    .resume-page { padding: var(--sp-mobile); }
  }
</style>
```

- [ ] **Step 2: Verify type-check passes**

Run:

```bash
bun run typecheck
```

Expected: zero errors. (The component is not yet imported, so this is a smoke test for the import path.)

- [ ] **Step 3: Commit**

```bash
git add portfolio/src/components/resume/Resume.svelte
git commit -m "feat(resume): add Resume.svelte presentational component"
```

---

## Task 3: Create `ResumeFromHash.svelte` wrapper

**Files:**
- Create: `portfolio/src/components/resume/ResumeFromHash.svelte`

- [ ] **Step 1: Create the wrapper component**

Create `portfolio/src/components/resume/ResumeFromHash.svelte`:

```svelte
<script lang="ts">
  import { onMount } from 'svelte'
  import type { Resume } from '../../data/resume'
  import ResumeView from './Resume.svelte'

  let resume: Partial<Resume> | null = null
  let error: string | null = null
  let ready = false

  function decodeHash(hash: string): Partial<Resume> {
    // hash starts with '#'; expect '#data=<urlencoded-json>'
    const trimmed = hash.startsWith('#') ? hash.slice(1) : hash
    const params = new URLSearchParams(trimmed)
    const raw = params.get('data')
    if (!raw) throw new Error('Missing "data" parameter in URL hash')
    let parsed: unknown
    try {
      parsed = JSON.parse(decodeURIComponent(raw))
    } catch (e) {
      throw new Error('Hash data is not valid JSON')
    }
    if (!parsed || typeof parsed !== 'object') {
      throw new Error('Hash data must be a JSON object')
    }
    if (!('name' in parsed) || typeof (parsed as { name: unknown }).name !== 'string') {
      throw new Error('Hash data must include a "name" string')
    }
    return parsed as Partial<Resume>
  }

  onMount(() => {
    try {
      resume = decodeHash(window.location.hash)
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
{:else if resume}
  <ResumeView {resume} />
{:else}
  <main class="status" role="alert">
    <h1>No tailored resume data</h1>
    <p>Open this page with tailored resume data in the URL hash.</p>
    <p>Example: <code>/resume/tailor#data=&#123;...&#125;</code> (URL-encoded JSON matching the <code>Resume</code> shape).</p>
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

- [ ] **Step 2: Verify type-check passes**

Run:

```bash
bun run typecheck
```

Expected: zero errors.

- [ ] **Step 3: Commit**

```bash
git add portfolio/src/components/resume/ResumeFromHash.svelte
git commit -m "feat(resume): add ResumeFromHash wrapper that decodes hash data"
```

---

## Task 4: Add `/resume/tailor` Astro page

**Files:**
- Create: `portfolio/src/pages/resume/tailor.astro`

- [ ] **Step 1: Create the page**

Create `portfolio/src/pages/resume/tailor.astro`:

```astro
---
import ResumeFromHash from '../../components/resume/ResumeFromHash.svelte'
---
<html lang="en">
  <head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <meta name="robots" content="noindex,nofollow" />
    <title>Tailored Resume</title>
  </head>
  <body>
    <ResumeFromHash client:only="svelte" />
  </body>
</html>
```

- [ ] **Step 2: Verify build succeeds**

Run:

```bash
bun run build
```

Expected: build emits both `dist/resume/index.html` (existing static page) and `dist/resume/tailor/index.html` (new shell). No errors.

- [ ] **Step 3: Commit**

```bash
git add portfolio/src/pages/resume/tailor.astro
git commit -m "feat(resume): add /resume/tailor route mounting Svelte island"
```

---

## Task 5: Manual verification

**Files:** none (verification only).

- [ ] **Step 1: Start the dev server**

Run from `portfolio/`:

```bash
bun run dev
```

Leave it running for the remaining steps.

- [ ] **Step 2: Verify the existing `/resume` page is unchanged**

Open `http://localhost:4321/resume` in a browser. Visually compare against the page on the deployed site (or against the previous build). Expected: no visible changes.

- [ ] **Step 3: Verify `/resume/tailor` with no hash shows fallback**

Open `http://localhost:4321/resume/tailor`. Expected: the "No tailored resume data" message renders. No console errors beyond the expected warning.

- [ ] **Step 4: Verify `/resume/tailor` with malformed hash shows fallback + error**

Open `http://localhost:4321/resume/tailor#data=not-json`. Expected: fallback message renders, error line says something like `Hash data is not valid JSON`, and the browser console shows the error from `console.error`.

- [ ] **Step 5: Verify `/resume/tailor` with a valid hash renders the tailored resume**

In a terminal, build a sample tailored payload and the URL:

```bash
node -e '
const data = {
  name: "Theodore Zurek-Dunne (TAILORED)",
  seniority: "Senior",
  yearsExperience: "9+ yrs",
  location: "Toronto",
  email: "test@example.com",
  professionalSummary: "Tailored summary for the target role.",
  skills: { favorite: ["TypeScript", "Astro", "Svelte"], toolbox: [] },
  experiences: [{ title: "Acme", role: "Lead Engineer", desc: "2022–present", info: ["Did X", "Did Y"] }],
  achievements: ["Shipped Z"]
};
const url = "http://localhost:4321/resume/tailor#data=" + encodeURIComponent(JSON.stringify(data));
console.log(url);
'
```

Open the printed URL in a browser. Expected:
- Name reads `Theodore Zurek-Dunne (TAILORED)`.
- Summary, skills, experience, and achievement sections render.
- Visual layout matches `/resume`.

- [ ] **Step 6: Verify print preview matches `/resume`**

With the tailored URL still open, trigger the browser's Print dialog (Cmd+P on macOS). Expected: the print layout is visually identical to printing `/resume` (same fonts, spacing, separators).

- [ ] **Step 7: Verify production build serves both routes**

Stop the dev server. Run:

```bash
bun run build
bun run preview
```

Repeat steps 2–5 against the preview server (port shown by `astro preview`, typically 4322). Expected: both routes work in the built output.

- [ ] **Step 8: Stop the preview server**

`Ctrl+C` in the terminal running `bun run preview`.

No commit for this task.

---

## Rollout

After all tasks pass, the branch is ready to merge. No migration, no environment changes, no deploy steps beyond the normal Cloudflare Pages build.

## Out of scope (future work)

- Compression of hash payload (`CompressionStream` + base64url) — add only if a real payload exceeds browser URL limits.
- A CLI helper in `personal-scripts` that takes a tailored JSON file and prints the URL.
- An agent-side script that drives a headless browser to print the tailored page to PDF.
