#!/bin/zsh

set -euo pipefail

root_directory="$(cd "$(dirname "$0")/.." && pwd)"
cd "$root_directory"

"$root_directory/Scripts/privacy-check.sh"

sensitive_paths="$(
    git rev-list --objects --all \
        | grep -Ei '\.(csv|tsv|db|sqlite|sqlite3|jsonl|zip|dmg|pkg|iso)$|(^|/)(catalog|katalog|export)[^/]*\.json$' \
        | grep -Eiv '^[0-9a-f]+ Backup/releases/(beta|final)/HealthAtlas(-Beta)?-[0-9][^/]*-macos\.(zip|dmg)$|^[0-9a-f]+ Backup/app-backups/HealthAtlas-Backup-[^/]+\.zip$' \
        || true
)"
if [[ -n "$sensitive_paths" ]]; then
    echo "$sensitive_paths" >&2
    echo "Datenschutzaudit fehlgeschlagen: sensible Datei in der Git-Historie." >&2
    exit 1
fi

tracked_files=("${(@f)$(git ls-files)}")
content_files=("${(@f)$(printf '%s\n' "${tracked_files[@]}" \
    | grep -Ev '^Scripts/privacy-(check|audit)\.sh$')}")
if grep -I -n -E '/Users/[^/]+|/Volumes/[^/]+|serialNumber[[:space:]]*[:=][[:space:]]*"[^"$]+' \
    "${content_files[@]}" >/tmp/healthatlas-privacy-audit.txt 2>/dev/null; then
    cat /tmp/healthatlas-privacy-audit.txt >&2
    echo "Datenschutzaudit fehlgeschlagen: persönlicher Pfad oder Geheimnis gefunden." >&2
    exit 1
fi

history_findings="/tmp/healthatlas-privacy-history-audit.txt"
rm -f "$history_findings"
for commit in "${(@f)$(git rev-list --all)}"; do
    git grep -I -n -E \
        '/Users/[^/]+|/Volumes/[^/]+|serialNumber[[:space:]]*[:=][[:space:]]*"[^"$]+' \
        "$commit" -- . ':!Scripts/privacy-check.sh' ':!Scripts/privacy-audit.sh' \
        >>"$history_findings" 2>/dev/null || true
done
if [[ -s "$history_findings" ]]; then
    cat "$history_findings" >&2
    echo "Datenschutzaudit fehlgeschlagen: Fund in der Git-Historie." >&2
    exit 1
fi

echo "Erweitertes Datenschutzaudit erfolgreich."
