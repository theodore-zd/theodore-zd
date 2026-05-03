<script lang="ts">
  import type { Resume } from '../../data/resume'
  import './resume-styles.css'

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
            <div class="experience-header">{e.title} — {e.role} <span class="experience-description">({e.dates})</span></div>
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
