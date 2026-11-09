if (-not $env:LOCALAPPDATA) {
    throw 'Uruchom ten skrypt w PowerShellu na Windows.'
}
if ($env:CODEX_ACCESS_TOKEN -or $env:CODEX_API_KEY -or $env:OPENAI_API_KEY -or $env:OPENAI_FEDERATION_RULE_ID) {
    throw 'Uzyj PowerShella bez CODEX_ACCESS_TOKEN, CODEX_API_KEY, OPENAI_API_KEY i OPENAI_FEDERATION_RULE_ID.'
}

$courseHome = Join-Path $env:LOCALAPPDATA 'JSystems/Codex-Java-2026-10'
[System.IO.Directory]::CreateDirectory($courseHome) | Out-Null
$previousCodexHome = $env:CODEX_HOME
$previousSqliteHome = $env:CODEX_SQLITE_HOME

try {
    $env:CODEX_HOME = $courseHome
    $env:CODEX_SQLITE_HOME = $courseHome
    & codex --no-daemon --cd $PSScriptRoot @args
}
finally {
    $env:CODEX_HOME = $previousCodexHome
    $env:CODEX_SQLITE_HOME = $previousSqliteHome
}
