# 🟢 Green Belt Hints

**Hint 1:** Matrix dimensions are lists under `strategy.matrix:`. For a list use YAML array syntax: `os: [ubuntu-latest, windows-latest]`.

**Hint 2:** `fail-fast` goes at the same level as `matrix:`, directly under `strategy:`. Set it to `false` (no quotes).

**Hint 3:** `runs-on` can take an expression, not just a literal. `runs-on: ${{ matrix.os }}` is perfectly valid YAML.

**Hint 4:** `include` is a list under `matrix:`. Each item is a mapping of key-value pairs. Only the combinations that match all the listed keys will get the extra property — so if you specify `os: ubuntu-latest` and `node: 20`, only that specific combo gets `label`.

**Hint 5:** For the conditional step, the `if:` condition can compare against an empty string: `if: ${{ matrix.label != '' }}`. When `label` isn't defined by the include, it evaluates to an empty string.
