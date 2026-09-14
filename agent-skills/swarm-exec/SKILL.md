---
name: swarm-exec
description: "Executes an approved plan file by splitting it into decision-complete micro-plans dispatched to budget DeepSeek workers, then correcting cheaply via staged review. Explicit call only."
---

# Swarm Exec

- TLDR: Parent stays lean: slices an approved plan, dispatches parallel DeepSeek
  workers, reviews evidence not files, corrects with delta prompts.
- TLDR: Worker = `swarm-worker` agent (deepseek-v4-flash, pinned). The parent never
  does worker-priced work itself.
- TLDR: Each dispatch batch is one `tasks[]` array; corrections are staged: live
  steer while running, delta reissue after settlement, escalate after 2 failed rounds.
- Not for: planning itself (use plan mode), single-file mechanical edits,
  open-ended investigation.

## Protocol

1. **Input** — Caller provides an approved plan file path (`local://<slug>-plan.md`
   or repo path). If no path is given, or the plan contains open decisions or
   `unverified` markers on load-bearing facts, stop and surface them to the user;
   workers never invent decisions.
2. **Slice** — Decompose the plan into independent work slices. For each slice pin:
   exact files, contracts (interfaces it provides/consumes), ordering dependencies.
   Merge tightly-coupled slices rather than parallelizing a dependency chain; shared
   contracts go in the batch `context`, never repeated per task.
3. **Micro-plan per worker** — Each `task` contains exactly three sections:
   - `# Target` — files + symbols, explicit non-goals
   - `# Change` — ordered concrete edits, reusable symbols with paths
   - `# Acceptance` — the observable check the worker must run and report
   No fourth section; anything else belongs in batch `context`.
4. **Dispatch** — One `tasks[]` batch with `agent: "swarm-worker"` on every item
   (use `workpool` for open-ended item streams). Workers skip lint/format/full
   test suites; the parent owns those.
5. **Review (evidence-first)** — For each settled worker, verify with the cheapest
   ground truth, in this order: (a) the worker's reported Acceptance output,
   (b) `git diff --stat` plus a targeted `read` of changed hunks only,
   (c) the plan's own Verification commands. Never re-read whole files the worker
   already covered; never re-run worker suites.
6. **Correct (staged)** — On a flaw:
   - Worker still running → `hub send` one concise delta message: file + flaw +
     expected observable. Nothing else.
   - Settled → reissue ONE targeted `swarm-worker` task with a delta prompt only
     (flaw, exact location, expected behavior, the slice's original Acceptance).
     Never resend the whole plan.
   - Same slice fails 2 correction rounds → stop looping; surface to the user
     with what was tried and the observed failure.
7. **Close** — When all slices settle: run the plan's Verification section once,
   in full, as the parent. Yield a per-slice one-line summary:
   done / corrected / escalated.