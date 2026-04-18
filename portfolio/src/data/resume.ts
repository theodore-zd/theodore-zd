// GitHub project types and data
export interface GithubProject {
  repo: string
  description: string
  language?: string
  stars: number
  forks: number
  homepage?: string
}

const LANGUAGE_COLORS: Record<string, string> = {
  Go: "#00ADD8",
  TypeScript: "#3178c6",
  JavaScript: "#f1e05a",
  Python: "#3572A5",
  Rust: "#dea584",
  Svelte: "#ff3e00",
  Astro: "#ff5a03",
  HTML: "#e34c26",
  CSS: "#563d7c",
  SCSS: "#c6538c",
  Shell: "#89e051",
  C: "#555555",
  "C++": "#f34b7d",
  "C#": "#178600",
  Java: "#b07219",
  Ruby: "#701516",
  PHP: "#4F5D95",
  Swift: "#F05138",
  Kotlin: "#A97BFF",
  Vue: "#41b883",
  Lua: "#000080",
  Zig: "#ec915c",
  Dart: "#00B4AB",
}

export function languageColor(lang?: string): string {
  if (!lang) return "#8b949e"
  return LANGUAGE_COLORS[lang] ?? "#8b949e"
}

const githubProjects: GithubProject[] = [
  {
    repo: "wispberry-tech/wispy-auth",
    description: "Lightweight authentication service in Go.",
    language: "Go",
    stars: 0,
    forks: 0,
    homepage: "",
  },
  {
    repo: "wispberry-tech/grove",
    description: "Grove — a Wispberry project written in Go.",
    language: "Go",
    stars: 0,
    forks: 0,
    homepage: "",
  },
  {
    repo: "wispberry-tech/wispy-grove-lang-support",
    description: "Language support and tooling for the Grove ecosystem.",
    language: "JavaScript",
    stars: 0,
    forks: 0,
    homepage: "",
  },
]

// Type definitions for resume data
export interface Resume {
  name: string
  displayName: string
  title: string
  tagline: string
  headline: string
  // valueProps: string[]
  /** Computed alias for first 8 items of skills.favorite */
  readonly coreStack: string[]
  email: string
  phone?: string
  github: string
  linkedin: string
  portfolioUrl: string
  resumeUrl: string
  professionalSummary: string
  location: string
  availability: string
  engagementType: string
  yearsExperience: string
  seniority: string
  metaItems: Array<{ text: string; accent: boolean }>
  impactBullets: string[]
  aboutDescription: string
  ctaDescription: string
  footerTagline: string
  skills: {
    favorite: string[]
    toolbox: string[]
  }
  experiences: Array<{
    title: string
    desc: string
    role: string
    info: string[]
  }>
  projects: Array<{
    title: string
    description: string
    tools: string[]
    live: string
    git: string
  }>
  githubProjects: GithubProject[]
  achievements: string[]
}

const yearsExperience = "9+ years experience"
const seniority = "Senior / Lead"
const availability = "Hybrid/Remote"
const location = "Toronto (EST)"
const engagementType = "Full-time + Contract"

