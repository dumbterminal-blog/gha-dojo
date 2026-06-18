# 🔵 Blue Belt Hints

**Hint 1:** Multiple triggers use a mapping under `on:`, not a list. Each trigger can have its own configuration block.

**Hint 2:** For `type: choice`, the options are a YAML list: `options: [staging, production]`.

**Hint 3:** `if:` conditions on steps and jobs can use bare expressions without `${{ }}`:
```yaml
if: github.event_name == 'push'
```
Or with the expression syntax: `if: ${{ github.event_name == 'push' }}`. Both work.

**Hint 4:** For the `deploy` job's `if:`, you're checking the event name the same way — just at job level instead of step level.

**Hint 5:** Checking a boolean input is slightly tricky. `inputs.dry-run` returns the string `"true"` or `"false"`, not a real boolean in all contexts. The most reliable check is:
```yaml
if: inputs.dry-run == false
```
Note: no quotes around `false` here.
