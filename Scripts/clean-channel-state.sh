#!/usr/bin/env bash
set -euo pipefail

channel="${1:-}"
case "$channel" in
  dev|beta|final) ;;
  *) echo "Usage: bash Scripts/clean-channel-state.sh {dev|beta|final}" >&2; exit 64 ;;
esac

if [[ "${HEALTHATLAS_SKIP_SCHEME_CLEAN:-}" == "YES" ]]; then
  exit 0
fi

defaults delete "com.healthatlas.app.${channel}.preferences" >/dev/null 2>&1 || true
rm -rf "$HOME/Library/Application Support/HealthAtlas/$channel"
