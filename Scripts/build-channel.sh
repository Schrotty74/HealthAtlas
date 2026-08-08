#!/usr/bin/env bash
set -euo pipefail

channel="${1:-}"
case "$channel" in
  dev) scheme="HealthAtlas Dev"; configuration="Dev" ;;
  beta) scheme="HealthAtlas Dev"; configuration="Beta" ;;
  final) scheme="HealthAtlas Dev"; configuration="Final" ;;
  *) echo "Usage: bash Scripts/build-channel.sh {dev|beta|final}" >&2; exit 64 ;;
esac

root="$(cd "$(dirname "$0")/.." && pwd)"
build_root="${HEALTHATLAS_BUILD_ROOT:-$root}"
derived_data="$build_root/.build/$channel/DerivedData"

# Each channel begins without app-owned state and never touches another channel.
bash "$root/Scripts/clean-channel-state.sh" "$channel"
mkdir -p "$build_root/.build/$channel"
rm -rf "$derived_data"

HEALTHATLAS_SKIP_SCHEME_CLEAN=YES xcodebuild \
  -project "$root/HealthAtlas.xcodeproj" \
  -scheme "$scheme" \
  -configuration "$configuration" \
  -derivedDataPath "$derived_data" \
  build

# The compiler cache stays private under .build; every usable Dev app is written
# to the same stable local-test location as AppAtlas.
if [[ "$channel" == "dev" ]]; then
  app_source="$derived_data/Build/Products/$configuration/HealthAtlas.app"
  output_directory="$root/dist/local-test/HealthAtlas-Development"
  app_bundle="$output_directory/HealthAtlas Dev.app"
  rm -rf "$output_directory"
  mkdir -p "$output_directory"
  ditto "$app_source" "$app_bundle"
  codesign --force --deep --sign - "$app_bundle"
  codesign --verify --deep --strict "$app_bundle"
  echo "Lokaler Dev-Build: $app_bundle"
fi
