---
description: Start a work session — sync cross-machine notes, rehydrate handoff state
---

# /workstation-start

Begin a work session. Session notes (`WORKSTATION.md` + CTS files) live in the **central
private working-notes repo**, NOT in this project's repo. The project's local
`_notes/` is a junction into that repo's `<client>/<project>/` folder, so everything here
reads/writes `_notes/...` and syncs through the central repo — never the client's remote.

Helper script (does all the mechanics): `~/.claude/scripts/workstation.ps1`

## Steps to execute

0. **First-run self-heal.** If `~/.claude/scripts/workstation.ps1` or
   `~/.claude/workstation.json` is missing, this machine isn't set up — perform the
   `/workstation-setup` routine first (fetch the helper from the pack's public raw URL,
   discover-or-ask the notes-repo URL, write the config, clone the notes repo), then
   continue below.

1. **Bootstrap the notes repo** (clone if missing on this machine, then pull):
   ```bash
   powershell -NoProfile -ExecutionPolicy Bypass -File "$HOME/.claude/scripts/workstation.ps1" -Action bootstrap
   ```
   If this errors with `NO_CONFIG`, the machine isn't set up yet: create
   `~/.claude/workstation.json` with `{ "notesRemote": "<git url>", "notesDir": "<local clone path>" }`
   (or just run `/workstation-setup`), then re-run.

2. **Resolve this project** to its client/project notes dir:
   ```bash
   powershell -NoProfile -ExecutionPolicy Bypass -File "$HOME/.claude/scripts/workstation.ps1" -Action resolve
   ```
   - If `found: true` → continue.
   - If `found: false` → this project has no notes dir yet. Determine the **client** and
     **project** names from existing docs (CLAUDE.md, README, the repo path). If they
     aren't clearly available, **ask the user**. Then register + create the dir:
     ```bash
     powershell -NoProfile -ExecutionPolicy Bypass -File "$HOME/.claude/scripts/workstation.ps1" -Action register -Client <client> -Project <project>
     ```

3. **Ensure the `_notes` junction exists** (creates it on a fresh machine; idempotent; also
   makes sure `.git/info/exclude` hides `_notes/` + `WORKSTATION.md` from the client repo):
   ```bash
   powershell -NoProfile -ExecutionPolicy Bypass -File "$HOME/.claude/scripts/workstation.ps1" -Action link
   ```

4. **Pull latest notes**:
   ```bash
   powershell -NoProfile -ExecutionPolicy Bypass -File "$HOME/.claude/scripts/workstation.ps1" -Action pull
   ```

5. **Rehydrate handoff state.** Read `_notes/WORKSTATION.md` and the most recent
   `_notes/*_CTS.md`. Summarize for the user: what the other machine was doing, current
   branch, uncommitted work, and the next steps.

6. **Stamp the session** into `_notes/WORKSTATION.md` (this is the file inside the junction,
   so it syncs): current machine name, session start time, current branch, latest commit hash.

7. **Project repo (read-only sync, optional).** If the project branch has an upstream,
   `git pull` it and report. Never force or stash without asking.

8. **Show summary**: uncommitted project changes, recent commits, and TODOs from
   `WORKSTATION.md`.

> Notes sync through your private notes repo. This command never commits or pushes the
> project (client) repo.
