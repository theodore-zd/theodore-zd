---
name: feral-ux-audit
description: 'Trigger phrases: "feral ux audit", "audit the ui", "audit the ux", "hunt for ux problems", "is this confusing", "usability review", "make this easier to use", "audit this screen", "audit this flow", "users cannot figure this out".'
---

# Feral UX Audit

- TLDR: Deep adversarial audit of the complete user experience of whatever it is pointed at — a screen, a component, a flow, a feature, a diff, or the whole app. Every screen is guilty until proven a stranger could use it.
- TLDR: Stance: assume the worst user — a real human, tired and hurried, who arrived with zero context, skimmed every label, clicked the first plausible thing, and will lose work if the UI lets them. The author is presumed a dumb child who designed for themselves: knew every button, never read their own copy, skipped the first run, and deleted the confirm dialog because it annoyed them.
- TLDR: Contract: judge everything against existing common UI/UX patterns — the conventions users already know from every other app. Familiar patterns are the gold standard; novelty must pay rent (a demonstrable understanding win) or it is a finding. Infer each screen's job-to-be-done from docs / routes / copy; if that fails, ask the user mid-audit with a batched `ask`.
- TLDR: Execution: orient → build the surface map (screens + journeys + states + boundaries) → dispatch one feral subagent per slice (journeys, screens, components) in parallel → merge into one severity-ranked report with a verdict per screen and per journey.

Not for: visual polish / making it prettier (`design-audit`), art direction and style (`frontend-design`), design tokens and brand systems (`design-system`), code-level correctness bugs (`feral-audit` — use it when the frontend actually misbehaves), implementing styles (`ui-styling`), or code stripping (`strip`).

## Stance — the feral UX rule

1. **Assume the worst user.** Not a hacker — a real human with no context, no
   time, and no patience. They skim instead of read, misread labels, click
   without reading dialogs, take silence as success, and blame themselves
   (and the product) when things go wrong. The dumb-child author built the UI
   for themselves: jargon everywhere, icon-only buttons, destructive controls
   next to harmless ones, empty screens that say nothing, errors that say
   "Something went wrong".
2. **Every screen is guilty until a stranger could use it.** "Looks fine" is
   not evidence. Evidence is a first-time-user scenario with a goal, the
   exact click-path, and no ambiguity at any step.
3. **Conventions are the law; novelty pays rent.** Users already know how the
   world works: nav on top or left, underlined links, buttons that do things,
   red for destructive, checkboxes tick, selects have options, X closes,
   trash deletes (after a confirm), Save saves. Reusing these patterns is
   free comprehension; inventing your own levies a learning tax on every user
   forever. Every deviation from a common pattern is a finding unless it
   demonstrably makes the task easier.
