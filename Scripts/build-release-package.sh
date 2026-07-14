#!/usr/bin/env bash
set -euo pipefail

if [[ "${HEALTHATLAS_ALLOW_RELEASE_PACKAGE:-}" != "YES" ]]; then
  echo "Release-Paket abgebrochen: ausdrückliche Freigabe fehlt." >&2
  echo "Aufruf: HEALTHATLAS_ALLOW_RELEASE_PACKAGE=YES $0 beta|final [version]" >&2
  exit 1
fi

channel="${1:-}"
version="${2:-}"
case "$channel" in
  beta)
    configuration="Beta"
    app_display_name="HealthAtlas Beta"
    app_bundle_name="HealthAtlas Beta.app"
    default_version="0.1.0-beta.1"
    ;;
  final)
    configuration="Final"
    app_display_name="HealthAtlas"
    app_bundle_name="HealthAtlas.app"
    default_version="0.1.0"
    ;;
  *)
    echo "Aufruf: $0 beta|final [version]" >&2
    exit 64
    ;;
esac

version="${version:-$default_version}"
root="$(cd "$(dirname "$0")/.." && pwd)"
derived_data="$root/.build/$channel/DerivedData"
release_directory="$root/dist/releases/$channel/$version"
backup_directory="$root/Backup/releases/$channel/$version"
artifact_base="HealthAtlas-${version}-macos"
zip_file="$backup_directory/$artifact_base.zip"
dmg_file="$backup_directory/$artifact_base.dmg"
app_source="$derived_data/Build/Products/$configuration/HealthAtlas.app"
app_bundle="$release_directory/$app_bundle_name"

cd "$root"
bash Scripts/prepare-build-layout.sh
bash Scripts/privacy-check.sh
bash Scripts/build-channel.sh "$channel"

if [[ ! -d "$app_source" ]]; then
  echo "Release-Paket abgebrochen: App-Bundle fehlt: $app_source" >&2
  exit 1
fi

rm -rf "$release_directory" "$backup_directory"
mkdir -p "$release_directory" "$backup_directory"
ditto "$app_source" "$app_bundle"
codesign --force --deep --sign - "$app_bundle"
codesign --verify --deep --strict "$app_bundle"

ditto -c -k --sequesterRsrc --keepParent "$app_bundle" "$zip_file"

dmg_staging="$root/.build/package-$channel/dmg-staging"
rm -rf "$dmg_staging"
mkdir -p "$dmg_staging"
ditto "$app_bundle" "$dmg_staging/$app_bundle_name"
ln -s /Applications "$dmg_staging/Applications"
hdiutil create \
  -volname "$app_display_name $version" \
  -srcfolder "$dmg_staging" \
  -ov -format UDZO "$dmg_file"

(
  cd "$backup_directory"
  shasum -a 256 "$(basename "$zip_file")" > "$(basename "$zip_file").sha256"
  shasum -a 256 "$(basename "$dmg_file")" > "$(basename "$dmg_file").sha256"
)

echo "Lokales $channel-Paket erstellt:"
echo "  App: $app_bundle"
echo "  ZIP: $zip_file"
echo "  DMG: $dmg_file"
