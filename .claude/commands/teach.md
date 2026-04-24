# /teach — Toggle Teaching Mode

Teaching mode makes Claude narrate every action in plain language before taking it.

## Steps

1. Check if `.claude/.teach_mode` exists.

2. If it EXISTS (currently ON):
   - Delete `.claude/.teach_mode`
   - Say: "Teaching mode OFF. Claude will work silently."

3. If it does NOT exist (currently OFF):
   - Create `.claude/.teach_mode` (empty file is fine)
   - Say: "Teaching mode ON. Before every action this session, Claude will explain what it's doing and why in plain language."

Do not explain further. One line confirmation, then stop.
