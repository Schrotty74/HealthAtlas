# HealthAtlas release workflow

## Dev

- Local only.
- Delete `.build`, `DerivedData`, previous app bundles, and local app data.
- Build with the development configuration.
- Do not commit or upload the resulting app.

## Beta

- Start from a clean checkout and clean build directories.
- Run tests and `Scripts/privacy-check.sh`.
- Build an unsigned or appropriately signed beta according to the selected distribution method.
- Review the app on a clean macOS 26+ account.
- Package only the app in a sanitised ZIP and DMG.
- Publish the privacy report next to the beta artifacts.

## Final

- Repeat the beta procedure from a fresh clean checkout.
- Verify version, build number, entitlements, signing, and notarisation status.
- Run the privacy check again immediately before packaging.
- Publish only the final ZIP/DMG and the privacy report.

Never use a beta or final build directory as the source for another build. Every channel must be reproducible from source.
