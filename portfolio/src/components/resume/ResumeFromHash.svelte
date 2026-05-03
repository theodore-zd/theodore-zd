<script lang="ts">
  import { onMount } from 'svelte'
  import type { Resume } from '../../data/resume'
  import ResumeView from './Resume.svelte'

  let resume: Partial<Resume> | null = null
  let error: string | null = null
  let ready = false

  function decodeHash(hash: string): Partial<Resume> {
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
