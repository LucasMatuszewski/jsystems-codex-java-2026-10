$ErrorActionPreference = 'Stop'
$glab = (Get-Command glab -CommandType Application -ErrorAction Stop | Select-Object -First 1).Source
$temporaryConfig = Join-Path ([System.IO.Path]::GetTempPath()) ("glab-szkolenie-" + [guid]::NewGuid())
$settings = @{
    GLAB_CONFIG_DIR = $temporaryConfig
    GITLAB_HOST = 'gitlab-devpowers.polandcentral.cloudapp.azure.com'
    GITLAB_API_HOST = 'gitlab-devpowers.polandcentral.cloudapp.azure.com'
    GITLAB_REPO = 'https://gitlab-devpowers.polandcentral.cloudapp.azure.com/lucas/dogrywka-jftp'
    GLAB_API_PROTOCOL = 'https'
    GLAB_ENABLE_CI_AUTOLOGIN = 'false'
    GLAB_DEBUG = 'false'
    GLAB_DEBUG_HTTP = 'false'
    GLAB_SKIP_TLS_VERIFY = 'false'
    GLAB_CHECK_UPDATE = 'false'
    GITLAB_TOKEN = $null
    GITLAB_ACCESS_TOKEN = $null
    OAUTH_TOKEN = $null
    CI_JOB_TOKEN = $null
    GITLAB_SUBFOLDER = $null
    GIT_ASKPASS = $null
    SSH_ASKPASS = $null
    GIT_TERMINAL_PROMPT = '1'
}
$previous = @{}
foreach ($name in $settings.Keys) {
    $previous[$name] = [Environment]::GetEnvironmentVariable($name, 'Process')
}

try {
    foreach ($name in $settings.Keys) {
        if ($null -eq $settings[$name]) {
            Remove-Item -LiteralPath "Env:$name" -ErrorAction SilentlyContinue
        }
        else {
            [Environment]::SetEnvironmentVariable($name, $settings[$name], 'Process')
        }
    }
    [System.IO.Directory]::CreateDirectory($temporaryConfig) | Out-Null
    $token = Read-Host 'Token GitLab otrzymany od trenera' -AsSecureString
    $env:GITLAB_TOKEN = [Net.NetworkCredential]::new('', $token).Password
    if (-not $env:GITLAB_TOKEN) {
        throw 'Token jest pusty.'
    }
    $response = & $glab api user --hostname $env:GITLAB_HOST
    if ($LASTEXITCODE -ne 0) {
        throw "glab api user - kod wyjscia $LASTEXITCODE"
    }
    $account = $response | ConvertFrom-Json
    Write-Host "GitLab szkoleniowy - konto $($account.username)"
    Write-Host 'Projekt dogrywka-jftp, MR 1. Polecenia do cwiczenia'
    Write-Host '  glab mr view 1'
    Write-Host '  glab mr diff 1'
    Write-Host 'Zamknij sesje poleceniem exit.'
    Push-Location -LiteralPath $PSScriptRoot
    try {
        & (Get-Process -Id $PID).Path -NoProfile
    }
    finally {
        Pop-Location
    }
}
finally {
    foreach ($name in $settings.Keys) {
        if ($null -eq $previous[$name]) {
            Remove-Item -LiteralPath "Env:$name" -ErrorAction SilentlyContinue
        }
        else {
            [Environment]::SetEnvironmentVariable($name, $previous[$name], 'Process')
        }
    }
    if (Test-Path -LiteralPath $temporaryConfig) {
        Remove-Item -LiteralPath $temporaryConfig -Recurse -Force
    }
}