const resumeData = {
  name: "Theodore Zurek-Dunne",
  displayName: "Theodore",
  title: "Senior Software Engineer | Go | TypeScript | React/Next.js | Node.js",
  tagline:
    "Senior software engineer with 9+ years of experience delivering high-performance, scalable systems",
  headline:
    "Senior Software Engineer | Go, TypeScript, Svelte, React | Building scalable, high‑performance systems with measurable business impact.",
  email: "99theodore@gmail.com",
  github: "https://github.com/theodore-zd",
  linkedin: "https://www.linkedin.com/in/theodore-zurek-dunne-37885b164/",
  portfolioUrl: "https://zurek-dunne.dev",
  resumeUrl: "/Theodore_Zurek-Dunne_Resume-2026.pdf",
  professionalSummary: `Senior Software Engineer with over 9 years of experience working with TypeScript, Go, React, and Svelte to deliver fast, scalable systems. Led Node.js→Go migrations cutting latency and costs, built design systems, shipped UX improvements boosting adoption.`,
  location,
  availability,
  engagementType,
  yearsExperience,
  seniority,
  metaItems: [
    { text: yearsExperience, accent: false },
    { text: seniority, accent: true },
    { text: availability, accent: false },
    { text: location, accent: true },
    { text: engagementType, accent: false },
  ],
  impactBullets: [
    "Led Node.js → Go migration — cut p95 latency and infra cost on high-traffic microservices",
    "Built design systems that accelerated delivery 33% and lifted user adoption 65%",
    "Mentored 4 engineers; founded Kato.Studio; shipped 95+ Lighthouse production sites",
  ],
  aboutDescription:
    "9+ years shipping high-performance systems in TypeScript, Go, React, and Next.js. I've led Node.js→Go migrations cutting latency and infrastructure costs, built design systems that accelerated delivery, and shipped UX overhauls that improved user metrics.",
  ctaDescription:
    "Scaling systems with TypeScript, Go, React, and Next.js. I focus on what matters: faster systems, lower costs, better user experience.",
  footerTagline: "9+ years. TypeScript, Go, React. Measurable impact.",
  skills: {
    favorite: [
      "TypeScript",
      "Go",
      "Python",
      "Alpine.js",
      "JavaScript/Typescript",
      "React",
      "Next.js",
      "Node.js",
      "Bun",
      "Docker",
      "PostgreSQL",
      "SvelteKit",
      "Git",

    ],
    toolbox: [
      "Netlify",
      "HTML5",
      "CSS3",
      "Nest.js",
      "GraphQL",
      "SASS",
      "Socket.io",
      "Vue",
      "Pnpm",
      "MongoDB",
      "Npm",
      "GraphQL",
      "Playwright",
      "Cypress",
      "HTTP/REST",
      "Design Systems",
      "Agile Methodologies",
      "SEO Optimization",
      "UI/UX Design",
      "Team Management",
      "Design Systems",
      "CI/CD",
    ],
  },
  experiences: [
    {
      title: "Freelance",
      desc: "September 2024 - Present",
      role: "Systems Performance Engineer",
      info: [
        "Migrated Node.js APIs to Golang, achieving 20% infrastructure cost reduction and 35% faster response times.",
        "Implemented URL-encoded data APIs with 10-15% smaller payloads and 16% faster deserialization.",
        "Designed cloud-agnostic architectures deployed across DigitalOcean, Vultr, Fly.io, and Railway.",
      ],
    },
    {
      title: "Indie Tech",
      desc: "May 2022 - July 2024",
      role: "Full-Stack Developer, UI/UX Designer",
      info: [
        "Spearheaded UI/UX overhaul, resulting in a 43% improvement in user testing scores and a 27% decrease in UI-related support tickets.",
        "Implemented REST endpoints & UI interfaces around complex computational models on an event-driven architecture using Python micro-services.",
        "Developed design systems and reusable components, reducing development time by 33% and decreasing technical debt by 42%.",
        "Built multi-tenant access controls, real-time collaboration features, and approval workflows.",
        "Corroborated to ensure ensure SOC 2 compliance, enhancing data security.",
      ],
    },
    {
      title: "Kato.Studio",
      desc: "October 2020 - July 2021",
      role: "Founder",
      info: [
        "Elevated client websites to achieve 95+ Lighthouse scores, resulting in an average increase of 53% in organic traffic and a 152% decrease in bounce rates.",
        "Engineered custom CMS and microservices architecture, improving content management efficiency by an average of 62%.",
        "Delivered analytics dashboards that increased client data utilization by 4x.",
        "Leveraged emerging industry trends to deliver innovative solutions, resulting in a 100% client satisfaction rate.",
      ],
    },
    {
      title: "Freelance",
      desc: "December 2019 - October 2020",
      role: "Full-Stack Developer, UI/UX Designer",
      info: [
        "Collaborated with cross-functional teams to integrate design concepts and backend functionality, reducing project timelines by 27%.",
        "Contributed to design systems and reusable components, increasing development efficiency by 2x.",
        "Built real-time stream overlay system for e-sports broadcasts.",
      ],
    },
    {
      title: "SalesGrowth Development Inc",
      desc: "December 2018 - December 2019",
      role: "Frontend Developer, UI/UX Designer",
      info: [
        "Optimized four client websites, improving SEO rankings by an average of 21%, accessibility scores by 42%, and load times by 22%.",
        "Led comprehensive redesign of the client application, resulting in a 65% increase in user adoption.",
        "Enhanced usability in existing client applications, leading to a 32% reduction in user-reported issues and a 28% increase in user satisfaction scores.",
      ],
    },
    {
      title: "Freelance",
      desc: "January 2016 - December 2018",
      role: "Freelance Graphic Designer",
      info: [
        "Collaborated with 23 clients to identify and execute optimal design solutions.",
        "Delivered tailored solutions for rebranding, packaging, and marketing materials, resulting in an average 45% increase in brand recognition for clients.",
      ],
    },
  ],
  projects: [],
  githubProjects,
  achievements: [
    "Winner of the 2019 McMaster Design League UI/UX Designathon",
    "Consistently received 5-star client ratings for freelance projects",
  ],
}

export const resume: Resume = {
  ...resumeData,
  get coreStack() {
    return this.skills.favorite.slice(0, 8)
  },
}
