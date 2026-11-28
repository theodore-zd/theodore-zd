# System model

Every project wiki has a `system-model/` area. It gives people and agents a shared account of what the system means and is intended to do, whether the project is being brainstormed, designed, or already implemented. Scale the depth and number of pages to the system; do not create empty placeholders to fill a template.

## What belongs here

Describe the system independently of its software implementation:

- Purpose, boundaries, actors, and important contexts.
- Shared vocabulary, entities, relationships, states, events, and invariants.
- Domain rules and interactions between systems.
- Important user journeys, workflows, or gameplay loops.
- Intended behavior, including concepts that do not have code yet.

For a coded system, ground descriptions of current behavior in source, tests, interfaces, or observed behavior. Separate that evidence from intended changes and identify discrepancies. For a pre-code project, treat the model as design intent: preserve ideas and open questions without implying that they are implemented or settled.

## Suggested shape

Start with an overview that explains the system boundary and links to its canonical vocabulary and major models. Keep a glossary as a section in the overview until it merits a separate page; once separate, link it as the canonical definition source. Split out experience and system pages when they answer distinct questions or become difficult to navigate inline.

```text
wiki/system-model/
├── overview.md                 # Purpose, boundaries, map of the model, current state
├── glossary.md                 # Optional separate page for shared terms
├── experiences/                # User journeys, workflows, or gameplay loops
└── systems/                    # Rules, states, and interactions
```

These names are a useful starting point, not a required set of files. A small project may keep the complete model in `overview.md`; a large game or application may organize by domain or system. Prefer a small number of navigable pages with clear ownership over one page per feature.

## Record certainty and lifecycle

Make the status of uncertain or changing statements clear in the relevant page or section. Useful labels include **Exploring**, **Proposed**, **Decided**, **Implemented**, and **Retired**. These are descriptive states, not a required workflow or metadata schema.

- **Exploring:** possibilities and open questions; do not present as a commitment.
- **Proposed:** a coherent candidate behavior awaiting a decision.
- **Decided:** agreed system behavior, even if implementation has not started.
- **Implemented:** present behavior has been verified against the code or running system.
- **Retired:** historical model no longer in force; link to its replacement when one exists.

Keep active task breakdowns and delivery tracking in the repository's established planning or issue system. The system model records the meaning and intended behavior that work implements; it is not a duplicate task tracker. Record technical decisions in ADRs when the repository uses them, and link between the ADR and affected model pages.

## Keep one authority per kind of information

| Information | Authoritative home | Link from the system model when useful |
| --- | --- | --- |
| Meaning of domain terms | System-model glossary | Source code names and API schemas as implementation evidence |
| Domain rules and intended behavior | System-model pages | Relevant code, tests, and work items |
| Software components and deployment | Architecture pages | The model concepts each component realizes |
| Current API, event, or configuration contract | Reference page or machine-readable contract | The system behavior the contract supports |
| Rationale for an architectural choice | ADR or established decision record | Affected concepts and systems |
| UI and interaction standards | Design-system guidance | User journeys and domain constraints |
| Active tasks and acceptance tracking | Existing issue/spec tracker | The concept or behavior being changed |

Other pages may briefly summarize a rule when needed for context, but link to its canonical definition and do not maintain a second version. The wiki index routes to the model; it should not copy the model into the index.

## Examples

### Game in early design

```text
wiki/
├── README.md                    # Routes to model, planning, and decisions
├── system-model/
│   ├── overview.md              # User role, world boundary, design state
│   ├── glossary.md              # Turn, run, region, relic, and other defined terms
│   ├── experiences/
│   │   └── core-loop.md         # Explore → encounter → collect → prepare
│   └── systems/
│       ├── combat.md            # Actions, turns, damage, resolution
│       └── progression.md       # Unlocks, resources, and advancement rules
├── architecture/                # Added as technical structure becomes known
├── adr/                         # Recorded technical decisions, if useful
└── design/                      # UI/UX standards when the project needs them
```

Combat can be **Decided** while enemy scaling is still **Exploring**. Keep those states explicit on the page. A future implementation plan belongs in the planning system and links to the relevant combat or progression model.

### Existing application

```text
wiki/
├── README.md
├── system-model/
│   ├── overview.md              # Users, projects, resources, and shared boundaries
│   ├── glossary.md              # Project, member, task, document, reference
│   └── systems/
│       ├── membership.md        # Roles and access rules
│       └── document-links.md    # Link and backlink behavior
├── reference/                   # Actual routes, payloads, settings, and schema facts
├── explanation/                 # Why markdown is canonical; implementation trade-offs
├── architecture/                # Web/API/database responsibilities and runtime flows
└── adr/
```

The model states what membership means; the reference identifies how authorization is currently enforced; architecture shows which software parts participate. If code and a decided model disagree, document the mismatch and link active work rather than quietly changing either account.

## Link model changes to implementation

When behavior moves from concept to code, verify the implemented behavior, update its model status, and link the relevant implementation or reference page. Keep architecture pages focused on software boundaries and realization. When implementation changes without changing intended behavior, update evidence and implementation links without rewriting the model's domain rules. When the intended behavior changes, update the model and the relevant decision or work item, then identify affected references and architecture pages for follow-up.
