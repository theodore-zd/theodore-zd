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
      parsed = JSON.parse(raw)
    } catch {
      throw new Error('Hash data is not valid JSON')
    }
    if (!parsed || typeof parsed !== 'object' || Array.isArray(parsed)) {
      throw new Error('Hash data must be a JSON object')
    }
    return parsed as Partial<Resume>
  }

  function mergeResume(base: Partial<Resume>, overrides: Partial<Resume>): Partial<Resume> {
    const merged: Partial<Resume> = { ...base, ...overrides }

    // skills: merge by key so favorite-only override doesn't clobber toolbox
    if (overrides.skills) {
      merged.skills = { ...(base.skills ?? { favorite: [], toolbox: [] }), ...overrides.skills }
    }

    // experiences: merge by id so a one-role override doesn't replace the array
    if (overrides.experiences && base.experiences) {
      const overrideById = new Map<string, Partial<Resume['experiences'][number]>>()
      for (const o of overrides.experiences as Array<Partial<Resume['experiences'][number]> & { id?: string }>) {
        if (typeof o.id === 'string' && o.id.length > 0) {
          overrideById.set(o.id, o)
        } else {
          console.warn('[resume/tailor] experience override missing id, ignored:', o)
        }
      }
      const seen = new Set<string>()
      merged.experiences = base.experiences.map((exp) => {
        const o = overrideById.get(exp.id)
        if (!o) return exp
        seen.add(exp.id)
        return { ...exp, ...o }
      })
      for (const id of overrideById.keys()) {
        if (!seen.has(id)) console.warn(`[resume/tailor] experience override id "${id}" not found in defaults, ignored`)
      }
    }

    return merged
  }

  onMount(() => {
    try {
      const overrides = decodeHash(window.location.hash)
      resume = overrides ? mergeResume(defaultResume, overrides) : defaultResume
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
