#!/bin/zsh

set -euo pipefail

if [[ "${HEALTHATLAS_ALLOW_RELEASE_PACKAGE:-}" != "YES" ]]; then
    echo "Release-Paket abgebrochen: ausdrückliche Freigabe fehlt." >&2
    echo "Für normale Prüfungen ausschließlich 'swift build' und 'swift test' verwenden." >&2
    echo "Nur nach Benutzerfreigabe mit HEALTHATLAS_ALLOW_RELEASE_PACKAGE=YES ausführen." >&2
    exit 1
fi

channel="${1:-}"
if [[ "$channel" != "beta" && "$channel" != "final" ]]; then
    echo "Aufruf: $0 beta|final" >&2
    exit 1
fi

root_directory="$(cd "$(dirname "$0")/.." && pwd)"
cd "$root_directory"

case "$channel" in
    beta)
        configuration="Beta"
        app_display_name="HealthAtlas Beta"
        app_bundle_name="HealthAtlas Beta.app"
        dist_name_prefix="HealthAtlas-Beta"
        default_version_suffix="-beta.local"
        ;;
    final)
        configuration="Final"
        app_display_name="HealthAtlas"
        app_bundle_name="HealthAtlas.app"
        dist_name_prefix="HealthAtlas"
        default_version_suffix=""
        ;;
esac

build_setting() {
    local name="$1"
    xcodebuild \
        -project HealthAtlas.xcodeproj \
        -target HealthAtlas \
        -configuration "$configuration" \
        -derivedDataPath "$root_directory/.build/xcode-$channel-derived-data" \
        -showBuildSettings 2>/dev/null \
        | awk -F' = ' -v setting="$name" '$1 ~ setting "$" { print $2; exit }'
}

if [[ -n "${HEALTHATLAS_VERSION:-}" ]]; then
    marketing_version="$HEALTHATLAS_VERSION"
    build_number="${HEALTHATLAS_BUILD_NUMBER:-1}"
else
    marketing_version="$(build_setting MARKETING_VERSION)"
    build_number="${HEALTHATLAS_BUILD_NUMBER:-$(build_setting CURRENT_PROJECT_VERSION)}"
fi
[[ -n "$marketing_version" ]] || marketing_version="0.1.0"
[[ -n "$build_number" ]] || build_number="1"

default_version="$marketing_version"
if [[ "$channel" == "beta" && "$default_version" != *beta* ]]; then
    default_version="$default_version$default_version_suffix"
fi
version="${2:-${HEALTHATLAS_VERSION:-$default_version}}"
artifact_base_name="HealthAtlas-$version-macos"
if [[ "$channel" == "beta" && "$version" != *beta* ]]; then
    artifact_base_name="HealthAtlas-Beta-$version-macos"
fi

case "$version" in
    *local*|*test*)
        backup_directory="$root_directory/Backup/local-test/$version"
        release_directory="$root_directory/dist/local-test/$version"
        ;;
    *)
        backup_directory="$root_directory/Backup/releases/$channel/$version"
        release_directory="$root_directory/dist/releases/$channel/$version"
        ;;
esac

derived_data="$root_directory/.build/$channel/DerivedData"
app_source="$derived_data/Build/Products/$configuration/HealthAtlas.app"
app_bundle="$release_directory/$app_bundle_name"
zip_file="$backup_directory/$artifact_base_name.zip"
dmg_file="$backup_directory/$artifact_base_name.dmg"
zip_checksum_file="$zip_file.sha256"
dmg_checksum_file="$dmg_file.sha256"

bash Scripts/prepare-build-layout.sh
Scripts/privacy-check.sh
bash Scripts/build-channel.sh "$channel"

[[ -d "$app_source" ]] || { echo "Build abgebrochen: App-Bundle fehlt: $app_source" >&2; exit 1; }

rm -rf "$release_directory" "$zip_file" "$dmg_file" "$zip_checksum_file" "$dmg_checksum_file"
mkdir -p "$release_directory" "$backup_directory"
ditto "$app_source" "$app_bundle"

private_file="$(find "$app_bundle" -type f \
    \( -iname '*.tsv' -o -iname '*.private.json' -o -iname '*.private.csv' -o -iname 'catalog.json' \) \
    -print -quit)"
if [[ -n "$private_file" ]]; then
    echo "Build abgebrochen: private Datei im App-Bundle: $private_file" >&2
    exit 1
fi

app_binary="$app_bundle/Contents/MacOS/HealthAtlas"
private_rpaths=("${(@f)$(otool -l "$app_binary" | awk '/^[[:space:]]+path \/(Users|Volumes)\// { print $2 }')}")
for private_rpath in "${private_rpaths[@]}"; do
    [[ -n "$private_rpath" ]] || continue
    install_name_tool -delete_rpath "$private_rpath" "$app_binary"
done
local_path_pattern="/""Users/[^/]+|/""Volumes/[^/]+"
if rg -a "$local_path_pattern" "$app_binary" >/dev/null; then
    echo "Build abgebrochen: lokaler Pfad im App-Binary gefunden." >&2
    exit 1
fi

codesign --force --deep --sign - "$app_bundle"
codesign --verify --deep --strict "$app_bundle"
ditto -c -k --sequesterRsrc --keepParent "$app_bundle" "$zip_file"

dmg_staging_directory="$release_directory/DMG"
rm -rf "$dmg_staging_directory"
mkdir -p "$dmg_staging_directory"
ditto "$app_bundle" "$dmg_staging_directory/$app_bundle_name"
ln -s /Applications "$dmg_staging_directory/Applications"
if ! hdiutil create -volname "$app_display_name $version" -srcfolder "$dmg_staging_directory" -ov -format UDZO "$dmg_file"; then
    rm -f "$dmg_file"
    hdiutil makehybrid -hfs -hfs-volume-name "$app_display_name $version" -o "$dmg_file" "$dmg_staging_directory"
fi

(
    cd "$backup_directory"
    shasum -a 256 "$(basename "$zip_file")" > "$(basename "$zip_checksum_file")"
    shasum -a 256 "$(basename "$dmg_file")" > "$(basename "$dmg_checksum_file")"
)

echo "$app_display_name-Paket erstellt:"
echo "  $app_bundle"
echo "  $dmg_file"
echo "  $dmg_checksum_file"
echo "  $zip_file"
echo "  $zip_checksum_file"
