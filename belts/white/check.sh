#!/usr/bin/env bash
# White Belt check — validates the hello.yml workflow
set -euo pipefail

BELT_DIR="$(cd "$(dirname "$0")" && pwd)"
DOJO_ROOT="$(cd "$BELT_DIR/../.." && pwd)"
source "$DOJO_ROOT/scripts/dojo-lib.sh"

echo ""
echo "  🤍 White Belt Check"
separator

WORKFLOW="$BELT_DIR/.github/workflows/hello.yml"
ERRORS=0

# ── Static checks (before running act) ───────────────────────────────────────

info "Checking workflow structure..."

# Check the workflow has a name that isn't ???
if grep -q 'name: ???' "$WORKFLOW"; then
  fail "Workflow 'name' is still set to ???"
  ((ERRORS++))
else
  pass "Workflow has a name"
fi

# Check trigger
if grep -qE '^on:\s*(push|\[push\])' "$WORKFLOW"; then
  pass "Trigger is set to 'push'"
else
  fail "Trigger should be 'push' — check your 'on:' key"
  ((ERRORS++))
fi

# Check job name
if grep -q 'greet:' "$WORKFLOW"; then
  pass "Job named 'greet' found"
else
  fail "Expected a job named 'greet'"
  ((ERRORS++))
fi

# Check runs-on
if grep -q 'runs-on: ubuntu-latest' "$WORKFLOW"; then
  pass "runs-on is ubuntu-latest"
else
  fail "Job should run on ubuntu-latest"
  ((ERRORS++))
fi

# Check for the expected echo
if grep -q 'Hello from the Actions Dojo' "$WORKFLOW"; then
  pass "Greeting echo found"
else
  fail "Step 1 should echo 'Hello from the Actions Dojo!'"
  ((ERRORS++))
fi

# Check date command
if grep -q 'date' "$WORKFLOW"; then
  pass "Date command found"
else
  fail "Step 2 should run the 'date' command"
  ((ERRORS++))
fi

if [[ $ERRORS -gt 0 ]]; then
  echo ""
  warn "$ERRORS issue(s) found. Fix them and try again."
  tip  "Run './dojo hint white' if you need a nudge."
  echo ""
  exit 1
fi

# ── Dynamic check — actually run the workflow ─────────────────────────────────

echo ""
info "Running workflow with act..."
echo ""

if cd "$BELT_DIR" && act push \
    --workflows ".github/workflows/hello.yml" \
    --secret-file "$DOJO_ROOT/.env" \
    2>&1 | tee /tmp/dojo-act-output.txt | grep -E '(Run |✅|❌|\[.*\].*Hello|date)'; then
  ACT_EXIT=0
else
  ACT_EXIT=${PIPESTATUS[0]}
fi

ACT_OUTPUT=$(cat /tmp/dojo-act-output.txt)

echo ""

if [[ $ACT_EXIT -ne 0 ]]; then
  fail "act reported workflow errors. See output above."
  echo ""
  echo "$ACT_OUTPUT" | tail -20 | sed 's/^/  /'
  exit 1
fi

if echo "$ACT_OUTPUT" | grep -q "Hello from the Actions Dojo"; then
  pass "Greeting printed successfully"
else
  fail "Didn't see 'Hello from the Actions Dojo!' in the output"
  ((ERRORS++))
fi

if [[ $ERRORS -gt 0 ]]; then
  warn "Almost there — check the output above."
  exit 1
fi

# ── Award the belt ────────────────────────────────────────────────────────────

award_belt "white"
