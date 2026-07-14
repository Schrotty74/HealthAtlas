#!/usr/bin/env bash
set -euo pipefail

root="$(cd "$(dirname "$0")/.." && pwd)"
temporary_index=""
requested_version="${1:-}"

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

if ! command -v gh >/dev/null 2>&1; then
  echo "Abbruch: GitHub CLI 'gh' wurde nicht gefunden." >&2
  exit 1
fi

version="${requested_version:-${HEALTHATLAS_BETA_VERSION:-0.1.0-beta.1}}"
artifact_directory="$root/Backup/releases/beta/$version"
artifact_base="HealthAtlas-$version-macos"
zip_file="$artifact_directory/$artifact_base.zip"
dmg_file="$artifact_directory/$artifact_base.dmg"
zip_checksum_file="$zip_file.sha256"
dmg_checksum_file="$dmg_file.sha256"
release_notes_file="$artifact_directory/HealthAtlas-Beta-$version-release-notes.md"

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
  bash Scripts/build-release-package.sh beta "$version"

release_tag="v$version"
release_files=(
  "$zip_file"
  "$dmg_file"
  "$zip_checksum_file"
  "$dmg_checksum_file"
)

for artifact in "${release_files[@]}"; do
  [[ -f "$artifact" ]] || { echo "Abbruch: Release-Artefakt fehlt: $artifact" >&2; exit 1; }
done

previous_beta_tag="$(git tag --list 'v*-beta*' --sort=-version:refname | awk -v current="$release_tag" '$0 != current { print; exit }')"
release_base="${previous_beta_tag:-$(git rev-list --max-parents=0 HEAD)}"
{
  echo "# HealthAtlas Beta $version"
  echo
  echo "## Änderungen"
  git log --reverse --no-merges --format='- %s' "$release_base"..HEAD
  echo
  echo "## Datenschutz"
  echo "Die Demo ist synthetisch. Der Build enthält keine persönlichen Gesundheitsdaten; Importe bleiben lokal."
  echo
  echo "## Gatekeeper"
  echo "Der Build ist ad-hoc signiert. Im Finder mit Control-Klick auf die App klicken, „Öffnen“ wählen und anschließend bestätigen."
} > "$release_notes_file"

git push -u origin beta
if gh release view "$release_tag" >/dev/null 2>&1; then
  gh release upload "$release_tag" "${release_files[@]}" --clobber
  gh release edit "$release_tag" --prerelease --title "HealthAtlas Beta $version" --notes-file "$release_notes_file"
else
  gh release create "$release_tag" "${release_files[@]}" \
    --target "$snapshot_commit" --prerelease --title "HealthAtlas Beta $version" --notes-file "$release_notes_file"
fi

echo "Lokaler Beta-Build erstellt."
echo "Quell-Snapshot: ${snapshot_commit:0:12}"
echo "App: $root/dist/releases/beta/$version/HealthAtlas Beta.app"
echo "ZIP, DMG, Prüfsummen und Changelog: $artifact_directory"
echo "GitHub Pre-Release: $release_tag"
