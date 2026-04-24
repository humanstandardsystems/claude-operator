# /operator — Operator Control Panel

Show the current status of all operator controls.

## Steps

1. Check if `.claude/.teach_mode` exists → Teaching Mode is ON, otherwise OFF
2. Check if `.claude/.scope_watch` exists → Scope Watch is ON, otherwise OFF
3. If `.claude/.scope_session` exists, read it and count the number of directories tracked this session

Output a clean status panel like this:

```
OPERATOR STATUS
───────────────────────────
Teaching Mode   [ON / OFF]
Scope Watch     [ON / OFF]
───────────────────────────
Scope session: X directories tracked   (only show if scope watch is ON and session file exists)
```

Then list available commands:
- `/teach` — toggle teaching mode on/off
- `/scope` — toggle scope watch on/off
