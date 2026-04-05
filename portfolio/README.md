# Theodore Zurek-Dunne - Portfolio

A modern personal portfolio site built with Astro 5 + React 19 + TypeScript + Tailwind CSS 4 + shadcn/ui. Features a terminal/developer aesthetic with seamless interactivity.

## Stack

- **Framework:** Astro 5 (static site generation)
- **UI:** React 19 with Astro integration
- **Styling:** Tailwind CSS 4
- **UI Components:** shadcn/ui (41+ primitives)
- **TypeScript:** Full type safety
- **Fonts:** JetBrains Mono Variable (Google Fonts)

## Features

- 🖥️ Terminal/developer aesthetic
- 🎨 Dark mode with theme toggle
- 📱 Fully responsive design
- ⚡ Fast static site generation
- 🔄 Interactive React components
- 📄 Single source of truth content (resume.ts)

## Getting Started

### Installation

```bash
# Install dependencies
npm install

# Start development server
npm run dev
```

Open [http://localhost:4321](http://localhost:4321) in your browser.

### Building

```bash
# Build for production
npm run build

# Preview production build
npm run preview
```

## Project Structure

```
src/
├── pages/           # Astro routes (index, blog, projects)
├── components/      # Astro sections + React components
├── components/ui/   # shadcn/ui primitives
├── data/            # resume.ts - portfolio content
├── lib/             # utils and tech-icons
└── styles/          # global.css + custom utilities
```

## Content

All portfolio content is managed in `src/data/resume.ts` as a single source of truth, including:

- Name, title, tagline
- Skills (favorite & toolbox)
- Experience & projects
- Awards & achievements

## Styling

Uses Tailwind CSS + custom utilities in `src/styles/global.css`:

- `.terminal-card` - bordered cards with glow effect
- `.terminal-prompt` - terminal prompt style
- `.cursor-blink` - animated cursor
- `.text-gradient` - gradient text effect
- `.glow-primary` - primary color glow

## Theme

Default theme is dark (fallback in main.astro). Theme toggle persists to localStorage.

## Adding Components

To add shadcn/ui components:

```bash
npx shadcn@latest add <component>
```

This will add the component to `src/components/ui/` and add any necessary styles.
