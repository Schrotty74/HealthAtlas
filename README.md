# HealthAtlas

[Deutsche README](README.de.md)

Privacy-first macOS app for visualising personal health data from local exports.

## Current status

This repository is a clean starter scaffold for Xcode and Codex. It contains a native AppKit shell, mock data only, the selected HealthAtlas heart icon concept, release rules, and a privacy review script.

The first implementation must use local import files. A direct macOS HealthKit integration must not be assumed: Apple Health data access is primarily provided by Apple platforms with HealthKit, while macOS support and Google data access require a separately verified import or synchronisation route. Do not add an integration until its current API and privacy requirements have been verified.

## Product principles

- macOS 26 or newer.
- Native Swift and AppKit. No external framework unless explicitly approved.
- Runtime language switch between English and German.
- An in-app link to the public GitHub repository.
- Privacy by default: local processing, no analytics, no tracking, no cloud upload.
- No private data, usernames, machine names, absolute paths, tokens, exports, or generated user data in GitHub.
- Development builds stay local.
- Beta and final releases may publish only sanitized ZIP/DMG artifacts and a privacy-review report.
- Dev, beta, and final are separate configurations and are always built from a clean state.

## Open in Xcode

Open `HealthAtlas.xcodeproj` in Xcode. Select the shared `HealthAtlas` scheme and run on macOS 26 or newer. `Package.swift` is also included for package-based Codex work.

## Open in Codex

Give Codex the file `Docs/CODEX_HANDOFF.md` as the primary instruction set. It defines scope, architecture, privacy rules, release workflow, and acceptance criteria.

## Icon and release status

The repository contains a prepared macOS `AppIcon.appiconset` based on the selected heart concept. Review it at all sizes in Xcode before release. The repository is a development scaffold; it does not contain a release app, ZIP, or DMG.
