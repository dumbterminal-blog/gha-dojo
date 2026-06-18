# ⬛ Black Belt Hints

## Part 1: JavaScript Action

**Hint 1:** The `action.yml` `runs` section for a JS action looks like:
```yaml
runs:
  using: node20
  main: index.js
```

**Hint 2:** In `index.js`, get an input with `core.getInput('text', { required: true })`. Set an output with `core.setOutput('count', count)`. Note: `setOutput` takes a string or number — both work.

**Hint 3:** To handle empty input safely when counting words:
```javascript
const words = text.trim() === '' ? [] : text.trim().split(/\s+/);
const count = words.length;
```

**Hint 4:** Run `npm install` from inside `.github/actions/word-count/` before running the workflow — the action needs `node_modules` to exist locally for `act` to use it.

---

## Part 2: Caching

**Hint 5:** The cache key uses two expressions joined: `npm-${{ runner.os }}-${{ hashFiles('**/package-lock.json') }}`. The `restore-keys` is a fallback prefix and goes in a YAML block scalar:
```yaml
restore-keys: |
  npm-${{ runner.os }}-
```

---

## Part 3: Artefacts

**Hint 6:** `upload-artifact` and `download-artifact` both need a `name:` that matches exactly. The `path:` on upload is the file or directory to include.

**Hint 7:** After `download-artifact`, the file lands in the current working directory with its original filename. So `cat report.txt` should work directly.
