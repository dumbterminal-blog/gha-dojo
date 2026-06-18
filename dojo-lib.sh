#!/usr/bin/env bash
# dojo-lib.sh — shared helpers for belt check scripts

DOJO_STATE_FILE="${DOJO_ROOT:-$(git -C "$(dirname "$0")" rev-parse --show-toplevel 2>/dev/null || echo ".")}/.dojo-progress"

BELTS=(white yellow orange green blue brown black red)
BELT_EMOJI=(🤍 🟡 🟠 🟢 🔵 🟤 ⬛ 🔴)
BELT_NAMES=("White" "Yellow" "Orange" "Green" "Blue" "Brown" "Black" "Red")

# ── Output helpers ────────────────────────────────────────────────────────────

dojo_banner() {
  echo ""
  echo "  ██████╗  ██████╗      ██╗ ██████╗ "
  echo "  ██╔══██╗██╔═══██╗     ██║██╔═══██╗"
  echo "  ██║  ██║██║   ██║     ██║██║   ██║"
  echo "  ██║  ██║██║   ██║██   ██║██║   ██║"
  echo "  ██████╔╝╚██████╔╝╚█████╔╝╚██████╔╝"
  echo "  ╚═════╝  ╚═════╝  ╚════╝  ╚═════╝ "
  echo "         GitHub Actions Dojo"
  echo ""
}

pass() { echo "  ✅  $*"; }
fail() { echo "  ❌  $*"; }
info() { echo "  ℹ️   $*"; }
warn() { echo "  ⚠️   $*"; }
belt() { echo "  🥋  $*"; }
tip()  { echo "  💡  $*"; }

separator() { echo "  ─────────────────────────────────────────"; }

# ── Progress state ────────────────────────────────────────────────────────────

_belt_index() {
  local name="$1"
  for i in "${!BELTS[@]}"; do
    [[ "${BELTS[$i]}" == "$name" ]] && echo "$i" && return
  done
  echo "-1"
}

award_belt() {
  local belt_name="$1"
  local idx
  idx=$(_belt_index "$belt_name")
  if [[ "$idx" == "-1" ]]; then
    fail "Unknown belt: $belt_name"
    return 1
  fi

  local current_belts=()
  if [[ -f "$DOJO_STATE_FILE" ]]; then
    mapfile -t current_belts < "$DOJO_STATE_FILE"
  fi

  # Check it's not already awarded
  for b in "${current_belts[@]}"; do
    [[ "$b" == "$belt_name" ]] && return 0
  done

  echo "$belt_name" >> "$DOJO_STATE_FILE"
  echo ""
  separator
  echo ""
  echo "  ${BELT_EMOJI[$idx]}  BELT AWARDED: ${BELT_NAMES[$idx]^} Belt"
  echo ""
  echo "  You have earned the ${BELT_EMOJI[$idx]} ${BELT_NAMES[$idx]} Belt."
  echo ""

  # Special messages per belt
  case "$belt_name" in
    white)  echo "  Every master was once a beginner. You've taken your first step." ;;
    yellow) echo "  You can read the context. The workflow is starting to speak to you." ;;
    orange) echo "  Jobs bow to your orchestration. Pipelines fear your sequencing." ;;
    green)  echo "  You bend the matrix to your will. Parallel power unlocked." ;;
    blue)   echo "  Conditions and triggers are your weapons. Use them wisely." ;;
    brown)  echo "  You share what you build. The dojo grows stronger for it." ;;
    black)  echo "  Custom actions, caching, artefacts. You have reached mastery." ;;
    red)    echo "  Sensei. There is nothing left to teach you. Go build something." ;;
  esac

  echo ""
  separator

  # Tease the next belt
  local next_idx=$((idx + 1))
  if [[ $next_idx -lt ${#BELTS[@]} ]]; then
    echo ""
    belt "Next challenge: ${BELT_EMOJI[$next_idx]} ${BELT_NAMES[$next_idx]} Belt"
    tip  "Run: ./dojo attempt ${BELTS[$next_idx]}"
  else
    echo ""
    echo "  🏆  YOU HAVE COMPLETED THE DOJO. ALL BELTS EARNED."
  fi
  echo ""
}

show_status() {
  local current_belts=()
  if [[ -f "$DOJO_STATE_FILE" ]]; then
    mapfile -t current_belts < "$DOJO_STATE_FILE"
  fi

  dojo_banner
  echo "  Progress"
  separator

  local awarded_count=0
  for i in "${!BELTS[@]}"; do
    local b="${BELTS[$i]}"
    local awarded=false
    for cb in "${current_belts[@]}"; do
      [[ "$cb" == "$b" ]] && awarded=true && break
    done

    if $awarded; then
      echo "  ${BELT_EMOJI[$i]}  ${BELT_NAMES[$i]} Belt  ✅"
      ((awarded_count++))
    else
      echo "  ${BELT_EMOJI[$i]}  ${BELT_NAMES[$i]} Belt  ···"
    fi
  done

  separator
  echo ""
  local total=${#BELTS[@]}
  echo "  $awarded_count / $total belts earned"

  if [[ $awarded_count -eq 0 ]]; then
    echo ""
    tip "Start your journey:  ./dojo attempt white"
  elif [[ $awarded_count -lt $total ]]; then
    local next_idx=$awarded_count
    echo ""
    belt "Current challenge: ${BELT_EMOJI[$next_idx]} ${BELT_NAMES[$next_idx]} Belt"
    tip  "Run: ./dojo attempt ${BELTS[$next_idx]}"
  else
    echo ""
    echo "  🏆  ALL BELTS EARNED — DOJO COMPLETE"
  fi
  echo ""
}

# ── act runner helper ─────────────────────────────────────────────────────────

# Run a workflow with act and capture output.
# Usage: run_act <belt-dir> <workflow-file> [extra act args...]
# Returns: act exit code; stdout captured in $ACT_OUTPUT
run_act() {
  local belt_dir="$1"
  local workflow="$2"
  shift 2

  # act needs to run from the belt directory so it picks up its .github/workflows
  ACT_OUTPUT=$(cd "$belt_dir" && act push \
    --workflows ".github/workflows/$workflow" \
    --secret-file "$(git rev-parse --show-toplevel)/.env" \
    "$@" 2>&1)
  return $?
}

# Check that a string appears in the last act output
assert_output_contains() {
  local expected="$1"
  if echo "$ACT_OUTPUT" | grep -q "$expected"; then
    pass "Output contains: '$expected'"
    return 0
  else
    fail "Expected output to contain: '$expected'"
    info "Actual output:"
    echo "$ACT_OUTPUT" | tail -30 | sed 's/^/      /'
    return 1
  fi
}

assert_exit_success() {
  if [[ $? -eq 0 ]]; then
    pass "Workflow completed successfully"
    return 0
  else
    fail "Workflow exited with errors"
    return 1
  fi
}
