if (-not $env:LOCALAPPDATA) {
    throw 'Uruchom ten skrypt w PowerShellu na Windows.'
}
$courseHome = Join-Path $env:LOCALAPPDATA 'JSystems/Codex-Java-2026-10'
[System.IO.Directory]::CreateDirectory($courseHome) | Out-Null
$authNames = @('CODEX_ACCESS_TOKEN', 'CODEX_API_KEY', 'OPENAI_API_KEY', 'OPENAI_FEDERATION_RULE_ID')
$previous = @{}
foreach ($name in @('CODEX_HOME', 'CODEX_SQLITE_HOME') + $authNames) {
    $previous[$name] = [Environment]::GetEnvironmentVariable($name, 'Process')
}

try {
    foreach ($name in $authNames) {
        Remove-Item -LiteralPath "Env:$name" -ErrorAction SilentlyContinue
    }
    $env:CODEX_HOME = $courseHome
    $env:CODEX_SQLITE_HOME = $courseHome
    & codex --no-daemon --cd $PSScriptRoot @args
}
finally {
    foreach ($name in $previous.Keys) {
        if ($null -eq $previous[$name]) {
            Remove-Item -LiteralPath "Env:$name" -ErrorAction SilentlyContinue
        }
        else {
            [Environment]::SetEnvironmentVariable($name, $previous[$name], 'Process')
        }
    }
}
