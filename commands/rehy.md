---
description: Rehydrate context from CLAUDE.md and latest CTS file
---

# Rehydrate Context from CLAUDE.md and Latest CTS

Session notes live in the central private repo `fpcg-working-notes`, surfaced in this
project through the `_notes/` junction. Refresh them first so you rehydrate from the latest
state synced from any machine.

Please perform the following steps:

1. **Sync the notes** (pull the central repo; ensure the `_notes` junction exists):
   ```bash
   powershell -NoProfile -ExecutionPolicy Bypass -File "$HOME/.claude/scripts/workstation.ps1" -Action bootstrap
   powershell -NoProfile -ExecutionPolicy Bypass -File "$HOME/.claude/scripts/workstation.ps1" -Action link
   ```
   If `link` reports the project isn't registered, run `-Action resolve`; if `found: false`,
   get client + project from docs or ask the user, then `-Action register` before linking.
   (If the helper/config isn't set up on this machine, fall back to reading whatever is in
   the local `_notes/` directory.)

2. **Check for CLAUDE.md in your current context:**
   - If CLAUDE.md content is already available in your context, **skip to step 3**
   - If not, read the CLAUDE.md file from the project root

3. **Read the handoff + latest CTS:**
   - Read `_notes/WORKSTATION.md` if present (live cross-machine handoff state)
   - Find and read the most recent timestamped CTS file in `_notes/` (format `*_CTS.md`)

4. Based on CLAUDE.md, `WORKSTATION.md`, and the latest CTS, provide a concise summary:

   **What Has Been Accomplished:**
   - Completed tasks and milestones from the CTS / handoff

   **What Remains to Be Accomplished:**
   - Pending/incomplete tasks, blockers, dependencies

   **Proposed Immediate Next Steps:**
   - The recommended next steps, prioritized by importance/dependency

Please format the response clearly with headers and bullet points for easy reading.
