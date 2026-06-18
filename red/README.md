# 🔴 Red Belt — The Sensei Challenge

> *"There is nothing left to teach you. Go build something."*

---

This is the final test. There is no skeleton. There are no `# TODO` markers. There is no wrong answer — only incomplete ones.

---

## The Challenge

Design and build a **complete CI/CD pipeline** for a fictional Node.js application. The pipeline must satisfy all of the requirements below. How you structure it is up to you.

---

## Requirements

Your pipeline must include all of the following:

### 1. Triggers
- Runs on `push` to the `main` branch
- Runs on `pull_request` targeting `main`
- Can be triggered manually via `workflow_dispatch` with at least one input

### 2. Jobs & sequencing
- At least **three jobs** with a clear dependency chain (not all parallel)
- At least one job that **only runs on `push` to main** (not on PRs)

### 3. Matrix
- At least one job runs across a **matrix** of at least two Node.js versions

### 4. Reuse
- Extract at least one piece of logic into either:
  - A **composite action** (`.github/actions/`), or
  - A **reusable workflow** (triggered by `workflow_call`)

### 5. Artefacts
- At least one job produces an **uploaded artefact**
- At least one downstream job **downloads and uses** that artefact

### 6. Caching
- At least one job uses **`actions/cache`** to cache dependencies

### 7. Conditionals
- Use **`if:` conditions** on at least two steps or jobs with different conditions

### 8. Quality
- All jobs should have meaningful **names**
- Steps should be clearly named — no unnamed steps
- The workflow should be readable by someone who hasn't seen it before

---

## Suggested fictional app

You don't need a real app. Simulate the pipeline with `echo` commands. For example:

- "Install dependencies" → `npm ci` (or `echo "Installing..."`)
- "Run tests" → `echo "All tests passed"`
- "Build" → `echo "Built bundle.js" && mkdir -p dist && echo "bundle" > dist/bundle.js`
- "Deploy" → `echo "Deploying to production..."`

---

## Passing the check

Run:

```bash
./dojo attempt red
```

The check will inspect your workflow(s) structurally. It does **not** run `act` — at this level, you are trusted to have tested it yourself.

If you pass the structural check, you'll be asked a verbal question. Answer it in the terminal. Get it right, and the 🔴 Red Belt is yours.

---

## Files

Your pipeline should be in `.github/workflows/` within this belt directory. You can create as many workflow files as you need. Composite actions go in `.github/actions/`.

There is no solution directory for the Red Belt. This one is yours.

---

> *"A black belt is a white belt who never quit."*

Good luck, Sensei.
