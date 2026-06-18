#!/usr/bin/env bash
set -euo pipefail

BELT_DIR="$(cd "$(dirname "$0")" && pwd)"
DOJO_ROOT="$(cd "$BELT_DIR/../.." && pwd)"
source "$DOJO_ROOT/scripts/dojo-lib.sh"

echo ""
echo "  🟢 Green Belt Check"
separator

WORKFLOW="$BELT_DIR/.github/workflows/matrix.yml"
ERRORS=0

info "Checking workflow structure..."

if grep -q '???' "$WORKFLOW"; then
  fail "There are still unfilled ??? placeholders in the workflow"
  ((ERRORS++))
fi

if grep -q 'fail-fast: false' "$WORKFLOW"; then
  pass "fail-fast is false"
else
  fail "fail-fast should be set to false"
  ((ERRORS++))
fi

if grep -q 'matrix.os' "$WORKFLOW"; then
  pass "matrix.os referenced"
else
  fail "Expected runs-on to use \${{ matrix.os }}"
  ((ERRORS++))
fi

if grep -q 'matrix.node' "$WORKFLOW"; then
  pass "matrix.node referenced in a step"
else
  fail "Expected a step to reference \${{ matrix.node }}"
  ((ERRORS++))
fi

if grep -q 'ubuntu-latest' "$WORKFLOW" && grep -q 'windows-latest' "$WORKFLOW"; then
  pass "Both os values defined"
else
  fail "Expected both ubuntu-latest and windows-latest in the matrix"
  ((ERRORS++))
fi

if grep -qE '18' "$WORKFLOW" && grep -qE '\b20\b' "$WORKFLOW"; then
  pass "Both node versions defined"
else
  fail "Expected node versions 18 and 20 in the matrix"
  ((ERRORS++))
fi

if grep -q 'LTS on Linux' "$WORKFLOW"; then
  pass "include label 'LTS on Linux' found"
else
  fail "Expected include to add label 'LTS on Linux'"
  ((ERRORS++))
fi

if grep -q "matrix.label" "$WORKFLOW"; then
  pass "matrix.label referenced"
else
  fail "Expected a conditional step using matrix.label"
  ((ERRORS++))
fi

if grep -q "if:" "$WORKFLOW"; then
  pass "Conditional if: found"
else
  fail "Expected an if: condition on the label step"
  ((ERRORS++))
fi

if [[ $ERRORS -gt 0 ]]; then
  echo ""
  warn "$ERRORS issue(s) found. Fix them and try again."
  tip  "Run './dojo hint green' if you need a nudge."
  echo ""
  exit 1
fi

echo ""
info "Running workflow with act (ubuntu-latest only — matrix is simulated)..."
info "Note: act runs one matrix combination at a time locally."
echo ""

# act struggles with cross-platform matrix; run ubuntu+18 and ubuntu+20 explicitly
cd "$BELT_DIR" && act push \
  --workflows ".github/workflows/matrix.yml" \
  --secret-file "$DOJO_ROOT/.env" \
  --matrix "os:ubuntu-latest" \
  2>&1 | tee /tmp/dojo-act-output.txt | grep -E '(Testing on|Special combo|LTS)' || true

ACT_OUTPUT=$(cat /tmp/dojo-act-output.txt)
ACT_EXIT=${PIPESTATUS[0]}

echo ""

if [[ $ACT_EXIT -ne 0 ]]; then
  fail "act reported errors."
  echo "$ACT_OUTPUT" | tail -20 | sed 's/^/  /'
  exit 1
fi

if echo "$ACT_OUTPUT" | grep -q "Testing on"; then
  pass "Matrix step printed OS/node info"
else
  fail "Didn't see 'Testing on ...' in the output"
  ((ERRORS++))
fi

if echo "$ACT_OUTPUT" | grep -q "LTS on Linux"; then
  pass "Include label 'LTS on Linux' printed for the correct combination"
else
  warn "Couldn't confirm 'LTS on Linux' — check output above manually"
fi

if [[ $ERRORS -gt 0 ]]; then
  warn "Close! Check the output above."
  exit 1
fi

award_belt "green"
