# Claude Code Booster Pack

Custom slash commands that fill gaps in Claude Code's built-in feature set. Focused on cross-session context management, architectural decision tracking, project metadata, and streamlined git/multi-workstation workflows.

## Why These Exist

Claude Code has excellent tools for working *within* a session — `/compact`, `--continue`, `--resume`, `/rewind`. But it lacks tools for carrying high-signal context *across* fresh sessions. It also has no built-in support for lightweight architectural decision records or project-level metadata management.

These commands address those gaps, and add a few git and multi-workstation workflow helpers.

## What's Included

| Command | Purpose |
|---|---|
| `/cts` | Create a context transfer summary for session handoff |
| `/rehy` | Rehydrate context from latest CTS file into a fresh session |
| `/adr` | Document, list, and view architectural decisions |
| `/tag` | Add and manage project tags and metadata |
| `/tech-stack` | Manage and visualize technology stack across projects |
| `/ship` | Commit and push with pre-flight checks and a meaningful message |
| `/workstation-start` | Sync and prepare your workstation for a new work session |
| `/workstation-end` | Save work and prepare handoff notes for your other workstation |

## Installation

1. Clone this repository:
```bash
git clone https://github.com/firstprinciplescg/claude-code-booster-pack.git
cd claude-code-booster-pack
```

2. Copy commands to your Claude Code directory:
```bash
cp -r commands/* ~/.claude/commands/
```

3. Restart Claude Code or reload your configuration.

## Command Reference

### Context Management

**The core workflow:**
```
Start session -> /rehy -> work -> End session -> /cts
```

This ensures Claude never repeats work, retries failed approaches, or loses architectural decisions across context resets.

#### `/cts` - Context Transfer Summary

Creates a lean handoff document (30-second skim) capturing:
- Key decisions and WHY they were made
- Approaches tried that failed (and why)
- Current state, blockers, open questions
- Next steps and prerequisites

Excludes code/file contents (they're in git). Focuses on context Claude needs to continue effectively after context reset.

**When to use:** End of every session, before hitting context limits, or before `/clear`.

#### `/rehy` - Rehydrate Context

Efficiently restores Claude's working context in a fresh session:
- Checks if CLAUDE.md already in context (token optimization)
- Loads latest CTS file with decisions/next steps
- Provides structured summary of what's accomplished and what remains

**Token efficiency:** Restores full project context in ~1700 tokens vs ~7000 tokens manually explaining everything.

**When to use:** Start of every session, after `/clear`, resuming work after context reset.

### Architectural Decisions

#### `/adr` - Architectural Decision Records

Document, list, and view architectural decisions using a lightweight format:
- Date, title, rationale
- Tradeoffs and alternatives considered
- Reversibility assessment

Stores decisions in `docs/decisions.md`. Prevents context loss on the *why* behind technical choices.

**When to use:** Making significant architectural choices, documenting design decisions.

### Project Metadata

#### `/tag` - Tag Management

Add and update project tags and metadata for organization across projects:
- Client, GitHub repo, team members, billable status
- Tags for filtering and search
- Integrates with external automation (Make.com, etc.)

**When to use:** Categorizing projects, adding metadata for search and filtering.

#### `/tech-stack` - Tech Stack Manager

Manage and visualize the technology stack across projects:
- Track technologies by category (Frontend, Backend, Database, DevOps, etc.)
- Record proficiency levels and learning status
- Export to CSV

**When to use:** Documenting technologies, tracking dependencies, planning migrations.

### Git & Workstation Workflow

#### `/ship` - Ship to Production

Commits all changes and pushes to GitHub with automatic pre-flight checks and meaningful commit messages.

**Features:**
- Pre-flight linting for Node.js projects (runs `npm run lint` if `package.json` exists)
- Reviews git status and staged changes
- Analyzes recent commit style for consistency
- Creates descriptive commit messages with proper formatting
- Includes Claude Code attribution footer

**When to use:** Ready to commit and push changes, deploying to production, ensuring lint passes before CI/CD.

#### `/workstation-start` - Start Work Session

Syncs with the remote repository and prepares your workstation for a new work session.

**Features:**
- Pulls latest changes from remote
- Checks current git status
- Reads WORKSTATION.md for handoff notes from other workstation
- Updates WORKSTATION.md with current session info (machine name, timestamp, branch, commit)
- Displays uncommitted changes and TODOs

**When to use:** Starting work on a project, switching between multiple workstations, resuming work after a break.

#### `/workstation-end` - End Work Session

Saves all work and prepares comprehensive handoff notes for your other workstation.

**Features:**
- Checks and stages all changes
- Creates WIP commits with descriptive state information
- Pushes all commits to remote
- Updates WORKSTATION.md with session summary, completed work, and next steps
- Final status check to confirm everything is saved

**When to use:** Ending a work session, switching to another machine, ensuring no work is lost during handoff.

## What Was Removed (and Why)

Previous versions of this booster pack also included 17 specialized agents and the `/ccc` command. These have been removed because Claude Code now provides them natively:

**Agents removed:** All 17 specialized agents (architecture-advisor, api-designer, code-review-specialist, debugging-assistant, etc.) are now built-in Claude Code subagent types. Installing custom copies creates duplicates that compete with the native versions.

**Commands removed:**
- `/ccc` — replaced by built-in `/doctor`, `/config`, and the native `claude-code-cleanup` agent

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

### Adding New Commands

1. Create a new `.md` file in `commands/`
2. Follow the existing command format
3. Document the command in this README

## License

MIT License - feel free to use and modify these tools for your projects.

## Acknowledgments

Built for the Claude Code community to enhance productivity and workflow efficiency.

---

**Questions or Issues?** Open an issue on GitHub or contribute improvements!
