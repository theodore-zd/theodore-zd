export type SkillCategory = 'language' | 'framework' | 'platform' | 'tool' | 'practice'
export type SkillProficiency = 'expert' | 'comfortable' | 'exposure'
export type SkillTag = 'backend' | 'frontend' | 'full-stack' | 'data' | 'performance' | 'ops' | 'testing' | 'design'

export interface Skill {
  name: string
  category: SkillCategory
  proficiency: SkillProficiency
  tags?: SkillTag[]
}

export const allSkills: Skill[] = [
  // Languages
  { name: 'TypeScript', category: 'language', proficiency: 'expert', tags: ['backend', 'frontend', 'full-stack'] },
  { name: 'Go', category: 'language', proficiency: 'expert', tags: ['backend', 'performance'] },
  { name: 'JavaScript', category: 'language', proficiency: 'expert', tags: ['frontend', 'backend', 'full-stack'] },
  { name: 'Python', category: 'language', proficiency: 'comfortable', tags: ['backend', 'data'] },
  { name: 'HTML5', category: 'language', proficiency: 'expert', tags: ['frontend'] },
  { name: 'CSS3', category: 'language', proficiency: 'expert', tags: ['frontend', 'design'] },
  { name: 'SASS', category: 'language', proficiency: 'expert', tags: ['frontend', 'design'] },

  // Frameworks
  { name: 'React', category: 'framework', proficiency: 'expert', tags: ['frontend', 'full-stack'] },
  { name: 'Next.js', category: 'framework', proficiency: 'expert', tags: ['frontend', 'full-stack'] },
  { name: 'SvelteKit', category: 'framework', proficiency: 'expert', tags: ['frontend', 'full-stack'] },
  { name: 'Node.js', category: 'framework', proficiency: 'expert', tags: ['backend', 'full-stack'] },
  { name: 'Bun', category: 'framework', proficiency: 'expert', tags: ['backend'] },
  { name: 'Alpine.js', category: 'framework', proficiency: 'expert', tags: ['frontend'] },
  { name: 'Nest.js', category: 'framework', proficiency: 'comfortable', tags: ['backend'] },
  { name: 'Vue', category: 'framework', proficiency: 'comfortable', tags: ['frontend'] },
  { name: 'Socket.io', category: 'framework', proficiency: 'comfortable', tags: ['backend'] },

  // Platforms
  { name: 'PostgreSQL', category: 'platform', proficiency: 'expert', tags: ['backend', 'data'] },
  { name: 'MongoDB', category: 'platform', proficiency: 'comfortable', tags: ['backend', 'data'] },
  { name: 'Docker', category: 'platform', proficiency: 'expert', tags: ['backend', 'ops'] },
  { name: 'Netlify', category: 'platform', proficiency: 'expert', tags: ['frontend', 'ops'] },

  // Tools
  { name: 'Git', category: 'tool', proficiency: 'expert', tags: ['ops'] },
  { name: 'Npm', category: 'tool', proficiency: 'expert', tags: ['ops'] },
  { name: 'Pnpm', category: 'tool', proficiency: 'expert', tags: ['ops'] },
  { name: 'GraphQL', category: 'tool', proficiency: 'comfortable', tags: ['backend', 'full-stack'] },
  { name: 'HTTP/REST', category: 'tool', proficiency: 'expert', tags: ['backend', 'full-stack'] },
  { name: 'Playwright', category: 'tool', proficiency: 'expert', tags: ['frontend', 'testing'] },
  { name: 'Cypress', category: 'tool', proficiency: 'comfortable', tags: ['frontend', 'testing'] },

  // Practices
  { name: 'Design Systems', category: 'practice', proficiency: 'expert', tags: ['frontend', 'full-stack', 'design'] },
  { name: 'CI/CD', category: 'practice', proficiency: 'expert', tags: ['ops', 'backend'] },
  { name: 'SEO Optimization', category: 'practice', proficiency: 'comfortable', tags: ['frontend', 'full-stack'] },
  { name: 'UI/UX Design', category: 'practice', proficiency: 'expert', tags: ['frontend', 'design'] },
  { name: 'Agile Methodologies', category: 'practice', proficiency: 'expert', tags: [] },
  { name: 'Team Management', category: 'practice', proficiency: 'expert', tags: [] },
]

export function getSkillsByProficiency(level: SkillProficiency): string[] {
  return allSkills.filter((s) => s.proficiency === level).map((s) => s.name)
}

export function getSkillsByTag(tag: SkillTag): string[] {
  return allSkills.filter((s) => s.tags?.includes(tag)).map((s) => s.name)
}

export function getSkillsByCategory(category: SkillCategory): string[] {
  return allSkills.filter((s) => s.category === category).map((s) => s.name)
}

/** Default `favorite` list for the resume — expert-tier skills only, capped at 12 (matches Resume.svelte slice). */
export function getDefaultFavoriteSkills(): string[] {
  return getSkillsByProficiency('expert').slice(0, 12)
}

/** Default `toolbox` — everything not in `favorite`. */
export function getDefaultToolboxSkills(): string[] {
  const fav = new Set(getDefaultFavoriteSkills())
  return allSkills.map((s) => s.name).filter((n) => !fav.has(n))
}
