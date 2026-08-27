# HealthAtlas – Projektkontext

Stand: 27. August 2026 · Arbeitsbranch: `dev`

HealthAtlas ist eine native macOS-App zur lokalen Darstellung eines bewusst
ausgewählten Apple-Health-Exports. Sie startet ohne Daten, verarbeitet nur eine
vom Nutzer ausgewählte lokale `Export.xml` oder ZIP-Datei und erstellt weder
Diagnosen noch Behandlungsempfehlungen. Es gibt keinen HealthKit-Zugriff, keine
Cloud-Synchronisierung, keine Telemetrie und kein Daten-Backend.

Die allgemeinen Arbeits-, Git-, Veröffentlichungs- und Repository-Datenschutzregeln stehen verbindlich in `AGENTS.md`. Diese Datei enthält den branch- und projektspezifischen technischen Kontext.

## Aktueller Stand

- Die aktuelle öffentliche Vorabversion ist `v0.1.0-beta.5` vom 27. August 2026. Sie enthält ZIP, DMG und SHA-256-Dateien.
- `dev` ist ausschließlich die lokale Arbeitslinie; auf GitHub liegen nur die getrennten Release-Linien `beta` und `main`.
- Die App bietet lokale Importansicht, Quellen-Auswahl, Übersichten, Verläufe, beschreibende Einblicke, Zeitraumvergleiche, Datenkalender, Musterkarte, Vollbild-Fokus, konfigurierbare Karten und Kartensortierung.
- Deutsch und Englisch, die Themes Clear Glass, Midnight Glass, Aurora und Warmpaper sowie die datensparsame Ersthilfe sind umgesetzt.
- `Demo/AppleHealthDemo/Export.xml` enthält ausschließlich synthetische Daten. Öffentliche Screenshots und Handbücher müssen ebenso synthetisch bleiben.

## Architektur

| Bereich | Aufgabe |
| --- | --- |
| `Sources/HealthAtlasApp/` | AppKit-/SwiftUI-App, Import, Datenaggregation, Oberfläche und KI-Ersthilfe |
| `Tests/HealthAtlasTests/` | Swift-Tests für Import, Datenverarbeitung und datensparsame Hilfe |
| `Demo/AppleHealthDemo/` | sichere synthetische Testdaten |
| `Scripts/` | Dev-Build, Beta-/Final-Release, Paketierung, Backup und Datenschutzprüfung |
| `output/pdf/` | öffentliche deutsche und englische Handbücher |
| `tmp/pdfs/generate_healthatlas_manuals.py` | Generator der Handbücher |
| `HealthAtlas.xcodeproj/`, `Package.swift` | Xcode- und Swift-Package-Konfiguration |

`Package.swift` deklariert keine externen Swift-Package-Abhängigkeiten. Das Projekt benötigt Xcode/Swift und eine Bash-Version, die mit den vorhandenen Skripten kompatibel ist. Projektabhängigkeiten, Anmeldungen, Zertifikate oder Tokens werden nicht automatisch installiert, angelegt oder geändert.

## Build, Test und Veröffentlichung

```zsh
swift test
Scripts/build-development.sh
```

- Dev-Builds landen unter `dist/local-test/HealthAtlas-Development/`.
- `Scripts/create-beta-from-dev.sh` erstellt vom lokalen Branch `dev` eine Beta und veröffentlicht sie nach `beta`.
- `Scripts/publish-beta-as-final.sh` übernimmt eine freigegebene Beta per Fast-Forward nach `main`.
- Vor Releases `Scripts/privacy-check.sh` ausführen; Release-Paketierung und Backups benötigen ihre jeweils explizite Umgebungsfreigabe.
- Die allgemeinen Regeln für Builds, Commits, Pushes, Tags, Releases und Backups stehen in `AGENTS.md`.

## Projektspezifische Regeln

- Die freiwillige KI-Ersthilfe kopiert nur eine feste allgemeine Frage mit öffentlichem Handbuch-Link; Gesundheitsdaten werden nicht gelesen oder übertragen.
- Dev, Beta und Final verwenden getrennte App-IDs und lokale Einstellungen.
- Bei sichtbaren Funktions-, Bedienungs- oder Datenschutzänderungen README, beide Handbücher und die Kontextdateien gegen den tatsächlichen Stand abgleichen.
- Vor öffentlichen Builds und Releases die vorhandenen Datenschutzskripte verwenden und ausschließlich synthetische Demo-/Testdaten einsetzen.
