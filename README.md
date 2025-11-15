# Claude Code Booster Pack

A collection of powerful custom slash commands and specialized agents to supercharge your Claude Code workflow.

## 🚀 What's Included

### Custom Slash Commands

- **`/cts`** - Context Transfer Summary - Create structured session handoff documents
- **`/rehy`** - Rehydrate - Restore context from CLAUDE.md and CTS files
- **`/adr`** - Architectural Decision Records - Document and track architectural decisions
- **`/ccc`** - Claude Code Cleanup - Analyze and optimize your Claude Code configuration
- **`/tag`** - Tag Management - Add and manage project tags and metadata
- **`/tech-stack`** - Tech Stack Manager - Manage and visualize technology stack across projects
- **`/ship`** - Ship - Streamlined deployment and release workflow
- **`/workstation-start`** - Workstation Start - Initialize your development environment
- **`/workstation-end`** - Workstation End - Clean shutdown of development environment

### Specialized Agents

**Architecture & Design**
- `architecture-advisor` - System architecture design and technology stack decisions
- `api-designer` - RESTful API design and documentation
- `adr-manager` - Architectural decision record management

**Development**
- `backend-api-developer` - Express.js, microservices, and authentication
- `ui-ux-developer` - React, state management, and frontend components
- `database-expert` - Prisma, PostgreSQL, TimescaleDB, and Redis

**Code Quality**
- `code-review-specialist` - Comprehensive code reviews and quality assessment
- `test-generation-engine` - Test suite creation and TDD workflows
- `refactoring-guide` - Code improvement and technical debt reduction
- `debugging-assistant` - Complex bug investigation and root cause analysis

**Operations**
- `performance-optimizer` - Performance bottleneck identification and optimization
- `security-auditor` - Security analysis and vulnerability assessment
- `documentation-generator` - Technical documentation and API docs
- `folder-organizer` - File and directory structure optimization

**Utilities**
- `claude-code-cleanup` - Claude Code configuration analysis
- `claude-code-dad-bot` - Session handoff and context transfer management
- `master-orchestrator` - Complex multi-agent task coordination

## 📦 Installation

### Quick Install

1. Clone this repository:
```bash
git clone https://github.com/firstprinciplescg/claude-code-booster-pack.git
cd claude-code-booster-pack
```

2. Copy commands and agents to your Claude Code directory:

**Windows (Git Bash/WSL):**
```bash
cp -r commands/* ~/.claude/commands/
cp -r agents/* ~/.claude/agents/
```

**macOS/Linux:**
```bash
cp -r commands/* ~/.claude/commands/
cp -r agents/* ~/.claude/agents/
```

3. Restart Claude Code or reload your configuration

### Manual Install

1. Navigate to your Claude Code directory:
   - Windows: `C:\Users\YOUR_USERNAME\.claude`
   - macOS/Linux: `~/.claude`

2. Copy the contents of:
   - `commands/` → `~/.claude/commands/`
   - `agents/` → `~/.claude/agents/`

## 🎯 Usage

### Slash Commands

Slash commands are invoked directly in Claude Code:

```
/cts
```

This will execute the Context Transfer Summary command, creating a handoff document for your session.

```
/rehy
```

This will rehydrate context from your CLAUDE.md and latest CTS file.

### Agents

Agents are automatically available in Claude Code and are invoked by Claude when appropriate for your task. You can also explicitly request them:

```
Can you use the architecture-advisor agent to help me design this system?
```

## 📚 Command Reference

### Context Management Workflow

**Critical for multi-session projects:** Claude Code's context window resets between sessions. Use these commands to maintain continuity:

**Session pattern:**
```
Start session → /rehy → work → End session → /cts
```

This ensures Claude never repeats work, retries failed approaches, or loses architectural decisions across context resets.

### `/cts` - Context Transfer Summary
Creates a lean handoff document (30-second skim) capturing:
- Key decisions and WHY they were made
- Approaches tried that failed (and why)
- Current state, blockers, open questions
- Next steps and prerequisites

Excludes code/file contents (they're in git). Focuses on context Claude needs to continue effectively after context reset.

**When to use:** End of every session, before hitting context limits, or before `/clear`.

### `/rehy` - Rehydrate Context
Efficiently restores Claude's working context after reset:
- Checks if CLAUDE.md already in context (token optimization)
- Loads latest CTS file with decisions/next steps
- Provides structured summary of what's accomplished and what remains

**Token efficiency:** Restores full project context in ~1700 tokens vs ~7000 tokens manually explaining everything.

**When to use:** Start of every session, after `/clear`, resuming work after context reset.

### `/adr` - Architectural Decision Records
Document, list, and view architectural decisions using the ADR pattern.

**When to use:** Making significant architectural choices, documenting design decisions.

### `/ccc` - Claude Code Cleanup
Analyzes and optimizes your Claude Code configuration files.

**When to use:** Periodic maintenance, troubleshooting configuration issues.

### `/tag` - Tag Management
Add and update project tags and metadata for better organization.

**When to use:** Categorizing projects, adding metadata for search and filtering.

### `/tech-stack` - Tech Stack Manager
Manage and visualize the technology stack across your projects.

**When to use:** Documenting technologies, tracking dependencies, planning migrations.

### `/ship` - Ship to Production
Commits all changes and pushes to GitHub with automatic pre-flight checks and meaningful commit messages.

**Features:**
- Pre-flight linting for Node.js projects (runs `npm run lint` if `package.json` exists)
- Reviews git status and staged changes
- Analyzes recent commit style for consistency
- Creates descriptive commit messages with proper formatting
- Includes Claude Code attribution footer

**When to use:** Ready to commit and push changes, deploying to production, ensuring lint passes before CI/CD.

### `/workstation-start` - Start Work Session
Syncs with the remote repository and prepares your workstation for a new work session.

**Features:**
- Pulls latest changes from remote
- Checks current git status
- Reads WORKSTATION.md for handoff notes from other workstation
- Updates WORKSTATION.md with current session info (machine name, timestamp, branch, commit)
- Displays uncommitted changes and TODOs

**When to use:** Starting work on a project, switching between multiple workstations, resuming work after a break.

### `/workstation-end` - End Work Session
Saves all work and prepares comprehensive handoff notes for your other workstation.

**Features:**
- Checks and stages all changes
- Creates WIP commits with descriptive state information
- Pushes all commits to remote
- Updates WORKSTATION.md with session summary, completed work, and next steps
- Final status check to confirm everything is saved

**When to use:** Ending a work session, switching to another machine, ensuring no work is lost during handoff.

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

### Adding New Commands

1. Create a new `.md` file in `commands/`
2. Follow the existing command format
3. Document the command in this README

### Adding New Agents

1. Create a new `.md` file in `agents/`
2. Define the agent's specialty and tools
3. Add documentation to this README

## 📄 License

MIT License - feel free to use and modify these tools for your projects.

## 🙏 Acknowledgments

Built for the Claude Code community to enhance productivity and workflow efficiency.

---

**Questions or Issues?** Open an issue on GitHub or contribute improvements!
