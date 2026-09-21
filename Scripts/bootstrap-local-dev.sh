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

require_clean_worktree
git show-ref --verify --quiet refs/heads/dev && {
    echo "Abbruch: Der lokale dev-Branch existiert bereits." >&2
    exit 1
}

git fetch --quiet origin beta
git show-ref --verify --quiet refs/remotes/origin/beta || {
    echo "Abbruch: origin/beta wurde nicht gefunden." >&2
    exit 1
}

git switch --no-track -c dev refs/remotes/origin/beta
if [[ -n "$(git config --get branch.dev.remote || true)" || -n "$(git config --get branch.dev.merge || true)" ]]; then
    echo "Abbruch: dev darf kein Remote-Tracking erhalten." >&2
    exit 1
fi

echo "Lokaler dev-Branch aus origin/beta erstellt; es wurde kein Remote-Tracking eingerichtet."
