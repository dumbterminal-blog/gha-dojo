# ⬛ Black Belt — Custom Actions, Caching & Artefacts

> *"Custom actions, caching, artefacts. You have reached mastery."*

---

## What you'll learn

- Writing a **JavaScript action** from scratch
- Using `@actions/core` to read inputs, set outputs, and log
- **Caching** dependencies with `actions/cache`
- **Uploading and downloading artefacts** with `actions/upload-artifact` / `actions/download-artifact`

---

## The Challenge

This belt has **three parts** that combine into one pipeline workflow.

---

### Part 1: Write a JavaScript Action

Create a custom action at `.github/actions/word-count/`.

It should:
- Have an `action.yml` with:
  - Input: `text` (required) — the text to count words in
  - Output: `count` — the number of words
  - `runs.using: node20`
  - `runs.main: index.js`

- Have an `index.js` that:
  - Uses `@actions/core` to read the `text` input
  - Counts the words (split on whitespace)
  - Sets the `count` output using `core.setOutput`
  - Logs `Word count: <n>` using `core.info`

A `package.json` is already provided. Run `npm install` inside the action directory to install `@actions/core`.

---

### Part 2: Caching

Open `.github/workflows/black-belt.yml`.

Add a caching step **before** `npm install` in the `build` job:
- Use `actions/cache@v4`
- Cache the `~/.npm` directory
- Use a cache key of `npm-${{ runner.os }}-${{ hashFiles('**/package-lock.json') }}`
- Restore keys: `npm-${{ runner.os }}-`

---

### Part 3: Artefacts

In the `build` job, after running the word-count action:
- Write the word count result to a file: `report.txt` containing `Word count: <count>`
- Upload `report.txt` as an artefact called `word-count-report`

Add a second job `review` that:
- Depends on `build`
- Downloads the `word-count-report` artefact
- Prints the contents of `report.txt`

---

## Key concepts

### JavaScript action skeleton

```javascript
const core = require('@actions/core');

async function run() {
  const myInput = core.getInput('my-input', { required: true });
  core.setOutput('my-output', 'some-value');
  core.info('Hello from the action!');
}

run().catch(core.setFailed);
```

### Cache action

```yaml
- uses: actions/cache@v4
  with:
    path: ~/.npm
    key: npm-${{ runner.os }}-${{ hashFiles('**/package-lock.json') }}
    restore-keys: |
      npm-${{ runner.os }}-
```

### Upload artefact

```yaml
- uses: actions/upload-artifact@v4
  with:
    name: my-artefact
    path: report.txt
```

### Download artefact

```yaml
- uses: actions/download-artifact@v4
  with:
    name: my-artefact
```

---

> 💡 **Hint:** Run `./dojo hint black` if you get stuck.

## Act pipeline failure

run `act push` with the flag `--artifact-server-path /tmp/artifacts`

https://github.com/nektos/act/discussions/2231

This flag is not a part of github actions. It is a flag for tools that run workflows locally. When you run a workflow on GitHub's servers, artifact uploads are sent to GitHub's artifact service automatically. But when running locally, there is no GitHub artifact service available, so `act` can start a local artifact server.
