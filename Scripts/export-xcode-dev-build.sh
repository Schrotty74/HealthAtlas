#!/opt/homebrew/bin/bash
set -euo pipefail

# Xcode uses its own DerivedData folder. After a direct Dev build, copy the
# runnable app to the same stable location used by Scripts/build-development.sh.
[[ "${CONFIGURATION:-}" == "Dev" ]] || exit 0

root="$(cd "$(dirname "$0")/.." && pwd)"
source_app="${BUILT_PRODUCTS_DIR:-}/HealthAtlas.app"
output_directory="$root/dist/local-test/HealthAtlas-Development"
output_app="$output_directory/HealthAtlas Dev.app"

[[ -d "$source_app" ]] || {
  echo "Dev-Export abgebrochen: Xcode-App fehlt: $source_app" >&2
  exit 1
}

rm -rf "$output_directory"
mkdir -p "$output_directory"
ditto "$source_app" "$output_app"
codesign --force --deep --sign - "$output_app"
codesign --verify --deep --strict "$output_app"
echo "Lokaler Dev-Build: $output_app"
