# 🔵 Blue Belt — Conditionals & Manual Dispatch

> *"Conditions and triggers are your weapons. Use them wisely."*

---

## What you'll learn

- The `workflow_dispatch` trigger — manually running a workflow from the GitHub UI (or `act`)
- Typed `inputs` for dispatch workflows
- `if:` conditions on jobs and steps
- The `contains()`, `==`, `!=` expression functions
- The special `github.event_name` context value

---

## The Challenge

Open `.github/workflows/dispatch.yml`.

Build a workflow with two triggers: `push` **and** `workflow_dispatch`.

The `workflow_dispatch` trigger should accept two inputs:

| Input | Type | Required | Default | Description |
|-------|------|----------|---------|-------------|
| `environment` | `choice` | yes | `staging` | choices: `staging`, `production` |
| `dry-run` | `boolean` | no | `true` | Skip actual deployment |

Then add these jobs:

### Job 1: `preflight`
Always runs. Has one step that prints how the workflow was triggered:
- If triggered by `push`: print `Triggered by a push event`
- If triggered by `workflow_dispatch`: print `Triggered manually`

Use `github.event_name` and an `if:` condition on each step (not each job).

### Job 2: `deploy`
- Only runs **if** the workflow was triggered by `workflow_dispatch`
- Depends on `preflight`
- Has a step that prints: `Deploying to: <environment input>`
- Has a second step that only runs if `dry-run` is **false**, printing: `🚀 REAL DEPLOYMENT`

---

## Key concepts

### workflow_dispatch with inputs

```yaml
on:
  workflow_dispatch:
    inputs:
      environment:
        type: choice
        options: [staging, production]
        default: staging
        required: true
      dry-run:
        type: boolean
        default: true
```

Access inputs with `${{ inputs.environment }}` and `${{ inputs.dry-run }}`.

### Conditional jobs

```yaml
jobs:
  my-job:
    if: github.event_name == 'workflow_dispatch'
```

### Conditional steps

```yaml
steps:
  - name: Only on push
    if: github.event_name == 'push'
    run: echo "push!"

  - name: Only when not dry run
    if: inputs.dry-run == false
    run: echo "real run!"
```

---

## Testing with act

To simulate a `workflow_dispatch` locally:

```bash
act workflow_dispatch \
  --input environment=production \
  --input dry-run=false
```

---

> 💡 **Hint:** Run `./dojo hint blue` if you get stuck.
