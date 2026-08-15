# HealthAtlas – Projektkontext

Stand: 15. August 2026 · Arbeitsbranch: `dev`

HealthAtlas ist eine native macOS-App zur lokalen Darstellung eines bewusst
ausgewählten Apple-Health-Exports. Sie startet ohne Daten, verarbeitet nur eine
vom Nutzer ausgewählte lokale `Export.xml` oder ZIP-Datei und erstellt weder
Diagnosen noch Behandlungsempfehlungen. Es gibt keinen HealthKit-Zugriff, keine
Cloud-Synchronisierung, keine Telemetrie und kein Daten-Backend.

## Zuerst lesen

1. Diese Datei
2. `NEXT_STEPS.md`
3. `README.md` und bei deutschen Texten `README.de.md`
4. `Demo/README.md` bei Demo- oder Testdatenarbeit
5. Betroffene Build-, Test-, Release- und Datenschutzskripte vor Änderungen

## Aktueller Stand

- Die aktuelle öffentliche Vorabversion ist `v0.1.0-beta.4` vom 13. August
  2026. Sie enthält ZIP, DMG und SHA-256-Dateien.
- Die aktuelle Arbeitslinie ist `dev`; `beta` und `main` bleiben getrennte
  Release-Linien. Diese Übergabedokumente liegen deshalb auch auf `dev`.
- Die App bietet lokale Importansicht, Quellen-Auswahl, Übersichten, Verläufe,
  beschreibende Einblicke, Zeitraumvergleiche, Datenkalender, Musterkarte,
  Vollbild-Fokus, konfigurierbare Karten und Kartensortierung.
- Deutsch und Englisch, die Themes Clear Glass, Midnight Glass, Aurora und
  Warmpaper sowie die datensparsame Ersthilfe sind umgesetzt.
- `Demo/AppleHealthDemo/Export.xml` enthält ausschließlich synthetische
  Daten. Öffentliche Screenshots und Handbücher müssen ebenso synthetisch
  bleiben.

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

`Package.swift` deklariert keine externen Swift-Package-Abhängigkeiten. Das
Projekt benötigt Xcode/Swift; die vorhandenen Bash-Skripte werden auf diesem
Mac mit `/opt/homebrew/bin/bash` ausgeführt. Keine Abhängigkeit, Anmeldung,
Zertifikat oder Token automatisch installieren, anlegen oder ändern.

## Build, Test und Veröffentlichung

```zsh
swift test
/opt/homebrew/bin/bash Scripts/build-development.sh
```

- Dev-Builds landen unter `dist/local-test/HealthAtlas-Development/`.
- `Scripts/create-beta-from-dev.sh` ist nur für den Branch `dev` bestimmt.
- `Scripts/publish-beta-as-final.sh` übernimmt eine freigegebene Beta per
  Fast-Forward nach `main`.
- Vor Releases `Scripts/privacy-check.sh` ausführen; Release-Paketierung und
  Backups benötigen ihre jeweils explizite Umgebungsfreigabe.
- Builds, Commits, Pushes, Tags, Releases und Backups erfolgen nur auf
  ausdrücklichen Auftrag.

## Feste Regeln

- Persönliche Apple-Health-Exporte, lokale Pfade, Zugangsdaten, Tokens,
  Zertifikate, Backups und private Testdaten gehören nie in Git,
  Dokumentation oder Screenshots.
- Die freiwillige KI-Ersthilfe kopiert nur eine feste allgemeine Frage mit
  öffentlichem Handbuch-Link; Gesundheitsdaten werden nicht gelesen oder
  übertragen.
- Dev, Beta und Final verwenden getrennte App-IDs und lokale Einstellungen.
- Bei sichtbaren Funktions-, Bedienungs- oder Datenschutzänderungen README,
  beide Handbücher und diese Übergabedokumente gegen den tatsächlichen Stand
  abgleichen.
