---
description: One-time per-machine setup for the cross-machine workstation notes system
---

# /workstation-setup

Bootstrap this machine so `/workstation-start`, `/workstation-end`, `/cts`, and `/rehy`
work. Run once per machine — afterward everything is automatic. The other commands also
call this routine automatically (their "Step 0") if they detect the machine isn't set up,
so you rarely need to run it by hand.

**This is generic and safe to publish.** The only personal value — your private notes-repo
URL — is never stored in this pack; it is discovered or asked for at runtime and saved only
to the local `~/.claude/workstation.json`.

## Prerequisites
- `gh` authenticated (`gh auth status`) — used to discover your notes repo and as the git
  identity fallback.
- `git` and either `curl` or PowerShell available (both ship with Git for Windows / Win10+).

## Steps (Claude: execute in order; skip a step if already satisfied)

### 1. Ensure the helper script exists
The helper lives at `~/.claude/scripts/workstation.ps1`. If missing, fetch it from this
pack's **public** raw URL (no auth needed):
```bash
mkdir -p ~/.claude/scripts
[ -f ~/.claude/scripts/workstation.ps1 ] || \
  curl -fsSL https://raw.githubusercontent.com/firstprinciplescg/claude-code-booster-pack/master/scripts/workstation.ps1 \
    -o ~/.claude/scripts/workstation.ps1
```
PowerShell fallback if `curl` is unavailable:
```powershell
$dst = "$HOME/.claude/scripts"; New-Item -ItemType Directory -Force $dst | Out-Null
if (-not (Test-Path "$dst/workstation.ps1")) {
  Invoke-WebRequest -UseBasicParsing -Uri "https://raw.githubusercontent.com/firstprinciplescg/claude-code-booster-pack/master/scripts/workstation.ps1" -OutFile "$dst/workstation.ps1"
}
```

### 2. Ensure the config exists (`~/.claude/workstation.json`)
- If the file already exists → **skip to step 3.**
- Otherwise, find the private notes repo, preferring zero prompts:
  ```bash
  powershell -NoProfile -ExecutionPolicy Bypass -File "$HOME/.claude/scripts/workstation.ps1" -Action discover
  ```
  - If it prints a URL → use that as `<notes-url>`.
  - If it prints **nothing** → ask the user: *"What's the git URL of your private working-notes repo?"* and use their answer as `<notes-url>`. (Tip for the user: add the GitHub topic `workstation-notes` to that repo so future machines auto-discover it.)
- Write the config (derives `notesDir` default + git identity from gh):
  ```bash
  powershell -NoProfile -ExecutionPolicy Bypass -File "$HOME/.claude/scripts/workstation.ps1" -Action init-config -NotesRemote "<notes-url>"
  ```

### 3. Clone/refresh the notes repo
```bash
powershell -NoProfile -ExecutionPolicy Bypass -File "$HOME/.claude/scripts/workstation.ps1" -Action bootstrap
```

### 4. Confirm
Report the resolved `notesRemote` and `notesDir` (from `~/.claude/workstation.json`) and
tell the user setup is complete — they can now run `/workstation-start` in any project.

> Per-project linking (creating the `_notes` junction) happens in `/workstation-start`,
> `/workstation-end`, and `/cts`, not here. This command only prepares the machine.
