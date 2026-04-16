# Скачивает демо-дамп Postgres Pro (версия 2025, ~133 МБ сжатых) в ../dumps/
$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
$dumps = Join-Path $root 'dumps'
New-Item -ItemType Directory -Force -Path $dumps | Out-Null
$out = Join-Path $dumps 'demo-20250901-3m.sql.gz'
$uri = 'https://edu.postgrespro.ru/demo-20250901-3m.sql.gz'
Write-Host "Downloading to $out ..."
Invoke-WebRequest -Uri $uri -OutFile $out
Write-Host "Done. Run: docker compose up --build"
