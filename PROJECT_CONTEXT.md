# HealthAtlas – Projektkontext

Stand: 13. September 2026 · Releasebranch: `main`

HealthAtlas ist eine native macOS-App zur lokalen Darstellung eines bewusst
ausgewählten Apple-Health-Exports. Sie startet ohne Daten, verarbeitet nur eine
vom Nutzer ausgewählte lokale `Export.xml` oder ZIP-Datei und erstellt weder
Diagnosen noch Behandlungsempfehlungen. Es gibt keinen HealthKit-Zugriff, keine
Cloud-Synchronisierung, keine Telemetrie und kein Daten-Backend.

Die allgemeinen Arbeits-, Git-, Veröffentlichungs- und Repository-Datenschutzregeln stehen verbindlich in `AGENTS.md`. Diese Datei enthält den branch- und projektspezifischen technischen Kontext.

## Aktueller Stand

- Die aktuelle öffentliche Final-Version ist `v1.0.1` mit ZIP, DMG und SHA-256-Dateien. Die aktuelle öffentliche Vorabversion ist `Beta 1.3.0` mit technischem Tag `v1.3.0-beta`; sie erweitert den lokalen Import, die Quellenlogik und die Oberfläche.
- Die App bietet lokale Importansicht, Quellen-Auswahl, Übersichten mit separat auswählbarem gemeinsamen Verlauf, Verläufe für 7T, 15T, 30T, 3M, 6M und 1J, beschreibende Einblicke, Zeitraumvergleiche, anklickbare Datenkalendertage für 7T, 15T, 4W, 3M, 6M und 1J mit lokalem Wert, Musterkarte, Vollbild-Fokus, konfigurierbare Karten und Kartensortierung.
- Deutsch und Englisch, die Themes Clear Glass, Midnight Glass, Aurora und Warmpaper sowie die datensparsame Ersthilfe sind umgesetzt. Im Design-Studio bleiben die drei KI-Dienste für eine Erklärung des passenden öffentlichen Handbuchs dauerhaft verfügbar; die deutschen und englischen Handbücher lassen sich dort getrennt öffnen. Das Design-Studio zeigt zudem die installierte Version und kann die öffentliche GitHub-Release-Liste nach frei wählbarem Intervall oder manuell prüfen; dabei werden keine Gesundheitsdaten übertragen.
- Die App verwendet eine native Menüleiste für Import, PDF-Export, Ansicht und Fenstersteuerung; die Sidebar lässt sich über einen App-Button und das View-Menü ein- und ausblenden. Der PDF-Export ist ohne importierte Daten deaktiviert.
- Eigene interaktive Diagramm- und Kartenansichten sind als AppKit-Accessibility-Controls erreichbar; die bestehenden Themes bleiben unverändert.

## Architektur

| Bereich | Aufgabe |
| --- | --- |
| `Sources/HealthAtlasApp/` | AppKit-/SwiftUI-App, Import, Datenaggregation, Oberfläche, KI-Ersthilfe und optionale Release-Prüfung |
| `Tests/HealthAtlasTests/` | Swift-Tests für Import, Datenverarbeitung und datensparsame Hilfe |
| `HealthAtlasUITests/` | Xcode-UI-Regressionstest für die stabile Positionierung der Design-Studio-Einstellungen bei Sprach- und Themewechsel |
| `Demo/AppleHealthDemo/` | sichere synthetische Testdaten |
| `Scripts/` | Dev-Build, Beta-/Final-Release, Paketierung, Backup und Datenschutzprüfung |
| `output/pdf/` | öffentliche deutsche und englische Handbücher |
| `tmp/pdfs/generate_healthatlas_manuals.py` | Generator der Handbücher |
| `HealthAtlas.xcodeproj/`, `Package.swift` | Xcode- und Swift-Package-Konfiguration |

`Package.swift` deklariert keine externen Swift-Package-Abhängigkeiten. Das Projekt benötigt Xcode/Swift und eine Bash-Version, die mit den vorhandenen Skripten kompatibel ist. Projektabhängigkeiten, Anmeldungen, Zertifikate oder Tokens werden nicht automatisch installiert, angelegt oder geändert.

