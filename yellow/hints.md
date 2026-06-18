# 🟡 Yellow Belt Hints

**Hint 1:** Environment variables at workflow level go under a top-level `env:` key, at the same indentation level as `on:` and `jobs:`.

**Hint 2:** The expression syntax is always `${{ expression }}`. To access an env var, it's `${{ env.VARIABLE_NAME }}`.

**Hint 3:** The `github` context has many useful properties. The user who triggered the run is `github.actor`. The full ref (like `refs/heads/main`) is `github.ref`.

**Hint 4:** The `runner` context describes the machine running the job. The OS is `runner.os` — it returns `Linux`, `Windows`, or `macOS`.

**Hint 5:** You can use expressions inside `run:` commands like this:
```yaml
run: echo "Hello ${{ github.actor }}"
```
The expression is evaluated before the shell command runs.
