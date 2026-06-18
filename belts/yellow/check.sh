#!/usr/bin/env bash
set -euo pipefail

BELT_DIR="$(cd "$(dirname "$0")" && pwd)"
DOJO_ROOT="$(cd "$BELT_DIR/../.." && pwd)"
source "$DOJO_ROOT/scripts/dojo-lib.sh"

echo ""
echo "  🟡 Yellow Belt Check"
separator

WORKFLOW="$BELT_DIR/.github/workflows/contexts.yml"
ERRORS=0

info "Checking workflow structure..."

# Check DOJO_GREETING defined
if grep -q 'DOJO_GREETING' "$WORKFLOW" && ! grep -q 'DOJO_GREETING: ???' "$WORKFLOW"; then
  pass "DOJO_GREETING env var defined"
else
  fail "DOJO_GREETING environment variable not found (or still set to ???)"
  ((ERRORS++))
fi

# Check env context is used
if grep -q 'env.DOJO_GREETING' "$WORKFLOW"; then
  pass "env.DOJO_GREETING expression used"
else
  fail "Expected to see \${{ env.DOJO_GREETING }} used in a step"
  ((ERRORS++))
fi

# Check github.actor
if grep -q 'github.actor' "$WORKFLOW"; then
  pass "github.actor context used"
else
  fail "Expected to see \${{ github.actor }}"
  ((ERRORS++))
fi

# Check github.ref
if grep -q 'github.ref' "$WORKFLOW"; then
  pass "github.ref context used"
else
  fail "Expected to see \${{ github.ref }}"
  ((ERRORS++))
fi

# Check runner.os
if grep -q 'runner.os' "$WORKFLOW"; then
  pass "runner.os context used"
else
  fail "Expected to see \${{ runner.os }}"
  ((ERRORS++))
fi

# Check no leftover ???
if grep -q '???' "$WORKFLOW"; then
  fail "There are still unfilled ??? placeholders in the workflow"
  ((ERRORS++))
fi

if [[ $ERRORS -gt 0 ]]; then
  echo ""
  warn "$ERRORS issue(s) found. Fix them and try again."
  tip  "Run './dojo hint yellow' if you need a nudge."
  echo ""
  exit 1
fi

echo ""
info "Running workflow with act..."
echo ""

cd "$BELT_DIR" && act push \
  --workflows ".github/workflows/contexts.yml" \
  --secret-file "$DOJO_ROOT/.env" \
  2>&1 | tee /tmp/dojo-act-output.txt | grep -E '(\[|✅|❌|Greetings|Triggered|Running on ref|Runner OS)' || true

ACT_OUTPUT=$(cat /tmp/dojo-act-output.txt)
ACT_EXIT=${PIPESTATUS[0]}

echo ""

if [[ $ACT_EXIT -ne 0 ]]; then
  fail "act reported errors. Check the output above."
  exit 1
fi

if echo "$ACT_OUTPUT" | grep -q "Greetings from the Dojo"; then
  pass "DOJO_GREETING printed correctly"
else
  fail "Didn't see 'Greetings from the Dojo' in output"
  ((ERRORS++))
fi

if echo "$ACT_OUTPUT" | grep -qE "Runner OS: Linux"; then
  pass "runner.os resolved to Linux"
else
  warn "Couldn't confirm runner.os output — check manually"
fi

if [[ $ERRORS -gt 0 ]]; then
  warn "Close! Check the output above."
  exit 1
fi

award_belt "yellow"
