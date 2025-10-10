---
description: Sync tasks between Claude Code TodoWrite and Asana
tags: [global, productivity, asana, task-management]
---

# Tasks - Bidirectional Todo ↔ Asana Sync

Sync your Claude Code session todos with Asana tasks for unified task management across your workflow.

## Commands

- `/tasks pull` - Pull open tasks from Asana → TodoWrite
- `/tasks push` - Push TodoWrite todos → Asana
- `/tasks sync` - Bidirectional sync (pull + push)
- `/tasks status` - Show current sync status

---

## Pull Tasks from Asana

Pull open Asana tasks for the current project into TodoWrite.

**Usage:** `/tasks pull`

**What it does:**
1. Identifies current project from `_fpcg_tags/projects.json`
2. Gets Asana project ID from client metadata
3. Fetches open tasks assigned to you via Asana MCP
4. Filters tasks by FPCG Project custom field
5. Populates TodoWrite with tasks
6. Marks pulled tasks as "In Progress" in Asana

**Example:**

```bash
cd ~/Documents/GitHub/llm-ad-platform-cc
/tasks pull

# TodoWrite now shows:
# [pending] Add comprehensive error logging
# [pending] Implement retry logic for failed auth
# [pending] Add user export feature (CSV)
```

---

## Push Tasks to Asana

Push your current TodoWrite todos to Asana as tasks.

**Usage:** `/tasks push`

**What it does:**
1. Reads current TodoWrite todos
2. For each todo:
   - Checks if task already exists in Asana (by title match)
   - If exists: Updates status and adds notes
   - If new: Creates Asana task with custom fields
3. Sets Source = "Claude Code"
4. Preserves todo status (pending/in_progress/completed)

**Example:**

```bash
# After working on tasks in Claude Code
/tasks push

# Asana now has:
# ✅ "Add error logging" (completed, from Claude Code)
# 🔄 "Implement retry logic" (in progress, from Claude Code)
# ⏸️ "Add export feature" (pending, from Claude Code)
```

---

## Bidirectional Sync

Pull from Asana AND push to Asana in one command.

**Usage:** `/tasks sync`

**What it does:**
1. Pull: Fetches new Asana tasks → TodoWrite
2. Deduplicates based on title matching
3. Push: Syncs TodoWrite changes → Asana
4. Resolves conflicts (Asana wins for external tasks, TodoWrite wins for Claude tasks)

**Conflict Resolution:**
- Asana task updated externally → Updates TodoWrite
- TodoWrite task completed → Marks Asana task complete
- New tasks from both → Merges intelligently

---

## Show Sync Status

Display current sync state and task counts.

**Usage:** `/tasks status`

**Shows:**
- Current project and Asana project link
- Tasks in TodoWrite: X
- Tasks in Asana: Y
- Last sync: timestamp
- Unsynced changes: Z

---

## Instructions for Claude

When the user runs a /tasks command:

### Step 1: Identify Current Project

```javascript
// Read current project metadata
const cwd = process.cwd();
const projectName = path.basename(cwd);

// Load FPCG tags
const projectsPath = path.join(os.homedir(), '.claude', '_fpcg_tags', 'projects.json');
const projects = JSON.parse(fs.readFileSync(projectsPath));

// Find matching project
const currentProject = Object.entries(projects).find(([key, proj]) => {
  return proj.name === projectName || key === projectName;
});

if (!currentProject) {
  console.log("❌ Current directory not tagged as FPCG project");
  console.log("Run /tag to tag this project first");
  return;
}

const [projectKey, projectData] = currentProject;
```

### Step 2: Get Asana Project Details

```javascript
// Load client metadata
const clientsPath = path.join(os.homedir(), '.claude', '_fpcg_tags', 'clients.json');
const clients = JSON.parse(fs.readFileSync(clientsPath));

const client = clients[projectData.client_id];

if (!client.asana_project_id) {
  console.log("❌ No Asana project ID configured for this client");
  console.log("Add asana_project_id to client metadata in clients.json");
  return;
}

const asanaProjectId = client.asana_project_id;
```

### Step 3A: Pull Tasks (if /tasks pull or /tasks sync)

