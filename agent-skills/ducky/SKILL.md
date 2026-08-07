---
name: ducky
description: 'Trigger phrases: "ducky", "flesh out", "turn this idea into a design", "make this concrete", "solidify the design", "design doc", "close the gaps", "design this".'
---

# Ducky

Turn a fuzzy idea or half-formed vision into a decision-complete, concise design doc. Pull every detail out of the user, close every gap against the codebase, and leave zero open design decisions. Complements brainstorm: brainstorm explores directions; this commits to one and makes it concrete.

## Process

1. **Elicit the vision.** Batch 3–6 `ask` questions covering: the goal in the user's words, who/what it is for, hard constraints and non-negotiables, scope edges (what it is NOT), and known edge cases. Ask everything in one `ask` call; never one question at a time.

2. **Research the codebase.** Ground every claim about the existing system: read AGENTS.md conventions, the files the design touches, and one similar existing feature as a pattern reference. For broad areas, dispatch parallel `scout` subagents — treat their output as discovery, not grounding: re-verify every claim you cite against the file yourself. Cite what you read in the doc's Context section.

3. **Draft the design doc** following the template below.

4. **Close the gaps.** Audit the draft: every ambiguous or unspecified point is either resolved from the codebase or settled with one final batched `ask`. No "TBD", no open questions. If the user has no answer, pick the conservative default, state it as an Assumption, and move on. Coverage checklist before moving on: every category from step 1 (goal, persona, constraints, scope edges, edge cases) is resolved as a decision, an ask, or a §7 entry — zero silent defaults. Decision-completeness includes seams: every file the design touches names its exact spec delta (a command change says which field changes, e.g. `list.maxArgs: 1 → 2`).

4.5 **Audit the grounding.** Before delivery, re-read every file the draft cites; cite **file + symbol**, never bare line numbers; strike any claim that cannot be re-derived in this session (no citations borrowed from prior sessions or subagent reports).

5. **Deliver.** Write the doc to `docs/ducky-plan/<slug>.md` (create the directory if missing), where `<slug>` is a kebab-case name derived from the idea. In chat, summarize the doc and list only the §7 *Override me* items (max 3).

## Design doc template

1. **Goal** — the vision restated in the user's words, one paragraph. This proves the doc represents their idea, not a substitute.
2. **Context** — what exists today and why this is needed (codebase claims grounded in files read).
3. **Requirements** — numbered, concrete, testable.
4. **Design** — the decisions: what changes and where (schema, API, UI, flows as relevant). Exact names and shapes for load-bearing symbols: fields, endpoints, components.
5. **Edge cases** — per new path: empty, missing, conflict, error handling — or state none needed and why.
6. **Verification** — how to prove it works: concrete input → expected observable output.
7. **Assumptions** — split into *Override me* (max 3: product-shaping decisions the user may want to change, surfaced in the delivery message) and *Defaults* (implementation-level defaults taken when the user had no preference). Not open questions.

## Rules

- The doc is the deliverable. Do NOT implement.
- Decision-complete output: zero open questions, no "TBD", nothing the reader must invent.
- Concise: as short as the doc can be while leaving zero decisions open.
- Grounded: every claim about the codebase comes from a file read this session by the drafting agent; re-verify on every revision (step 4.5).
- Batched questions only; prefer codebase answers over asking.
