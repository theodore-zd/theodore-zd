---
name: agent-wiki
description: Scaffold, reorganize, or migrate a repository wiki for people and coding agents using an adapted Diátaxis model. Use for project wiki structure and knowledge workflows, not routine edits to a single document.
metadata:
  short-description: Scaffold and maintain project wikis
---

# Agent Wiki

Create a useful, maintainable project wiki for contributors and coding agents. Use [Diátaxis](https://diataxis.fr/) to distinguish reader needs; adapt the organization to the repository rather than imposing a fixed template. Every wiki includes a `system-model/` area that explains the system's vocabulary, domain, rules, and intended behavior; scale its detail to the project. For a new wiki use `wiki/`; preserve an established location and vocabulary unless the user directs otherwise.

Write concisely: include the detail readers need to understand or complete a task, remove filler and repeated explanations, and link to canonical guidance instead of copying it.

## Workflow

1. **Discover.** Inspect repository guidance, entry points, existing docs and indexes, domain vocabulary, decisions, relevant source, and the intended audiences. Identify canonical sources, existing conventions, applicable harness instruction discovery, and UI or design assets.
2. **Assess.** Establish the system model from the product or domain material and implementation evidence available. Identify actual learning, task, reference, explanation, architecture, decision, and design needs. Select useful pages and views supported by evidence. A curated model, map, invariant, contract, or explanation can earn its maintenance cost even if derivable from code.
3. **Create or migrate.** Create or maintain `wiki/system-model/` as the authority for shared vocabulary, domain concepts, rules, and intended behavior. Choose one primary reader need per page and route readers from an index to maintained content, instruction files, and authoritative sources. Ensure applicable root or scoped harness instructions tell contributors and agents when to consult the wiki and when changes should update it; add or revise those instructions when missing or stale. Keep these rules concise and link to the wiki for detail. Use nested files only when useful and supported by the harness. Preserve useful content, established conventions, and decision history. For moves, map destinations, update incoming and relative links, and retain pointers or redirects where needed; do not silently discard ambiguous material.
4. **Check.** Verify index entries, relative links, moved paths, claims, and instruction precedence. Resolve duplicate or conflicting guidance, remove unused newly created scaffold placeholders, and report unresolved gaps. Preserve existing material until assessed.
5. **Maintain.** Explain when changes to code, contracts, design, or decisions should prompt updates. Follow repository rules and do not commit unless requested and permitted.

## Reader needs

- **Tutorial:** teach through a guided example with prerequisites, explanations, and an observable learning outcome.
- **How-to:** provide an executable task contract: goal and scope, prerequisites, ordered actions, applicable invariants, decision points, and verification or completion criteria. Name relevant files or explain reliably how to locate them; identify the expected check outcome and any limits. State when a category does not apply. Link authoritative rules and repeat short task-critical constraints when useful.
- **Reference:** provide accurate facts, interfaces, commands, and contracts linked to their authoritative sources.
- **Explanation:** clarify concepts, behavior, rationale, and trade-offs using implementation evidence and decision links.

Architecture, ADRs, and design standards complement these purposes. Diátaxis is a page-purpose test, not a mandatory folder hierarchy. Give each page a clear primary purpose, but combine or split content when it improves navigation. Use concise, labeled sections for dense material. Do not invent facts, requirements, decisions, or enforcement; label proposals, unknowns, and inferences.

Use the system model for shared meaning and intended behavior; keep software architecture and current technical contracts in their respective pages. Follow the [system-model reference](references/system-model.md) for status labels and linking conventions.

## Guidance by task

- Read [wiki layout](references/wiki-layout.md) for placement, navigation, examples, instructions, and migration.
- Read [system model](references/system-model.md) when creating or maintaining the system-model area, including pre-code product or game concepts, shared vocabulary, and system rules.
- Read [architecture models](references/architecture-models.md) when assessing or documenting software architecture. Select arc42 concerns and C4 views that answer real questions, and link implementation views to the system model.
- Read [design system](references/design-system.md) when assessing UI/UX needs; assess whether each project needs such guidance, and use the reference when a UI exists or is requested. Create the smallest useful design entry point; remove unused new scaffolding when no design content applies.
