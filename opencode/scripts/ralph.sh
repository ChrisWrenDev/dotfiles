#!/usr/bin/env bash
# Ralph loop — processes one task per iteration using the individual phase commands.
# The shell loop continues until no actionable tasks remain or tasks/.stop exists.
#
# Usage:
#   bash opencode/scripts/ralph.sh           # run all phases
#   bash opencode/scripts/ralph.sh research  # only research phase
#   bash opencode/scripts/ralph.sh plan      # only plan phase
#   bash opencode/scripts/ralph.sh impl      # only impl phase
#
# To stop cleanly between tasks: touch tasks/.stop

set -euo pipefail

TASKS_DIR="${TASKS_DIR:-tasks}"
STOP_FILE="$TASKS_DIR/.stop"
PHASE_FILTER="${1:-all}"

# Find the highest-priority task file with a given status.
# Returns the file path, or empty string if none found.
find_task() {
  local status="$1"
  grep -rl "^status: $status" "$TASKS_DIR" 2>/dev/null \
    | while read -r file; do
        priority=$(grep -m1 "^priority:" "$file" 2>/dev/null | awk '{print $2}')
        echo "${priority:-9} $file"
      done \
    | sort -n \
    | head -1 \
    | awk '{print $2}'
}

# Return "command task-file" for the next actionable task, or empty if none.
next_action() {
  local file

  if [[ "$PHASE_FILTER" == "all" || "$PHASE_FILTER" == "research" ]]; then
    file=$(find_task "research-needed")
    [[ -n "$file" ]] && echo "ralph_research $file" && return
  fi

  if [[ "$PHASE_FILTER" == "all" || "$PHASE_FILTER" == "plan" ]]; then
    file=$(find_task "research-done")
    [[ -n "$file" ]] && echo "ralph_plan $file" && return
    file=$(find_task "plan-needed")
    [[ -n "$file" ]] && echo "ralph_plan $file" && return
  fi

  if [[ "$PHASE_FILTER" == "all" || "$PHASE_FILTER" == "impl" ]]; then
    file=$(find_task "plan-ready")
    [[ -n "$file" ]] && echo "ralph_impl $file" && return
  fi
}

echo "Ralph loop starting (phase: $PHASE_FILTER)"
echo "Touch $STOP_FILE to stop cleanly between tasks."
echo ""

while true; do
  if [[ -f "$STOP_FILE" ]]; then
    echo "Stop file detected. Exiting cleanly."
    rm -f "$STOP_FILE"
    break
  fi

  ACTION=$(next_action)

  if [[ -z "$ACTION" ]]; then
    echo "No actionable tasks remaining. Ralph complete."
    break
  fi

  COMMAND="${ACTION%% *}"
  TASK_FILE="${ACTION#* }"

  echo ">>> /$COMMAND -- $TASK_FILE"
  opencode run --command "$COMMAND" --file "$TASK_FILE"
  echo ""
done
