# /scope — Toggle Scope Watch

Scope watch tracks which files and directories Claude touches and warns when it starts expanding outside the original context.

## Steps

1. Check if `.claude/.scope_watch` exists.

2. If it EXISTS (currently ON):
   - Delete `.claude/.scope_watch`
   - Delete `.claude/.scope_session` if it exists (clears session tracking)
   - Say: "Scope watch OFF. Session tracking cleared."

3. If it does NOT exist (currently OFF):
   - Create `.claude/.scope_watch` (empty file)
   - Say: "Scope watch ON. Claude will warn you when it starts touching files outside the original context."

Do not explain further. One line confirmation, then stop.
