# HealthAtlas

HealthAtlas is a privacy-first macOS app for turning personal health data into clear, visual insights.

The app is designed to bring data from Apple Health and Google Health/Google Fit together in one calm, modern dashboard. HealthAtlas focuses on trends and personal patterns instead of overwhelming users with raw tables.

## What HealthAtlas offers

- A native macOS 26+ experience built with Swift and AppKit
- Visual dashboards for activity, sleep, heart rate, wellness and other health metrics
- Interactive trends with time ranges, comparisons and animated charts
- Local, descriptive insights without medical diagnosis or treatment claims
- Support for English and German, switchable directly inside the app
- Selectable Liquid Glass themes and visual styles
- Accessible animation controls, including Reduced Motion support
- A visible local-processing status so it is clear where calculations happen
- Direct access to the public [HealthAtlas GitHub repository](https://github.com/Schrotty74/HealthAtlas)

## Privacy first

HealthAtlas is designed around local processing. Personal health data should remain on the user's Mac. The project does not include analytics, advertising, tracking or hidden cloud uploads.

Development builds are kept local. Only reviewed beta and final release artifacts may be published, and every publication must pass the project's privacy check first.

## Data sources

The initial development direction uses user-selected local import files. Direct synchronisation with Apple Health or Google services will only be added after the relevant platform APIs, permissions and privacy requirements have been verified.

## Project status

HealthAtlas is currently in early development. This repository contains the native macOS project foundation, the first AppKit dashboard, the Liquid Glass design system, the bilingual UI foundation, the privacy workflow and the HealthAtlas heart icon.

The interface is being developed from the included visual concept, with animation and interaction treated as central parts of the product rather than optional decoration.

## License

License information will be added before the first public release.

For technical project guidance, see the documentation in [`Docs/`](Docs/).
