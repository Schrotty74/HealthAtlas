#!/usr/bin/env bash
set -euo pipefail

root="$(cd "$(dirname "$0")/.." && pwd)"
temporary_index=""

cleanup() {
  rm -f "$temporary_index"
}
trap cleanup EXIT

cd "$root"
bash Scripts/prepare-build-layout.sh
bash Scripts/privacy-check.sh

if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "Abbruch: Beta benötigt ein lokales Git-Arbeitsverzeichnis." >&2
  exit 1
fi

if [[ "$(git branch --show-current)" != "dev" ]]; then
  echo "Abbruch: Beta wird nur aus dem lokalen dev-Branch erstellt." >&2
  exit 1
fi

if ! git show-ref --verify --quiet refs/heads/beta; then
  git update-ref refs/heads/beta HEAD
fi

# Use an isolated index: the developer's staged files and Dev branch remain untouched.
temporary_index="$(mktemp)"
export GIT_INDEX_FILE="$temporary_index"
git read-tree HEAD
git add -A
snapshot_tree="$(git write-tree)"
unset GIT_INDEX_FILE

beta_before="$(git rev-parse refs/heads/beta)"
if [[ "$snapshot_tree" == "$(git rev-parse "$beta_before^{tree}")" ]]; then
  snapshot_commit="$beta_before"
else
  snapshot_commit="$(printf 'Create local HealthAtlas beta snapshot from dev\n' | git commit-tree "$snapshot_tree" -p "$beta_before")"
  git update-ref refs/heads/beta "$snapshot_commit" "$beta_before"
fi

HEALTHATLAS_ALLOW_RELEASE_PACKAGE=YES \
  bash Scripts/build-release-package.sh beta "${HEALTHATLAS_BETA_VERSION:-0.1.0-beta.1}"

version="${HEALTHATLAS_BETA_VERSION:-0.1.0-beta.1}"
artifact_directory="$root/Backup/releases/beta/$version"
release_tag="v$version"

if ! command -v gh >/dev/null 2>&1; then
  echo "Abbruch: GitHub CLI 'gh' wurde nicht gefunden." >&2
  exit 1
fi

git push -u origin beta

release_files=(
  "$artifact_directory/HealthAtlas-$version-macos.zip"
  "$artifact_directory/HealthAtlas-$version-macos.dmg"
  "$artifact_directory/HealthAtlas-$version-macos.zip.sha256"
  "$artifact_directory/HealthAtlas-$version-macos.dmg.sha256"
)
release_notes=$'HealthAtlas Beta mit lokalem Apple-Health-Import, auswählbaren Kennzahlen, interaktiven Verläufen und lokalen Einblicken.\n\nGatekeeper: Dieser Build ist ad-hoc signiert. Im Finder mit Control-Klick auf die App klicken, „Öffnen“ wählen und anschließend bestätigen.\n\nDer Build enthält keine persönlichen Gesundheitsdaten.'
if gh release view "$release_tag" >/dev/null 2>&1; then
  gh release upload "$release_tag" "${release_files[@]}" --clobber
  gh release edit "$release_tag" --prerelease --title "HealthAtlas $version" --notes "$release_notes"
else
  gh release create "$release_tag" "${release_files[@]}" \
    --target beta --prerelease --title "HealthAtlas $version" --notes "$release_notes"
fi

echo "Lokaler Beta-Build erstellt."
echo "Quell-Snapshot: ${snapshot_commit:0:12}"
echo "App: $root/dist/releases/beta/${HEALTHATLAS_BETA_VERSION:-0.1.0-beta.1}/HealthAtlas Beta.app"
echo "ZIP und DMG: $root/Backup/releases/beta/${HEALTHATLAS_BETA_VERSION:-0.1.0-beta.1}/"
echo "GitHub Pre-Release: $release_tag"
