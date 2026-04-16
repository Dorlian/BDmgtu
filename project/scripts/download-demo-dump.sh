#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
mkdir -p "$ROOT/dumps"
OUT="$ROOT/dumps/demo-20250901-3m.sql.gz"
URI="https://edu.postgrespro.ru/demo-20250901-3m.sql.gz"
echo "Downloading to $OUT ..."
curl -L --fail --retry 3 -o "$OUT" "$URI"
echo "Done. Run: docker compose up --build"
