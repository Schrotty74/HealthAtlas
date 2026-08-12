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

sync_branch_with_origin() {
    local branch="$1" current_branch local_ref remote_ref local_commit remote_commit
    current_branch="$(git branch --show-current)"
    local_ref="refs/heads/$branch"
    remote_ref="refs/remotes/origin/$branch"

    git fetch --quiet origin "$branch"
    if ! git show-ref --verify --quiet "$local_ref"; then
        git update-ref "$local_ref" "$remote_ref"
        return
    fi

    local_commit="$(git rev-parse "$local_ref")"
    remote_commit="$(git rev-parse "$remote_ref")"
    [[ "$local_commit" == "$remote_commit" ]] && return

    if git merge-base --is-ancestor "$local_ref" "$remote_ref"; then
        if [[ "$current_branch" == "$branch" ]]; then
            git merge --ff-only "$remote_ref"
        else
            git update-ref "$local_ref" "$remote_ref"
        fi
    elif git merge-base --is-ancestor "$remote_ref" "$local_ref"; then
        git push origin "$local_ref:$local_ref"
    else
        echo "Abbruch: $branch ist lokal und auf GitHub auseinander gelaufen." >&2
        echo "Bitte die Abweichung zuerst bewusst zusammenführen." >&2
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

last_final_tag() {
    git tag --list 'v*' --sort=-version:refname | grep -v -- '-beta' | head -n 1 || true
}

categorized_release_changes() {
    local base_ref="$1"
    local changed_paths
    changed_paths="$(git diff --name-only "$base_ref" HEAD -- Sources Tests HealthAtlas.xcodeproj README.md README.de.md output/pdf Scripts 2>/dev/null | sort -u)"
    [[ -n "$changed_paths" ]] || return 1

    printf '## Changelog\n\n'
    if grep -q '^Sources/' <<<"$changed_paths"; then
        printf '%s\n' '- HealthAtlas app functionality and interface updated.'
    fi
    if grep -q '^HealthAtlas.xcodeproj/' <<<"$changed_paths"; then
        printf '%s\n' '- Xcode project configuration updated.'
    fi
    if grep -q '^Tests/' <<<"$changed_paths"; then
        printf '%s\n' '- Automated tests for local behavior updated.'
    fi
    if grep -Eq '^(README\.md|README\.de\.md|output/pdf/)' <<<"$changed_paths"; then
        printf '%s\n' '- German and English documentation, screenshots and manuals updated.'
    fi
    if grep -q '^Scripts/' <<<"$changed_paths"; then
        printf '%s\n' '- Build, backup, privacy or release automation updated.'
    fi
}

write_release_notes() {
    local notes_file="$1" previous_final_tag="$2" changes="$3"
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
sync_branch_with_origin beta
sync_branch_with_origin main
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

release_changes="$(categorized_release_changes "${previous_release_note_ref}")" || {
    echo "Abbruch: Seit ${previous_final_tag:-dem Projektbeginn} wurden keine releasbaren Änderungen gefunden. Kein Final ohne vollständigen Changelog erstellen." >&2
    exit 1
}

HEALTHATLAS_VERSION="$version" HEALTHATLAS_ALLOW_RELEASE_PACKAGE=YES Scripts/build-release-package.sh final
require_release_artifacts "$zip_file" "$dmg_file" "$zip_checksum_file" "$dmg_checksum_file"

write_release_notes "$release_notes_file" "$previous_final_tag" "$release_changes"
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
