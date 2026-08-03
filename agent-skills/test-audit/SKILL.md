---
name: test-audit
description: 'Trigger phrases: "audit the tests", "are the tests validating correctly", "review test quality", "check if tests actually verify", "do the e2e tests catch bugs", "audit E2E test quality".'
---

# Test Audit

Run the full E2E suite, then audit every test file for construction quality.
This skill asks: **does this test actually verify the behavior it claims to,
or does it just exercise a code path without proving anything?**

## When to Use

Audit every E2E test file for construction quality: does each test actually verify the behavior it claims to, or does it just exercise a code path without proving anything?

## Step 1: Run the full suite

```bash
./scripts/test-e2e.sh
```

Collect pass/fail for every test. If the suite can't run (missing env,
provisioning failure), report it and stop — there's nothing to audit yet.

## Step 2: Audit each test file

For every `frontend/tests/**/*.spec.ts`, analyze the source (don't just
read the test names — read the assertions). Classify each test into one
of these categories:

### ✅ Sound
Test has a clear action and a meaningful assertion that proves the
behavior worked. Examples:
- `await tasks.createTask(title); await expect(page.getByText(title)).toBeVisible();`
- `await tasks.delete(); await expect(page.getByText(title)).toHaveCount(0);`
- `await expect(checkbox).toHaveAttribute('aria-pressed', 'true');`

### ⚠️ Weak
Test has an assertion, but it's too vague, non-specific, or doesn't
prove the claimed behavior. Examples:
- `await expect(page.locator('body')).not.toContainText('Error');`
  (verifies nothing crashed, but doesn't prove the feature worked)
- `await expect(page).toHaveURL(/\/tasks/);`
  (confirms navigation happened, but not that the action succeeded)
- Asserting only that a heading or section exists rather than the
  specific data that should have been created/modified.

### ❌ No-op
Test exercises a code path but has **no assertion at all**, or the
assertion is trivially always-true. Also flag tests that use
`waitForTimeout` as their only "verification" (sleeping is not testing).

**Red flags that indicate a no-op test:**
- No `expect()` call anywhere in the test body.
- Only `waitForTimeout` / `waitForLoadState` calls with no assertion after.
- Assertions commented out or behind a condition that never fires.
- Creating/uploading data, navigating, but never reading it back.

### 🔴 Broken
Test fails. Report the error, classify as test-issue vs app-bug
(following the same triage logic as the `e2e-triage` skill — check if
the failure is a stale selector/test bug or a real application problem).

## Step 3: Check test isolation

For each test file, verify:
- Tests don't depend on state left by previous tests (each test creates
  its own data with unique names).
- Cleanup or at least idempotent setup (unique names are acceptable;
  full cleanup is not required).

Flag tests that reuse hardcoded names across runs without unique
identifiers — these will collide in the test database over time.

## Step 4: Check assertions-per-action ratio

Count the number of distinct `expect()` calls per logical action:

| Action type | Minimum assertions |
|---|---|
| Create (task, doc, file) | 1: verify it appears in the list/page |
| Delete | 1: verify it's gone (toHaveCount(0) or not visible) |
| Update/rename | 1: verify the new value is reflected |
| Toggle/state change | 1: verify the new state (attribute, text, visibility) |
| Search/filter | 1: verify matching items appear AND/OR non-matching don't |

If a test creates data without verifying it, or modifies without
checking the result, flag it.

## Step 5: Report

Produce one report:

```
## E2E Test Audit

**Suite result:** X passed, Y failed, Z total

### Sound (✅) — N tests
- `file:line` — test name (brief note if non-obvious)

### Weak (⚠️) — N tests
- `file:line` — test name
  - Issue: <what's wrong>
  - Fix: <suggested improvement>

### No-op (❌) — N tests
- `file:line` — test name
  - Issue: <why it's a no-op>

### Broken (🔴) — N tests
- `file:line` — test name
  - Error: <error summary>
  - Classification: test-issue | app-bug
```

## Red Flags

**Never:**
- Skip reading test source — audit from the actual assertions, not test names.
- Classify a `waitForTimeout` as a valid assertion.
- Ignore tests that pass but have zero assertions — passing silently is worse
  than failing loudly.
- Report false positives — if a test looks weak but actually proves the
  behavior, defend your classification in the report.

**If unsure about a classification:**
- Default to Weak (⚠️) rather than Sound — better to flag and discuss
  than to approve a useless test.
