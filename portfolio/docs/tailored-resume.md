# Tailored Resume — Usage

A static page at `/resume/tailor` that renders a job-tailored resume from JSON encoded into the URL hash. No backend, no auth — anyone with the URL sees what's in it. Page has `noindex,nofollow`.

## Flow

1. Build a JSON object matching the schema below.
2. URL-encode the JSON, append as `#data=` to `/resume/tailor`.
3. Open the URL in a headless browser, print to PDF.

## URL format

```
https://<site>/resume/tailor#data=<encodeURIComponent(JSON.stringify(resume))>
```

The hash is read client-side only — never sent to the server. No CDN logging.

## Schema

All fields are optional — anything you omit falls back to the default values from `src/data/resume.ts` (see [Defaults](#defaults)). Fields the renderer uses:

| Field                 | Type                              | Notes                                       |
| --------------------- | --------------------------------- | ------------------------------------------- |
| `name`                | `string`                          | Header name.                                |
| `seniority`           | `string`                          | Shown in subtitle line.                     |
| `yearsExperience`     | `string`                          | Shown in subtitle line.                     |
| `location`            | `string`                          | Contact line.                               |
| `email`               | `string`                          | Contact line, rendered as `mailto:` link.   |
| `linkedin`            | `string` (URL)                    | Contact line.                               |
| `portfolioUrl`        | `string` (URL)                    | Contact line.                               |
| `professionalSummary` | `string`                          | Single paragraph.                           |
| `skills.favorite`     | `string[]`                        | First 12 joined with `, ` under "Favorite Tools". |
| `experiences`         | `Array<{title, role, desc, info[]}>` | Renders as `{title} — {role} ({desc})`. `title` = company, `role` = job title, `desc` = duration (e.g. "September 2024 – Present"), `info` = bullets. |
| `achievements`        | `string[]`                        | Bullet list.                                |

Other fields from the full `Resume` interface (in `src/data/resume.ts`) are accepted but not rendered. Pass them or omit them — same result.

## Defaults

Any field omitted from the hash falls back to the default values in `src/data/resume.ts`. Send only the fields you want to override. Opening `/resume/tailor` with no hash at all renders the full default resume.

The merge is shallow at the top level — `skills`, `experiences`, and `achievements` are replaced wholesale when present in the hash, not deep-merged. To rewrite a single bullet inside an experience, send the entire `experiences` array.

## Minimal example

```json
{
  "name": "Theodore Zurek-Dunne",
  "seniority": "Senior",
  "yearsExperience": "9+ yrs",
  "location": "Toronto",
  "email": "you@example.com",
  "linkedin": "https://linkedin.com/in/handle",
  "portfolioUrl": "https://zurek-dunne.dev",
  "professionalSummary": "Senior engineer focused on Go/TypeScript backend performance, with a track record of cutting infra cost via service rewrites.",
  "skills": {
    "favorite": ["Go", "TypeScript", "PostgreSQL", "Docker", "React"]
  },
  "experiences": [
    {
      "title": "Acme",
      "role": "Lead Engineer",
      "desc": "January 2022 – Present",
      "info": [
        "Cut p99 latency 40% migrating Node services to Go.",
        "Owned the design system used by 12 frontend squads."
      ]
    }
  ],
  "achievements": [
    "Speaker at GopherCon 2024."
  ]
}
```

## Build the URL — JavaScript

```js
const data = { /* see example above */ };
const url = `https://zurek-dunne.dev/resume/tailor#data=${encodeURIComponent(JSON.stringify(data))}`;
```

## Build the URL — shell

```bash
DATA=$(cat tailored.json | jq -c .)
ENC=$(printf '%s' "$DATA" | jq -sRr @uri)
echo "https://zurek-dunne.dev/resume/tailor#data=${ENC}"
```

## Print to PDF — agent

Headless Chrome:

```bash
chrome --headless --disable-gpu --print-to-pdf=resume.pdf "<URL>"
```

Or Playwright:

```js
await page.goto(url, { waitUntil: 'networkidle' });
await page.pdf({ path: 'resume.pdf', format: 'Letter', printBackground: true });
```

## Fallback behavior

The page renders an instructional fallback (and logs to console) when:

- `data=` cannot be `JSON.parse`d.
- The parsed value is not an object.

A missing or empty hash is no longer an error — the page renders the full default resume.

## Limits

- Plain JSON in the URL hash. No compression. Browsers handle hashes well past 30 KB; if a real payload ever exceeds that, add `CompressionStream`-based gzip + base64url to both ends.
- The page does no schema validation beyond "is the parsed value an object". The agent producing the JSON is trusted.

## QA fixture

End-to-end fixture for verifying the round-trip — exercises `%`, `&`, `<`, `/`, `+`, `#`, `:`, `;`, `$`, `×`, `→`, en/em dashes, and nested arrays. Verified rendered DOM matches every input field exactly (run via `bun run dev` then load the URL with a fresh page load — hash-only navigations don't re-mount the Svelte island).

```json
{"name":"Ada Q. Lovelace-Test","professionalSummary":"Achieved 20% cost reduction & 35% throughput gain. Delivered <50ms p99 latency, A/B testing wins, and 100%-coverage tests.","seniority":"Senior Engineer","yearsExperience":"10+ yrs","location":"Berlin, DE — EU/UK","email":"qa+test@example.com","skills":{"favorite":["TypeScript","Go","Svelte","C#","F#","Node.js→Bun"]},"experiences":[{"title":"Acme Corp","role":"Staff Engineer","desc":"January 2022 – Present","info":["Led 5-person team delivering A/B testing framework w/ 99.9% uptime.","Rewrote billing service: 10× throughput, <100ms p95, $250k/yr saved.","Mentored 3 engineers; introduced TDD & RFC process."]},{"title":"Beta Labs","role":"Senior Engineer","desc":"March 2019 – December 2021","info":["Built C#/F# interop layer for legacy services.","Reduced bundle size by 35% via code-splitting & tree-shaking."]}]}
```

---

# Cover Letter — Usage

A static page at `/letter/tailor` that renders a cover letter from a list of paragraphs encoded into the URL hash. Sender contact info, today's date, "Dear Hiring Manager,", and the "Sincerely,"/signature lines are static — only the body paragraphs come from the hash.

## URL format

```
https://<site>/letter/tailor#data=<encodeURIComponent(JSON.stringify({ body: ["...", "..."] }))>
```

## Schema

| Field  | Type       | Notes                                                            |
| ------ | ---------- | ---------------------------------------------------------------- |
| `body` | `string[]` | Paragraphs, ≥1, required. Each is rendered as its own `<p>`.     |

Any other fields in the hash are ignored.

## Minimal example

```json
{
  "body": [
    "I'm writing to apply for the Senior Backend Engineer role at Acme. Your work on the data ingestion platform overlaps directly with what I spent the last two years building.",
    "Over nine years I've shipped Go and TypeScript services with strong reliability targets, including a Node→Go migration that cut p99 latency 40% and infra cost 20%. The numbers in your latest engineering blog suggest you're tackling similar problems at a different scale, and I'd like to help.",
    "I'd be glad to walk through specifics of the migration work, the design system I built, or anything else relevant. Thanks for your time."
  ]
}
```

## Build the URL — JavaScript

```js
const data = { body: ["Paragraph 1…", "Paragraph 2…"] };
const url = `https://zurek-dunne.dev/letter/tailor#data=${encodeURIComponent(JSON.stringify(data))}`;
```

## Build the URL — shell

```bash
DATA=$(cat letter.json | jq -c .)
ENC=$(printf '%s' "$DATA" | jq -sRr @uri)
echo "https://zurek-dunne.dev/letter/tailor#data=${ENC}"
```

## Print to PDF — agent

Same flow as the resume:

```bash
chrome --headless --disable-gpu --print-to-pdf=cover-letter.pdf "<URL>"
```

## Fallback behavior

The page renders an instructional fallback when:

- The hash is missing or has no `data=` param.
- `data=` cannot be `JSON.parse`d.
- The parsed value is not an object.
- `body` is missing, not an array, or empty.
- Any element in `body` is not a string.
