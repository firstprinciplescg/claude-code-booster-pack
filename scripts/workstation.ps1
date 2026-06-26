<#
  workstation.ps1 - shared mechanics for the /workstation-start, /workstation-end,
  /cts, and /rehy commands.

  Central model: ONE private repo (fpcg-working-notes) holds <client>/<project>/ dirs.
  Each project's local _notes/ is a junction into its <client>/<project>/ folder, so
  notes read/written as _notes/... in the project actually live in (and sync via) the
  central repo - never the client's repo.

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
  [ValidateSet('bootstrap', 'resolve', 'register', 'link', 'pull', 'push')]
  [string]$Action,
  [string]$Client,
  [string]$Project,
  [string]$Message,
  [string]$ProjectPath = (Get-Location).Path
)

$ErrorActionPreference = 'Stop'
$ConfigPath = Join-Path $HOME '.claude\workstation.json'

function Load-Config {
  if (-not (Test-Path $ConfigPath)) {
    throw "NO_CONFIG: $ConfigPath missing. Create it: { `"notesRemote`": `"<git url>`", `"notesDir`": `"<local clone path>`" }. See the fpcg-working-notes README."
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
    try { git pull --ff-only 2>&1 | Out-Null } finally { Pop-Location }
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
    if ($entry) {
      $dir = Join-Path (Join-Path $cfg.notesDir $entry.client) $entry.project
      Write-Output "found: true"
      Write-Output "client: $($entry.client)"
      Write-Output "project: $($entry.project)"
      Write-Output "dir: $dir"
      Write-Output "link: $(Join-Path $ProjectPath '_notes')"
      Write-Output "remoteKey: $remoteKey"
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
    Write-Output "registered: $remoteKey -> $Client/$Project"
    Write-Output "dir: $dir"
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
      if ($LASTEXITCODE -ne 0) {
        git commit -q -m $Message
        git push
        Write-Output "OK: notes synced - $Message"
      }
      else {
        Write-Output "OK: nothing to sync (notes already up to date)"
      }
    }
    finally { Pop-Location }
  }
}
