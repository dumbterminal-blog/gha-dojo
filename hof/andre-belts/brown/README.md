# 🟤 Brown Belt — Reusable Workflows & Composite Actions

> *"You share what you build. The dojo grows stronger for it."*

---

## What you'll learn

- **Reusable workflows** — call one workflow from another with `workflow_call`
- **Composite actions** — bundle steps into a shareable action in the same repo
- The difference between the two approaches and when to use each

---

## The Challenge

This belt has **two parts**.

---

### Part 1: Composite Action

Create a composite action at `.github/actions/greet-user/action.yml`.

The action should:
- Accept one **input** called `username` (required, description: "The user to greet")
- Have one **output** called `message` (description: "The greeting message")
- Contain two steps:
  1. Build the greeting string `Hello, <username>! Welcome to the Dojo.` and write it to `$GITHUB_OUTPUT` as `message`
  2. Print the greeting using `echo`

Then open `.github/workflows/use-composite.yml` and call your action:
- Use `uses: ./.github/actions/greet-user` with input `username: Sensei`
- Print the action's `message` output in a subsequent step

---

### Part 2: Reusable Workflow

Create a reusable workflow at `.github/workflows/reusable-setup.yml`.

It should:
- Trigger on `workflow_call`
- Accept one input: `node-version` (type: string, default: `20`)
- Have one job called `setup` that prints: `Setting up Node ${{ inputs.node-version }}`

Then open `.github/workflows/use-reusable.yml` and call it:
- Use `uses: ./.github/workflows/reusable-setup.yml` with `node-version: 18`

---

## Key concepts

### Composite action structure

```
.github/
  actions/
    my-action/
      action.yml     ← the action definition
```

```yaml
# action.yml
name: My Action
description: Does a thing
inputs:
  username:
    description: Who to greet
    required: true
outputs:
  message:
    description: The result
    value: ${{ steps.build-message.outputs.message }}
runs:
  using: composite
  steps:
    - name: Build message
      id: build-message
      shell: bash
      run: echo "message=Hello ${{ inputs.username }}" >> $GITHUB_OUTPUT
```

### Calling a composite action

```yaml
steps:
  - name: Use it
    id: greeter
    uses: ./.github/actions/my-action
    with:
      username: Alice

  - name: Use its output
    run: echo "${{ steps.greeter.outputs.message }}"
```

### Reusable workflow

```yaml
# .github/workflows/reusable.yml
on:
  workflow_call:
    inputs:
      node-version:
        type: string
        default: '20'
```

### Calling a reusable workflow

```yaml
# caller.yml
jobs:
  call-setup:
    uses: ./.github/workflows/reusable.yml
    with:
      node-version: '18'
```

> ⚠️ A job that calls a reusable workflow **cannot** have `steps:` — it's either a `uses:` job or a `steps:` job, never both.

---

> 💡 **Hint:** Run `./dojo hint brown` if you get stuck.
