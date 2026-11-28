# Wiki layout and migration

Use this guidance for scaffolding, reorganizing, or migrating a wiki. Organize by reader purpose, domain, or both; page purpose and navigable content matter more than directory names. Every wiki has a `system-model/` area; scale its contents to the project and read [system model](system-model.md) for its authority, lifecycle, and detailed structure. Do not create a separate `areas/` hierarchy by default or populate a fixed catalog of placeholders.

## Placement

| Reader need or information | Primary home | Example |
| --- | --- | --- |
| Mandatory agent rule | Applicable root or scoped harness instruction | Reuse approved frontend components. |
| Learn through an example | Tutorial | Trace a request and make a small change. |
| Complete a task | How-to | Add an endpoint or investigate a failure. |
| Look up facts or a contract | Reference | Configuration defaults or event payloads. |
| Understand behavior or rationale | Explanation | Why processing is asynchronous. |
| Define shared vocabulary, domain rules, or intended system behavior | System model | A game's progression rules or an app's task lifecycle. |
| Understand boundaries or interactions | Architecture | Browser → API → worker → provider. |
| Record a decision and consequences | ADR | Choose asynchronous processing. |
| Apply UI/UX standards | Design | Dialog behavior and its component source. |
| Track active work | Existing issue or spec tracker | A planned feature and acceptance criteria. |

These are defaults; honor useful established conventions. Cross-link related content and identify the authoritative rule, contract, or decision. A procedure can repeat a short critical constraint while linking its authoritative source. Source-derived summaries, maps, and invariants are worthwhile when they help readers enough to justify upkeep.

## Index and instruction routing

The wiki index should route readers to the system model, learning, tasks, reference, explanation, architecture, decisions, and design standards where present. Describe linked pages briefly and organize the index to fit its size. Link repository entry points and relevant root or scoped instruction files, explaining their scope without claiming that every harness discovers or prioritizes instructions the same way.

Include an authority map appropriate to the repository: for example, the system model for shared meaning and intended behavior, an API contract for an interface, migrations for schema history, source and tests for implemented behavior, design guidance for intended UI rules, token and component source for implemented values, and ADRs for recorded technical decisions. Flag discrepancies and link to active work where useful. Explain how to update the wiki as code, contracts, design, and decisions change.

Put concise instructions agents must obey in the applicable harness instruction file; link to longer procedures and shared standards. For a project wiki, those instructions should make wiki consultation and upkeep part of the normal workflow, and should point to the wiki index. When creating or maintaining a wiki, inspect the applicable root or scoped instruction files and add or revise this routing if it is missing or stale. Keep the index focused on navigation and the instruction file focused on the required workflow. Add a scoped file near code only when it contains meaningful local guidance and the harness supports its discovery. Avoid duplicating rules across instruction files and wiki pages.

## Example: mature multi-application repository

This fictional Harbor tree illustrates possibilities, not a required scaffold. Create or retain only useful, evidence-backed material; small projects may need only an index and a few pages. Existing projects may have different names and grouping.

```text
harbor/
├── AGENTS.md                       # Repository-wide instructions
├── apps/
│   ├── web/AGENTS.md               # Frontend rules, if useful and discoverable
│   ├── api/AGENTS.md               # API rules, if useful and discoverable
│   └── worker/
└── wiki/
    ├── README.md                   # Routing and authority map
    ├── tutorials/
    │   ├── first-change.md         # Learn the contribution flow
    │   └── trace-a-request.md      # Follow browser → API → database
    ├── how-to/
    │   ├── development/add-an-endpoint.md
    │   ├── operations/restore-a-backup.md
    │   └── investigation/failed-payment.md
    ├── reference/
    │   ├── api.md                  # Link canonical contract
    │   ├── configuration.md
    │   └── events-and-jobs.md
    ├── explanation/
    │   └── asynchronous-processing.md # Implementation rationale and trade-offs
    ├── system-model/
    │   ├── overview.md            # Shared meaning, scope, and current/intended behavior
    │   ├── glossary.md            # Canonical domain vocabulary
    │   ├── experiences/           # Useful user journeys or gameplay loops
    │   └── systems/               # Rules and interactions, split when useful
    ├── architecture/
    │   ├── context.md
    │   ├── building-blocks.md
    │   ├── runtime-views.md        # End-to-end cross-app flows
    │   ├── deployment.md
    │   └── diagrams/               # Selected useful views
    ├── adr/0001-asynchronous-payments.md
    └── design/                     # Conditional, evidence-backed UI/UX standards
        ├── README.md
        ├── principles.md
        ├── foundations/
        ├── components/
        ├── patterns/
        ├── accessibility.md
        └── contribution.md
```

For one payment feature, the system model defines the payment lifecycle and terms; a tutorial may teach tracing it, a how-to may diagnose a failure, reference may define job payloads, explanation may describe implementation trade-offs, architecture may show cross-application interactions, and an ADR may record a decision. Keep each fact or rule at one authoritative home and link related pages rather than copying definitions. Read [system model](system-model.md) for how to separate product/domain meaning from architecture and implementation evidence.

## Tutorials and how-tos

A tutorial identifies what the reader will learn, prerequisites, an example with explanations, and what to observe afterward. A how-to instead enables completion of a known task. Include its goal and scope, prerequisites, ordered actions, applicable invariants, decision points, and completion verification; explicitly state when a category does not apply. Identify stable file targets or give reliable instructions for finding variable targets, with selection criteria for branching choices.

Name a relevant check and its expected result, or describe a concrete manual check and its limits when automation is unavailable. Recovery and operational procedures may also need access prerequisites, rollback, escalation, or safety checks. Adapt steps to actual project conventions; never invent commands.

## Migration checklist

- Inventory existing content and classify it as keep, move, merge, rewrite, archive, or remove; investigate ambiguous or actively used content before changing it.
- Identify canonical sources, duplicates, established names, and inbound links. Preserve useful material and ADR history; do not make transient notes into permanent guidance without a reason.
- Update indexes, instruction files, internal links, and references to moved paths. Retain pointers or redirects where needed, and mark superseded pages rather than leaving competing authorities.
- Verify relative links and search for stale old paths. Remove unused placeholders created by the scaffold, not unassessed existing content. Report unresolved gaps and maintenance triggers.
