# README Redesign — Design Spec

## Overview

Redesign the theodore-zd GitHub profile README to match the terminal-themed aesthetic of the portfolio site, serve both recruiters and developers, and reflect the repo's expanded purpose (scripts, configs, dotfiles).

## Audience

Both recruiters/hiring managers and fellow developers.

## Design Direction

Terminal-themed (Approach A) — consistent with the portfolio site's CLI aesthetic. Uses code-block-style headers (`$ command` format), monospace feel, and terminal metaphors throughout.

## Structure

### Section 1: Hero

- Terminal-style heading: `# > theodore-zd`
- Title line: **Senior Software Engineer** | TypeScript | Go | Python | React/Next.js | Node.js
- Availability status: `` `$ status --available` ``
- Medium-length bio paragraph (from portfolio summary, no specific company mentions):
  > "Seasoned software engineer delivering fast, reliable, scalable full-stack solutions. Expert in TypeScript, Go, Python, and modern cloud architectures. I collaborate with cross-functional teams to translate complex requirements into high-quality software that drives business results and measurable impact."
- Social links: Portfolio | LinkedIn | Email

### Section 2: Tech Stack

Header: `## $ ls tech-stack/`

All items rendered as shields.io badges (`for-the-badge` style), organized into four groups:

**Languages:** Go, TypeScript, JavaScript, Python, HTML5, CSS3

**Frameworks & Libraries:** React, Next.js, Node.js, NestJS, Vue.js, Svelte, SvelteKit, Socket.io, Styled Components, MUI, SASS

**Databases:** PostgreSQL, MongoDB, MySQL, Supabase

**Infrastructure:** Docker, Nginx

**Removed from current README:**
- Design apps: Figma, Adobe Illustrator, Affinity Designer/Photo, Aseprite, Krita, Adobe XD
- Platforms: Netlify, Vultr
- Package managers: NPM, PNPM
- Build tools: Webpack
- Routing: React Router
- Languages: GraphQL, Shell Script, Markdown

### Section 3: Footer — Repo Contents

Separated from professional content by a horizontal rule (`---`).

Header: `## $ ls ./`

Table format listing repo directories with descriptions:

| Directory | Description |
|-----------|-------------|
| `claude-settings/` | Claude Code configuration |
| `docker-scripts/` | Common Docker utilities |

This section grows as new folders are added.

### Removed Elements

- Random Dev Quote widget
- GitHub Stats (contribution streak, top languages, trophies) — stays removed
- Emoji section headers (replaced with terminal-style `$` commands)

## Content Source

Bio and tech stack sourced from the portfolio site at `portfolio/src/data/resume.ts`. Social links from the same source.

## Key Decisions

1. Badges: kept but trimmed to coding-relevant items only (langs, libs, frameworks, databases, infra)
2. Bio: medium length, no company-specific mentions, achievement-oriented
3. Repo contents: in footer to keep hero area professional
4. No GitHub stats or quote widgets — clean finish
5. Terminal aesthetic throughout for brand consistency with portfolio
