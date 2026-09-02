---
name: brainstorm-old
description: 'Trigger phrases: "brainstorm", "ideate", "explore approaches", "think through this problem", "generate options", "what are some ways to".'
---

# Brainstorm

The user wants to explore approaches before committing.
Continue to ask follow-up questions until you have gathered enough context and generated options.

## Rules
- Always use interactive questions `ask`
- Do NOT jump to implementation.

## The shape: four phases

Research-backed principle: brainstorming is **divergent first, convergent after** — generating a large, uncensored batch is what surfaces the novel ideas, and judging while generating kills them. So the skill runs distinct phases, and generation and evaluation are NEVER blended.

**GROUND ✦ IDEATE ✦ EVALUATE ✦ DECIDE ✦ ITERATE**

## Phase 0 — GROUND (optional, only when it helps)

Before diverging, run **one bounded research pass** — read the relevant repo/docs or do a single targeted search — but only when it actually helps. Trigger it when:

- the topic or domain is unfamiliar,
- prior art or feasibility genuinely matters,
- the user is brainstorming against a codebase/docs you haven't seen.

If none of those apply, **skip straight to IDEATE** — don't let preparation crush the divergent phase. The batch is grounded, not exhaustive.

## Phase 1 — IDEATE (diverge)

Restate the problem in one sentence to confirm shared understanding, then **generate a large batch of raw options — no filtering, no critique**.

- Produce 10–15 raw options, explicitly uncensored.
- Do NOT rank, trim, or shoot down ideas while generating — defer all judgment.
- If the batch stays obvious, notice it and push for wilder options before moving on.
- The creative ideas surface only after the obvious ones are exhausted — this phase must not be cut short.

## Phase 2 — EVALUATE (converge)

Now judge — and only now. This must be a separate pass from Phase 1: never interleave "what if X" with "but X fails because…".

- **Cluster** similar raw options into themes.
- **Score the top clusters** against the restated goal and the obvious constraints.
- **Present the 2–5 strongest approaches**, each as a 1-line description plus a 1-line tradeoff.

## Phase 3 — DECIDE

Ask via `ask` which direction to pursue. Present the 2–5 as concrete options — name what changes, what it costs. If one is clearly best, say so and mark it recommended/default.

## Phase 4 — ITERATE (build & combine)

After the user picks a direction, don't stop at "ok." Build on it:

- **Combine** the chosen approach with other raw options from Phase 1 that were passed over — hybrids often beat any single original.
- Offer 2–3 stronger variants of the chosen direction.
- Offer to go deeper on one, and loop back to DECIDE if the user wants to explore further.

---

## Guidelines

- Prefer concrete options over vague: name what changes, what it costs.
- If one approach is clearly best, say so and default it in the `ask`.
- Keep IDEATE and EVALUATE strictly separate — defer all judgment until Phase 2 begins.
- Repeat phases as needed; each iteration sharpens the options.