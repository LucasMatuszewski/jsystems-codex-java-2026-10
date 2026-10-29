<#
Opens a separate "Codex KURS" PowerShell window for the course on your own Windows laptop.
Your normal Codex, VS Code, glab and Git settings stay untouched:
  - Codex state (login, history, config)  -> %USERPROFILE%\CodexKurs\codex-home
  - VS Code settings and extensions       -> %USERPROFILE%\CodexKurs\vscode-*
  - glab login                            -> %USERPROFILE%\CodexKurs\glab
  - Git global writes                     -> %USERPROFILE%\CodexKurs\gitconfig (reads your ~/.gitconfig)
  - Course repositories                   -> %USERPROFILE%\CodexKurs\repos
Nothing is written to $PROFILE, user/machine environment variables or %USERPROFILE%\.codex.
Re-running reuses the same folders (log in once, keep it for day 3). Remove the course setup by
closing the KURS windows and deleting %USERPROFILE%\CodexKurs.

Usage (from any PowerShell):
  powershell -NoProfile -ExecutionPolicy Bypass -File .\Start-CodexKurs.ps1           # KURS terminal
  powershell -NoProfile -ExecutionPolicy Bypass -File .\Start-CodexKurs.ps1 -VSCode   # + isolated VS Code
  powershell -NoProfile -ExecutionPolicy Bypass -File .\Start-CodexKurs.ps1 -Check    # print state, open nothing
#>
param([switch]$VSCode, [switch]$Check)
$ErrorActionPreference = 'Stop'

$Root = Join-Path $env:USERPROFILE 'CodexKurs'
$Dirs = [ordered]@{
  CodexHome = Join-Path $Root 'codex-home'
  Repos     = Join-Path $Root 'repos'
  Glab      = Join-Path $Root 'glab'
  VsData    = Join-Path $Root 'vscode-data'
  VsExt     = Join-Path $Root 'vscode-extensions'
}
foreach ($d in $Dirs.Values) { New-Item -ItemType Directory -Force -Path $d | Out-Null }

$Utf8NoBom = New-Object System.Text.UTF8Encoding($false)

# Codex: file-based login inside the course home, ChatGPT login only. Written once, never overwritten.
$CodexConfig = Join-Path $Dirs.CodexHome 'config.toml'
if (-not (Test-Path -LiteralPath $CodexConfig)) {
  [IO.File]::WriteAllText($CodexConfig, @"
cli_auth_credentials_store = "file"
forced_login_method = "chatgpt"
approval_policy = "on-request"
sandbox_mode = "workspace-write"
"@, $Utf8NoBom)
}

# Git: writes go to the course file; your global config is still read (identity, proxy, certificates).
$GitConfig = Join-Path $Root 'gitconfig'
if (-not (Test-Path -LiteralPath $GitConfig)) {
  $UserGitConfig = (Join-Path $env:USERPROFILE '.gitconfig') -replace '\\', '/'
  [IO.File]::WriteAllText($GitConfig, "[include]`n`tpath = $UserGitConfig`n", $Utf8NoBom)
}

# VS Code: separate settings; integrated terminal without your profile scripts.
$VsUser = Join-Path $Dirs.VsData 'User'
New-Item -ItemType Directory -Force -Path $VsUser | Out-Null
$VsSettings = Join-Path $VsUser 'settings.json'
if (-not (Test-Path -LiteralPath $VsSettings)) {
  [IO.File]::WriteAllText($VsSettings, @'
{
  "window.restoreWindows": "none",
  "chatgpt.runCodexInWindowsSubsystemForLinux": false,
  "terminal.integrated.profiles.windows": {
    "KURS PowerShell": { "path": "powershell.exe", "args": ["-NoLogo", "-NoProfile"] }
  },
  "terminal.integrated.defaultProfile.windows": "KURS PowerShell"
}
'@, $Utf8NoBom)
}

# Environment for the KURS window only (inherited by everything started from it).
$env:CODEX_HOME = $Dirs.CodexHome
$env:CODEX_SQLITE_HOME = $Dirs.CodexHome
$env:GLAB_CONFIG_DIR = $Dirs.Glab
$env:GIT_CONFIG_GLOBAL = $GitConfig
foreach ($n in 'OPENAI_API_KEY','CODEX_API_KEY','CODEX_ACCESS_TOKEN','OPENAI_BASE_URL','AZURE_OPENAI_API_KEY',
               'GITLAB_TOKEN','GLAB_TOKEN','GITLAB_HOST','GH_TOKEN','GITHUB_TOKEN') {
  Remove-Item -LiteralPath "Env:$n" -ErrorAction SilentlyContinue
}

$Missing = @('codex','git','glab','code') | Where-Object { -not (Get-Command $_ -ErrorAction SilentlyContinue) }

if ($Check) {
  "CodexKurs root : $Root"
  "CODEX_HOME     : $env:CODEX_HOME"
  "GLAB_CONFIG_DIR: $env:GLAB_CONFIG_DIR"
  "GIT global file: $env:GIT_CONFIG_GLOBAL"
  "Codex login in course home: " + (Test-Path -LiteralPath (Join-Path $Dirs.CodexHome 'auth.json'))
  "Missing tools  : " + ($(if ($Missing) { $Missing -join ', ' } else { 'none' }))
  return
}

if ($VSCode) {
  if ($Missing -contains 'code') { throw 'VS Code (code) is not on PATH.' }
  $VsArgs = @('--user-data-dir', $Dirs.VsData, '--extensions-dir', $Dirs.VsExt)
  if (-not (& code @VsArgs --list-extensions | Select-String -SimpleMatch -Quiet 'openai.chatgpt')) {
    & code @VsArgs --install-extension openai.chatgpt | Out-Host
  }
  & code @VsArgs --new-window $Dirs.Repos
}

$Banner = "Write-Host 'Codex KURS - osobny CODEX_HOME, glab i Git. Zamknij okno, by wrócić do swoich ustawień.' -ForegroundColor Cyan; " +
          "`$Host.UI.RawUI.WindowTitle = 'Codex KURS'; Set-Location -LiteralPath '$($Dirs.Repos)'"
if ($Missing) { $Banner += "; Write-Host 'Brakuje: $($Missing -join ', ')' -ForegroundColor Yellow" }
Start-Process powershell.exe -ArgumentList '-NoExit', '-NoLogo', '-NoProfile', '-Command', $Banner