```javascript
// Use Asana MCP to fetch tasks
const asanaTasks = await mcp__asana__get_tasks({
  project_gid: asanaProjectId,
  assignee: "me",
  completed_since: "now", // only open tasks
  opt_fields: ["name", "due_on", "notes", "completed", "custom_fields"]
});

// Filter by FPCG Project custom field
const relevantTasks = asanaTasks.data.filter(task => {
  const fpcgProjectField = task.custom_fields?.find(f => f.name === "FPCG Project");
  return fpcgProjectField?.text_value === projectKey;
});

// Create TodoWrite entries
const todos = relevantTasks.map(task => ({
  content: task.name,
  status: task.completed ? "completed" : "pending",
  activeForm: task.name.replace(/^([A-Z])/, (match) => match.toLowerCase() + "ing"),
  asana_task_id: task.gid,
  asana_url: task.permalink_url
}));

// Populate TodoWrite
TodoWrite({ todos });

// Mark tasks as "In Progress" in Asana
for (const task of relevantTasks) {
  if (!task.completed) {
    await mcp__asana__update_task({
      task_gid: task.gid,
      custom_fields: {
        "Source": "Claude Code (Active)"
      }
    });
  }
}

console.log(`✅ Pulled ${relevantTasks.length} tasks from Asana`);
```

### Step 3B: Push Tasks (if /tasks push or /tasks sync)

```javascript
// Get current todos from context (user must provide)
const currentTodos = []; // From TodoWrite state

for (const todo of currentTodos) {
  // Check if task exists in Asana
  const existingTask = asanaTasks.data.find(t =>
    t.name.toLowerCase() === todo.content.toLowerCase()
  );

  if (existingTask) {
    // Update existing task
    await mcp__asana__update_task({
      task_gid: existingTask.gid,
      completed: todo.status === "completed",
      notes: `Updated from Claude Code session\n\n${existingTask.notes || ""}`
    });
    console.log(`✅ Updated: ${todo.content}`);
  } else {
    // Create new task
    const newTask = await mcp__asana__create_task({
      project_gid: asanaProjectId,
      name: todo.content,
      notes: `Created from Claude Code session`,
      assignee: "me",
      completed: todo.status === "completed",
      custom_fields: {
        "Source": "Claude Code",
        "FPCG Project": projectKey,
        "Billable": projectData.billable
      }
    });
    console.log(`✅ Created: ${todo.content}`);
  }
}
```

### Step 4: Show Status (if /tasks status)

```javascript
const todoCount = currentTodos.length;
const asanaTaskCount = asanaTasks.data.length;
const lastSync = new Date().toISOString();

console.log(`
📊 Task Sync Status

**Project:** ${projectData.name}
**Client:** ${client.name}
**Asana Project:** https://app.asana.com/0/${asanaProjectId}

📝 **TodoWrite:** ${todoCount} tasks
📋 **Asana:** ${asanaTaskCount} tasks
🔄 **Last Sync:** ${lastSync}

${todoCount !== asanaTaskCount ? '⚠️  Unsynced changes detected. Run /tasks sync to align.' : '✅ In sync'}
`);
```

## Integration with /workstation-end

Enhance the existing `/workstation-end` command to auto-push tasks:

**Add to workstation-end.md:**

```markdown
## Step 4: Sync Completed Tasks to Asana

Before logging time, sync your completed work to Asana:

1. Run `/tasks push` to update Asana
2. Completed todos → Mark Asana tasks complete
3. In-progress todos → Update Asana task status
4. Add session notes to Asana tasks
```

## Error Handling

### No Asana MCP Connection

```
❌ Asana MCP not connected

To connect:
1. Restart Claude Desktop
2. Authenticate with Asana when prompted
3. Try /tasks again
```

### Project Not Tagged

```
❌ Current project not found in FPCG tags

Run /tag to add this project:
  /tag
```

### No Asana Project ID

```
❌ No Asana project configured for this client

Add to ~/.claude/_fpcg_tags/clients.json:
{
  "your-client-id": {
    "asana_project_id": "1234567890"
  }
}

Get project ID from Asana URL: https://app.asana.com/0/{PROJECT_ID}/...
```

