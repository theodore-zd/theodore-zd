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
