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

export const githubProjects: GithubProject[] = [
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
