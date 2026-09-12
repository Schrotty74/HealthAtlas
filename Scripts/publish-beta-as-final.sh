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

final_tree_from_beta() {
    local english_readme german_readme tree_entries
    english_readme="$(git show beta:README.md | sed '/^See \[what’s new and the complete feature overview\](FEATURES\.md)\.$/d' | git hash-object -w --stdin)"
    german_readme="$(git show beta:README.de.md | sed '/^Neuigkeiten und alle Details stehen in der \[vollständigen Funktionsübersicht\](FEATURES\.de\.md)\.$/d' | git hash-object -w --stdin)"
    tree_entries="$(git ls-tree beta | awk -F '\t' '$2 != "FEATURES.md" && $2 != "FEATURES.de.md" && $2 != "README.md" && $2 != "README.de.md"')"
    {
        printf '100644 blob %s\tREADME.md\n' "$english_readme"
        printf '100644 blob %s\tREADME.de.md\n' "$german_readme"
        printf '%s\n' "$tree_entries"
    } | LC_ALL=C sort -k 2 | git mktree
}

bugfix_tree_from_dev() {
    local main_ref="$1" temporary_index tree
    if [[ -n "$(git diff --name-only --diff-filter=D "$main_ref" dev)" ]]; then
        echo "Abbruch: Der direkte Dev-Bugfix würde Dateien aus main entfernen." >&2
        echo "Bitte die Entfernung zuerst bewusst auf main vorbereiten." >&2
        exit 1
    fi

    temporary_index="$(mktemp "${TMPDIR:-/tmp}/healthatlas-bugfix-index.XXXXXX")"
    rm -f "$temporary_index"
    GIT_INDEX_FILE="$temporary_index" git read-tree "$main_ref^{tree}"
    git diff --binary --diff-filter=AM "$main_ref" dev | GIT_INDEX_FILE="$temporary_index" git apply --cached
    tree="$(GIT_INDEX_FILE="$temporary_index" git write-tree)"
    rm -f "$temporary_index"
    echo "$tree"
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
    local base_ref="$1" release_label="$2"
    local changed_paths
    changed_paths="$(git diff --name-only "$base_ref" HEAD -- Sources Tests HealthAtlas.xcodeproj HealthAtlas/Info.plist README.md README.de.md output/pdf Scripts 2>/dev/null | sort -u)"
    [[ -n "$changed_paths" ]] || return 1

    if [[ "$release_label" == "Bugfix" ]]; then
        printf '## Fixed\n\n'
        if grep -q '^Sources/HealthAtlasApp/DashboardViewController.swift$' <<<"$changed_paths"; then
            printf '%s\n' '- Card backgrounds, borders and rounded corners now use the same clipped shape throughout the app.'
        elif grep -q '^Sources/' <<<"$changed_paths"; then
            printf '%s\n' '- Corrected an issue in the HealthAtlas app.'
        fi
    else
        printf '## Changelog\n\n'
        if grep -q '^Sources/' <<<"$changed_paths"; then
            printf '%s\n' '- HealthAtlas app functionality and interface updated.'
        fi
    fi
    if grep -Eq '^(HealthAtlas\.xcodeproj/|HealthAtlas/Info\.plist$)' <<<"$changed_paths"; then
        printf '%s\n' '- Xcode project configuration updated.'
    fi
    if grep -q '^Tests/' <<<"$changed_paths"; then
        printf '%s\n' '- Automated tests for local behavior updated.'
    fi
    if grep -Eq '^(README\.md|README\.de\.md|output/pdf/)' <<<"$changed_paths"; then
        printf '%s\n' '- German and English project documentation updated.'
    fi
    if grep -q '^Scripts/' <<<"$changed_paths"; then
        printf '%s\n' '- Build, backup, privacy or release automation updated.'
    fi
}

write_release_notes() {
    local notes_file="$1" previous_final_tag="$2" changes="$3"
    cat > "$notes_file" <<EOF
$changes
## Privacy

HealthAtlas starts without personal data. The included demo is synthetic; imports remain local and are never uploaded.

## Gatekeeper

This build is ad-hoc signed. Open the app normally once; if macOS blocks it, go to System Settings > Privacy & Security, scroll to Security, choose Open Anyway for that build, then confirm Open and authenticate if asked. Open Anyway is available only for a limited time after the blocked launch and creates an exception only for that build; do not disable Gatekeeper system-wide. Use this only for the official GitHub release.
EOF
}

create_github_release() {
    local version="$1" release_label="$2" target_commit="$3" notes_file="$4"; shift 4
    GH_PROMPT_DISABLED=1 gh release create "v$version" "$@" --target "$target_commit" --title "$release_label $version" --notes-file "$notes_file"
}

require_clean_worktree
require_gh
ensure_branch_exists main beta
sync_branch_with_origin main
bash Scripts/prepare-build-layout.sh
Scripts/privacy-check.sh

version="$(release_version)"
if [[ "$version" =~ ^[1-9][0-9]*\.0\.0$ ]]; then
    release_label="Final"
    source_branch="beta"
    ensure_branch_exists beta main
    sync_branch_with_origin beta
elif [[ "$version" =~ ^[1-9][0-9]*\.[0-9]+\.[0-9]*[1-9][0-9]*$ ]]; then
    release_label="Bugfix"
    source_branch="dev"
    git show-ref --verify --quiet refs/heads/dev || { echo "Abbruch: Lokaler dev-Branch fehlt." >&2; exit 1; }
else
    echo "Abbruch: Final-Version muss X.0.0 und ein Bugfix X.Y.Z mit Z größer 0 sein." >&2
    exit 1
fi
previous_final_tag="$(last_final_tag)"
previous_release_note_ref="${previous_final_tag:-$(git rev-list --max-parents=0 HEAD)}"
backup_directory="$(backup_directory_for_version "$version")"
artifact_base="HealthAtlas-$version-macos"
zip_file="$backup_directory/$artifact_base.zip"
dmg_file="$backup_directory/$artifact_base.dmg"
zip_checksum_file="$zip_file.sha256"
dmg_checksum_file="$dmg_file.sha256"
release_notes_file="$backup_directory/HealthAtlas-$version-release-notes.md"

git switch "$source_branch"
source_commit="$(git rev-parse --short HEAD)"
main_before="$(git rev-parse refs/heads/main)"
if [[ "$release_label" == "Bugfix" ]]; then
    final_tree="$(bugfix_tree_from_dev "$main_before")"
    release_change_base="$main_before"
else
    final_tree="$(final_tree_from_beta)"
    release_change_base="${previous_release_note_ref}"
fi
final_commit="$(printf 'Publish %s %s from %s\n' "$release_label" "$version" "$source_branch" | git commit-tree "$final_tree" -p "$main_before")"
git update-ref refs/heads/main "$final_commit" "$main_before"
git switch main

release_changes="$(categorized_release_changes "$release_change_base" "$release_label")" || {
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
    gh release edit "$release_tag" --title "$release_label $version" --notes-file "$release_notes_file"
else
    create_github_release "$version" "$release_label" "$(git rev-parse HEAD)" "$release_notes_file" "$zip_file" "$dmg_file" "$zip_checksum_file" "$dmg_checksum_file"
fi

echo "$release_label wurde aus $source_branch veröffentlicht."
echo "Ausgabeordner: $backup_directory"
echo "GitHub Release: $release_tag"
echo "Quell-Commit: $source_commit"