## Branch-Grenzen

| Branch | Zweck | Grenze |
| --- | --- | --- |
| `dev` | ausschließlich lokale Arbeitslinie | wird nicht nach GitHub gepusht; Änderungen erst nach ausdrücklichem Beta-Auftrag übernehmen |
| `beta` | öffentliche Vorabversion auf GitHub | enthält die veröffentlichte Vorabversion `Beta 1.3.0` |
| `main` | Final-Linie auf GitHub | enthält die ausdrücklich freigegebene Final-Version `v1.0.1` |

Die Branches haben unterschiedliche Historien und Dokumentationsstände. Dateien nicht allein zur Vereinheitlichung zwischen Branches kopieren oder zusammenführen. Die ausführlichen Funktionsübersichten `FEATURES.md` und `FEATURES.de.md` werden jedoch auf `dev`, `beta` und `main` gepflegt. Sie ergänzen README und Projektkontext, ersetzen aber keine Branch- oder Release-Regeln.

Die lokalen Refs `beta` und `main` entsprechen jeweils `origin/beta` und `origin/main`. Weder zu `main` wechseln noch Branches zusammenführen, sofern dies nicht ausdrücklich beauftragt wurde.

## Build, Test und Veröffentlichung

```zsh
swift test
Scripts/build-development.sh
```

- Dev-Builds landen unter `dist/local-test/HealthAtlas-Development/`; auch ein direkter erfolgreicher Xcode-Dev-Build aktualisiert dort die startbare Dev-App.
- Jeder Build schreibt die Git-Commitanzahl als interne Buildnummer in die App; die öffentliche Marketing-Version bleibt für Beta- und Final-Freigaben ausdrücklich festgelegt.
- `Scripts/create-beta-from-dev.sh` erstellt vom lokalen Branch `dev` eine Beta `X.Y.0` oder einen Beta-Bugfix `X.Y.Z` und veröffentlicht sie nach `beta`.
- `Scripts/publish-beta-as-final.sh` erstellt einen ausdrücklich freigegebenen Final-Snapshot `X.0.0` standardmäßig aus der `beta`-Linie oder mit `--from-dev` direkt aus `dev`. Die getrennten Branch-Historien bleiben dabei erhalten.
- Beide Veröffentlichungswege sind technisch gesperrt: Eine Beta startet nur mit `Scripts/create-beta-from-dev.sh [X.Y.Z] --publish-beta --confirm-publish-beta`; ein Final oder Bugfix auf `main` nur mit `Scripts/publish-beta-as-final.sh [X.Y.Z] --publish-final --confirm-publish-final`. Die Versionsnummer ist optional; ohne sie verwenden die Skripte die konfigurierte Marketing-Version. Die Flags sind ausschließlich eine technische Sperre und keine zusätzliche Anforderung an den Nutzer: Nur ein direkter Auftrag des Nutzers wie „Baue eine Beta“ oder „Baue ein Final“ genügt. Ohne beide passenden Flags brechen die Skripte vor Build, Commit, Tag, Release und Push ab.
- Vor Releases `Scripts/privacy-check.sh` ausführen; Release-Paketierung und Backups benötigen ihre jeweils explizite Umgebungsfreigabe.
- Die allgemeinen Regeln für Builds, Commits, Pushes, Tags, Releases und Backups stehen in `AGENTS.md`.
- GitHub-Changelog-Titel beginnen ausschließlich mit `Final X.0.0`, `Beta X.Y.0` oder `Bugfix X.Y.Z`. Bei Final-Releases steigt die erste Stelle, bei Betas die zweite und bei Bugfixes die dritte Stelle auf Basis der letzten Veröffentlichung. Technische Git-Tags bleiben maschinenlesbar, etwa `v1.0.0` oder `v1.1.0-beta`.

## Projektspezifische Regeln

- Dev, Beta und Final verwenden getrennte App-IDs und lokale Einstellungen.
- Bei sichtbaren Funktions-, Bedienungs- oder Datenschutzänderungen README, beide Handbücher und die Kontextdateien gegen den tatsächlichen Stand abgleichen.
