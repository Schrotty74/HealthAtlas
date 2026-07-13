# HealthAtlas

[Deutsche README](README.de.md)

Privacy-first macOS app for visualising personal health data from local exports.

## Current status

This repository is a clean starter scaffold for Xcode and Codex. It contains a native AppKit shell, mock data only, the selected HealthAtlas heart icon concept, release rules, and a privacy review script.

The first implementation must use local import files. A direct macOS HealthKit integration must not be assumed: Apple Health data access is primarily provided by Apple platforms with HealthKit, while macOS support and Google data access require a separately verified import or synchronisation route. Do not add an integration until its current API and privacy requirements have been verified.

## Product principles

- macOS 26 or newer.
- Native Swift and AppKit. No external framework unless explicitly approved.
- Privacy by default: local processing, no analytics, no tracking, no cloud upload.
- No private data, usernames, machine names, absolute paths, tokens, exports, or generated user data in GitHub.
- Development builds stay local.
- Beta and final releases may publish only sanitized ZIP/DMG artifacts and a privacy-review report.
- Dev, beta, and final are separate configurations and are always built from a clean state.

## Open in Xcode

Open `Package.swift` in Xcode. Select the `HealthAtlasApp` executable scheme and run on macOS 26 or newer.

## Open in Codex

Give Codex the file `Docs/CODEX_HANDOFF.md` as the primary instruction set. It defines scope, architecture, privacy rules, release workflow, and acceptance criteria.

## Important limitation

The supplied icon is a design concept PNG, not yet a complete `.icns`/`.appiconset`. Before a release, create the complete macOS iconset from the concept and verify all required sizes in Xcode. Do not publish the concept sheet or any unreviewed asset.
