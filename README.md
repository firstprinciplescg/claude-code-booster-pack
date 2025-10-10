# Claude Code Booster Pack

A collection of powerful custom slash commands and specialized agents to supercharge your Claude Code workflow.

## 🚀 What's Included

### Custom Slash Commands

- **`/cts`** - Context Transfer Summary - Create structured session handoff documents
- **`/rehy`** - Rehydrate - Restore context from CLAUDE.md and CTS files
- **`/adr`** - Architectural Decision Records - Document and track architectural decisions
- **`/ccc`** - Claude Code Cleanup - Analyze and optimize your Claude Code configuration
- **`/tag`** - Tag Management - Add and manage project tags and metadata
- **`/tasks`** - Task Sync - Synchronize tasks between Claude Code TodoWrite and Asana
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
git clone https://github.com/YOUR_USERNAME/claude-code-booster-pack.git
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

### `/cts` - Context Transfer Summary
Creates a comprehensive session handoff document including:
- Session summary and progress
- File changes and modifications
- Key decisions and context
- Next steps and TODOs

**When to use:** Before ending a session, hitting context limits, or handing off work.

### `/rehy` - Rehydrate Context
Restores working context from:
- CLAUDE.md memory files
- Latest CTS file from session history

**When to use:** Starting a new session, resuming previous work, recovering from crashes.

### `/adr` - Architectural Decision Records
Document, list, and view architectural decisions using the ADR pattern.

**When to use:** Making significant architectural choices, documenting design decisions.

### `/ccc` - Claude Code Cleanup
Analyzes and optimizes your Claude Code configuration files.

**When to use:** Periodic maintenance, troubleshooting configuration issues.

### `/tag` - Tag Management
Add and update project tags and metadata for better organization.

**When to use:** Categorizing projects, adding metadata for search and filtering.

### `/tasks` - Task Synchronization
Sync tasks between Claude Code TodoWrite and Asana.

**When to use:** Managing tasks across tools, keeping work synchronized.

### `/tech-stack` - Tech Stack Manager
Manage and visualize the technology stack across your projects.

**When to use:** Documenting technologies, tracking dependencies, planning migrations.

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
