---
name: doc-interrogator
description: 'Trigger phrases: "interrogate the docs", "interrogate my documentation", "grill me about the docs", "docs interrogation", "are my docs any good", "is this doc accurate", "doc review", "tighten my docs", "make the docs concise", "review my documentation", "documentation review".'
---

# Doc Interrogator

- TLDR: adversarial, claim-by-claim interrogation of the user about their documentation. Every sentence is guilty until proven true, current, necessary, and clear; the user must defend it with evidence or it is cut. End state: the docs are rewritten to survive the interrogation — end-to-end, in the same run.
- TLDR: Stance: treat every doc line as a suspect statement by someone who did not check. "Trust me" is not evidence; the code, the config, and the reader's actual next action are. Claims that cannot be evidenced are deleted, never guessed.
- TLDR: Contract: read the target → interrogate in at most 3 batched rounds → verified truth table → rewrite → re-check the rewrite against the table → done.

## Not this skill
Code audits (`feral-audit`), UI/UX audits (`feral-ux-audit`, `design-audit`), and writing brand-new docs with nothing to challenge. If the doc does not exist yet, interrogate the user's outline and claims first, then write — same rules, but 2 rounds.

## Target
- User names a file or directory → that is the target, nothing else.
- Otherwise scan the repo: root `README*`, `docs/**`, `AGENTS.md`, `api.md`, and `*.md` at repo root depth 1. List the candidates in the round-1 question so the user can trim scope.
- If the user says "all documentation", expand to every `*.md` in the repo; still list them in round 1.

## Interrogation — 3 rounds max, each round is ONE batched `ask`
Round 1 — claim inventory. Read every target file fully. Extract every claim: facts, numbers, dates, examples, promised behaviors, "how to" steps. For each claim (all batched into one `ask`):
1. Source of truth — can the user name the code line, config value, live behavior, or user decision it comes from? No source → the claim is cut. "I don't know" also cuts it, unless the user says "verify it yourself" — then read the code/config and settle it yourself.
2. Simplicity tax — does any reader change their action because of this sentence? No → cut it.
3. Clarity — will a fresh reader without the repo open understand it? Jargon, implied steps, or mixed audiences → flag for rewrite.

Round 2 — pushback. Re-challenge only the vague answers ("it's fine", "basically works", "I think so"): demand the exact source. Probe contradictions between the doc and what you can actually read in the code/config. Concede only when the user names the concrete evidence, or you verify it yourself.

Round 3 — rewrite contract, only if needed. Confirm the deletions and merges the user resisted, and settle: who is the reader, what must survive, any length target. After round 3 the interrogation stops; no new challenges.

Room rules: never ask one question at a time — each round is one batched `ask`. Aggression is relentless inside the 3 rounds, then it ends.

## Verified truth table
For every claim, one row:

| Claim (verbatim quote) | Location | Verdict | Source of truth | Replacement text |

Verdicts: KEEP / CUT / REWRITE / MERGE (into another row). Traceability: every verdict traces to a user answer, or to your own read marked `verified: code` / `verified: config` / `verified: live`.

## Rewrite
Apply the table top to bottom; no deviations.
- KEEP rows: byte-identical text.
- CUT rows: removed; nothing takes their place.
- REWRITE rows: exactly the replacement text.
- One idea per sentence; active voice; plain words; a "how to" step starts with a verb.
- Numbers/config values only when they will not drift; otherwise point to "current values in <file>".
- One audience per doc; split at section level if it serves two.
- Do not touch formatting, voice, or KEEP rows — this skill targets content, not churn.

## Verify — always
1. Re-read the rewritten files. Every sentence maps to a truth-table row: REWRITE text matches the replacement text, nothing was invented, nothing beyond the table changed.
2. Fresh-read check on the largest rewrite: close the repo context and skim top-to-bottom; any sentence that needs the repo open to be true must carry its evidence inline or be cut.
3. Report per file: lines before → after, and counts of claims cut / rewritten / kept.

## Red flags — never
- One question at a time; rounds are always a batched `ask`.
- Inventing facts to fill a gap — cut the sentence.
- Accepting "trust me" / "it's fine" — round 2 demands the concrete source.
- A fourth round, or new challenges after round 3.
- Rewriting beyond the table (formatting churn, voice changes, touching KEEP rows).
- Leaving the user homework — the rewrite ships in the same run.
