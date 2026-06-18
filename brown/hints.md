# 🟤 Brown Belt Hints

## Part 1: Composite Action

**Hint 1:** A composite action lives in `.github/actions/<name>/action.yml`. The `runs:` section must say `using: composite`, and every step inside must have `shell: bash` (or another shell) — composite actions don't inherit a default shell.

**Hint 2:** The output's `value` references a step output using `${{ steps.<step-id>.outputs.<key> }}`. The step must have an `id:` for this to work.

**Hint 3:** When calling a composite action from within the same repo, use a relative path: `uses: ./.github/actions/greet-user`. Note the leading `./`.

**Hint 4:** To use the output of an action step in a later step, give the action step an `id:`, then reference `${{ steps.<id>.outputs.<output-name> }}`.

---

## Part 2: Reusable Workflow

**Hint 5:** The reusable workflow trigger is `workflow_call:` (not `workflow_dispatch:`). Inputs go under `workflow_call.inputs`, not at the top level.

**Hint 6:** A job that calls a reusable workflow uses `uses:` instead of `runs-on:` and `steps:`. You cannot mix them. The job looks like:
```yaml
my-job:
  uses: ./.github/workflows/reusable.yml
  with:
    my-input: value
```

**Hint 7:** String inputs passed via `with:` should be quoted: `node-version: '18'`.
