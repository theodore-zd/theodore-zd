---
name: e2e-triage
description: 'Trigger phrases: "run the e2e tests and find bugs", "triage e2e failures", "check the app for real bugs from the e2e suite", "investigate e2e failures", "are these test failures real bugs".'
---

# E2E Triage

Run the E2E suite, then for every failing test decide whether the failure
is a problem with the test/script itself or a genuine application bug. For
genuine bugs, reproduce the flow live in a browser, gather evidence, and
report a diagnosis with a suggested fix location. **Never edit code** — this
skill's job ends at diagnosis, not fixing.

## When to Use

Run the E2E suite, triage failures as test issues vs. real application bugs, and diagnose confirmed bugs live in a browser. Never fixes code — diagnosis only.

## Step 1: Run the full suite

Always run the full suite — never scope or filter it:

```bash
./scripts/test-e2e.sh
```

This script (see `scripts/test-e2e.sh`) auto-provisions the E2E test user
if needed and requires `E2E_EMAIL` / `E2E_PASSWORD` to be set (in `.env` or
the environment). It assumes Postgres/SeaweedFS/the Go API are already
running on `:3001` and the frontend dev server is reachable at
`PLAYWRIGHT_BASE_URL` (default `http://localhost:5173`) — do not start
these services yourself; ask the user if they're not running.

If the script exits before running any Playwright tests (e.g. missing
`E2E_EMAIL`/`E2E_PASSWORD`, provisioning failure, `bun install` failure),
that is an environment/setup problem, not an application bug — report it
plainly and stop; there is nothing to triage yet.

## Step 2: Collect failures

Playwright's HTML/list report and trace files are the source of truth for
what failed. For each failing test, gather:
- The test file and test name.
- The assertion/error message and stack trace.
- Any screenshot or trace artifact Playwright captured for that failure.

## Step 3: Triage each failure

Read the Playwright error/trace **first** — this is the primary signal for
classification, not a fallback used only when things are unclear.

Classify as a **test issue** (no browser investigation needed) when the
error points at the test itself, e.g.:
- A selector/locator not found because the component was renamed or
  restructured (check the page object in `frontend/tests/pages/` against
  the current component).
- A route or URL in the test that no longer matches the app.
- Fixture/expected data in the test that's simply stale.
- A flaky timing wait (arbitrary `waitForTimeout`, race condition in the
  test's own polling) rather than a real app delay.

Classify as an **app-bug candidate** when the error points at the
application behaving wrong, e.g.:
- The UI shows incorrect or missing data for a valid flow.
- A network request comes back with an unexpected 4xx/5xx.
- The DOM ends up in a broken/unexpected state that isn't explained by a
  stale selector (e.g. an error boundary, a blank page, a stuck loading
  spinner).
- Unexpected console errors during a flow that should succeed.

If the trace doesn't make the classification obvious, treat it as an
app-bug candidate — investigate rather than guess.

## Step 4: Investigate every app-bug candidate live

Do this for **all** app-bug candidates found in the run, not just the
first — a single E2E run can surface more than one real bug.

Drive the `browser` tool against `PLAYWRIGHT_BASE_URL` (default
`http://localhost:5173`) — same origin as the E2E suite, so page-object
patterns from `frontend/tests/pages/` and selectors from
`frontend/tests/support/selectors.ts` can be reused directly to navigate
to the same flow.

For each candidate:
1. Reproduce the failing flow manually (navigate, perform the same steps
   the test performed).
2. Capture evidence: console messages/errors, relevant network
   requests/responses, and a screenshot of the broken state.
3. Confirm the app is genuinely misbehaving (not just a one-off flake) —
   if it reproduces once and looks like a fluke, note that explicitly
   rather than asserting a confirmed bug.

## Step 5: Trace toward a fix location

Once a bug is confirmed, do a quick code trace to find the likely
responsible file — e.g. the Go handler in `internal/handlers/` returning
the bad response, or the Svelte component in `frontend/src/lib/components/`
rendering the broken state. This is a pointer for whoever fixes it, not an
implementation — **do not write or modify any code**.

## Step 6: Report

Produce one block per failing test:

- `test issue: <what in the test/script is wrong, and why>`
- `app bug: <repro steps> / <evidence: console/network/screenshot summary> / <suggested fix location: file:line or component name>`

If a candidate couldn't be confirmed as a real bug after investigation
(e.g. flaky, or on closer look it matches the "test issue" criteria),
reclassify it and say so rather than reporting a false positive.
