#!/bin/zsh

set -euo pipefail

if [[ "${HEALTHATLAS_ALLOW_BACKUP:-}" != "YES" ]]; then
    echo "Backup abgebrochen: ausdrückliche Freigabe fehlt." >&2
    echo "Nur nach Benutzerfreigabe mit HEALTHATLAS_ALLOW_BACKUP=YES ausführen." >&2
    exit 1
fi

root_directory="$(cd "$(dirname "$0")/.." && pwd)"
version="${HEALTHATLAS_VERSION:-0.1.0-beta.1}"
timestamp="${HEALTHATLAS_BACKUP_TIMESTAMP:-$(date '+%Y-%m-%d_%H-%M-%S')}"
case "$version" in
    *local*|*test*)
        artifact_directory="$root_directory/Backup/local-test/$version"
        release_notes_file="$artifact_directory/HealthAtlas-$version-release-notes.md"
        ;;
    *beta*)
        artifact_directory="$root_directory/Backup/releases/beta/$version"
        release_notes_file="$artifact_directory/HealthAtlas-Beta-$version-release-notes.md"
        ;;
    *)
        artifact_directory="$root_directory/Backup/releases/final/$version"
        release_notes_file="$artifact_directory/HealthAtlas-$version-release-notes.md"
        ;;
esac
local_backup_directory="$root_directory/Backup/app-backups"
icloud_backup_directory="${HEALTHATLAS_ICLOUD_BACKUP_DIRECTORY:-$HOME/Library/Mobile Documents/com~apple~CloudDocs/Backup/Apps/Codex}"
artifact_base="HealthAtlas-$version-macos"
build_zip="$artifact_directory/$artifact_base.zip"
checksum_file="$build_zip.sha256"
staging_directory="$root_directory/.build/backup/HealthAtlas-$version"
backup_name="HealthAtlas-Backup-$version-$timestamp.zip"
local_backup="$local_backup_directory/$backup_name"

for required_file in "$build_zip" "$checksum_file" "$release_notes_file"; do
    if [[ ! -f "$required_file" ]]; then
        echo "Erforderliche Datei fehlt: $required_file" >&2
        exit 1
    fi
done

rm -rf "$staging_directory"
mkdir -p "$staging_directory" "$local_backup_directory"

cp "$build_zip" "$staging_directory/"
cp "$checksum_file" "$staging_directory/"
cp "$release_notes_file" "$staging_directory/CHANGELOG-$version.md"

rm -f "$local_backup"
(
    cd "$(dirname "$staging_directory")"
    zip -X -q -r "$local_backup" "$(basename "$staging_directory")"
)
local_checksum="$(shasum -a 256 "$local_backup" | awk '{print $1}')"

echo "Build-Backup erstellt:"
echo "  $local_backup"
if [[ -n "$icloud_backup_directory" ]]; then
    mkdir -p "$icloud_backup_directory"
    icloud_backup="$icloud_backup_directory/$backup_name"
    cp "$local_backup" "$icloud_backup"
    icloud_checksum="$(shasum -a 256 "$icloud_backup" | awk '{print $1}')"
    if [[ "$local_checksum" != "$icloud_checksum" ]]; then
        echo "Die optionale Kopie stimmt nicht mit dem lokalen Backup überein." >&2
        exit 1
    fi

    healthatlas_icloud_backups=(
        "${(@f)$(find "$icloud_backup_directory" \
            -maxdepth 1 \
            -type f \
            -name 'HealthAtlas-Backup-*.zip' \
            -print \
            | sort)}"
    )
    while (( ${#healthatlas_icloud_backups[@]} > 2 )); do
        oldest_backup="${healthatlas_icloud_backups[1]}"
        rm -f "$oldest_backup"
        echo "Ältestes HealthAtlas-iCloud-Backup entfernt:"
        echo "  $oldest_backup"
        healthatlas_icloud_backups=("${healthatlas_icloud_backups[@]:1}")
    done

    echo "Optionale Kopie erstellt:"
    echo "  $icloud_backup"
fi
echo "SHA-256:"
echo "  $local_checksum"
