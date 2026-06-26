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
| `/workstation-setup` | One-time per-machine setup for the cross-machine notes system |
| `/workstation-start` | Sync cross-machine notes and rehydrate handoff state for a new session |
| `/workstation-end` | Write handoff notes and sync them across machines (report-only on your repo) |

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

4. (Workstation commands only) Run `/workstation-setup` once per machine — or just run any
   `/workstation-*` command and it self-heals. Setup fetches `scripts/workstation.ps1` to
   `~/.claude/scripts/`, discovers or asks for your private notes-repo URL, and clones it.
   Requires `gh` authenticated. To enable zero-prompt discovery on future machines, add the
   GitHub topic `workstation-notes` to your private notes repo.

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

#### How cross-machine notes work

Session notes (`WORKSTATION.md` + `*_CTS.md`) sync through **one universal private repo**
of your own — *not* the project's repo. This matters most for client repos: you never want
WIP or personal handoff notes pushed to a client's remote.

- The private notes repo uses a `<client>/<project>/` layout, one folder per project.
- Each project's local `_notes/` is a **junction/symlink** into its folder in that repo, so
  the commands read/write `_notes/...` in the project while the files live in (and sync via)
  the central repo. `WORKSTATION.md` lives at `_notes/WORKSTATION.md`.
- Mechanics live in `scripts/workstation.ps1` (actions: `bootstrap`, `resolve`, `register`,
  `link`, `pull`, `push`, `discover`, `init-config`), driven by a local
  `~/.claude/workstation.json` config.

**Nothing personal is stored in this public pack.** Your notes-repo URL is discovered at
runtime (via a `workstation-notes` GitHub topic) or asked for once, and saved only locally.

#### `/workstation-setup` - One-Time Machine Setup

Prepares a machine: fetches the helper script, discovers (or asks for) your private
notes-repo URL, writes `~/.claude/workstation.json`, and clones the notes repo. The other
workstation commands run this automatically (their "Step 0") if they detect the machine
isn't set up, so it's rarely needed by hand.

**When to use:** First time on a new machine (or just run any workstation command and let it
self-heal).

#### `/workstation-start` - Start Work Session

Syncs cross-machine notes and rehydrates handoff state.

**Features:**
- Self-heals an unconfigured machine (runs setup)
- Pulls the central notes repo and ensures the project's `_notes` junction exists
- Reads `_notes/WORKSTATION.md` + latest CTS and summarizes what the other machine was doing
- Stamps the session (machine, time, branch, commit) into `WORKSTATION.md`
- Optionally pulls the project repo (read-only); never force/stash without asking

**When to use:** Starting work, switching machines, resuming after a break.

#### `/workstation-end` - End Work Session

Writes handoff notes and syncs them across machines.

**Features:**
- Writes `_notes/WORKSTATION.md`: branch, commit, uncommitted files, clear next steps
- **Report-only on the project repo by default** — it does NOT `git add`/commit/push your
  code (safe for client repos). Pass `--commit` to opt into a WIP commit + push.
- Syncs the central notes repo (the only automatic push)

**When to use:** Ending a session, switching machines, handing off without losing context.

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
