# 🟡 Yellow Belt — Contexts & Expressions

> *"You can read the context. The workflow is starting to speak to you."*

---

## What you'll learn

- How to define environment variables at workflow, job, and step level
- How to use **contexts** — the built-in objects GitHub Actions passes into every run (`github`, `env`, `runner`)
- How to use **expressions** — the `${{ }}` syntax that evaluates values at runtime

---

## The Challenge

Open `.github/workflows/contexts.yml`.

Fill it in so the workflow:

1. Triggers on `push`
2. Defines a **workflow-level** environment variable called `DOJO_GREETING` with the value `Greetings from the Dojo`
3. Has a single job called `show-context` running on `ubuntu-latest`
4. Has these four steps:

   **Step 1 — Print the greeting**  
   Print the `DOJO_GREETING` env var using the `${{ env.DOJO_GREETING }}` expression in a `run:` command.

   **Step 2 — Who triggered this?**  
   Print the GitHub actor (the user who triggered the run) using `${{ github.actor }}`.

   **Step 3 — What branch are we on?**  
   Print the ref (branch) using `${{ github.ref }}`.

   **Step 4 — What runner are we on?**  
   Print the runner OS using `${{ runner.os }}`.

---

## Key concepts

### Environment variables

```yaml
env:                          # Workflow-level — available to all jobs
  MY_VAR: hello

jobs:
  my-job:
    env:                      # Job-level — available to all steps in this job
      JOB_VAR: world
    steps:
      - name: Step with its own var
        env:                  # Step-level — only this step
          STEP_VAR: "!"
        run: echo "$MY_VAR $JOB_VAR $STEP_VAR"
```

### Expressions and contexts

`${{ }}` is the expression syntax. Inside it you can reference:

| Context | Examples |
|---------|---------|
| `env`    | `${{ env.MY_VAR }}` |
| `github` | `${{ github.actor }}`, `${{ github.ref }}`, `${{ github.sha }}` |
| `runner` | `${{ runner.os }}`, `${{ runner.arch }}` |
| `secrets`| `${{ secrets.MY_SECRET }}` |
| `inputs` | `${{ inputs.my-input }}` (workflow_dispatch only) |

You can use expressions in `run:` commands, step `name:` fields, and most other places.

---

> 💡 **Hint:** If you're stuck, run `./dojo hint yellow` from the repo root.
