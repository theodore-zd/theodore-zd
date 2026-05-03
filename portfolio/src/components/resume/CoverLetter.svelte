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
      {#if sender?.email}<span class="sep" aria-hidden="true">•</span><a href={`mailto:${sender.email}`}>{sender.email}</a>{/if}
      {#if sender?.linkedin}<span class="sep" aria-hidden="true">•</span><a href={sender.linkedin} target="_blank" rel="noopener noreferrer">LinkedIn</a>{/if}
      {#if sender?.portfolioUrl}<span class="sep" aria-hidden="true">•</span><a href={sender.portfolioUrl} target="_blank" rel="noopener noreferrer">Portfolio</a>{/if}
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
    font-size: var(--fs-body);
    line-height: 1.5;
  }

  header { margin-bottom: 0.4rem; }

  .name {
    font-size: var(--fs-name);
    font-weight: 700;
    margin: 0;
    line-height: 1.1;
  }

  .contact {
    margin-top: var(--margin-contact);
    font-size: var(--fs-body);
    color: var(--muted);
    line-height: 1.3;
    display: flex;
    flex-wrap: wrap;
    gap: 0.4em;
    align-items: baseline;
  }

  .contact a { color: #0969da; text-decoration: none; }
  .contact a:hover { text-decoration: underline; }
  .contact .sep { color: var(--border-button); }

  .separator {
    height: 1px;
    background: var(--border);
    margin: 0.6rem 0 1.25rem 0;
    border: 0;
  }

  .date {
    margin: 0 0 1.25rem 0;
    font-size: var(--fs-body);
    color: var(--text-secondary);
  }

  .salutation {
    margin: 0 0 1rem 0;
    font-size: var(--fs-body);
  }

  .body p {
    margin: 0 0 0.9rem 0;
    font-size: var(--fs-body);
    line-height: 1.55;
    color: var(--text);
  }

  .body p:last-child { margin-bottom: 0; }

  .closing {
    margin: 1.25rem 0 1rem 0;
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

  @media print {
    .letter-page { max-width: none; }
  }
</style>
