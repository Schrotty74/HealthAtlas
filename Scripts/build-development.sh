#!/usr/bin/env bash
set -euo pipefail

root="$(cd "$(dirname "$0")/.." && pwd)"

# The only supported local-development entry point. Its runnable app is always
# written to dist/local-test/HealthAtlas-Development, never to DerivedData.
bash "$root/Scripts/prepare-build-layout.sh"
bash "$root/Scripts/build-channel.sh" dev
