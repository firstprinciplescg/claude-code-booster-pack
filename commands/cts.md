---
description: Create context transfer summary for session handoff
---

I need to create a comprehensive context transfer summary (CTS) that will allow a new Claude Code session to pick up exactly where this session left off.

Please analyze our entire conversation history and create a detailed summary that includes:

1. **Project Context**: Current working directory, project structure, and key files we've been working with
2. **Task Progress**: What we've accomplished, what's currently in progress, and what remains to be done
3. **Code Changes**: Summary of all modifications made during this session
4. **Configuration & Dependencies**: Any tools, frameworks, or settings that are relevant
5. **Next Steps**: Clear action items for the next session
6. **Important Context**: Any decisions, constraints, or specific requirements discussed

After creating this summary, save it to the `_notes` subdirectory with the filename format: `<yyyy-mm-dd-hhmm>_<project_name>_<brief_ctc_summary_description>_CTS_session_handoff.md`

If the `_notes` directory doesn't exist, create it first.