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
