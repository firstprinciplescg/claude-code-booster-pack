<#
  workstation.ps1 - shared mechanics for the /workstation-start, /workstation-end,
  /cts, and /rehy commands.

  Central model: ONE private notes repo holds <client>/<project>/ dirs.
  Each project's local _notes/ is a junction into its <client>/<project>/ folder, so
  notes read/written as _notes/... in the project actually live in (and sync via) the
  central repo - never the client's repo.
  Claude Code's per-project memory (~/.claude/projects/<slug>/memory) is likewise a
  junction into <client>/<project>/_memory, so memory syncs between machines too.

  Config: ~/.claude/workstation.json  { notesRemote, notesDir, git:{userName,userEmail} }

  Usage:
    workstation.ps1 -Action bootstrap
    workstation.ps1 -Action resolve   [-ProjectPath <path>]
    workstation.ps1 -Action register  -Client <c> -Project <p> [-ProjectPath <path>]
    workstation.ps1 -Action link      [-ProjectPath <path>]
    workstation.ps1 -Action pull
    workstation.ps1 -Action push      -Message "<commit msg>"
#>
param(
  [Parameter(Mandatory = $true)]
  [ValidateSet('bootstrap', 'resolve', 'register', 'link', 'pull', 'push', 'discover', 'init-config')]
  [string]$Action,
  [string]$Client,
  [string]$Project,
  [string]$Message,
  [string]$NotesRemote,
  [string]$NotesDir,
  [string]$ProjectPath = (Get-Location).Path
)

$ErrorActionPreference = 'Stop'
$ConfigPath = Join-Path $HOME '.claude\workstation.json'

