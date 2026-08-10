# HealthAtlas – Projektkontext

> Zuerst lesen: diese Datei, dann `NEXT_STEPS.md`, anschließend `README.md` oder
> `README.de.md`. Für konkrete Build- und Veröffentlichungsschritte immer auch
> die betroffenen Skripte unter `Scripts/` lesen.

## Ziel und Umfang

HealthAtlas ist eine native macOS-App für die lokale, verständliche Darstellung
eines bewusst ausgewählten Apple-Health-Exports. Sie ist kein Diagnose- oder
Behandlungstool. Die App startet ohne Daten und verarbeitet Importe nur lokal
für die laufende Sitzung.

## Architektur und wichtige Dateien

- `HealthAtlas.xcodeproj/`: Xcode-Projekt mit Dev-, Beta- und Final-Konfiguration.
- `Sources/HealthAtlasApp/DashboardViewController.swift`: AppKit-Oberfläche,
  Navigation, Themen, Diagramme, Karten und Animationen.
- `Sources/HealthAtlasApp/HealthData.swift`: lokaler XML-/ZIP-Import,
  Datenmodell und Auswertungen.
- `Sources/HealthAtlasApp/AIHelp.swift`: datensparsame Ersteinführungs-Hilfe;
  kopiert nur einen allgemeinen Prompt in die Zwischenablage und öffnet einen
  gewählten Dienst erst nach Klick.
- `Sources/HealthAtlasApp/Resources/AI/`: lokal eingebundene KI-Logos.
- `Tests/HealthAtlasTests/`: Parser-, Vergleichs- und KI-Hilfe-Tests.
- `Demo/AppleHealthDemo/Export.xml`: ausschließlich synthetische Demodaten.
- `output/pdf/`: deutsches und englisches Handbuch.
- `tmp/pdfs/generate_healthatlas_manuals.py`: Generator für beide Handbücher.

## Daten und Datenschutz

- Unterstützt werden direkte `Export.xml`-Dateien sowie ZIP-Archive mit einer
  solchen Datei. Die klinische Begleitdatei wird bewusst nicht importiert.
- Es gibt keine HealthKit-Anbindung, kein Konto, keine Analytics, kein Tracking
  und keinen Upload.
- Keine persönlichen Daten, lokalen Pfade, Backups oder Testexporte committen.
- `Scripts/privacy-check.sh` vor jedem Beta- oder Final-Build ausführen.
- Öffentliche Screenshots und Handbücher dürfen nur synthetische Demodaten zeigen.

## Build-, Test- und Release-Workflow

- Dev: `Scripts/build-development.sh`; Ausgabe unter
  `dist/local-test/HealthAtlas-Development/`.
- Tests: `swift test`.
- Beta: `Scripts/create-beta-from-dev.sh <version>` erzeugt signierte App,
  ZIP, DMG, SHA-256-Dateien, Backup und GitHub-Pre-Release auf `beta`.
- Final: `Scripts/publish-beta-as-final.sh <version>` übernimmt `beta` nach
  `main`, baut ZIP/DMG und veröffentlicht den Final-Release.
- Ohne Apple-Developer-Account sind Build-Artefakte ad-hoc signiert; Gatekeeper-
  Hinweise und die dokumentierte Öffnen-Anleitung müssen erhalten bleiben.
- Bei Bash-Aufgaben auf diesem Mac `/opt/homebrew/bin/bash` verwenden. Die
  Release-Skripte selbst sind zsh-Skripte.

## Umgesetzt

- Lokaler Apple-Health-XML- und ZIP-Import mit auswählbaren Datentypen.
- Deutsche und englische Oberfläche.
- Übersicht, Verläufe, Quellen, Einblicke und Design-Studio.
- Interaktive Diagrammpunkte, Zeiträume, Kartenanzahl/-dichte,
  Drag-and-drop-Reihenfolge, Vollbild-Fokus, Datenkalender und lokale Vergleiche.
- Clear-Glass-Thema mit ruhiger, bewegungsreduzierbarer Hintergrundanimation.
- Lokale GitHub- und Discord-Links sowie freiwillige KI-Ersteinführung ohne
  Weitergabe persönlicher Daten.
- Deutsche und englische PDF-Handbücher.

## Feste Regeln

- Keine automatische Gesundheits-, Cloud- oder KI-Datenübertragung.
- Keine neue Veröffentlichung, kein Tag und kein Push ohne ausdrücklichen Auftrag.
- Bei sichtbaren Funktions-, Datenschutz- oder Navigationsänderungen beide
  Handbücher und beide READMEs aktualisieren und die PDFs prüfen.
- Für Beta und Final immer ZIP und DMG plus Prüfsummen erzeugen und den
  Ausgabepfad im Ergebnis nennen.
- Keine temporären Build-, PDF-Render- oder Compilerdateien in Git aufnehmen.

## Bekannte Grenzen

- Es gibt keine Notarisierung; Gatekeeper muss beim ersten Öffnen bestätigt werden.
- Daten bleiben absichtlich nur für die aktuelle Sitzung erhalten.
- Keine medizinische Interpretation, Diagnose oder Behandlungsempfehlung.
