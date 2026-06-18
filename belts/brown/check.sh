#!/usr/bin/env bash
set -euo pipefail

BELT_DIR="$(cd "$(dirname "$0")" && pwd)"
DOJO_ROOT="$(cd "$BELT_DIR/../.." && pwd)"
source "$DOJO_ROOT/scripts/dojo-lib.sh"

echo ""
echo "  🟤 Brown Belt Check"
separator

ERRORS=0

ACTION="$BELT_DIR/.github/actions/greet-user/action.yml"
COMPOSITE_WF="$BELT_DIR/.github/workflows/use-composite.yml"
REUSABLE_WF="$BELT_DIR/.github/workflows/reusable-setup.yml"
CALLER_WF="$BELT_DIR/.github/workflows/use-reusable.yml"

info "Part 1: Checking composite action..."

for f in "$ACTION" "$COMPOSITE_WF"; do
  if grep -q '???' "$f"; then
    fail "Unfilled ??? placeholders in $(basename $f)"
    ((ERRORS++))
  fi
done

if grep -q 'using: composite' "$ACTION"; then
  pass "Action uses composite runner"
else
  fail "action.yml should have 'using: composite'"
  ((ERRORS++))
fi

if grep -q 'username' "$ACTION"; then
  pass "username input defined in action"
else
  fail "Expected an input called 'username' in action.yml"
  ((ERRORS++))
fi

if grep -q 'message' "$ACTION"; then
  pass "message output defined in action"
else
  fail "Expected an output called 'message' in action.yml"
  ((ERRORS++))
fi

if grep -q 'GITHUB_OUTPUT' "$ACTION"; then
  pass "GITHUB_OUTPUT used in action"
else
  fail "Action should write to \$GITHUB_OUTPUT"
  ((ERRORS++))
fi

if grep -q 'Welcome to the Dojo' "$ACTION"; then
  pass "Greeting text found in action"
else
  fail "Expected greeting to include 'Welcome to the Dojo'"
  ((ERRORS++))
fi

if grep -q '.github/actions/greet-user' "$COMPOSITE_WF"; then
  pass "Composite action called correctly in use-composite.yml"
else
  fail "use-composite.yml should call ./.github/actions/greet-user"
  ((ERRORS++))
fi

if grep -q 'Sensei' "$COMPOSITE_WF"; then
  pass "username: Sensei passed to action"
else
  fail "Expected 'username: Sensei' in use-composite.yml"
  ((ERRORS++))
fi

echo ""
info "Part 2: Checking reusable workflow..."

for f in "$REUSABLE_WF" "$CALLER_WF"; do
  if grep -q '???' "$f"; then
    fail "Unfilled ??? placeholders in $(basename $f)"
    ((ERRORS++))
  fi
done

if grep -q 'workflow_call' "$REUSABLE_WF"; then
  pass "reusable-setup.yml uses workflow_call trigger"
else
  fail "reusable-setup.yml should trigger on workflow_call"
  ((ERRORS++))
fi

if grep -q 'node-version' "$REUSABLE_WF"; then
  pass "node-version input defined in reusable workflow"
else
  fail "Expected a node-version input in reusable-setup.yml"
  ((ERRORS++))
fi

if grep -q 'inputs.node-version' "$REUSABLE_WF"; then
  pass "node-version input used in a step"
else
  fail "Expected inputs.node-version to be used in a step"
  ((ERRORS++))
fi

if grep -q 'reusable-setup.yml' "$CALLER_WF"; then
  pass "Caller references reusable-setup.yml"
else
  fail "use-reusable.yml should call ./.github/workflows/reusable-setup.yml"
  ((ERRORS++))
fi

if grep -q "'18'" "$CALLER_WF" || grep -q '"18"' "$CALLER_WF"; then
  pass "node-version: 18 passed to reusable workflow"
else
  fail "Expected node-version: '18' in use-reusable.yml"
  ((ERRORS++))
fi

# Ensure no steps: in caller job
if grep -q 'steps:' "$CALLER_WF"; then
  fail "Caller job should not have steps: — reusable workflow jobs use 'uses:' only"
  ((ERRORS++))
else
  pass "Caller job has no steps: (correct for reusable workflows)"
fi

if [[ $ERRORS -gt 0 ]]; then
  echo ""
  warn "$ERRORS issue(s) found. Fix them and try again."
  tip  "Run './dojo hint brown' if you need a nudge."
  echo ""
  exit 1
fi

echo ""
info "Running Part 1: composite action workflow..."
echo ""

cd "$BELT_DIR" && act push \
  --workflows ".github/workflows/use-composite.yml" \
  --secret-file "$DOJO_ROOT/.env" \
  2>&1 | tee /tmp/dojo-act-composite.txt | grep -E '(Sensei|Welcome|Action said|Hello)' || true

COMPOSITE_OUTPUT=$(cat /tmp/dojo-act-composite.txt)
ACT_EXIT=${PIPESTATUS[0]}

echo ""

if [[ $ACT_EXIT -ne 0 ]]; then
  fail "act reported errors on composite workflow."
  echo "$COMPOSITE_OUTPUT" | tail -20 | sed 's/^/  /'
  exit 1
fi

if echo "$COMPOSITE_OUTPUT" | grep -q "Welcome to the Dojo"; then
  pass "Composite action ran and printed greeting"
else
  fail "Didn't see 'Welcome to the Dojo' in the composite action output"
  ((ERRORS++))
fi

if echo "$COMPOSITE_OUTPUT" | grep -q "Sensei"; then
  pass "Username 'Sensei' passed through correctly"
else
  fail "Didn't see 'Sensei' in the output"
  ((ERRORS++))
fi

echo ""
info "Running Part 2: reusable workflow caller..."
echo ""

cd "$BELT_DIR" && act push \
  --workflows ".github/workflows/use-reusable.yml" \
  --secret-file "$DOJO_ROOT/.env" \
  2>&1 | tee /tmp/dojo-act-reusable.txt | grep -E '(Setting up Node|18)' || true

REUSABLE_OUTPUT=$(cat /tmp/dojo-act-reusable.txt)
ACT_EXIT=${PIPESTATUS[0]}

echo ""

if [[ $ACT_EXIT -ne 0 ]]; then
  fail "act reported errors on reusable workflow."
  echo "$REUSABLE_OUTPUT" | tail -20 | sed 's/^/  /'
  exit 1
fi

if echo "$REUSABLE_OUTPUT" | grep -q "Setting up Node 18"; then
  pass "Reusable workflow received node-version: 18"
else
  fail "Didn't see 'Setting up Node 18' in output"
  ((ERRORS++))
fi

if [[ $ERRORS -gt 0 ]]; then
  warn "Close! Check the output above."
  exit 1
fi

award_belt "brown"
