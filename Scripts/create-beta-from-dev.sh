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

echo "Lokaler Beta-Build erstellt."
echo "Quell-Snapshot: ${snapshot_commit:0:12}"
echo "App: $root/dist/releases/beta/${HEALTHATLAS_BETA_VERSION:-0.1.0-beta.1}/HealthAtlas Beta.app"
echo "ZIP und DMG: $root/Backup/releases/beta/${HEALTHATLAS_BETA_VERSION:-0.1.0-beta.1}/"
