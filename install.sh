#!/usr/bin/env bash
# install.sh — install operator into any Claude Code project
# Usage: bash /path/to/operator/install.sh [target-dir]
# Defaults to current directory if no target is given.

set -euo pipefail

SOURCE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET="${1:-$(pwd)}"

if [ "$TARGET" = "$SOURCE_DIR" ]; then
    echo "error: target cannot be the operator repo itself." >&2
    exit 1
fi

echo "Installing operator into: $TARGET"

# ── Create directory structure ───────────────────────────────────────────────
mkdir -p "$TARGET/.claude/commands"
mkdir -p "$TARGET/.claude/hooks"

# ── Copy commands ────────────────────────────────────────────────────────────
cp "$SOURCE_DIR/.claude/commands/operator.md" "$TARGET/.claude/commands/"
cp "$SOURCE_DIR/.claude/commands/teach.md"    "$TARGET/.claude/commands/"
cp "$SOURCE_DIR/.claude/commands/scope.md"    "$TARGET/.claude/commands/"
echo "  copied /operator, /teach, /scope commands"

# ── Copy hooks ───────────────────────────────────────────────────────────────
cp "$SOURCE_DIR/.claude/hooks/startup-operator.sh" "$TARGET/.claude/hooks/"
cp "$SOURCE_DIR/.claude/hooks/scope-watch.sh"      "$TARGET/.claude/hooks/"
chmod +x "$TARGET/.claude/hooks/"*.sh
echo "  copied hooks"

# ── Merge settings.json ───────────────────────────────────────────────────────
SETTINGS="$TARGET/.claude/settings.json"

if [ -f "$SETTINGS" ]; then
    python3 - "$SETTINGS" "$TARGET" <<'PY'
import sys, json

settings_path = sys.argv[1]
target = sys.argv[2]

with open(settings_path) as f:
    s = json.load(f)

if "hooks" not in s:
    s["hooks"] = {}

prompt_hook = {"type": "command", "command": f"bash {target}/.claude/hooks/startup-operator.sh"}
scope_hook  = {"type": "command", "command": f"bash {target}/.claude/hooks/scope-watch.sh"}

# UserPromptSubmit
if "UserPromptSubmit" not in s["hooks"]:
    s["hooks"]["UserPromptSubmit"] = []
s["hooks"]["UserPromptSubmit"].append({"hooks": [prompt_hook]})

# PostToolUse
if "PostToolUse" not in s["hooks"]:
    s["hooks"]["PostToolUse"] = []
s["hooks"]["PostToolUse"].append({"hooks": [scope_hook]})

with open(settings_path, "w") as f:
    json.dump(s, f, indent=2)

print("  merged hooks into existing settings.json")
PY
else
    python3 - "$TARGET" <<PY
import sys, json
target = sys.argv[1]
s = {
    "hooks": {
        "UserPromptSubmit": [{"hooks": [{"type": "command", "command": f"bash {target}/.claude/hooks/startup-operator.sh"}]}],
        "PostToolUse":      [{"hooks": [{"type": "command", "command": f"bash {target}/.claude/hooks/scope-watch.sh"}]}]
    }
}
with open(f"{target}/.claude/settings.json", "w") as f:
    json.dump(s, f, indent=2)
print("  created settings.json")
PY
fi

echo ""
echo "Done."
echo "  /operator  — show control panel"
echo "  /teach     — toggle teaching mode"
echo "  /scope     — toggle scope watch"
