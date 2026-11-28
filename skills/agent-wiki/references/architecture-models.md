# Architecture models

Assess software architecture during discovery. Use arc42 as a selectable coverage checklist and C4 as a way to visualize boundaries and responsibilities. Select what the project and request need; do not require twelve files or a fixed diagram count. A concise paragraph and source links can be enough. The system model is the authority for shared domain vocabulary, rules, and intended behavior; link to it instead of redefining those concepts in architecture pages. Read [system model](system-model.md) for its scope and lifecycle.

| Concern | Questions and possible coverage |
| --- | --- |
| Goals and constraints | What must the system achieve, and what limits its design? |
| Context | Who and what interact with the system? A C4 system-context view may clarify the boundary. |
| Strategy and building blocks | What are the major approaches, applications, stores, and responsibilities? Consider a C4 container or selected component view. |
| Runtime | How do important synchronous and asynchronous interactions unfold? A sequence or dynamic view may help. |
| Deployment | Where does the system run, and what infrastructure does it require? Consider a deployment view. |
| Technical crosscutting concepts | Which implementation concerns span components, such as authentication or observability? Link to their authoritative homes. |
| Decisions, quality, and risks | What choices and consequences are recorded, which qualities matter, and what risks are evidenced? Link ADRs. |
| Vocabulary | Which terms need shared definitions? Link the canonical glossary in the [system model](system-model.md). |

For a flow crossing apps or services, make an end-to-end account discoverable in one place when useful, then link to focused app-specific details and authoritative source. Do not duplicate the whole flow per app. Organize per-app material when ownership, size, or reader needs warrant it.

Choose context and container diagrams when they clarify system boundaries; use component, dynamic, deployment, or other views only when they answer a useful question. Provide context and links to source alongside diagrams. Use Diátaxis to identify each page's reader need; architecture concerns can span purposes. Link decision records rather than reproducing them. Label unknowns and inferences; do not manufacture risks, quality requirements, or rationale.
