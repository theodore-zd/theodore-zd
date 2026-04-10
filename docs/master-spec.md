# Master Specification - theodore-zd Portfolio

## Table of Contents
- [Overview](#overview)
- [Project Organization](#project-organization)
- [Technology Stack](#technology-stack)
- [Architecture](#architecture)
- [Key Components](#key-components)
- [Styling & Theming](#styling--theming)
- [Data & Content](#data--content)
- [Build & Deployment](#build--deployment)
- [Development Workflow](#development-workflow)

## Overview

**theodore-zd** is a modern portfolio website showcasing the professional experience and technical expertise of Theodore Zurek-Dunne, a Senior Software Engineer. The site is built with Astro (a modern web framework for building fast, optimized websites) and includes interactive React components for rich, dynamic user experiences.

The portfolio serves to:
- Showcase professional background, skills, and experience
- Demonstrate technical capability through the site's architecture and implementation
- Provide an interactive platform with search, filtering, and responsive design
- Display expertise across full-stack development (TypeScript, Go, Python, React, Node.js, and more)

## Project Organization

The project is organized as a single frontend application with the following structure:

```
theodore-zd/
├── portfolio/                 # Main Astro application
│   ├── src/                  # Source code directory
│   │   ├── components/       # Reusable React components
│   │   ├── data/            # Static data files (projects, skills, etc.)
│   │   ├── layouts/         # Astro layout components (page templates)
│   │   ├── lib/             # Utility functions and helpers
│   │   ├── pages/           # Route handlers (Astro pages, auto-routed)
│   │   ├── styles/          # Global styles and CSS utilities
│   │   └── env.d.ts         # TypeScript environment type definitions
│   ├── public/              # Static assets (fonts, images, icons)
│   ├── package.json         # Node dependencies and scripts
│   ├── tsconfig.json        # TypeScript configuration
│   ├── astro.config.mjs     # Astro framework configuration
│   ├── components.json      # Component library configuration (shadcn)
│   └── .eslintrc.cjs        # ESLint configuration for code quality
├── docker-scripts/          # Docker configurations for deployment
├── claude-skills/           # Custom Claude Code skills
├── claude-settings/         # Claude Code settings and configuration
└── ReadMe.md               # Project overview and tech stack documentation
```

## Technology Stack

### Frontend Framework
- **Astro** (v5.17.1) — Modern static site generator with partial hydration. Astro renders pages to HTML at build time and only hydrates interactive components in the browser, resulting in excellent performance.
- **React** (v19.2.4) — Used via `@astrojs/react` integration for interactive UI components where needed
- **TypeScript** (v5.9.3) — Strict typing for better code quality and developer experience

### Styling
- **Tailwind CSS** (v4.1.18) — Utility-first CSS framework for rapid, responsive design
- **shadcn/ui** (v4.0.2) — Unstyled, accessible component library built on Radix UI and Tailwind
- **Tailwind Merge** (v3.5.0) — Utility for merging Tailwind class names intelligently
- **TW Animate CSS** (v1.4.0) — Additional Tailwind animation utilities
- **Styled Components** — Used in some React components for scoped styling

### UI Components & Interactions
- **@base-ui/react** (v1.2.0) — Unstyled, accessible component primitives
- **cmdk** (v1.1.1) — Command menu / command palette component
- **react-resizable-panels** (v4.7.2) — Resizable panel layout for flexible UI arrangements
- **vaul** (v1.1.2) — Drawer/sheet component
- **@phosphor-icons/react** (v2.1.10) — Icon library with 9000+ icons
- **simple-icons** (v16.13.0) — SVG icons for popular brands and services

### Data Visualization
- **Recharts** (v2.15.4) — React charting library for data visualization components
- **Lighthouse** (v13.0.3) — Performance auditing and metrics

### Utilities
- **clsx** (v2.1.1) — Utility for constructing className strings conditionally
- **class-variance-authority** (v0.7.1) — CSS-in-JS variant library for component styling

### Fonts
- **@fontsource-variable/jetbrains-mono** (v5.2.8) — JetBrains Mono font as a variable font for typography

### Build & Development Tools
- **Prettier** (v3.8.1) — Code formatter with Astro and Tailwind plugins
- **ESLint** (v9.39.1) — Code linting with React and TypeScript support
- **Astro CLI** — Command-line tools for development and building

## Architecture

### Astro + React Hybrid Approach
This project uses Astro's "islands architecture" pattern:
- Pages are **static HTML** generated at build time for excellent performance and SEO
- **Interactive components** are React islands that hydrate only when needed
- This approach combines the speed of static sites with the power of dynamic components

### Page Structure
Astro pages are automatically routed based on file structure:
- `src/pages/index.astro` → `/` (home page)
- `src/pages/[route].astro` → `/route` (dynamic routes)

Each page uses Astro layouts from `src/layouts/` for consistent page structure and styling.

### Component Organization
- **src/components/** — Reusable React components wrapped for Astro
  - Many components use shadcn/ui as the base
  - Components are responsive and accessible
  - Styled with Tailwind CSS utility classes
  
- **src/lib/** — Pure utility functions
  - Helper functions for data manipulation
  - Type utilities
  - Constants and configuration

### Data Layer
- **src/data/** — Static data files (not a backend API)
  - Portfolio projects, experience, skills stored as JSON/JS files
  - This data is imported into pages at build time
  - No runtime API calls needed for core content

### Styling Strategy
- **Global Styles** in `src/styles/` — Base CSS, Tailwind directives
- **Component Styles** — Tailwind classes in component JSX
- **Theme System** — Likely configured through Tailwind's config, supporting light/dark modes
- **Responsive Design** — Mobile-first approach using Tailwind breakpoints (sm, md, lg, xl)

## Key Components

### Layout Components (src/layouts/)
Astro layout components that wrap pages and provide consistent structure. Likely includes:
- Main page layout with header/footer
- Metadata and head management
- Navigation structure

### UI Components (src/components/)
React components that provide interactivity:
- **Search/Command Component** — Uses `cmdk` for searchable navigation
- **Resizable Panels** — Using `react-resizable-panels` for flexible layouts
- **Drawers/Sheets** — Using `vaul` for modals and side panels
- **Icon Components** — Phosphor Icons and Simple Icons wrapped for easy use
- **Data Visualizations** — Recharts for charts and graphs
- **Base UI Components** — Accessible primitives from shadcn/ui and @base-ui/react

### Page Components (src/pages/)
Astro pages that render the actual routes:
- Each page is an Astro file that combines layout + content + interactive components
- Pages are pre-rendered to HTML at build time
- Individual React components hydrate on the client as needed

## Styling & Theming

### Tailwind Configuration
The project uses Tailwind CSS v4 with:
- Utility-first approach for rapid development
- Responsive design capabilities
- Likely custom color palette matching the portfolio's brand
- CSS variable integration for theming

### Component Styling
- **shadcn/ui Components** — Pre-styled accessible components, customized via Tailwind
- **Class Variance Authority** — Used for component variant management
- **Tailwind Merge** — Prevents conflicting Tailwind classes

### Typography
- **JetBrains Mono** — Monospace font for code/technical elements
- Default system fonts likely used for body text

## Data & Content

### Static Content
Portfolio content is stored as static files in `src/data/`:
- Project descriptions and details
- Professional experience/timeline
- Skills and technologies
- Links and contact information

### No Backend API
This is a **static site** — content is:
- Stored in the repository
- Built into the HTML at build time
- Updated by committing new content and rebuilding

## Build & Deployment

### Development
```bash
npm run dev      # Start Astro dev server (typically on localhost:3000)
```

### Production Build
```bash
npm run build    # Generate optimized static HTML/CSS/JS
npm run preview  # Preview production build locally
```

### Build Output
- **dist/** directory contains the final static site
- HTML files for each page
- Optimized CSS and JavaScript bundles
- Static assets (images, fonts, etc.)

### Deployment Options
The static output can be deployed to:
- Vercel (optimized for Astro)
- Netlify
- GitHub Pages
- Any static hosting service
- Traditional web servers (nginx, Apache)

Docker scripts in `docker-scripts/` suggest Docker-based deployment, likely:
- Building the site in a Docker container
- Serving via nginx from a Docker image
- Possible integration with PostgreSQL and SeaweedFS based on git history notes

## Development Workflow

### Code Quality
- **ESLint** — Linting with React, TypeScript, and React Hooks rules
- **Prettier** — Automatic code formatting
  - Astro plugin for `.astro` file formatting
  - Tailwind plugin for class ordering
- **TypeScript** — Strict mode type checking
- **astro check** — Astro-specific type checking

### Available npm Scripts
```json
{
  "dev": "astro dev",              // Development server
  "build": "astro build",          // Production build
  "preview": "astro preview",      // Preview production build
  "lint": "eslint .",              // Run linter
  "format": "prettier --write",    // Format code
  "typecheck": "astro check"       // Type check Astro files
}
```

### Project Standards
- TypeScript for type safety
- Tailwind for consistent styling
- Component-driven development with shadcn/ui
- Responsive, accessible design patterns
- ESLint and Prettier for code consistency

---

## Notes

This portfolio is a well-architected example of modern web development practices:
- **Performance-First** — Astro's static generation + partial hydration ensures fast load times
- **Type-Safe** — TypeScript throughout for reliability
- **Accessible** — Using accessible component libraries and best practices
- **Maintainable** — Clear component structure, consistent styling approach
- **SEO-Optimized** — Static HTML for search engines, proper metadata handling

The site effectively demonstrates Theodore's technical expertise through both its content and its implementation.