function Load-Config {
  if (-not (Test-Path $ConfigPath)) {
    throw "NO_CONFIG: $ConfigPath missing. Run /workstation-setup (or create it: { `"notesRemote`": `"<git url>`", `"notesDir`": `"<local clone path>`" })."
  }
  return (Get-Content $ConfigPath -Raw | ConvertFrom-Json)
}

function Ensure-NotesRepo($cfg) {
  if (-not (Test-Path (Join-Path $cfg.notesDir '.git'))) {
    Write-Output "Cloning notes repo -> $($cfg.notesDir)"
    git clone $cfg.notesRemote $cfg.notesDir
  }
}

function Get-NormalizedRemote([string]$path) {
  Push-Location $path
  try { $url = (git remote get-url origin 2>$null) } catch { $url = $null } finally { Pop-Location }
  if (-not $url) { return $null }
  $u = $url.Trim().ToLower()
  $u = $u -replace '^git@([^:]+):', '$1/'   # git@github.com:foo/bar -> github.com/foo/bar
  $u = $u -replace '^https?://', ''
  $u = $u -replace '^[^@/]+@', ''            # strip leading user@
  $u = $u -replace '\.git$', ''
  return $u.TrimEnd('/')
}

function Load-Registry($cfg) {
  $p = Join-Path $cfg.notesDir 'registry.json'
  if (-not (Test-Path $p)) { return [pscustomobject]@{ version = 1; projects = [pscustomobject]@{} } }
  return (Get-Content $p -Raw | ConvertFrom-Json)
}

function Save-Registry($cfg, $reg) {
  $p = Join-Path $cfg.notesDir 'registry.json'
  ($reg | ConvertTo-Json -Depth 10) | Out-File -FilePath $p -Encoding utf8
}

function Load-Marker([string]$projectPath) {
  # A committed .workstation.json in the client repo records this project's
  # <client>/<project> mapping. Present on every fresh checkout, so it resolves the
  # notes dir even when the synced registry is stale or unreachable.
  $p = Join-Path $projectPath '.workstation.json'
  if (-not (Test-Path $p)) { return $null }
  try { return (Get-Content $p -Raw | ConvertFrom-Json) } catch { return $null }
}

function Write-Marker([string]$projectPath, [string]$client, [string]$project) {
  $p = Join-Path $projectPath '.workstation.json'
  ([ordered]@{ client = $client; project = $project } | ConvertTo-Json) | Out-File -FilePath $p -Encoding utf8
  return $p
}

function Default-Slug([string]$remoteKey, [string]$projectPath) {
  # Fallback when no docs/registry: derive from remote basename, else folder name.
  if ($remoteKey) { return ($remoteKey -split '/')[-1] }
  return (Split-Path $projectPath -Leaf)
}

switch ($Action) {

  'bootstrap' {
    $cfg = Load-Config
    Ensure-NotesRepo $cfg
    Push-Location $cfg.notesDir
    # --rebase --autostash: a genuinely-unpushed local registration survives and replays on
    # top; a stale/aborted local edit no longer blocks the sync. Do NOT pipe to Out-Null or
    # redirect stderr - a swallowed failure here leaves the registry stale and cascades into
    # bad guesses downstream. Surface any real failure loudly instead of printing "OK".
    try {
      git pull --rebase --autostash
      $code = $LASTEXITCODE
    }
    finally { Pop-Location }
    if ($code -ne 0) {
      throw "PULL_FAILED: notes repo at $($cfg.notesDir) could not sync (exit $code). Resolve manually there, then re-run bootstrap."
    }
    Write-Output "OK: notes repo ready at $($cfg.notesDir)"
  }

  'resolve' {
    $cfg = Load-Config
    Ensure-NotesRepo $cfg
    $remoteKey = Get-NormalizedRemote $ProjectPath
    $reg = Load-Registry $cfg
    $entry = $null
    if ($remoteKey -and $reg.projects.PSObject.Properties.Name -contains $remoteKey) {
      $entry = $reg.projects.$remoteKey
    }
    # Fallback: the committed .workstation.json marker. Lets a fresh machine resolve the
    # mapping without guessing when the synced registry hasn't got this project yet.
    $viaMarker = $false
    if (-not $entry) {
      $marker = Load-Marker $ProjectPath
      if ($marker -and $marker.client -and $marker.project) {
        $entry = [pscustomobject]@{ client = $marker.client; project = $marker.project }
        $viaMarker = $true
        # Self-heal: seed the registry so later resolves are fast and the mapping syncs.
        if ($remoteKey) {
          $reg.projects | Add-Member -NotePropertyName $remoteKey -NotePropertyValue $entry -Force
          Save-Registry $cfg $reg
        }
      }
    }
    if ($entry) {
      $dir = Join-Path (Join-Path $cfg.notesDir $entry.client) $entry.project
      if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Path $dir -Force | Out-Null }
      Write-Output "found: true"
      Write-Output "client: $($entry.client)"
      Write-Output "project: $($entry.project)"
      Write-Output "dir: $dir"
      Write-Output "link: $(Join-Path $ProjectPath '_notes')"
      Write-Output "remoteKey: $remoteKey"
      if ($viaMarker) { Write-Output "note: resolved via .workstation.json marker; registry healed." }
    }
    else {
      Write-Output "found: false"
      Write-Output "remoteKey: $remoteKey"
      Write-Output "suggestedProject: $(Default-Slug $remoteKey $ProjectPath)"
      Write-Output "note: not in registry - ask user for client + project, then call -Action register."
    }
  }

  'register' {
    if (-not $Client -or -not $Project) { throw "register requires -Client and -Project" }
    $cfg = Load-Config
    Ensure-NotesRepo $cfg
    $remoteKey = Get-NormalizedRemote $ProjectPath
    if (-not $remoteKey) { $remoteKey = "local/" + (Split-Path $ProjectPath -Leaf) }
    $reg = Load-Registry $cfg
    $reg.projects | Add-Member -NotePropertyName $remoteKey -NotePropertyValue ([pscustomobject]@{ client = $Client; project = $Project }) -Force
    Save-Registry $cfg $reg
    $dir = Join-Path (Join-Path $cfg.notesDir $Client) $Project
    if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Path $dir -Force | Out-Null }
    # Drop a committed marker in the client repo so any fresh machine resolves this mapping
    # without guessing (belt-and-suspenders for a stale/unreachable registry). Just two names.
    $markerPath = Write-Marker $ProjectPath $Client $Project
    Write-Output "registered: $remoteKey -> $Client/$Project"
    Write-Output "dir: $dir"
    Write-Output "marker: $markerPath  (commit this to the project repo)"
  }

  'link' {
    $cfg = Load-Config
    $remoteKey = Get-NormalizedRemote $ProjectPath
    $reg = Load-Registry $cfg
    if (-not ($remoteKey -and $reg.projects.PSObject.Properties.Name -contains $remoteKey)) {
      throw "NOT_REGISTERED: run -Action register first."
    }
    $entry = $reg.projects.$remoteKey
    $target = Join-Path (Join-Path $cfg.notesDir $entry.client) $entry.project
    if (-not (Test-Path $target)) { New-Item -ItemType Directory -Path $target -Force | Out-Null }
    # Backfill the committed marker for projects registered before markers existed.
    if (-not (Load-Marker $ProjectPath)) { Write-Marker $ProjectPath $entry.client $entry.project | Out-Null }
    $link = Join-Path $ProjectPath '_notes'

    if (Test-Path $link) {
      $item = Get-Item $link -Force
      if ($item.LinkType -eq 'Junction') {
        Write-Output "OK: junction already present -> $($item.Target -join ',')"
      }
      else {
        throw "EXISTS_REAL_DIR: $link is a real directory, not a junction. Migrate its contents into $target, remove it, then re-run link."
      }
    }
    else {
      New-Item -ItemType Junction -Path $link -Target $target | Out-Null
      Write-Output "OK: created junction $link -> $target"
    }

    # Ensure the client repo locally ignores the junction (never commit notes to a client remote).
    $exclude = Join-Path $ProjectPath '.git\info\exclude'
    if (Test-Path $exclude) {
      $lines = Get-Content $exclude
      if ($lines -notcontains '_notes/') { Add-Content $exclude '_notes/' }
      if ($lines -notcontains 'WORKSTATION.md') { Add-Content $exclude 'WORKSTATION.md' }
      Write-Output "OK: .git/info/exclude covers _notes/ and WORKSTATION.md"
    }

    # Claude Code per-project memory lives OUTSIDE the project, at
    # ~/.claude/projects/<slug>/memory, where <slug> is the absolute project path with every
    # non-alphanumeric char replaced by '-'. The slug is computed per machine, so differing
    # usernames/paths across machines still land on the same central <client>/<project>/_memory.
    $memTarget = Join-Path $target '_memory'
    if (-not (Test-Path $memTarget)) { New-Item -ItemType Directory -Path $memTarget -Force | Out-Null }
    $slug = ($ProjectPath.TrimEnd('\', '/')) -replace '[^A-Za-z0-9]', '-'
    $memParent = Join-Path (Join-Path (Join-Path $HOME '.claude') 'projects') $slug
    if (-not (Test-Path $memParent)) { New-Item -ItemType Directory -Path $memParent -Force | Out-Null }
    $memLink = Join-Path $memParent 'memory'

    if (Test-Path $memLink) {
      $mi = Get-Item $memLink -Force
      if ($mi.LinkType -eq 'Junction') {
        Write-Output "OK: memory junction already present -> $($mi.Target -join ',')"
      }
      else {
        # First link on this machine: Claude already created a real memory dir. Copy in any
        # files the central copy lacks (never overwrite), keep the local dir as a backup,
        # then replace it with the junction. Differing same-name files are reported, not merged.
        $conflicts = @()
        Get-ChildItem $memLink -File -Force | ForEach-Object {
          $dest = Join-Path $memTarget $_.Name
          if (-not (Test-Path $dest)) { Copy-Item $_.FullName $dest }
          elseif ((Get-FileHash $dest).Hash -ne (Get-FileHash $_.FullName).Hash) { $conflicts += $_.Name }
        }
        $backup = "$memLink.bak-" + (Get-Date -Format 'yyyyMMdd-HHmmss')
        Rename-Item -Path $memLink -NewName (Split-Path $backup -Leaf)
        New-Item -ItemType Junction -Path $memLink -Target $memTarget | Out-Null
        Write-Output "OK: migrated memory into $memTarget and created junction $memLink"
        Write-Output "backup: $backup"
        if ($conflicts.Count -gt 0) {
          Write-Output "WARN: MEMORY_CONFLICT - central copy kept; local versions are in the backup: $($conflicts -join ', ')"
        }
      }
    }
    else {
      New-Item -ItemType Junction -Path $memLink -Target $memTarget | Out-Null
      Write-Output "OK: created memory junction $memLink -> $memTarget"
    }
  }

  'pull' {
    $cfg = Load-Config
    Ensure-NotesRepo $cfg
    Push-Location $cfg.notesDir
    try { git pull --ff-only } finally { Pop-Location }
  }

  'push' {
    if (-not $Message) { throw "push requires -Message" }
    $cfg = Load-Config
    Push-Location $cfg.notesDir
    try {
      if ($cfg.git -and $cfg.git.userName) { git config user.name $cfg.git.userName }
      if ($cfg.git -and $cfg.git.userEmail) { git config user.email $cfg.git.userEmail }
      git add -A
      git diff --cached --quiet
      if ($LASTEXITCODE -eq 0) {
        Write-Output "OK: nothing to sync (notes already up to date)"
      }
      else {
        git commit -q -m $Message
        # Integrate commits pushed from another machine before pushing, so a
        # non-fast-forward doesn't leave this commit stranded locally.
        git pull --rebase 2>&1 | Out-Null
        if ($LASTEXITCODE -ne 0) {
          git rebase --abort 2>&1 | Out-Null
          throw "SYNC_CONFLICT: the notes repo has diverging remote changes needing a manual merge in $($cfg.notesDir). Your commit is saved locally - resolve there and re-run push."
        }
        git push
        if ($LASTEXITCODE -ne 0) {
          throw "PUSH_FAILED: rebased cleanly but push was rejected. Check $($cfg.notesDir)."
        }
        Write-Output "OK: notes synced - $Message"
      }
    }
    finally { Pop-Location }
  }

  'discover' {
    # Find the user's private notes repo via the 'workstation-notes' GitHub topic, then
    # a name-pattern fallback. Prints the clone URL (with .git) or nothing. Never throws -
    # callers treat empty output as "not found, ask the user".
    $found = ''
    try {
      $login = (gh api user --jq .login 2>$null)
      if ($login) {
        $json = gh search repos --owner=$login --topic=workstation-notes --json url --limit 5 2>$null
        if ($json) {
          $items = $json | ConvertFrom-Json
          if ($items -and $items.Count -ge 1) { $found = $items[0].url }
        }
      }
    }
    catch {}
    if (-not $found) {
      try {
        $json = gh repo list --json name, url --limit 300 2>$null
        if ($json) {
          $m = ($json | ConvertFrom-Json) | Where-Object { $_.name -match '(working|workstation)-notes$' } | Select-Object -First 1
          if ($m) { $found = $m.url }
        }
      }
      catch {}
    }
    if ($found) {
      if ($found -notmatch '\.git$') { $found = "$found.git" }
      Write-Output $found
    }
  }

  'init-config' {
    if (-not $NotesRemote) { throw "init-config requires -NotesRemote" }
    $dir = Split-Path $ConfigPath -Parent
    if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Path $dir -Force | Out-Null }
    $repoName = (($NotesRemote -split '/')[-1]) -replace '\.git$', ''
    if (-not $NotesDir) { $NotesDir = (Join-Path (Join-Path $HOME '.claude') $repoName) }
    # Identity for the notes-repo commits. Prefer global git config; fall back to the
    # authed gh account so a fresh machine needs no manual git setup.
    $gitName = ''; $gitEmail = ''
    try { $gitName = (git config --global user.name) } catch {}
    try { $gitEmail = (git config --global user.email) } catch {}
    if (-not $gitName) { try { $gitName = (gh api user --jq .login 2>$null) } catch {} }
    if (-not $gitEmail) { try { $gitEmail = (gh api user --jq '.email // empty' 2>$null) } catch {} }
    if (-not $gitEmail -and $gitName) { $gitEmail = "$gitName@users.noreply.github.com" }
    $cfg = [ordered]@{
      notesRemote = $NotesRemote
      notesDir    = ($NotesDir -replace '\\', '/')
      git         = [ordered]@{ userName = "$gitName"; userEmail = "$gitEmail" }
    }
    ($cfg | ConvertTo-Json -Depth 5) | Out-File -FilePath $ConfigPath -Encoding utf8
    Write-Output "OK: wrote $ConfigPath"
    Write-Output "notesRemote: $NotesRemote"
    Write-Output "notesDir: $($cfg.notesDir)"
  }
}
