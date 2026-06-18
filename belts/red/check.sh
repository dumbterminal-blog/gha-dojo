#!/usr/bin/env bash
set -euo pipefail

BELT_DIR="$(cd "$(dirname "$0")" && pwd)"
DOJO_ROOT="$(cd "$BELT_DIR/../.." && pwd)"
source "$DOJO_ROOT/scripts/dojo-lib.sh"

echo ""
echo "  🔴 Red Belt — Sensei Challenge"
separator

WORKFLOWS_DIR="$BELT_DIR/.github/workflows"
ERRORS=0
WARNINGS=0

# Find all workflow files (exclude .gitkeep)
WORKFLOW_FILES=()
while IFS= read -r -d '' f; do
  [[ "$f" == *".gitkeep" ]] && continue
  WORKFLOW_FILES+=("$f")
done < <(find "$WORKFLOWS_DIR" -name "*.yml" -o -name "*.yaml" | tr '\n' '\0')

if [[ ${#WORKFLOW_FILES[@]} -eq 0 ]]; then
  fail "No workflow files found in .github/workflows/"
  info "Create your pipeline there and try again."
  exit 1
fi

info "Found ${#WORKFLOW_FILES[@]} workflow file(s): $(basename -a "${WORKFLOW_FILES[@]}" | tr '\n' ' ')"
echo ""

ALL_CONTENT=""
for f in "${WORKFLOW_FILES[@]}"; do
  ALL_CONTENT+=$'\n'
  ALL_CONTENT+=$(cat "$f")
done

# ── Requirement 1: Triggers ────────────────────────────────────────────────

info "Checking triggers..."

if echo "$ALL_CONTENT" | grep -q 'push:'; then
  pass "push trigger found"
else
  fail "Need a push trigger"
  ((ERRORS++))
fi

if echo "$ALL_CONTENT" | grep -q 'pull_request'; then
  pass "pull_request trigger found"
else
  fail "Need a pull_request trigger"
  ((ERRORS++))
fi

if echo "$ALL_CONTENT" | grep -q 'workflow_dispatch'; then
  pass "workflow_dispatch trigger found"
else
  fail "Need a workflow_dispatch trigger with at least one input"
  ((ERRORS++))
fi

if echo "$ALL_CONTENT" | grep -qA5 'workflow_dispatch' | grep -q 'inputs:'; then
  pass "workflow_dispatch has inputs"
else
  warn "workflow_dispatch should define at least one input"
  ((WARNINGS++))
fi

# ── Requirement 2: Jobs & sequencing ─────────────────────────────────────

echo ""
info "Checking jobs & sequencing..."

JOB_COUNT=$(echo "$ALL_CONTENT" | grep -cE '^\s{2}[a-z_-]+:$' || true)
if [[ $JOB_COUNT -ge 3 ]]; then
  pass "At least 3 jobs found (counted ~$JOB_COUNT)"
else
  fail "Need at least 3 jobs"
  ((ERRORS++))
fi

if echo "$ALL_CONTENT" | grep -q 'needs:'; then
  pass "Job dependencies (needs:) found"
else
  fail "Jobs should have dependencies — use 'needs:'"
  ((ERRORS++))
fi

# At least one job conditional on push to main
if echo "$ALL_CONTENT" | grep -qE "github.ref.*main|github.event_name.*push|refs/heads/main"; then
  pass "At least one condition limiting a job to push/main"
else
  fail "At least one job should only run on push to main (not PRs)"
  ((ERRORS++))
fi

# ── Requirement 3: Matrix ─────────────────────────────────────────────────

echo ""
info "Checking matrix..."

if echo "$ALL_CONTENT" | grep -q 'strategy:' && echo "$ALL_CONTENT" | grep -q 'matrix:'; then
  pass "Matrix strategy found"
else
  fail "Need a matrix strategy on at least one job"
  ((ERRORS++))
fi

NODE_VERSIONS=$(echo "$ALL_CONTENT" | grep -oE '\b(16|18|20|22)\b' | sort -u | wc -l)
if [[ $NODE_VERSIONS -ge 2 ]]; then
  pass "Matrix includes at least 2 Node.js versions"
else
  fail "Matrix should include at least 2 Node.js versions"
  ((ERRORS++))
fi

# ── Requirement 4: Reuse ─────────────────────────────────────────────────

echo ""
info "Checking reuse..."

HAS_COMPOSITE=$(find "$BELT_DIR/.github/actions" -name "action.yml" 2>/dev/null | wc -l)
HAS_REUSABLE=$(echo "$ALL_CONTENT" | grep -c 'workflow_call' || true)

if [[ $HAS_COMPOSITE -ge 1 ]] || [[ $HAS_REUSABLE -ge 1 ]]; then
  pass "Reusable component found (composite action or reusable workflow)"
else
  fail "Need at least one composite action or reusable workflow"
  ((ERRORS++))
fi

# ── Requirement 5: Artefacts ─────────────────────────────────────────────

echo ""
info "Checking artefacts..."

if echo "$ALL_CONTENT" | grep -q 'upload-artifact'; then
  pass "upload-artifact found"
else
  fail "Need to upload at least one artefact"
  ((ERRORS++))
fi

if echo "$ALL_CONTENT" | grep -q 'download-artifact'; then
  pass "download-artifact found"
else
  fail "Need to download and use the artefact in a downstream job"
  ((ERRORS++))
fi

# ── Requirement 6: Caching ───────────────────────────────────────────────

echo ""
info "Checking caching..."

if echo "$ALL_CONTENT" | grep -q 'actions/cache'; then
  pass "actions/cache used"
else
  fail "Need to cache dependencies with actions/cache"
  ((ERRORS++))
fi

# ── Requirement 7: Conditionals ──────────────────────────────────────────

echo ""
info "Checking conditionals..."

IF_COUNT=$(echo "$ALL_CONTENT" | grep -c '^\s*if:' || true)
if [[ $IF_COUNT -ge 2 ]]; then
  pass "At least 2 conditional if: expressions found"
else
  fail "Need at least 2 if: conditions (on jobs or steps)"
  ((ERRORS++))
fi

# ── Requirement 8: Quality ────────────────────────────────────────────────

echo ""
info "Checking quality..."

UNNAMED_STEPS=$(echo "$ALL_CONTENT" | grep -cE '^\s*- (run|uses):' || true)
NAMED_STEPS=$(echo "$ALL_CONTENT" | grep -cE '^\s*- name:' || true)

if [[ $NAMED_STEPS -ge $UNNAMED_STEPS ]]; then
  pass "Steps are well named ($NAMED_STEPS named vs $UNNAMED_STEPS potentially unnamed)"
else
  warn "Some steps may be missing names — add 'name:' to every step"
  ((WARNINGS++))
fi

# ── Summary ───────────────────────────────────────────────────────────────

echo ""
separator
echo ""

if [[ $WARNINGS -gt 0 ]]; then
  warn "$WARNINGS warning(s) — review them but they won't block your belt"
fi

if [[ $ERRORS -gt 0 ]]; then
  fail "$ERRORS requirement(s) not met. Fix them and try again."
  tip  "Re-read the README for the full requirement list."
  echo ""
  exit 1
fi

pass "All structural requirements satisfied!"
echo ""

# ── Verbal question ───────────────────────────────────────────────────────

separator
echo ""
echo "  🎓 Sensei Question"
echo ""
echo "  Before the Red Belt is awarded, answer this:"
echo ""

QUESTIONS=(
  "What is the difference between a composite action and a reusable workflow — and when would you choose one over the other?"
  "Explain what 'fail-fast' does in a matrix strategy and describe a real-world situation where you'd set it to false."
  "What context would you use to detect whether a workflow was triggered by a pull_request or a push, and why does that matter for deployment jobs?"
  "Describe the difference between job outputs and step outputs, and how data flows from one job to another."
  "If your workflow caches node_modules but someone adds a new package, why does the cache not go stale automatically — and how would you fix this?"
)

# Pick a pseudo-random question based on day of month
IDX=$(( $(date +%d) % ${#QUESTIONS[@]} ))
QUESTION="${QUESTIONS[$IDX]}"

echo "  $QUESTION"
echo ""
echo -n "  Your answer: "
read -r ANSWER

# Minimum quality check — at least 20 words
WORD_COUNT=$(echo "$ANSWER" | wc -w)
if [[ $WORD_COUNT -lt 20 ]]; then
  echo ""
  fail "Answer too brief (${WORD_COUNT} words). A Sensei can explain their thinking. Try again."
  exit 1
fi

echo ""
pass "Answer accepted (${WORD_COUNT} words — Sensei approves)."

award_belt "red"