4. **UX bugs are proven, not asserted.** Every Critical and Important finding
   carries a concrete worst-user scenario: the user with goal G, at step N,
   loses / gets stuck / deletes data because… When you can run the app, verify
   by walking it (browser); when you cannot, trace the screen states in code
   and stamp the finding `evidence: static`. Suspicion without a scenario goes
   to the **Unproven** section. Preference-shopping ("I don't like this
   color") is not a UX finding — that lives in the design skills.
5. **Improvements are reasoned, with a simplicity tax.** "Add onboarding" must
   name the confusion it removes. Prefer the smallest change that closes the
   understanding gap: rename a button, reorder fields, add an empty state,
   show the error in the field it belongs to. Proposing a big system (tour,
   wizard, mascot) where a label fix suffices is itself a finding.

## Contract — what "easy to understand" means

1. Infer the job-to-be-done for each surface from local docs first (`docs/`,
   `api.md`, product README, `AGENTS.md`), then from routes and existing
   copy. A screen exists to let the user do a thing; the audit tests whether
   the screen makes that thing obvious.
2. Every screen must answer three questions within seconds, for a stranger:
   **Where am I? What can I do here? What happens next?** — plus, when
   something fails, **what happened and what do I do about it?**
3. Pattern conformance is judged against, in order:
   - common UI/UX conventions — Nielsen's ten usability heuristics
     (visibility of system status; match between system and the real world;
     user control and freedom; consistency and standards; error prevention;
     recognition rather than recall; flexibility and efficiency of use;
     aesthetic and minimalist design; help users recognize, diagnose, and
     recover from errors; help and documentation), plus Norman's signifiers
     and affordances;
   - platform conventions (web / OS / device);
   - the app's OWN established patterns — a second convention beside an
     existing one is a violation, even if each is fine in isolation.
4. Findings whose job-to-be-done was inferred are stamped `contract: inferred`.

## Dispatch

**1. Orient (main agent, not subagents).**
- Identify the target: screen / component / flow / feature / diff / whole app.
- Cheap grounding: frontend check (`bun run check` or equivalent), the route
  table, the app shell, design rules (`docs/design.md` when present), and the
  UI stack in use — the conventions to check against depend on it (plain
  HTML vs component library vs custom widgets).
- Decide `WALK_OK`: can a browser walk be run (dev server + browser tooling)?
  If not, the whole run is static state-trace evidence.

**2. Map the experience surface.**
- Enumerate every screen (route) and every user journey in scope from the
  route table and entry points — never an eyeball guess.
- Produce a **surface map**: each screen with its route, its primary action
  (the one job it exists to do), its states (loading / empty / error /
  success / disabled / offline / denied), and the journeys connecting the
  screens. Boundary: where the experience leaves the app (external links,
  auth-provider pages, third-party widgets) — those are graded "wired up
  correctly?", not re-audited.

**3. Slice per surface, dispatch in parallel.**
- One feral subagent per slice:
  - journeys (`skill://feral-ux-audit/journey-auditor.md`): end-to-end
    flows — first run, the core task, destructive action, failure &
    recovery, edge journeys (empty data, denied access, lost session, failed
    save);
  - screens (`skill://feral-ux-audit/screen-auditor.md`): per-screen
    understandability, hierarchy, naming, states, pattern conformance;
  - components (`skill://feral-ux-audit/component-auditor.md`): per
    interactive component — affordance, feedback, full state set,
    keyboard/ARIA, wording.
- Give each subagent its template, its exact surface slice, the boundaries,
  and the evidence rules (browser walk vs static trace).
- Slice boundaries MUST be explicit so no screen/journey/component is
  audited twice and none is skipped. Same for frontier: what each subagent
  may/should not touch.

**4. Assemble (main agent).**
- Merge the returned findings, drop cross-slice duplicates, link
  cross-cutting issues (a consistent mislabel across screens; a flow that
  dead-ends; the same invented widget in three places).
- Apply severity ranking, produce the report in the format below.

## UX battery — the worst user never survives this

Run every screen, journey, and component against each family:

- **First contact**: can a stranger on their first visit — no docs, no
  training — say what this is, what to do first, and what happens if they do
  it? Watch for: jargon and unexplained acronyms; icon-only buttons; blank
  screens where an empty state belongs ("No projects yet — create one");
  dead ends; no affordance for the first step; missing onboarding where the
  domain is genuinely unfamiliar.
- **Familiarity**: label/action mismatch (button says one thing, result is
  another); invented widgets where a standard one exists; actions that do
  not look like actions (unstyled links, non-button buttons); destructive
  actions that do not look destructive; gestures nobody knows; nav not where
  users look.
- **Feedback — visibility of system status**: every action gets a visible
  response in expected time, then success or failure. Silent failures (saved
  but never confirmed; deleted but still visible); no-op buttons; disabled
  buttons with no reason; forms that fail without naming the field; long
  operations with no progress; stale data after a save.
- **State coverage**: loading / empty / error / success / disabled /
  offline / denied / expired — every screen renders each state it can hit,
  and none of those states is blank, stuck, or lying.
- **Recovery & safety**: destructive actions confirm AND name the
  consequence ("Delete 12 documents" — not "Are you sure?") and are undoable
  where the domain allows; forms keep input when validation fails or
  navigation happens; error copy says what to do next, not "Error 500";
  back / escape / cancel / logout always reachable.
- **Cognitive load**: sensible defaults make the common case zero-typing; no
  walls of unlabeled choices; advanced options behind progressive
  disclosure; every field asks only what is needed; recognition over recall
  (no memorize-the-code workflows); repeated controls live in the same place
  on every screen.
- **Accessibility floor**: keyboard reachable, visible focus, readable
  contrast, every control has an accessible name (visible or aria), no
  color-only meaning, tap targets big enough. Table stakes for "easy to
  understand" — but a full a11y compliance audit is a different skill.
- **Consistency**: the same action uses the same control and the same words
  everywhere; terminology is uniform (a thing is never "folder" here and
  "bucket" there); the app reuses its own established patterns instead of
  re-inventing per screen.

## UX ledger

For every audited screen/journey/component (roll up per slice and per
report):

- primary action named with the user's verb and visually dominant?
- states rendered: loading / empty / error / success / disabled / offline / denied
- destructive paths: confirmed with consequence? undoable? recoverable?
- label vocabulary: user's words or system jargon?
- pattern used: standard (name it) or invented (rent paid?); in-app consistent?
- feedback: what tells the user the action worked?
- error copy: path forward, or opaque code?
- keyboard / ARIA: reachable, named, focus visible?

## Report format

```
## Feral UX Audit — {TARGET}

### Trigger / Scope
- target, user's ask, surface map summary (screens + journeys + boundaries + exclusions)

### UX Bugs — Proven
[slice] file:line — the confusion — worst-user scenario (goal, step, what happens) — impact — evidence (browser walk or static trace)

### Important — Confusing or Risky
[slice] file:line — why it matters, what users actually hit — one-sentence fix

### Minor — Friction & Simplicity
[slice] file:line — suggested change — simplicity tax (+X / -Y lines)

### Convention violations
[slice] file:line — the common pattern users expect vs what the app does — the fix

### Unproven candidates
[slice] file:line — the suspicion — why not (yet) proven

### Verdict
one line per screen AND per journey: "clear", "usable with friction", "a stranger would be lost" — plus one overall line.
```

## Red flags — never

- Run the audit without orientation or without a surface map.
- Dispatch per-slice auditors serially — parallel or not at all.
- Report a finding without a worst-user scenario (no user + goal =
  preference, not a finding).
- Judge by aesthetics ("I don't like the color") — that is `design-audit`
  territory; judge against conventions and understanding only.
- Treat novelty as neutral — every invented pattern must pay rent or be a
  finding.
- Let a subagent edit production code.
- Re-summarize subagent findings instead of integrating them verbatim.