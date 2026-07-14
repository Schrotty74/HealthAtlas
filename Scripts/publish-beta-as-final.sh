#!/usr/bin/env bash
set -euo pipefail

root="$(cd "$(dirname "$0")/.." && pwd)"
version="${1:-${HEALTHATLAS_FINAL_VERSION:-0.1.0}}"
cd "$root"

if ! git diff --quiet || ! git diff --cached --quiet; then
  echo "Abbruch: Final benötigt einen sauberen Git-Arbeitsstand." >&2
  exit 1
fi
if ! git show-ref --verify --quiet refs/heads/beta; then
  echo "Abbruch: Es gibt keinen lokalen beta-Branch." >&2
  exit 1
fi
if ! command -v gh >/dev/null 2>&1; then
  echo "Abbruch: GitHub CLI 'gh' wurde nicht gefunden." >&2
  exit 1
fi

bash Scripts/prepare-build-layout.sh
bash Scripts/privacy-check.sh

git switch beta
beta_commit="$(git rev-parse --short HEAD)"
git switch main
git merge --ff-only beta

artifact_directory="$root/Backup/releases/final/$version"
artifact_base="HealthAtlas-$version-macos"
zip_file="$artifact_directory/$artifact_base.zip"
dmg_file="$artifact_directory/$artifact_base.dmg"
zip_checksum_file="$zip_file.sha256"
dmg_checksum_file="$dmg_file.sha256"
release_notes_file="$artifact_directory/HealthAtlas-$version-release-notes.md"

HEALTHATLAS_ALLOW_RELEASE_PACKAGE=YES \
  bash Scripts/build-release-package.sh final "$version"

for artifact in "$zip_file" "$dmg_file" "$zip_checksum_file" "$dmg_checksum_file"; do
  [[ -f "$artifact" ]] || { echo "Abbruch: Release-Artefakt fehlt: $artifact" >&2; exit 1; }
done

previous_final_tag="$(git tag --list 'v*' --sort=-version:refname | awk '$0 !~ /-beta/ { print; exit }')"
release_base="${previous_final_tag:-$(git rev-list --max-parents=0 HEAD)}"
{
  echo "# HealthAtlas $version"
  echo
  echo "## Änderungen"
  git log --reverse --no-merges --format='- %s' "$release_base"..HEAD
  echo
  echo "## Datenschutz"
  echo "Der Build enthält keine persönlichen Gesundheitsdaten; Importe bleiben lokal."
  echo
  echo "## Gatekeeper"
  echo "Der Build ist ad-hoc signiert. Im Finder mit Control-Klick auf die App klicken, „Öffnen“ wählen und anschließend bestätigen."
} > "$release_notes_file"

git push --set-upstream origin main
release_tag="v$version"
gh release create "$release_tag" "$zip_file" "$dmg_file" "$zip_checksum_file" "$dmg_checksum_file" \
  --target "$(git rev-parse HEAD)" --title "HealthAtlas $version" --notes-file "$release_notes_file"

echo "Final wurde aus Beta veröffentlicht."
echo "App: $root/dist/releases/final/$version/HealthAtlas.app"
echo "ZIP, DMG, Prüfsummen und Changelog: $artifact_directory"
echo "GitHub Release: $release_tag"
echo "Beta-Commit: $beta_commit"
