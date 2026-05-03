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

Only `name` is required. All other fields are optional; missing fields are skipped in the rendered page. Fields the renderer actually uses:

| Field                 | Type                              | Notes                                       |
| --------------------- | --------------------------------- | ------------------------------------------- |
| `name`                | `string` (**required**)           | Header name.                                |
| `seniority`           | `string`                          | Shown in subtitle line.                     |
| `yearsExperience`     | `string`                          | Shown in subtitle line.                     |
| `location`            | `string`                          | Contact line.                               |
| `email`               | `string`                          | Contact line, rendered as `mailto:` link.   |
| `linkedin`            | `string` (URL)                    | Contact line.                               |
| `portfolioUrl`        | `string` (URL)                    | Contact line.                               |
| `professionalSummary` | `string`                          | Single paragraph.                           |
| `skills.favorite`     | `string[]`                        | First 12 joined with `, ` under "Favorite Tools". |
| `experiences`         | `Array<{title, role, desc, info[]}>` | `info` is bullet list per experience.    |
| `achievements`        | `string[]`                        | Bullet list.                                |

Other fields from the full `Resume` interface (in `src/data/resume.ts`) are accepted but not rendered. Pass them or omit them — same result.

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
      "desc": "2022 – present",
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

- The hash is missing or has no `data=` param.
- `data=` cannot be `JSON.parse`d.
- The parsed value is not an object.
- The object is missing `name` or `name` is not a string.

## Limits

- Plain JSON in the URL hash. No compression. Browsers handle hashes well past 30 KB; if a real payload ever exceeds that, add `CompressionStream`-based gzip + base64url to both ends.
- The page does no schema validation beyond `name`. The agent producing the JSON is trusted.
