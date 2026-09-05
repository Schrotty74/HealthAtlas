# HealthAtlas

[Deutsch](README.de.md)

HealthAtlas is a privacy-first macOS app for turning a local Apple Health export into clear, visual insights.

It starts empty, imports only a file you choose, and turns selected health data into a calm, modern dashboard. HealthAtlas focuses on trends and personal patterns instead of raw tables.

## Features

- Import a local Apple Health `Export.xml` file or ZIP archive and choose the recognised data types to show.
- Explore a configurable overview with metric cards, shared timelines, period rings and a local PDF report.
- Follow individual metrics in interactive 7D, 30D, 3M and 1Y trends, including point details and a local activity calendar.
- Open a metric in a dedicated full-screen focus view with its local trend and period comparison.
- Read descriptive local snapshots, coverage and recording patterns without diagnoses or health ratings.
- Keep separate pins and local ordering for Overview, Trends and Insights.
- Use German or English and choose from four glass themes.

See the complete, grouped [feature overview](FEATURES.md), including current screenshots.

## Privacy first

HealthAtlas is designed around local processing. Personal health data should remain on the user's Mac. The project does not include analytics, advertising, tracking or hidden cloud uploads.

The project contains no analytics, advertising, tracking, account or cloud upload. Imported data stays in memory for the current app session and the app opens empty again next time.

## Local builds and Gatekeeper

Create the local Dev app with:

```bash
bash Scripts/build-development.sh
```

The only runnable Dev output is `dist/local-test/HealthAtlas-Development/HealthAtlas Dev.app`.
Building or running the shared Dev scheme directly in Xcode refreshes this same app.
The `.build` directory is only Xcode's temporary compiler workspace, not a second app to open.

The current Dev and Beta builds are ad-hoc signed. macOS Gatekeeper may show a
warning the first time one is opened.

To open a local build without disabling Gatekeeper system-wide:

1. In Finder, Control-click `HealthAtlas Beta.app` (or `HealthAtlas Dev.app`) and choose **Open**.
2. Confirm **Open** in the dialog.
3. If macOS still blocks it, open **System Settings → Privacy & Security** and
   choose **Open Anyway** for that specific HealthAtlas build.

Only do this for a build you created yourself or obtained from the official
HealthAtlas GitHub release. This does not disable Gatekeeper system-wide.

## Data sources

Apple Health ZIP archives containing `Export.xml` and direct `Export.xml` files
are read locally. The clinical companion file is intentionally not imported.
There is no direct HealthKit or cloud-service connection.

## Demo without personal data

The repository includes a fully synthetic Apple Health file for safe testing: [`Demo/AppleHealthDemo/Export.xml`](Demo/AppleHealthDemo/Export.xml). It contains fictional values for every currently supported, non-deprecated Apple Health export type; no personal export values are included.

In HealthAtlas, choose **Import Apple Health…** and select that file. Use **Sources** to choose data types, **Overview** to select card count and density, and **Trends** to try data types, periods and individual points. No personal data is required or uploaded.

## Try it safely

Use the included synthetic demo instead of personal data:

1. Open HealthAtlas and choose **Import Apple Health…**.
2. Select [`Demo/AppleHealthDemo/Export.xml`](Demo/AppleHealthDemo/Export.xml).
3. Choose the metrics under **Sources**.
4. Explore cards, the shared timeline and rings in **Overview**, point details and time ranges in **Trends**, and coverage and recording patterns in **Insights**.

## Beta packages

The beta script builds an ad-hoc-signed app plus ZIP, DMG and SHA-256 files,
stores them locally and publishes a GitHub pre-release.

```bash
bash Scripts/create-beta-from-dev.sh
```

The app is written to `dist/releases/beta/<version>/`; ZIP, DMG, checksums and
the changelog are written to `Backup/releases/beta/<version>/`.

## Project status

HealthAtlas is an early beta. The local import and interface are ready for
feedback. It does not provide medical integration, diagnoses or treatment
recommendations.

## License

HealthAtlas is licensed under the [GNU General Public License v3.0](LICENSE).
