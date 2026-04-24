#!/usr/bin/env bash
# PostToolUse hook — scope creep detection.
# Tracks directories Claude touches. Warns when new directories appear.

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
SCOPE_FLAG="$REPO_ROOT/.claude/.scope_watch"
SCOPE_SESSION="$REPO_ROOT/.claude/.scope_session"

# Only run if scope watch is active
[ -f "$SCOPE_FLAG" ] || exit 0

INPUT=$(cat)
TOOL_NAME=$(echo "$INPUT" | jq -r '.tool_name // ""' 2>/dev/null)
TOOL_INPUT=$(echo "$INPUT" | jq -r '.tool_input // {}' 2>/dev/null)

# Extract file path from file-based tools
PATH_TOUCHED=""
case "$TOOL_NAME" in
    Read|Write|Edit|NotebookEdit)
        PATH_TOUCHED=$(echo "$TOOL_INPUT" | jq -r '.file_path // ""' 2>/dev/null)
        ;;
    Bash)
        CMD=$(echo "$TOOL_INPUT" | jq -r '.command // ""' 2>/dev/null)
        # Skip internal operator/hook commands
        echo "$CMD" | grep -qE "^\s*(touch|rm|cat|echo)\s+.*\.claude/\." && exit 0
        # Try to extract first file-like argument from command
        PATH_TOUCHED=$(echo "$CMD" | grep -oE '[~/][^[:space:]]+\.[a-zA-Z0-9]+' | head -1 || true)
        ;;
    *)
        exit 0
        ;;
esac

[ -z "$PATH_TOUCHED" ] && exit 0

# Resolve to directory
DIR_TOUCHED=$(dirname "$PATH_TOUCHED")

# Skip .claude internal paths
echo "$DIR_TOUCHED" | grep -q "\.claude" && exit 0

# Initialize scope session on first tracked file
if [ ! -f "$SCOPE_SESSION" ]; then
    echo "$DIR_TOUCHED" > "$SCOPE_SESSION"
    exit 0
fi

# Check if this directory is already tracked
if grep -qF "$DIR_TOUCHED" "$SCOPE_SESSION" 2>/dev/null; then
    exit 0
fi

# New directory — log it and warn
echo "$DIR_TOUCHED" >> "$SCOPE_SESSION"
ORIGIN=$(head -1 "$SCOPE_SESSION")
TOTAL=$(wc -l < "$SCOPE_SESSION")

echo "SCOPE WARNING — Claude is now touching $DIR_TOUCHED (started in: $ORIGIN, now across $TOTAL directories). Surface this to the user before continuing."
