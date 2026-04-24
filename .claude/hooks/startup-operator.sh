#!/usr/bin/env bash
# UserPromptSubmit hook — injects operator mode reminders into Claude's context.
# Fires on every prompt. Lightweight: only outputs if a mode is active.

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
TEACH_FLAG="$REPO_ROOT/.claude/.teach_mode"
SCOPE_FLAG="$REPO_ROOT/.claude/.scope_watch"

[ -f "$TEACH_FLAG" ] && echo "TEACHING MODE ACTIVE — Before every action, briefly explain in plain language: what you are about to do, why, and what the expected result is. Keep it jargon-free. Always prefix the explanation with the label [LET'S LEARN] on its own line so the user knows it's a teaching message, not a system message. Then proceed with the action."

[ -f "$SCOPE_FLAG" ] && echo "SCOPE WATCH ACTIVE — The scope-watch.sh PostToolUse hook is tracking file access this session. If you see a [CREEPIN] warning, surface it to the user immediately and pause before continuing."
