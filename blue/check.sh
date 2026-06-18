#!/usr/bin/env bash
set -euo pipefail

BELT_DIR="$(cd "$(dirname "$0")" && pwd)"
DOJO_ROOT="$(cd "$BELT_DIR/../.." && pwd)"
source "$DOJO_ROOT/scripts/dojo-lib.sh"

echo ""
echo "  🔵 Blue Belt Check"
separator

WORKFLOW="$BELT_DIR/.github/workflows/dispatch.yml"
ERRORS=0

info "Checking workflow structure..."

if grep -q '???' "$WORKFLOW"; then
  fail "There are still unfilled ??? placeholders in the workflow"
  ((ERRORS++))
fi

if grep -q 'workflow_dispatch:' "$WORKFLOW"; then
  pass "workflow_dispatch trigger found"
else
  fail "Expected workflow_dispatch trigger"
  ((ERRORS++))
fi

if grep -q 'type: choice' "$WORKFLOW"; then
  pass "environment input is type choice"
else
  fail "environment input should be type: choice"
  ((ERRORS++))
fi

if grep -q 'staging' "$WORKFLOW" && grep -q 'production' "$WORKFLOW"; then
  pass "choice options include staging and production"
else
  fail "Expected staging and production as choice options"
  ((ERRORS++))
fi

if grep -q 'type: boolean' "$WORKFLOW"; then
  pass "dry-run input is type boolean"
else
  fail "dry-run input should be type: boolean"
  ((ERRORS++))
fi

if grep -q "github.event_name" "$WORKFLOW"; then
  pass "github.event_name used in conditions"
else
  fail "Expected if: conditions using github.event_name"
  ((ERRORS++))
fi

if grep -qE "if:.*event_name.*==.*'push'|if:.*event_name == 'push'" "$WORKFLOW"; then
  pass "push condition found"
else
  fail "Expected an if: condition checking for push event"
  ((ERRORS++))
fi

if grep -qE "if:.*event_name.*workflow_dispatch|if:.*workflow_dispatch" "$WORKFLOW"; then
  pass "workflow_dispatch condition found"
else
  fail "Expected if: conditions checking for workflow_dispatch"
  ((ERRORS++))
fi

if grep -qE "inputs.dry-run|inputs\['dry-run'\]" "$WORKFLOW"; then
  pass "dry-run input referenced"
else
  fail "Expected inputs.dry-run to be used in a condition"
  ((ERRORS++))
fi

if grep -q 'inputs.environment' "$WORKFLOW"; then
  pass "environment input referenced"
else
  fail "Expected inputs.environment to be referenced in a step"
  ((ERRORS++))
fi

if [[ $ERRORS -gt 0 ]]; then
  echo ""
  warn "$ERRORS issue(s) found. Fix them and try again."
  tip  "Run './dojo hint blue' if you need a nudge."
  echo ""
  exit 1
fi

echo ""
info "Test 1: Simulating a push event..."
echo ""

cd "$BELT_DIR" && act push \
  --workflows ".github/workflows/dispatch.yml" \
  --secret-file "$DOJO_ROOT/.env" \
  2>&1 | tee /tmp/dojo-act-output-push.txt | grep -E '(Triggered|Deploying|REAL)' || true

PUSH_OUTPUT=$(cat /tmp/dojo-act-output-push.txt)

echo ""
info "Test 2: Simulating a workflow_dispatch (production, dry-run=false)..."
echo ""

cd "$BELT_DIR" && act workflow_dispatch \
  --workflows ".github/workflows/dispatch.yml" \
  --secret-file "$DOJO_ROOT/.env" \
  --input environment=production \
  --input dry-run=false \
  2>&1 | tee /tmp/dojo-act-output-dispatch.txt | grep -E '(Triggered|Deploying|REAL)' || true

DISPATCH_OUTPUT=$(cat /tmp/dojo-act-output-dispatch.txt)
echo ""

if echo "$PUSH_OUTPUT" | grep -q "Triggered by a push event"; then
  pass "Push trigger message printed on push event"
else
  fail "Expected 'Triggered by a push event' on push"
  ((ERRORS++))
fi

if echo "$DISPATCH_OUTPUT" | grep -q "Triggered manually"; then
  pass "Manual trigger message printed on workflow_dispatch"
else
  fail "Expected 'Triggered manually' on workflow_dispatch"
  ((ERRORS++))
fi

if echo "$DISPATCH_OUTPUT" | grep -q "Deploying to: production"; then
  pass "Deploying to production shown"
else
  fail "Expected 'Deploying to: production' in dispatch output"
  ((ERRORS++))
fi

if echo "$DISPATCH_OUTPUT" | grep -q "REAL DEPLOYMENT"; then
  pass "REAL DEPLOYMENT step ran (dry-run=false)"
else
  fail "Expected '🚀 REAL DEPLOYMENT' when dry-run=false"
  ((ERRORS++))
fi

if [[ $ERRORS -gt 0 ]]; then
  warn "Close! Check the output above."
  exit 1
fi

award_belt "blue"
