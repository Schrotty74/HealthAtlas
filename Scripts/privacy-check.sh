#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

fail=0
forbidden='(/Users/|/Volumes/|/private/var/|/tmp/|access_token|client_secret|PRIVATE KEY|BEGIN RSA|BEGIN OPENSSH|\.sqlite$|\.db$|\.jsonl$)'

if rg -n -i "$forbidden" --glob '!Scripts/privacy-check.sh' --glob '!Docs/**' --glob '!.git/**' .; then
  echo "Privacy check failed: possible private data, path, credential, or local database detected."
  fail=1
fi

if find . \
    \( -path './.git' -o -path './.build' -o -path './Backup' -o -path './dist' \) -prune -o \
    -type f \( -name '*.dmg' -o -name '*.zip' -o -name '*.log' -o -name '*.ips' \) -print \
    | rg -q .; then
  echo "Privacy check failed: release or diagnostic artifacts must not be staged in the source tree."
  fail=1
fi

if [[ "$fail" -ne 0 ]]; then exit 1; fi
echo "Privacy check passed: no known private paths, credentials, health exports, or release artifacts detected."
