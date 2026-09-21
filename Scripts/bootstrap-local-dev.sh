#!/bin/zsh

set -euo pipefail

root_directory="$(cd "$(dirname "$0")/.." && pwd)"
cd "$root_directory"

require_clean_worktree() {
    if ! git diff --quiet || ! git diff --cached --quiet || [[ -n "$(git ls-files --others --exclude-standard)" ]]; then
        echo "Abbruch: Es gibt ungespeicherte Git-Änderungen." >&2
        echo "Bitte zuerst committen, stashen oder bewusst sichern." >&2
        exit 1
    fi
}

release_version_from_context() {
    local ref="$1" branch="$2" pattern version
    case "$branch" in
        beta)
            pattern='^\| `beta` \| öffentliche Vorabversion auf GitHub \| enthält die veröffentlichte Vorabversion `(Beta|Bugfix) ([1-9][0-9]*\.[0-9]+\.[0-9]+)` \|$'
            ;;
        main)
            pattern='^\| `main` \| Final-Linie auf GitHub \| enthält die ausdrücklich freigegebene Final-Version `(Final|Bugfix) ([1-9][0-9]*\.[0-9]+\.[0-9]+)` \|$'
            ;;
        *)
            echo "Abbruch: Unbekannter Release-Branch: $branch" >&2
            exit 1
            ;;
    esac

    version="$(git show "${ref}:PROJECT_CONTEXT.md" | sed -n -E "s#${pattern}#\\2#p")"
    [[ "$version" =~ ^[1-9][0-9]*\.[0-9]+\.[0-9]+$ ]] || {
        echo "Abbruch: Die Release-Version in $ref:PROJECT_CONTEXT.md konnte nicht sicher gelesen werden." >&2
        exit 1
    }
    echo "$version"
}

version_is_newer() {
    local candidate="$1" baseline="$2" index
    local -a candidate_parts baseline_parts
    candidate_parts=("${(@s:.:)candidate}")
    baseline_parts=("${(@s:.:)baseline}")

    for index in 1 2 3; do
        if (( 10#${candidate_parts[index]} > 10#${baseline_parts[index]} )); then
            return 0
        elif (( 10#${candidate_parts[index]} < 10#${baseline_parts[index]} )); then
            return 1
        fi
    done
    return 1
}

select_release_source() {
    local beta_version main_version
    git fetch --quiet origin beta main
    git show-ref --verify --quiet refs/remotes/origin/beta || {
        echo "Abbruch: origin/beta wurde nicht gefunden." >&2
        exit 1
    }
    git show-ref --verify --quiet refs/remotes/origin/main || {
        echo "Abbruch: origin/main wurde nicht gefunden." >&2
        exit 1
    }

    beta_version="$(release_version_from_context refs/remotes/origin/beta beta)"
    main_version="$(release_version_from_context refs/remotes/origin/main main)"
    if version_is_newer "$beta_version" "$main_version"; then
        selected_branch="beta"
        selected_version="$beta_version"
    elif version_is_newer "$main_version" "$beta_version"; then
        selected_branch="main"
        selected_version="$main_version"
    else
        echo "Abbruch: Beta ($beta_version) und Final ($main_version) sind versionsgleich." >&2
        echo "Bitte die gewünschte Ausgangslinie bewusst prüfen, statt dev automatisch anzulegen." >&2
        exit 1
    fi
}

require_clean_worktree
git show-ref --verify --quiet refs/heads/dev && {
    echo "Abbruch: Der lokale dev-Branch existiert bereits." >&2
    exit 1
}

select_release_source

git switch --no-track -c dev "refs/remotes/origin/$selected_branch"
if [[ -n "$(git config --get branch.dev.remote || true)" || -n "$(git config --get branch.dev.merge || true)" ]]; then
    echo "Abbruch: dev darf kein Remote-Tracking erhalten." >&2
    exit 1
fi

echo "Lokaler dev-Branch aus origin/$selected_branch (Version $selected_version) erstellt; es wurde kein Remote-Tracking eingerichtet."
