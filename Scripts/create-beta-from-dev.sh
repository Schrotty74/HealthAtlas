#!/bin/zsh

set -euo pipefail

root_directory="$(cd "$(dirname "$0")/.." && pwd)"
cd "$root_directory"
requested_version="${1:-}"

build_setting() {
    local name="$1"
    xcodebuild -project HealthAtlas.xcodeproj -target HealthAtlas -configuration Beta \
        -derivedDataPath "$root_directory/.build/xcode-beta-derived-data" -showBuildSettings 2>/dev/null \
        | awk -F' = ' -v setting="$name" '$1 ~ setting "$" { print $2; exit }'
}

release_version() {
    [[ -n "$requested_version" ]] && { echo "$requested_version"; return; }
    local marketing_version="$(build_setting MARKETING_VERSION)"
    [[ -n "$marketing_version" ]] || { echo "Abbruch: MARKETING_VERSION fehlt." >&2; exit 1; }
    echo "$marketing_version"
}

require_dev_branch() {
    local branch="$(git branch --show-current)"
    [[ "$branch" == "dev" ]] || { echo "Abbruch: Beta muss vom aktuellen dev-Branch erstellt werden." >&2; exit 1; }
}

ensure_beta_ref() {
    git show-ref --verify --quiet refs/heads/beta && return
    if git show-ref --verify --quiet refs/remotes/origin/beta; then
        git update-ref refs/heads/beta refs/remotes/origin/beta
    else
        git update-ref refs/heads/beta HEAD
    fi
}

require_gh() {
    command -v gh >/dev/null 2>&1 || { echo "Abbruch: GitHub CLI 'gh' wurde nicht gefunden." >&2; exit 1; }
}

