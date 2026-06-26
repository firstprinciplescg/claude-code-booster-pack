---
description: Create lean context transfer summary for session handoff
---

Create a CONCISE context transfer summary (CTS) that captures THIS SESSION's key decisions and next steps.

**IMPORTANT: Be lean. Focus on WHY and NEXT, not WHAT and HOW. Don't duplicate information available in git, source files, or CLAUDE.md.**

## Structure (aim for 30-second skim):

### Session Overview (2-3 sentences)
- Goal: What we set out to accomplish
- Directory: [pwd]
- Branch: [branch name]
- Last commit: [SHA - one-line description]

### Key Decisions & Reasoning
- Decision 1: What we decided and WHY
- Approach X tried but failed because Y
- Constraint/tradeoff Z that affected our choices

### Current State
- Where we are in solving the problem
- What's working / what's blocked
- Open questions or ongoing investigations

### Changes Made (reference only)
- Commits: [SHA1: description], [SHA2: description]
- Modified files: list paths (no code blocks)
- New docs created: link to paths

### Next Steps (actionable)
1. Specific action to take first
2. Next action after that
3. Any prerequisites or dependencies

### Important Context
- Constraints, preferences, gotchas discussed
- Links to relevant files/docs for deep dive

## What to EXCLUDE:
❌ Code blocks (they're in git)
❌ File contents (they're in the repo)
❌ Complete git diffs (use SHAs)
❌ Project description (it's in CLAUDE.md)
❌ Details already in committed code

## Where to save + how it syncs

`_notes/` is a **junction** into your central private working-notes repo
(`<client>/<project>/`). Writing into `_notes/` automatically lands the file in that repo.

0. **First-run self-heal.** If `~/.claude/scripts/workstation.ps1` or
   `~/.claude/workstation.json` is missing, run the `/workstation-setup` routine first
   (fetch helper, discover-or-ask notes URL, write config, clone notes repo), then continue.

1. **Ensure the junction exists** (creates it on a fresh machine; idempotent):
   ```bash
   powershell -NoProfile -ExecutionPolicy Bypass -File "$HOME/.claude/scripts/workstation.ps1" -Action link
   ```
   If this reports the project isn't registered, run `-Action resolve`; if `found: false`,
   get the client + project names from docs or ask the user, then
   `-Action register -Client <client> -Project <project>` before linking.

2. **Save** to: `_notes/<yyyy-mm-dd-hhmm>_<project_name>_<brief_description>_CTS.md`

3. **Sync** the new CTS to the central repo:
   ```bash
   powershell -NoProfile -ExecutionPolicy Bypass -File "$HOME/.claude/scripts/workstation.ps1" -Action push -Message "cts: <brief_description>"
   ```

> This writes only to the central notes repo — never the project (client) repo.
