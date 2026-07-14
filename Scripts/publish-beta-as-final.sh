#!/usr/bin/env bash
set -euo pipefail

root="$(cd "$(dirname "$0")/.." && pwd)"
cd "$root"

if ! git diff --quiet || ! git diff --cached --quiet; then
  echo "Abbruch: Final benötigt einen sauberen Git-Arbeitsstand." >&2
  echo "Der lokale Dev-Stand bleibt dadurch vor einer versehentlichen Übernahme geschützt." >&2
  exit 1
fi

if ! git show-ref --verify --quiet refs/heads/beta; then
  echo "Abbruch: Es gibt keinen lokalen beta-Branch." >&2
  echo "Zuerst Scripts/create-beta-from-dev.sh auf dem dev-Branch ausführen." >&2
  exit 1
fi

bash Scripts/prepare-build-layout.sh
bash Scripts/privacy-check.sh

git switch beta
beta_commit="$(git rev-parse --short HEAD)"
git switch main
git merge --ff-only beta

bash Scripts/build-channel.sh final

echo "Lokaler Final-Build aus beta erstellt."
echo "Beta-Commit: $beta_commit"
echo "App: $root/.build/final/DerivedData/Build/Products/Final/HealthAtlas.app"
echo "Es wurde nichts gepusht, veröffentlicht, gezippt oder signiert."
