# First Codex prompt for HealthAtlas

You are working on the HealthAtlas macOS application in this repository.

Before changing code:

1. Read `README.md`, `README.de.md`, `Docs/CODEX_HANDOFF.md`, `Docs/DESIGN_SYSTEM.md`, `Docs/PRIVACY.md`, and `Docs/RELEASE_WORKFLOW.md`.
2. Inspect both `HealthAtlas.xcodeproj` and `Package.swift`.
3. Build the first local development version in Xcode on macOS 26 or newer.
4. Start with a clean state and verify that no user data, private paths, credentials, exports, or release artifacts are included.
5. If the build fails, fix only the concrete build blockers and explain each change.
6. Do not add real health-data integrations, network calls, telemetry, or dependencies yet.
7. Do not publish a Dev build or create a ZIP/DMG.
8. Keep the Liquid Glass mockup, bilingual English/German UI, animations, privacy-first architecture, and in-app GitHub link as binding requirements.

After the first build, report:

- whether the project builds;
- whether the app launches;
- which language controls and GitHub link are present;
- whether the initial state is clean and contains only clearly labelled demo data;
- any remaining blockers before implementing the real local import pipeline.
