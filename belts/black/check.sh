#!/usr/bin/env bash
set -euo pipefail

BELT_DIR="$(cd "$(dirname "$0")" && pwd)"
DOJO_ROOT="$(cd "$BELT_DIR/../.." && pwd)"
source "$DOJO_ROOT/scripts/dojo-lib.sh"

echo ""
echo "  ⬛ Black Belt Check"
separator

ERRORS=0

ACTION_YML="$BELT_DIR/.github/actions/word-count/action.yml"
INDEX_JS="$BELT_DIR/.github/actions/word-count/index.js"
WORKFLOW="$BELT_DIR/.github/workflows/black-belt.yml"

info "Part 1: Checking custom JavaScript action..."

for f in "$ACTION_YML" "$INDEX_JS" "$WORKFLOW"; do
  if grep -q '???' "$f"; then
    fail "Unfilled ??? placeholders in $(basename $f)"
    ((ERRORS++))
  fi
done

if grep -q 'using: node20' "$ACTION_YML"; then
  pass "action.yml uses node20 runner"
else
  fail "action.yml should have 'using: node20'"
  ((ERRORS++))
fi

if grep -q 'main: index.js' "$ACTION_YML"; then
  pass "action.yml points to index.js"
else
  fail "action.yml should have 'main: index.js'"
  ((ERRORS++))
fi

if grep -q "getInput" "$INDEX_JS"; then
  pass "index.js uses core.getInput"
else
  fail "index.js should call core.getInput to read the text input"
  ((ERRORS++))
fi

if grep -q "setOutput" "$INDEX_JS"; then
  pass "index.js uses core.setOutput"
else
  fail "index.js should call core.setOutput with the word count"
  ((ERRORS++))
fi

if grep -q "core.info" "$INDEX_JS"; then
  pass "index.js uses core.info for logging"
else
  fail "index.js should log with core.info"
  ((ERRORS++))
fi

if [[ ! -f "$BELT_DIR/.github/actions/word-count/node_modules/@actions/core/package.json" ]]; then
  warn "node_modules not found — running npm install in the action directory..."
  (cd "$BELT_DIR/.github/actions/word-count" && npm install --silent) \
    && pass "npm install succeeded" \
    || { fail "npm install failed"; ((ERRORS++)); }
else
  pass "@actions/core is installed"
fi

echo ""
info "Part 2 & 3: Checking workflow (cache + artefacts)..."

if grep -q 'actions/cache' "$WORKFLOW"; then
  pass "actions/cache used"
else
  fail "Expected actions/cache@v4 in the build job"
  ((ERRORS++))
fi

if grep -q '~/.npm' "$WORKFLOW"; then
  pass "~/.npm cache path set"
else
  fail "Cache path should be ~/.npm"
  ((ERRORS++))
fi

if grep -q 'hashFiles' "$WORKFLOW"; then
  pass "hashFiles used in cache key"
else
  fail "Cache key should use hashFiles('**/package-lock.json')"
  ((ERRORS++))
fi

if grep -q 'actions/upload-artifact' "$WORKFLOW"; then
  pass "actions/upload-artifact used"
else
  fail "Expected actions/upload-artifact@v4 in build job"
  ((ERRORS++))
fi

if grep -q 'word-count-report' "$WORKFLOW"; then
  pass "artefact named 'word-count-report'"
else
  fail "Artefact should be named 'word-count-report'"
  ((ERRORS++))
fi

if grep -q 'actions/download-artifact' "$WORKFLOW"; then
  pass "actions/download-artifact used in review job"
else
  fail "Expected actions/download-artifact@v4 in review job"
  ((ERRORS++))
fi

if grep -q 'cat report.txt' "$WORKFLOW"; then
  pass "report.txt printed in review job"
else
  fail "Expected 'cat report.txt' in the review job"
  ((ERRORS++))
fi

if grep -q 'word-count-action\|word-count' "$WORKFLOW" && grep -q 'steps\.' "$WORKFLOW"; then
  pass "word-count action called and output referenced"
else
  fail "Expected word-count action to be called and its output used"
  ((ERRORS++))
fi

if [[ $ERRORS -gt 0 ]]; then
  echo ""
  warn "$ERRORS issue(s) found. Fix them and try again."
  tip  "Run './dojo hint black' if you need a nudge."
  echo ""
  exit 1
fi

echo ""
info "Running the full pipeline with act..."
echo ""

cd "$BELT_DIR" && act push --artifact-server-path /tmp/artifacts \
  --workflows ".github/workflows/black-belt.yml" \
  --secret-file "$DOJO_ROOT/.env" \
  2>&1 | tee /tmp/dojo-act-black.txt | grep -E '(Word count|Cache|Artifact|report|✅|❌)' || true

ACT_OUTPUT=$(cat /tmp/dojo-act-black.txt)
ACT_EXIT=${PIPESTATUS[0]}

echo ""

if [[ $ACT_EXIT -ne 0 ]]; then
  fail "act reported errors."
  echo "$ACT_OUTPUT" | tail -30 | sed 's/^/  /'
  exit 1
fi

# The test sentence "The quick brown fox jumps over the lazy dog" = 9 words
if echo "$ACT_OUTPUT" | grep -qE "Word count: 9"; then
  pass "Word count correctly computed as 9"
else
  warn "Couldn't confirm word count of 9 — check output above"
fi

if echo "$ACT_OUTPUT" | grep -q "Word count"; then
  pass "Report printed in review job"
else
  fail "Didn't see report output in review job"
  ((ERRORS++))
fi

if [[ $ERRORS -gt 0 ]]; then
  warn "Close! Check the output above."
  exit 1
fi

award_belt "black"
