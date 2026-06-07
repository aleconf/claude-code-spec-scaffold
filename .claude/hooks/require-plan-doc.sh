#!/bin/sh
# Blocks ExitPlanMode unless a new plan .md file was written to docs/ since the last exit.

DOCS_DIR="${CLAUDE_PROJECT_DIR:-$(pwd)}/docs"
MARKER="${CLAUDE_PROJECT_DIR:-$(pwd)}/.claude/.last_plan_exit"
GLOB="plan-*-[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9].md"

# Create docs/ if it doesn't exist
mkdir -p "$DOCS_DIR"

# Create marker file on first run (set the marker's mtime to the epoch) without affecting its mtime if it already exists
[ -f "$MARKER" ] || touch -t 197001010000 "$MARKER"

# Check if any .md file in docs/ is newer than the marker
RECENT_PLAN=$(find "$DOCS_DIR" -maxdepth 1 -name "$GLOB" -type f -newer "$MARKER" 2>/dev/null | head -1)

if [ -n "$RECENT_PLAN" ]; then
  touch "$MARKER"  # Advance marker so the same file can't be reused next time
  exit 0
fi

# No new plan file found — block and explain
echo "BLOCKED: No file matching docs/plan-*-[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9].md found since last exit. Save the implementation plan as docs/plan-<feature-name>-<YYYY-MM-DD>.md and retry." >&2
exit 2
