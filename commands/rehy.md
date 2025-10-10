---
description: Rehydrate context from CLAUDE.md and latest CTS file
---

# Rehydrate Context from CLAUDE.md and Latest CTS

Please perform the following steps:

1. Read the CLAUDE.md file from the project root to understand the current project context

2. Search for the most recent Context Transfer Summary (CTS) file:
   - First, check if the `_notes` directory exists in the project root
   - If `_notes` exists, look for the most recent timestamped CTS file (format: `*CTS*.md` or `YYYY-MM-DD*.md`) in that directory
   - If no CTS file is found in `_notes` or `_notes` doesn't exist, search the project root directory for timestamped files (format: `YYYY-MM-DD_*`)

3. Based on the information in both files, provide a comprehensive summary that includes:

   **What Has Been Accomplished:**
   - List all completed tasks and implementations from the CTS file
   - Highlight major milestones reached

   **What Remains to Be Accomplished:**
   - List all pending/incomplete tasks from the CTS file
   - Note any blockers or dependencies

   **Proposed Immediate Next Steps:**
   - Extract and present the recommended next steps from the CTS file
   - Prioritize them in order of importance/dependency

Please format the response clearly with headers and bullet points for easy reading.
