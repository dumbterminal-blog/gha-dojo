#!/usr/bin/env bash
set -euo pipefail

BELT_DIR="$(cd "$(dirname "$0")" && pwd)"
DOJO_ROOT="$(cd "$BELT_DIR/../.." && pwd)"
source "$DOJO_ROOT/scripts/dojo-lib.sh"

echo ""
echo "  🟠 Orange Belt Check"
separator

WORKFLOW="$BELT_DIR/.github/workflows/pipeline.yml"
ERRORS=0

info "Checking workflow structure..."

# No leftover ???
if grep -q '???' "$WORKFLOW"; then
  fail "There are still unfilled ??? placeholders in the workflow"
  ((ERRORS++))
fi

# Check needs: on test job
if grep -A2 '^  test:' "$WORKFLOW" | grep -q 'needs:'; then
  pass "'test' job has a 'needs:' dependency"
else
  fail "'test' job should depend on 'build' via 'needs:'"
  ((ERRORS++))
fi

# Check needs: on report job
if grep -A2 '^  report:' "$WORKFLOW" | grep -q 'needs:'; then
  pass "'report' job has 'needs:' dependency"
else
  fail "'report' job should declare 'needs:' with both build and test"
  ((ERRORS++))
fi

# Check both jobs are listed in report's needs
if grep -A3 '^  report:' "$WORKFLOW" | grep -qE 'build.*test|test.*build|\[.*build.*\]|\[.*test.*\]'; then
  pass "'report' depends on both 'build' and 'test'"
else
  fail "'report' should list both 'build' and 'test' in its needs"
  ((ERRORS++))
fi

# Check GITHUB_OUTPUT usage
OUTPUT_COUNT=$(grep -c 'GITHUB_OUTPUT' "$WORKFLOW" || true)
if [[ $OUTPUT_COUNT -ge 2 ]]; then
  pass "GITHUB_OUTPUT used for outputs ($OUTPUT_COUNT times)"
else
  fail "Expected at least 2 uses of \$GITHUB_OUTPUT (one per producing job)"
  ((ERRORS++))
fi

# Check needs context reads
if grep -qE 'needs\.(build|test)\.outputs\.' "$WORKFLOW"; then
  pass "needs context used to read upstream outputs"
else
  fail "Expected to see needs.<job>.outputs.<name> in the report job"
  ((ERRORS++))
fi

if [[ $ERRORS -gt 0 ]]; then
  echo ""
  warn "$ERRORS issue(s) found. Fix them and try again."
  tip  "Run './dojo hint orange' if you need a nudge."
  echo ""
  exit 1
fi

echo ""
info "Running workflow with act..."
echo ""

cd "$BELT_DIR" && act push \
  --workflows ".github/workflows/pipeline.yml" \
  --secret-file "$DOJO_ROOT/.env" \
  2>&1 | tee /tmp/dojo-act-output.txt | grep -E '(\[|Built artifact|Test result|Building|Running tests)' || true

ACT_OUTPUT=$(cat /tmp/dojo-act-output.txt)
ACT_EXIT=${PIPESTATUS[0]}

echo ""

if [[ $ACT_EXIT -ne 0 ]]; then
  fail "act reported errors. Check the output above."
  exit 1
fi

if echo "$ACT_OUTPUT" | grep -q "Built artifact: my-app-v1.0"; then
  pass "Artifact name passed correctly from build → report"
else
  fail "Didn't see 'Built artifact: my-app-v1.0' in report job output"
  ((ERRORS++))
fi

if echo "$ACT_OUTPUT" | grep -q "Test result: passed"; then
  pass "Test result passed correctly from test → report"
else
  fail "Didn't see 'Test result: passed' in report job output"
  ((ERRORS++))
fi

if [[ $ERRORS -gt 0 ]]; then
  warn "Close! Check the output above."
  exit 1
fi

award_belt "orange"