### Duplicate Tasks

```
⚠️  Found duplicate task in Asana: "Task name"

Options:
1. Update existing task (recommended)
2. Create duplicate anyway
3. Skip this task

Choice: [1/2/3]
```

## Examples

### Example 1: Morning Workflow

```bash
# Start work session
cd ~/Documents/GitHub/llm-ad-platform-cc
/workstation-start

# Pull today's tasks from Asana
/tasks pull

# TodoWrite now shows client tasks:
# [pending] Fix authentication bug
# [pending] Add CSV export feature
# [pending] Update documentation

# Work on tasks...
# (Mark todos as in_progress/completed as you work)

# End session
/tasks push  # Sync progress to Asana
/workstation-end  # Log time
```

### Example 2: Creating Tasks During Development

```bash
# Working on code, identify new tasks
TodoWrite({
  todos: [
    {content: "Refactor login component", status: "pending"},
    {content: "Add unit tests for auth flow", status: "pending"},
    {content: "Update API documentation", status: "pending"}
  ]
})

# Push new tasks to Asana
/tasks push

# Tasks now in Asana with:
# - Source: Claude Code
# - FPCG Project: llm-ad-platform-cc
# - Billable: Yes (from client metadata)
```

### Example 3: Syncing Mid-Session

```bash
# Client emails new urgent task → Added to Asana by email parser

# Pull latest tasks (includes new urgent task)
/tasks pull

# TodoWrite updates with new task:
# [pending] Fix login bug (URGENT)
# [in_progress] Add CSV export
# [completed] Update docs

# Work on urgent task...

# Sync progress back
/tasks push
```

## Advanced Features

### Task Prioritization

Tasks pulled from Asana inherit priority:
- Asana High Priority → TodoWrite top of list
- Asana Normal → TodoWrite middle
- Asana Low → TodoWrite bottom

### Due Date Handling

- Tasks with due dates shown with ⏰ indicator
- Overdue tasks highlighted in red
- Due today shown in yellow

### Smart Deduplication

When pushing tasks:
1. Exact title match → Update existing
2. High similarity (>85%) → Prompt user
3. No match → Create new task

### Batch Operations

```bash
# Complete all pending tasks
/tasks complete-all

# Archive completed tasks in Asana
/tasks archive-completed

# Clear TodoWrite and pull fresh
/tasks reset
```

## Best Practices

1. **Start each session with /tasks pull**
   - Gets latest tasks from Asana
   - Ensures you're working on current priorities

2. **Use TodoWrite actively during work**
   - Mark tasks in_progress when you start
   - Mark completed when done
   - Add new tasks as you discover them

3. **Push frequently**
   - `/tasks push` every hour or two
   - Keeps Asana updated for clients/team

4. **End session with full sync**
   - `/tasks sync` before /workstation-end
   - Ensures all work is captured

5. **Review Asana weekly**
   - Clean up completed tasks
   - Verify all Claude Code tasks synced correctly

## Troubleshooting

### Issue: Tasks not syncing

**Solution:**
1. Check Asana MCP connection: Restart Claude Desktop
2. Verify custom fields exist in Asana project
3. Ensure FPCG Project custom field matches project key

### Issue: Duplicate tasks created

**Solution:**
- Use `/tasks sync` instead of `/tasks push` for deduplication
- Manually merge duplicates in Asana
- Update title matching logic if needed

### Issue: Wrong project in Asana

**Solution:**
1. Check `_fpcg_tags/projects.json` project key
2. Verify `clients.json` asana_project_id is correct
3. Update custom field "FPCG Project" in Asana

## Related Commands

- `/tag` - Tag current project for task routing
- `/workstation-end` - End session with task sync
- `/projects` - List all tagged projects (to be built)

## Support Files

- **Command:** `~/.claude/commands/tasks.md` (this file)
- **Projects:** `~/.claude/_fpcg_tags/projects.json`
- **Clients:** `~/.claude/_fpcg_tags/clients.json`
- **Docs:** `~/.claude/docs/hybrid-task-orchestration.md`

---

**End of /tasks command**

*Bidirectional task sync between Claude Code and Asana*