worktree_tree() {
    local changed_paths=("${(@f)$( { git diff --name-only HEAD --; git diff --cached --name-only; git ls-files --others --exclude-standard; } | sort -u)}")
    (( ${#changed_paths[@]} > 0 )) && git add -A -- "${changed_paths[@]}"
    git write-tree
}

create_beta_commit() {
    local version="$1" tree="$2" parent parent_tree
    parent="$(git rev-parse refs/heads/beta)"
    parent_tree="$(git rev-parse "$parent^{tree}")"
    [[ "$tree" == "$parent_tree" ]] && { echo "$parent"; return; }
    printf 'Create beta %s from dev\n' "$version" | git commit-tree "$tree" -p "$parent"
}

backup_directory_for_version() {
    case "$1" in
        *local*|*test*) echo "$root_directory/Backup/local-test/$1" ;;
        *) echo "$root_directory/Backup/releases/beta/$1" ;;
    esac
}

artifact_base_name() {
    if [[ "$1" == *beta* ]]; then
        echo "HealthAtlas-$1-macos"
    else
        echo "HealthAtlas-Beta-$1-macos"
    fi
}

require_release_artifacts() {
    local artifact
    for artifact in "$@"; do [[ -f "$artifact" ]] || { echo "Abbruch: Release-Artefakt fehlt: $artifact" >&2; exit 1; }; done
}

last_beta_tag() {
    git tag --list 'v*-beta*' --sort=-version:refname | head -n 1
}

categorized_release_changes() {
    local base_ref="$1"
    local changed_paths
    changed_paths="$(git diff --name-only "$base_ref" HEAD -- Sources Tests HealthAtlas.xcodeproj README.md README.de.md output/pdf Scripts 2>/dev/null | sort -u)"
    [[ -n "$changed_paths" ]] || return 1

    printf '## Changes\n\n'
    if grep -q '^Sources/' <<<"$changed_paths"; then
        printf '%s\n' '- Updated HealthAtlas app functionality and interface.'
    fi
    if grep -q '^HealthAtlas.xcodeproj/' <<<"$changed_paths"; then
        printf '%s\n' '- Updated the Xcode project configuration.'
    fi
    if grep -q '^Tests/' <<<"$changed_paths"; then
        printf '%s\n' '- Updated automated tests for local behavior.'
    fi
    if grep -Eq '^(README\.md|README\.de\.md|output/pdf/)' <<<"$changed_paths"; then
        printf '%s\n' '- Updated German and English documentation, screenshots or manuals.'
    fi
    if grep -q '^Scripts/' <<<"$changed_paths"; then
        printf '%s\n' '- Updated build, backup, privacy or release automation.'
    fi
}

write_release_notes() {
    local notes_file="$1" previous_beta_tag="$2" changes="$3"
    cat > "$notes_file" <<EOF
This beta contains the latest HealthAtlas fixes and improvements since ${previous_beta_tag:-the first beta}.

$changes
## Privacy

HealthAtlas starts without personal data. The included demo is synthetic; imports remain local to the active build variant and are never uploaded.

## Gatekeeper

This build is ad-hoc signed. In Finder, Control-click the app, choose Open, then confirm Open.
EOF
}

create_github_release() {
    local version="$1" target_commit="$2" notes_file="$3"; shift 3
    GH_PROMPT_DISABLED=1 gh release create "v$version" "$@" --target "$target_commit" --title "HealthAtlas Beta $version" --notes-file "$notes_file" --prerelease
}

require_dev_branch
ensure_beta_ref
require_gh
bash Scripts/prepare-build-layout.sh
Scripts/privacy-check.sh

version="$(release_version)"
dev_commit="$(git rev-parse --short HEAD)"
previous_beta_tag="$(last_beta_tag)"
previous_release_note_ref="${previous_beta_tag:-$(git rev-list --max-parents=0 HEAD)}"
release_changes="$(categorized_release_changes "$previous_release_note_ref")" || {
    echo "Abbruch: Seit ${previous_beta_tag:-dem Projektbeginn} wurden keine releasbaren Änderungen gefunden. Keine Beta ohne tatsächliche Änderungen erstellen." >&2
    exit 1
}
artifact_base="$(artifact_base_name "$version")"
backup_directory="$(backup_directory_for_version "$version")"
zip_file="$backup_directory/$artifact_base.zip"
dmg_file="$backup_directory/$artifact_base.dmg"
zip_checksum_file="$zip_file.sha256"
dmg_checksum_file="$dmg_file.sha256"
release_notes_file="$backup_directory/HealthAtlas-Beta-$version-release-notes.md"

HEALTHATLAS_VERSION="$version" HEALTHATLAS_ALLOW_RELEASE_PACKAGE=YES Scripts/build-release-package.sh beta
require_release_artifacts "$zip_file" "$dmg_file" "$zip_checksum_file" "$dmg_checksum_file"
Scripts/privacy-check.sh

tree="$(worktree_tree)"
beta_before="$(git rev-parse refs/heads/beta)"
beta_commit="$(create_beta_commit "$version" "$tree")"
git update-ref refs/heads/beta "$beta_commit" "$beta_before"
git push --set-upstream origin refs/heads/beta:refs/heads/beta

write_release_notes "$release_notes_file" "$previous_beta_tag" "$release_changes"
if gh release view "v$version" >/dev/null 2>&1; then
    gh release upload "v$version" "$zip_file" "$dmg_file" "$zip_checksum_file" "$dmg_checksum_file" --clobber
    gh release edit "v$version" --prerelease --title "HealthAtlas Beta $version" --notes-file "$release_notes_file"
else
    create_github_release "$version" "$beta_commit" "$release_notes_file" "$zip_file" "$dmg_file" "$zip_checksum_file" "$dmg_checksum_file"
fi

echo "Beta wurde aus Dev erstellt."
echo "Version: $version"
echo "Ausgabeordner: $backup_directory"
echo "Release Notes: $release_notes_file"
echo "Dev-Commit: $dev_commit"
echo "Beta-Commit: $(git rev-parse --short "$beta_commit")"
