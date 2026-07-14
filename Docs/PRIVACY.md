# HealthAtlas privacy contract

HealthAtlas is designed to process imported health data locally on the user's Mac.

The project must not collect or transmit health data, usage analytics, advertising identifiers, or diagnostic logs containing user content. Imported files must be user-selected, processed locally, and never copied into the repository or release artifacts.

The app must provide a visible local-only status, explain what is stored locally, allow deletion of imported data, and keep exports opt-in. Any future network feature requires a separate documented review before implementation.

The current Apple Health import reads only a user-selected ZIP archive containing `Export.xml` or a directly selected `Export.xml` file. It parses the file locally for the current app session and retains only the displayed aggregate values in memory. The original archive or XML file is not copied, uploaded, or retained by HealthAtlas. The clinical companion XML is not imported.

Dev, Beta, and Final builds use separate bundle identifiers and separate local
preference domains. Dev is built locally in Xcode on the `dev` branch. The Beta
script creates a local `beta` snapshot through a temporary Git index; the Final
script fast-forwards local `main` only from that `beta` branch. Neither script
reads or copies imported health data, preferences, caches,
application-support files, or a previous app bundle. Every build clears only
the state belonging to its own channel.

This document is a product requirement, not a legal certification. App Store privacy declarations and legal wording must be checked against the actual implementation before distribution.
