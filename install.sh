#!/usr/bin/env bash
# install.sh — install operator into Claude Code
# Usage:
#   bash install.sh             # global install (default) → ~/.claude/
#   bash install.sh --project   # project install → current directory's .claude/

set -euo pipefail

SOURCE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# ── Resolve target ────────────────────────────────────────────────────────────
SCOPE="global"
if [ "${1:-}" = "--project" ]; then
    SCOPE="project"
fi

if [ "$SCOPE" = "global" ]; then
    CLAUDE_DIR="$HOME/.claude"
else
    TARGET="$(pwd)"
    if [ "$TARGET" = "$SOURCE_DIR" ]; then
        echo "error: target cannot be the operator repo itself." >&2
        exit 1
    fi
    CLAUDE_DIR="$TARGET/.claude"
fi

echo "Installing operator ($SCOPE) into: $CLAUDE_DIR"

# ── Create directory structure ────────────────────────────────────────────────
mkdir -p "$CLAUDE_DIR/commands"
mkdir -p "$CLAUDE_DIR/hooks"

# ── Copy commands ─────────────────────────────────────────────────────────────
cp "$SOURCE_DIR/.claude/commands/operator.md" "$CLAUDE_DIR/commands/"
cp "$SOURCE_DIR/.claude/commands/teach.md"    "$CLAUDE_DIR/commands/"
cp "$SOURCE_DIR/.claude/commands/scope.md"    "$CLAUDE_DIR/commands/"
echo "  copied /operator, /teach, /scope commands"

# ── Copy hooks ────────────────────────────────────────────────────────────────
cp "$SOURCE_DIR/.claude/hooks/startup-operator.sh" "$CLAUDE_DIR/hooks/"
cp "$SOURCE_DIR/.claude/hooks/scope-watch.sh"      "$CLAUDE_DIR/hooks/"
chmod +x "$CLAUDE_DIR/hooks/"*.sh
echo "  copied hooks"

# ── Merge settings.json (idempotent — skips if hooks already wired) ───────────
SETTINGS="$CLAUDE_DIR/settings.json"

if [ -f "$SETTINGS" ]; then
    python3 - "$SETTINGS" "$CLAUDE_DIR" <<'PY'
import sys, json

settings_path = sys.argv[1]
claude_dir    = sys.argv[2]

with open(settings_path) as f:
    s = json.load(f)

if "hooks" not in s:
    s["hooks"] = {}

prompt_hook = {"type": "command", "command": f"bash {claude_dir}/hooks/startup-operator.sh"}
scope_hook  = {"type": "command", "command": f"bash {claude_dir}/hooks/scope-watch.sh"}

def already_wired(hook_list, hook):
    for entry in hook_list:
        for h in entry.get("hooks", []):
            if h.get("command") == hook["command"]:
                return True
    return False

if "UserPromptSubmit" not in s["hooks"]:
    s["hooks"]["UserPromptSubmit"] = []
if not already_wired(s["hooks"]["UserPromptSubmit"], prompt_hook):
    s["hooks"]["UserPromptSubmit"].append({"hooks": [prompt_hook]})

if "PostToolUse" not in s["hooks"]:
    s["hooks"]["PostToolUse"] = []
if not already_wired(s["hooks"]["PostToolUse"], scope_hook):
    s["hooks"]["PostToolUse"].append({"hooks": [scope_hook]})

with open(settings_path, "w") as f:
    json.dump(s, f, indent=2)

print("  merged hooks into existing settings.json")
PY
else
    python3 - "$CLAUDE_DIR" <<'PY'
import sys, json
claude_dir = sys.argv[1]
s = {
    "hooks": {
        "UserPromptSubmit": [{"hooks": [{"type": "command", "command": f"bash {claude_dir}/hooks/startup-operator.sh"}]}],
        "PostToolUse":      [{"hooks": [{"type": "command", "command": f"bash {claude_dir}/hooks/scope-watch.sh"}]}]
    }
}
with open(f"{claude_dir}/settings.json", "w") as f:
    json.dump(s, f, indent=2)
print("  created settings.json")
PY
fi

echo ""
echo "Done. Operator installed $SCOPE."
echo "  /operator  — show control panel"
echo "  /teach     — toggle teaching mode"
echo "  /scope     — toggle scope watch"
if [ "$SCOPE" = "project" ]; then
    echo ""
    echo "  Note: commands are scoped to this project only."
    echo "  Run without --project to install globally."
fi
