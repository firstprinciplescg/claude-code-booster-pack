# Claude Code Booster Pack

Custom slash commands that fill gaps in Claude Code's built-in feature set. Focused on cross-session context management, architectural decision tracking, and project metadata.

## Why These Exist

Claude Code has excellent tools for working *within* a session — `/compact`, `--continue`, `--resume`, `/rewind`. But it lacks tools for carrying high-signal context *across* fresh sessions. It also has no built-in support for lightweight architectural decision records or project-level metadata management.

These five commands address those gaps.

## What's Included

| Command | Purpose |
|---|---|
| `/cts` | Create a context transfer summary for session handoff |
| `/rehy` | Rehydrate context from latest CTS file into a fresh session |
| `/adr` | Document, list, and view architectural decisions |
| `/tag` | Add and manage project tags and metadata |
| `/tech-stack` | Manage and visualize technology stack across projects |

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

## What Was Removed (and Why)

Previous versions of this booster pack included 17 specialized agents and 4 additional commands. These have been removed because Claude Code now provides them natively:

**Agents removed:** All 17 specialized agents (architecture-advisor, api-designer, code-review-specialist, debugging-assistant, etc.) are now built-in Claude Code subagent types. Installing custom copies creates duplicates that compete with the native versions.

**Commands removed:**
- `/ccc` — replaced by built-in `/doctor`, `/config`, and the native `claude-code-cleanup` agent
- `/ship` — replaced by built-in `/diff`, `/security-review`, and native git workflows
- `/workstation-start` and `/workstation-end` — replaced by `claude --continue`, `--resume`, and built-in session persistence

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
