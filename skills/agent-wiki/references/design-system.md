# Design system guidance

Assess whether UI/UX guidance is useful for every project. When a UI exists or is requested, inspect existing visual direction, tokens, components, examples, interaction conventions, responsive behavior, accessibility practices, and checks. Preserve and assess existing guidance before moving or removing it. Create or adapt the smallest useful design entry point, expanding only where evidence and reader needs support it; remove unused new scaffolding if no design content applies.

## From intent to implementation

- **Principles:** product design intent and trade-offs.
- **Foundations:** color, typography, spacing, layout, icons, and motion, linked to implemented tokens.
- **Components:** approved reusable elements, selection, variants, states, and behavior, linked to source and maintained examples.
- **Patterns:** interactions across components, such as forms and validation, navigation, loading/empty/error states, destructive actions, and responsive behavior.
- **Accessibility:** shared requirements and applicable component and pattern behavior, including keyboard and focus behavior.
- **Contribution:** how to introduce or change tokens, components, patterns, and examples; identify relevant checks and reviews.

Organize these as pages or sections according to project size. A destructive-action pattern, for example, can specify when confirmation is needed, consequence text, a safe default, keyboard and focus behavior, and the approved dialog, with links to its source and examples.

Keep user goals, journeys, domain rules, and intended system behavior in the canonical [system model](system-model.md). Design standards may link to those experiences to explain UI decisions, but should own only visual and interaction standards; do not copy domain rules into design pages.

## Authority and enforcement

Link mandatory agent behavior from applicable harness instructions to the design standards and scoped rules. Treat token and component source and maintained examples as evidence of implemented values; maintained design guidance describes intended visual and UX standards. Identify known gaps or proposals explicitly, especially where an existing UI has no agreed standards. Do not present inferred conventions as established decisions.

Name existing automated checks, lint rules, component APIs, accessibility tooling, or visual review mechanisms and what each actually verifies. Describe relevant manual comparison when appropriate. Do not claim a standard is enforced by tooling unless the tooling exists and covers it; do not invent commands or claim visual verification that did not happen.
