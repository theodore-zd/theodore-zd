---
name: brainstorm
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

## Phase 0 — GROUND 

Before diverging, run **one bounded research pass** — read the relevant repo/docs or do a research  and pull reference information targeted search Trigger it when:

- the topic or domain is unfamiliar,
- prior art or feasibility genuinely matters,
- the user is brainstorming against a codebase/docs you haven't seen.

If none of those apply, **skip straight to IDEATE**

## Phase 1 — IDEATE (diverge)

Gathered initial information look for gaps and/or uncertainly, then **generate a large batch of questions to drill down**.

- The creative ideas surface only after the obvious ones are exhausted

## Phase 2 — EVALUATE (converge)

Based on information gathered look for gaps and/or uncertainly, then **generate a large batch of questions to drill down**.

## Phase 3 — IDEATE (diverge)

Restate the problem in one sentence to confirm shared understanding, then **generate a large batch of raw options — no filtering, no critique**.

- Produce 10–15 raw options, explicitly uncensored.
- Do NOT rank, trim, or shoot down ideas while generating — defer all judgment.
- If the batch stays obvious, notice it and push for wilder options before moving on.
- The creative ideas surface only after the obvious ones are exhausted — this phase must not be cut short.

## Phase 4 — EVALUATE (converge)

Based on information gathered look for gaps and/or uncertainly, then **generate a large batch of questions to drill down**.

## Phase 5 — DECIDE

Ask via `ask` which direction to pursue. Present the 2–5 as concrete options — name what changes, what it costs. If one is clearly best, say so and mark it recommended/default.

## Phase 6 — ITERATE (build & combine)

- **Combine** the chosen approach summarize you plan with a bullet point TLDR
- Offer to go deeper on one, and loop back to DECIDE if the user wants to explore further
- After the user picks a direction, Go deep OR Start building

---

## Guidelines

- If one approach is clearly best, say so and default it in the `ask`.

- Keep IDEATE and EVALUATE strictly separate — defer all judgment until Phase 2 begins.

  