---
description: Add or update project tags and metadata
---

# /tag - Project Tagging System

Tag the current project with client info, team members, and metadata for automation and reporting.

## Steps

1. **Detect current project**
   ```bash
   PROJECT_DIR=$(pwd)
   PROJECT_NAME=$(basename "$PROJECT_DIR")
   ```

2. **Check if project already tagged**
   - Read `~/.claude/_fpcg_tags/projects.json`
   - Look for current project entry

3. **If new project, prompt for:**
   - **Client** (autocomplete from clients.json or add new)
   - **GitHub repo** (e.g., `firstprinciplescg/project-name`)
   - **Team members** (comma-separated emails)
   - **Billable** (Y/n)
   - **Tags** (comma-separated: react, microservices, etc.)
   - **Standup enabled** (Y/n)

4. **If client is new, prompt for client details:**
   - Client full name
   - POC name
   - POC email
   - Hourly rate (or 0 for internal)
   - Standup delivery method (email/slack/file)

5. **Update or create entries:**
   - Add/update project in `~/.claude/_fpcg_tags/projects.json`
   - Add/update client in `~/.claude/_fpcg_tags/clients.json`
   - Set `last_worked` to current timestamp

6. **Show confirmation:**
   ```
   ✅ Project tagged successfully!

   📂 Project: llm-ad-platform-cc
   💼 Client: ACME Corporation
   👥 Team: dustin@firstprinciplescg.com
   💵 Billable: Yes ($200/hour)
   🏷️  Tags: react, microservices, ads-platform
   📊 Standup: Enabled (email to jane@acme.com at 08:00)
   ```

## Usage Examples

### Tag current project
```bash
/tag
```

### Quick update (change status)
```bash
/tag status:paused
```

### Add team member
```bash
/tag team:+contractor@example.com
```

### Update tags
```bash
/tag tags:react,typescript,docker
```

## Auto-Detection

The command will try to detect:
- **Project path** from current directory
- **GitHub repo** from git remote origin
- **Client** from existing entries or directory name patterns

## Integration

Tags are automatically used by:
- `/switch` - List projects by client/tag
- `/timelog` - Auto-fill client name
- `/standup` - Filter projects for daily reports
- `/client-report` - Aggregate metrics by client
- Make.com automation - Read project metadata
