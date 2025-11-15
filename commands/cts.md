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

### Project Status Update (if applicable)
⚠️ **Update PROJECT_STATUS.md when you complete significant work:**

**When to update:**
- Complete a major feature/component (update checkboxes: ⏳ → 🔄 or ✅)
- Finish an entire category of work (e.g., all endpoints for a feature)
- Phase progress changes significantly (e.g., 40% → 60%)
- New blocker discovered or resolved

**Where to update:**
- Find the relevant phase section in [PROJECT_STATUS.md](../PROJECT_STATUS.md)
- Update checkboxes: `[ ]` → `[x]`
- Update progress percentages if significant
- Update "Next Priorities" if focus shifts
- Add/remove blockers in "Known Blockers & Issues" section

**Example:**
```markdown
### 5.3 Revenue-Share Campaign Tracking

**Frontend (🔄 In Progress - ~40% Complete)**  ← Update percentage
- [x] Revenue-share configuration UI (was [ ])  ← Mark complete
- [x] Commission tracking dashboard (was [ ])
- [ ] GMV reporting charts  ← Still pending
```

**Don't update:** CLAUDE.md Phase 5 Progress Tracker (it's a summary, not the source of truth)

### Important Context
- Constraints, preferences, gotchas discussed
- Links to relevant files/docs for deep dive

## What to EXCLUDE:
❌ Code blocks (they're in git)
❌ File contents (they're in the repo)
❌ Complete git diffs (use SHAs)
❌ Project description (it's in CLAUDE.md)
❌ Details already in committed code

Save to: `_notes/<yyyy-mm-dd-hhmm>_<project_name>_<brief_description>_CTS.md`

Create `_notes/` directory if it doesn't exist.
