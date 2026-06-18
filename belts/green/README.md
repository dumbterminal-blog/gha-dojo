# 🟢 Green Belt — Matrix Builds

> *"You bend the matrix to your will. Parallel power unlocked."*

---

## What you'll learn

- How to run the same job across multiple configurations simultaneously
- The `strategy.matrix` key and how to define dimensions
- `fail-fast` — whether one failure should cancel the rest
- `matrix.include` — adding extra variables to specific combinations

---

## The Challenge

Open `.github/workflows/matrix.yml`.

Build a matrix workflow that:

1. Runs a job called `test` across **two dimensions simultaneously**:
   - `os`: `ubuntu-latest`, `windows-latest`
   - `node`: `18`, `20`
   - This creates **4 combinations** (2 × 2)

2. Sets `fail-fast: false` so that all combinations run even if one fails

3. Uses `runs-on: ${{ matrix.os }}` to run each combination on its own OS

4. Has a single step that prints:
   ```
   Testing on <os> with Node <node>
   ```
   using the matrix values

5. Uses `matrix.include` to add an extra variable `label` only to the `node: 20` + `ubuntu-latest` combination, with value `LTS on Linux`. Print it in a second step — but only if `matrix.label` is set (use an `if:` condition).

---

## Key concepts

### Basic matrix

```yaml
strategy:
  matrix:
    node: [16, 18, 20]
    os: [ubuntu-latest, macos-latest]
```

This runs 6 jobs (3 node × 2 os). Each job can access its values via `${{ matrix.node }}` and `${{ matrix.os }}`.

### fail-fast

```yaml
strategy:
  fail-fast: false   # default is true — set false to let all combinations finish
  matrix:
    node: [16, 18, 20]
```

### matrix.include

Adds extra properties (or extra combinations) to the matrix:

```yaml
strategy:
  matrix:
    node: [16, 18, 20]
    include:
      - node: 20
        label: "LTS"     # only added to node:20 combinations
```

### Conditional steps

```yaml
- name: Only sometimes
  if: ${{ matrix.label != '' }}
  run: echo "Label is ${{ matrix.label }}"
```

---

> 💡 **Hint:** Run `./dojo hint green` if you get stuck.
