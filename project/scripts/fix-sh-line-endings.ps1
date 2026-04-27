# Исправляет CRLF -> LF у shell-скриптов (иначе Postgres init: "cannot execute: required file not found").
$ErrorActionPreference = 'Stop'
$projectRoot = Split-Path $PSScriptRoot -Parent
$targets = @(
    (Join-Path $projectRoot 'init-db\01_load_demo.sh'),
    (Join-Path $projectRoot 'scripts\download-demo-dump.sh')
)

foreach ($p in $targets) {
    if (-not (Test-Path $p)) { continue }
    $c = [System.IO.File]::ReadAllText($p)
    $c = $c -replace "`r`n", "`n" -replace "`r", "`n"
    $utf8NoBom = New-Object System.Text.UTF8Encoding $false
    [System.IO.File]::WriteAllText($p, $c, $utf8NoBom)
    Write-Host "OK: $p"
}
