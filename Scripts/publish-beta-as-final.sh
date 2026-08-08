#!/bin/zsh

set -euo pipefail

root_directory="$(cd "$(dirname "$0")/.." && pwd)"
cd "$root_directory"
requested_version="${1:-}"

build_setting() {
    local name="$1"
    xcodebuild -project HealthAtlas.xcodeproj -target HealthAtlas -configuration Final \
        -derivedDataPath "$root_directory/.build/xcode-final-derived-data" -showBuildSettings 2>/dev/null \
        | awk -F' = ' -v setting="$name" '$1 ~ setting "$" { print $2; exit }'
}

release_version() {
    [[ -n "$requested_version" ]] && { echo "$requested_version"; return; }
    local marketing_version="$(build_setting MARKETING_VERSION)"
    [[ -n "$marketing_version" ]] || { echo "Abbruch: MARKETING_VERSION fehlt." >&2; exit 1; }
    echo "$marketing_version"
}

require_clean_worktree() {
    if ! git diff --quiet || ! git diff --cached --quiet; then
        echo "Abbruch: Es gibt ungespeicherte Git-Änderungen." >&2
        echo "Bitte zuerst committen oder stashen." >&2
        exit 1
    fi
}

ensure_branch_exists() {
    local branch="$1" start_point="$2"
    git show-ref --verify --quiet "refs/heads/$branch" || git branch "$branch" "$start_point"
}

require_gh() {
    command -v gh >/dev/null 2>&1 || { echo "Abbruch: GitHub CLI 'gh' wurde nicht gefunden." >&2; exit 1; }
}

backup_directory_for_version() {
    case "$1" in
        *local*|*test*) echo "$root_directory/Backup/local-test/$1" ;;
        *) echo "$root_directory/Backup/releases/final/$1" ;;
    esac
}

require_release_artifacts() {
    local artifact
    for artifact in "$@"; do [[ -f "$artifact" ]] || { echo "Abbruch: Release-Artefakt fehlt: $artifact" >&2; exit 1; }; done
}

last_final_tag() { git describe --tags --match 'v*' --exclude '*beta*' --abbrev=0 HEAD 2>/dev/null || true; }

categorized_release_changes() {
    local base_ref="$1"
    git log --reverse --no-merges --format='%s' "$base_ref"..HEAD | awk '
        BEGIN { new=""; fixed=""; improved="" }
        tolower($0) ~ /(fix|bug|hang|crash|error)/ { fixed = fixed "- " $0 "\n"; next }
        tolower($0) ~ /(improve|faster|performance|speed)/ { improved = improved "- " $0 "\n"; next }
        { new = new "- " $0 "\n" }
        END { if (new != "") print "## New\n\n" new; if (fixed != "") print "## Fixed\n\n" fixed; if (improved != "") print "## Improved\n\n" improved }'
}

write_release_notes() {
    local notes_file="$1" previous_final_tag="$2" changes
    changes="$(categorized_release_changes "$previous_final_tag")"
    [[ -n "$changes" ]] || changes="## Changes\n\n- Initial stable HealthAtlas release."
    cat > "$notes_file" <<EOF
This stable release contains the latest HealthAtlas changes since ${previous_final_tag:-the first stable release}.

$changes
## Privacy

HealthAtlas starts without personal data. The included demo is synthetic; imports remain local and are never uploaded.

## Gatekeeper

This build is ad-hoc signed. In Finder, Control-click the app, choose Open, then confirm Open.
EOF
}

create_github_release() {
    local version="$1" target_commit="$2" notes_file="$3"; shift 3
    GH_PROMPT_DISABLED=1 gh release create "v$version" "$@" --target "$target_commit" --title "HealthAtlas $version" --notes-file "$notes_file"
}

require_clean_worktree
require_gh
ensure_branch_exists beta main
ensure_branch_exists main beta
bash Scripts/prepare-build-layout.sh
Scripts/privacy-check.sh

version="$(release_version)"
previous_final_tag="$(last_final_tag)"
previous_release_note_ref="${previous_final_tag:-$(git rev-list --max-parents=0 HEAD)}"
backup_directory="$(backup_directory_for_version "$version")"
artifact_base="HealthAtlas-$version-macos"
zip_file="$backup_directory/$artifact_base.zip"
dmg_file="$backup_directory/$artifact_base.dmg"
zip_checksum_file="$zip_file.sha256"
dmg_checksum_file="$dmg_file.sha256"
release_notes_file="$backup_directory/HealthAtlas-$version-release-notes.md"

git switch beta
beta_commit="$(git rev-parse --short HEAD)"
git switch main
git merge --ff-only beta

HEALTHATLAS_VERSION="$version" HEALTHATLAS_ALLOW_RELEASE_PACKAGE=YES Scripts/build-release-package.sh final
require_release_artifacts "$zip_file" "$dmg_file" "$zip_checksum_file" "$dmg_checksum_file"

write_release_notes "$release_notes_file" "$previous_final_tag" "$previous_release_note_ref"
HEALTHATLAS_ALLOW_PUSH=YES git push --set-upstream origin main
release_tag="v$version"
if gh release view "$release_tag" >/dev/null 2>&1; then
    gh release upload "$release_tag" "$zip_file" "$dmg_file" "$zip_checksum_file" "$dmg_checksum_file" --clobber
    gh release edit "$release_tag" --title "HealthAtlas $version" --notes-file "$release_notes_file"
else
    create_github_release "$version" "$(git rev-parse HEAD)" "$release_notes_file" "$zip_file" "$dmg_file" "$zip_checksum_file" "$dmg_checksum_file"
fi

echo "Final wurde aus Beta veröffentlicht."
echo "Ausgabeordner: $backup_directory"
echo "GitHub Release: $release_tag"
echo "Beta-Commit: $beta_commit"
