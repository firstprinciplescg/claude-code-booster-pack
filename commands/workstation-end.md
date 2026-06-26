---
description: End a work session — write handoff notes and sync them across machines
---

# /workstation-end

End a work session and hand off to your other machine. Handoff notes go to the **central
private repo** `fpcg-working-notes` (via the `_notes/` junction), **not** the project's
repo. By default this command is **report-only** for the project (client) repo — it will
not commit or push it. Pass `--commit` only if you explicitly want a WIP commit + push on
the project repo (use with care on client repos).

Helper script: `~/.claude/scripts/workstation.ps1`

## Steps to execute

1. **Bootstrap + pull notes**:
   ```bash
   powershell -NoProfile -ExecutionPolicy Bypass -File "$HOME/.claude/scripts/workstation.ps1" -Action bootstrap
   ```

2. **Resolve this project** (and register on first use):
   ```bash
   powershell -NoProfile -ExecutionPolicy Bypass -File "$HOME/.claude/scripts/workstation.ps1" -Action resolve
   ```
   If `found: false`, determine **client** + **project** from docs (CLAUDE.md, README, repo
   path) or **ask the user**, then:
   ```bash
   powershell -NoProfile -ExecutionPolicy Bypass -File "$HOME/.claude/scripts/workstation.ps1" -Action register -Client <client> -Project <project>
   ```

3. **Ensure the junction**:
   ```bash
   powershell -NoProfile -ExecutionPolicy Bypass -File "$HOME/.claude/scripts/workstation.ps1" -Action link
   ```

4. **Check project status** (report only):
   ```bash
   git status
   ```
   Note uncommitted/unstaged files — these go into the handoff so the next session knows
   what's outstanding.

5. **Write the handoff** into `_notes/WORKSTATION.md`: timestamp, machine name, current
   branch, latest commit hash, list of uncommitted project files, and **clear next steps**
   for the other machine. Keep it current — overwrite stale state.

6. **Project repo handling:**
   - **Default (no `--commit`):** do NOT `git add`/`commit`/`push` the project repo. Just
     leave the uncommitted work reported in the handoff. The user controls client commits.
   - **If `--commit` was passed:** stage, WIP-commit, and push the project repo:
     ```bash
     git add -A && git commit -m "WIP: <description of state>" && git push
     ```
     (Only do this when explicitly requested.)

7. **Sync notes** to the central repo:
   ```bash
   powershell -NoProfile -ExecutionPolicy Bypass -File "$HOME/.claude/scripts/workstation.ps1" -Action push -Message "workstation-end: <client>/<project> @ <machine> <yyyy-mm-dd>"
   ```

8. **Final confirmation**: report that notes are pushed, and explicitly remind the user of
   any uncommitted **project** work they still need to handle themselves (unless `--commit`
   was used).
