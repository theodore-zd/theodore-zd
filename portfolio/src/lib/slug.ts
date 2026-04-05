// Shared utility for generating URL-friendly slugs from titles
export const slugFromTitle = (title: string): string =>
  title
    .toLowerCase()
    .replace(/\s+/g, "-")
    .replace(/[^a-z0-9-]/g, "")
