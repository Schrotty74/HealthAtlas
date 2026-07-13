# HealthAtlas — Codex handoff

## Mission

Build a polished privacy-first macOS 26+ AppKit app named HealthAtlas. It visualises personal health data from local Apple Health and Google Health/Google Fit exports. The UI uses native AppKit and a Liquid Glass-inspired visual system with selectable themes and restrained animations.

The supplied HealthAtlas mockup is the binding design baseline. Do not replace it with a plain utility interface. The finished app must visibly carry over its glass depth, dashboard cards, source badges, dark premium palette, charts, selectable themes, and animated transitions. Read `Docs/DESIGN_SYSTEM.md` before changing UI code.

## Non-negotiable rules

1. Never commit private data, health exports, usernames, email addresses, device names, absolute paths, access tokens, API credentials, signing identities, or machine-specific build output.
2. Development builds remain local and are never uploaded to GitHub.
3. Beta and final releases may upload only sanitised ZIP/DMG files and the generated privacy-review report.
4. Dev, beta, and final are independent configurations. Never reuse an old app bundle, cache, application support directory, or test database.
5. Every dev, beta, and final build starts clean and contains no user content.
6. Run `Scripts/privacy-check.sh` before every beta or final publication. A failed check blocks publication.
7. Do not add telemetry, crash reporting, remote analytics, cloud upload, advertising SDKs, or hidden network calls.
8. Do not claim medical diagnosis or treatment. Insights must be descriptive and clearly non-medical.
9. Do not implement a direct health-data integration based on assumption. Verify current Apple and Google platform/API availability first. The initial release should support explicit local import.

## First milestones

- Make the AppKit shell compile on macOS 26.
- Replace placeholder cards with a privacy-safe local import pipeline.
- Define documented import formats and reject unknown/unsafe files.
- Build a normalised internal health model with provenance and timestamps.
- Add Overview, Trends, Sources, Insights, and Settings screens.
- Add selectable Clear Glass, Midnight Glass, Aurora, and Warm Paper themes.
- Add accessible reduced-motion and high-contrast modes.
- Implement the motion system from `Docs/DESIGN_SYSTEM.md`: animated card entrance, chart drawing, ring progress, hover depth, time-range transitions, and animated sidebar selection.
- Keep decorative animation subtle, purposeful, and fully disabled or reduced when macOS Reduced Motion is enabled.
- Add deterministic demo data that is clearly labelled and never mixed with imported user data.
- Add unit tests for parsing, normalisation, date handling, export redaction, and clean-start behaviour.

## Architecture direction

- `Import`: file selection, format validation, parsing, and import summaries.
- `Domain`: normalised metric models and date/calendar logic.
- `Store`: local persistence only; use an app-owned container and document the location without exposing user paths in logs.
- `Presentation`: AppKit view controllers, charts, themes, animations, accessibility.
- `Privacy`: redaction, consent state, export controls, privacy report generation.

Keep the first implementation simple and testable. Do not introduce SwiftUI, a database package, or a networking layer without an explicit decision recorded in the project documentation.

## Xcode handoff

Open `HealthAtlas.xcodeproj` in Xcode and select the shared `HealthAtlas` scheme. The repository also contains `Package.swift` for package-based Codex work. The Xcode project currently contains a minimal AppKit dashboard with fictional demo values only and a generated macOS AppIcon set. The icon remains a design master and must be reviewed at small sizes before release.

## Release acceptance

A release is ready only when:

- clean dev, beta, and final builds are independently reproducible;
- no private content or absolute paths are present in the staged tree or artifacts;
- the privacy script passes;
- the app launches on a clean macOS 26+ user account;
- the app starts with an empty state and no demo data unless demo mode is explicitly selected;
- imports are local and user initiated;
- the release ZIP/DMG contains no debug symbols, logs, test exports, or local metadata;
- the privacy report is published alongside the beta/final artifact.
