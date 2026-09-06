#!/bin/zsh

set -euo pipefail

root_directory="$(cd "$(dirname "$0")/.." && pwd)"
cd "$root_directory"

candidate_files=("${(@f)$(git ls-files --cached --others --exclude-standard)}")
for file in "${candidate_files[@]}"; do
    [[ -f "$file" ]] || continue
    normalized_file="${(L)file}"
    case "$normalized_file" in
        *.csv|*.tsv|*.db|*.sqlite|*.sqlite3|*.private.json|\
        */catalog.json|*/catalog-*.json|*/katalog.json|*/katalog-*.json|\
        */export-*.json|*/healthatlas-katalog*.json|*/healthatlas-catalog*.json)
            echo "Datenschutzprüfung fehlgeschlagen: private Datei: $file" >&2
            exit 1
            ;;
    esac
done

content_files=("${(@f)$(printf '%s\n' "${candidate_files[@]}" \
    | grep -Ev '^Scripts/privacy-(check|audit)\.sh$')}")
findings_file="/tmp/healthatlas-privacy-check.txt"
: >"$findings_file"
for file in "${content_files[@]}"; do
    grep -I -q '' "$file" 2>/dev/null || continue
    matches="$(LC_ALL=C sed 's#/Users/example/#~/#g' "$file" \
        | grep -n -E '/Users/[^/]+|/Volumes/[^/]+|serialNumber[[:space:]]*[:=][[:space:]]*"[^"$]+' || true)"
    [[ -n "$matches" ]] || continue
    while IFS= read -r match; do
        echo "$file:$match" >>"$findings_file"
    done <<<"$matches"
done
if [[ -s "$findings_file" ]]; then
    cat "$findings_file" >&2
    echo "Datenschutzprüfung fehlgeschlagen: persönlicher Pfad oder Geheimnis gefunden." >&2
    exit 1
fi

echo "Datenschutzprüfung erfolgreich."
