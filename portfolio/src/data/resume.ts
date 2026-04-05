// Type definitions for resume data
export interface Resume {
  name: string
  title: string
  tagline: string
  headline: string
  valueProps: string[]
  /** Computed alias for first 8 items of skills.favorite */
  readonly coreStack: string[]
  email: string
  phone?: string
  github: string
  linkedin: string
  resumeUrl: string
  professionalSummary: string
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
  awards: string[]
}

const resumeData = {
  name: "Theodore Zurek-Dunne",
  title: "Senior Software Engineer | TypeScript | Go | React/Next.js | Node.js",
  tagline:
    "Senior software engineer with 7+ years of experience delivering high-performance, scalable systems",
  headline:
    "Senior Software Engineer | TypeScript, Go, Python, React | Building scalable, high‑performance full‑stack applications with measurable business impact.",
  valueProps: [
    "Frontend: React, Next.js, TypeScript, Tailwind, Svelte",
    "Backend: Node.js, Python, Go, PostgreSQL, MongoDB",
    "DevOps: Docker, CI/CD, cloud deployment",
  ],
  email: "theodore.zd@example.com",
  phone: "+1 (555) 010-9876",
  github: "https://github.com/theodore-zd",
  linkedin: "https://www.linkedin.com/in/theodore-zurek-dunne-37885b164/",
  resumeUrl: "/Theodore_Zurek-Dunne_Resume-2025.pdf",
  professionalSummary: `Seasoned software engineer delivering fast, reliable, scalable full-stack solutions. Expert in TypeScript, Go, Python, and modern cloud architectures. I collaborate with cross-functional teams to translate complex requirements into high-quality software that drives business results and measurable impact.`,
  skills: {
    favorite: [
      "TypeScript",
      "Go",
      "Python",
      "JavaScript",
      "React",
      "Next.js",
      "Node.js",
      "Docker",
      "PostgreSQL",
      "MongoDB",
      "Git",
      "GraphQL",
      "REST APIs",
      "Design Systems",
      "CI/CD",
      "Cloud Infrastructure",
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
      "Npm",
      "SvelteKit",
      "Cypress",
      "HTTP/REST",
      "Full-Stack Development",
      "Frontend & Backend Development",
      "Design Systems",
      "Agile Methodologies",
      "SEO Optimization",
      "UI/UX Design",
      "Team Management",
      "Team Collaboration",
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
        "Ensured SOC 2 compliance, enhancing data security.",
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
      role: "Full-Stack Developer",
      info: [
        "Collaborated with cross-functional teams to integrate design concepts and backend functionality, reducing project timelines by 27%.",
        "Contributed to design systems and reusable components, increasing development efficiency by 2x.",
        "Built real-time stream overlay system for e-sports broadcasts.",
        "Delivered innovative solutions that exceeded client expectations, resulting in a 100% client retention rate.",
      ],
    },
    {
      title: "SalesGrowth Development Inc",
      desc: "December 2018 - December 2019",
      role: "Frontend Engineer, UI/UX Designer",
      info: [
        "Optimized four client websites, improving SEO rankings by an average of 21%, accessibility scores by 42%, and load times by 22%.",
        "Led comprehensive redesign of the client application, resulting in a 65% increase in user adoption.",
        "Enhanced usability in existing client applications, leading to a 32% reduction in user-reported issues and a 28% increase in user satisfaction scores.",
      ],
    },
    {
      title: "Freelance",
      desc: "January 2016 - December 2018",
      role: "Graphic Designer",
      info: [
        "Collaborated with 23 clients to identify and execute optimal design solutions.",
        "Delivered tailored solutions for rebranding, packaging, and marketing materials, resulting in an average 45% increase in brand recognition for clients.",
      ],
    },
    {
      title: "Senior Software Engineer",
      desc: "July 2024 - Present",
      role: "Lead Frontend & API Engineer",
      info: [
        "Architected and led frontend and API initiatives delivering scalable microservices and a 40% performance improvement.",
        "Mentored 4 engineers, improved release velocity by 25%, and elevated code quality and reliability.",
        "Implemented performance budgets, testing strategies, and accessible UI components.",
      ],
    },
  ],
  projects: [
    // {
    //   title: "Kato CMS",
    //   description:
    //     "Kato CMS is a custom content management system built on a microservice architecture operating as a headless facilitate additional functionality for my clients.",
    //   tools: ["Node.js", "React", "MongoDB", "Socket.io", "Express", "Docker"],
    //   live: "#",
    //   git: "#",
    // },
    // {
    //   title: "Simplified Web Scraper",
    //   description:
    //     "This is a simplified demo of a web scraper built to scrape business contact details from a business's website. This can be used to confirm or add to data collected from sites like HomeStars or Yellow Pages.",
    //   tools: ["Next.js", "Puppeteer", "TypeScript"],
    //   live: "#",
    //   git: "#",
    // },
    // {
    //   title: "Nexxt Construction",
    //   description:
    //     "Nexxt Construction is a single page website template built on Next.js, TypeScript & Tailwind made open source under the MIT license.",
    //   tools: ["Next.js", "TypeScript", "Tailwind"],
    //   live: "#",
    //   git: "#",
    // },
  ],
  awards: [
    "Winner of the 2019 McMaster Design League UI/UX Designathon",
    "Achieved 100% on-time project delivery rate across all roles",
    "Consistently received 5-star client ratings for freelance projects",
  ],
}

export const resume: Resume = {
  ...resumeData,
  get coreStack() {
    return this.skills.favorite.slice(0, 8)
  },
}
