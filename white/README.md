# 🤍 White Belt — Hello, Workflow

> *Every master was once a beginner.*

---

## What you'll learn

- What a GitHub Actions workflow file is and where it lives
- The three required top-level keys: `name`, `on`, `jobs`
- What a **job** is and what a **step** is
- How to run a simple shell command inside a workflow

---

## The Challenge

Open `.github/workflows/hello.yml` in this directory.

You'll see a skeleton with `# TODO` markers. Fill it in so that when you run it, the workflow:

1. Triggers on a `push` event
2. Has a single job called `greet`
3. Runs on `ubuntu-latest`
4. Has two steps:
   - Step 1: prints `Hello from the Actions Dojo!` using `echo`
   - Step 2: prints the current date using the `date` command

---

## Running your workflow

From inside this directory:

```bash
act push
```

Or use the dojo CLI from the repo root:

```bash
./dojo attempt white
```

---

## What to expect

A successful run will show both messages in the act output and award you the 🤍 White Belt.

---

## Key concepts

```yaml
name: My Workflow        # Display name (optional but good practice)

on: push                 # The trigger — when does this run?

jobs:
  my-job:                # Job ID (you choose the name)
    runs-on: ubuntu-latest   # The runner environment
    steps:
      - name: Say hello        # Step name (optional but helpful)
        run: echo "Hello!"     # The shell command to run
```

> 💡 **Hint:** If you're really stuck, run `./dojo hint white` from the repo root.
