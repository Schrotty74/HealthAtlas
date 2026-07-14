#!/usr/bin/env bash
set -euo pipefail

root="$(cd "$(dirname "$0")/.." && pwd)"

mkdir -p \
  "$root/.build/dev" \
  "$root/.build/beta" \
  "$root/.build/final" \
  "$root/Backup/app-backups" \
  "$root/Backup/local-test" \
  "$root/Backup/releases/beta" \
  "$root/Backup/releases/final" \
  "$root/dist/local-test" \
  "$root/dist/releases/beta" \
  "$root/dist/releases/final"
