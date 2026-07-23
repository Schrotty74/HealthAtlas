# HealthAtlas – Projektkontext

> Haupt-Wissensquelle für neue Codex-Chats. Stand: 2026-07-23.  
> Zuerst diese Datei, danach [NEXT_STEPS.md](NEXT_STEPS.md), [README.md](README.md) und bei deutschen Texten [README.de.md](README.de.md) lesen. Für synthetische Testdaten siehe [Demo/README.md](Demo/README.md).

## Ziel und Zweck

HealthAtlas ist eine native macOS-App zur **lokalen** Darstellung eines vom Nutzer ausgewählten Apple-Health-Exports. Sie startet ohne Daten, wertet einen lokalen ZIP- oder `Export.xml`-Export aus und zeigt bewusst ausgewählte Datentypen als Übersicht, Verlauf und beschreibende Einblicke. Die App erstellt keine Diagnosen und gibt keine Behandlungsempfehlungen.

## Architektur und wichtige Ordner

- `Sources/HealthAtlasApp/`: AppKit-/SwiftUI-Anwendung.
  - `AppEntry.swift`: Fenster, App-Lebenszyklus und Wiederöffnen aus dem Dock.
  - `DashboardViewController.swift`: Dashboard, AppKit-Layout, native Glas-Sidebar, Importansicht, Themes, Karten, Trends und Einblicke.
  - `HealthData.swift`: Dateiprüfung, ZIP-/XML-Import, XML-Parser, Tagesaggregation und Datentyp-Bezeichnungen.
  - `AppLanguage.swift`: Deutsch/Englisch sowie getrennte Einstellungen je Build-Kanal.
- `Tests/HealthAtlasTests/`: Swift-Testing-Test für die Apple-Health-XML-Auswertung.
- `Demo/AppleHealthDemo/Export.xml`: synthetische, sichere Testdaten. Keine persönlichen Daten hinzufügen.
- `Scripts/`: Dev-, Release-, Backup- und Datenschutzskripte.
- `dist/`: erzeugte, nicht zu versionierende App-Ausgaben.
- `Backup/`: erzeugte, nicht zu versionierende Release- und Backup-Artefakte.
- `HealthAtlas.xcodeproj/`: Xcode-Projekt; Projektformat ist Xcode 16.0.
- `Package.swift`: Swift Package Manifest für die App und Tests. Es sind keine externen Swift-Package-Abhängigkeiten deklariert.

## Datenformate und Datenfluss

- Unterstützter tatsächlicher Import: Apple Health `Export.xml` direkt oder ZIP mit einer darin enthaltenen `Export.xml`.
- Die maximale Dateigröße für Import und XML-Auswertung beträgt 100 MB.
- XML-`Record`-Einträge werden nach Typ gruppiert und zu Anzahl, Summe, Durchschnitt und Tageswerten zusammengefasst.
- Nichtnumerische Einträge können als erkannter Datentyp erscheinen, haben aber keinen numerischen Verlauf.
- Importierte Daten liegen nur im Speicher der laufenden App-Sitzung. Beim nächsten Start ist die App wieder leer.
- Kein direkter HealthKit-Zugriff, keine Cloud-Synchronisierung und keine Analyse- oder Tracking-Anbindung.
- Die Dateiauswahl akzeptiert derzeit auch JSON/CSV zur lokalen Prüfung; daraus wird jedoch kein Apple-Health-Dashboard importiert. Dieser Unterschied ist eine bekannte Einschränkung.

## Umgesetzte Funktionen

- Leerer Start mit animierter lokaler Importansicht.
- Auswahl erkannter Datentypen unter **Quellen**; Auswahl wird getrennt je Dev/Beta/Final gespeichert.
- Übersicht mit wählbar 4, 8 oder 12 Karten und Seitennavigation.
- Interaktive Verläufe: Datentyp, 7T/30T/3M/1J und anklickbare Datenpunkte.
- Einblicke als beschreibende lokale Zusammenfassung mit letztem Wert und Veränderung zum vorherigen Wert.
- Deutsch und Englisch, wählbar im Design-Studio.
- Themes: Clear Glass, Midnight Glass, Aurora und Warmpaper.
- Native AppKit-Milchglas-Sidebar; Clear Glass nutzt zusätzlich eine durchscheinende Arbeitsfläche.
- Animierte Karten, Liniencharts und Importdarstellung.
- Synthetische Demo für sichere Tests und Repository-Screenshots.

## Build-, Test- und Release-Workflow

Die Login-Shell ist zsh. Für Bash-Skripte auf diesem Mac die Homebrew-Bash verwenden:

```bash
/opt/homebrew/bin/bash Scripts/build-development.sh
```

- **Dev:** `Scripts/build-development.sh` erzeugt die startbare App unter `dist/local-test/HealthAtlas-Development/HealthAtlas Dev.app`.
- **Tests:** `swift test` führt die Swift-Tests aus. Ein aktuelles Testergebnis ist in diesem Dokument nicht festgehalten; vor Aussagen über den Status selbst ausführen.
- **Beta:** `Scripts/create-beta-from-dev.sh` darf nur vom Branch `dev` aus verwendet werden. Es baut Paketdateien, aktualisiert `beta` und erstellt bzw. aktualisiert eine GitHub-Vorabveröffentlichung.
- **Final:** `Scripts/publish-beta-as-final.sh` erwartet einen sauberen Arbeitsbaum, übernimmt `beta` per Fast-Forward in `main`, baut Paketdateien und veröffentlicht auf GitHub.
- **Paketierung:** `Scripts/build-release-package.sh` erfordert die explizite Umgebungsfreigabe `HEALTHATLAS_ALLOW_RELEASE_PACKAGE=YES`.
- **Backups:** `Scripts/archive-build.sh` erfordert `HEALTHATLAS_ALLOW_BACKUP=YES`, erstellt ein lokales Build-Backup und kann eine optionale Cloud-Kopie anlegen.
- **Datenschutz:** Vor Releases `Scripts/privacy-check.sh`; bei Bedarf zusätzlich `Scripts/privacy-audit.sh` ausführen.

Builds, Releases, Tags, Commits, Pushes und Backups niemals ohne ausdrücklichen Auftrag starten.

## Abhängigkeiten und Entwicklungsumgebung

Es gibt keine externen Swift-Package-Abhängigkeiten und keine Lockfile-Datei. Für eine neue Entwicklungsumgebung sind folgende Werkzeuge relevant; nichts davon automatisch installieren oder aktualisieren:

| Werkzeug | Zweck | Quelle im Projekt | Offizieller Installationsweg | Verifikation | Einordnung |
| --- | --- | --- | --- | --- | --- |
| Xcode mit Swift-Toolchain | App-Build, Tests und Xcode-Projekt | `Package.swift`, `HealthAtlas.xcodeproj`, Build-Skripte | Apple App Store oder Apple Developer | `xcodebuild -version`, `swift --version` | Allgemeine macOS-Entwicklungsumgebung |
| Homebrew Bash | Ausführung der Bash-Skripte nach lokaler Konvention | `Scripts/*.sh` | Homebrew-Formel `bash` | `/opt/homebrew/bin/bash --version` | Allgemeine Shell-Laufzeit auf diesem Mac |
| macOS-Systemwerkzeuge | Import, Signierung und Paketierung (`unzip`, `zip`, `ditto`, `codesign`, `hdiutil`, `otool`) | Import- und Release-Skripte | Bestandteil von macOS/Xcode; nicht separat projektweit installieren | `command -v unzip zip ditto codesign hdiutil otool` | Projekt-Build/Release, keine Swift-Abhängigkeit |
| GitHub CLI (`gh`) | Nur Beta- und Final-Veröffentlichung | `create-beta-from-dev.sh`, `publish-beta-as-final.sh` | Offizielle GitHub-CLI-Installation | `gh --version` | Release-spezifisch; Anmeldung oder Tokens niemals automatisch anlegen oder speichern |

Für eine Ergänzung der allgemeinen Entwicklungsumgebung muss zuerst ein exakter Prompt-Diff vorgelegt und bestätigt werden. Dieser Projektkontext dokumentiert nur den Bedarf; er ändert keine Umgebung.

## Feste Entscheidungen und Regeln

- Drei Git-Branches: `dev`, `beta`, `main`. In Xcode müssen alle drei einmal lokal durchgewechselt werden, damit Xcode sie im Branch-Menü zuverlässig anzeigt. Xcodes Play-Button bleibt auf den Dev-Scheme beschränkt.
- Die Dev-, Beta- und Final-Varianten haben getrennte App-IDs und getrennte lokale Einstellungen.
- Die App verwendet AppKit für Fenster, Glas-Sidebar und Diagramm-/Kartenansichten; SwiftUI wird für den Sidebar-Inhalt eingebettet.
- Änderungen an Release-Skripten immer gegen AppAtlas abgleichen, wenn ein Auftrag das ausdrücklich verlangt.
- Persönliche Exporte, lokale Benutzerpfade, Zugangsdaten, Zertifikate, Teams, Tokens, Backups und private Testdaten gehören weder in Git noch in Dokumentation oder Screenshots.
- Öffentliche Namensnennung ausschließlich als `Schrotty74`.

## Datenschutz und Veröffentlichung

- Keine Konten, Analytics, Werbung, Tracking oder versteckten Uploads.
- Nur vom Nutzer gewählte lokale Dateien werden gelesen.
- Die Demo und alle Repository-Screenshots müssen synthetische Daten verwenden und als Demo gekennzeichnet sein.
- Die vorhandenen Builds sind ad-hoc signiert; ohne Apple-Developer-Account erscheint beim ersten Start Gatekeeper. Die README enthält die sichere Öffnungsanleitung.
- Medizinische Integration, Diagnosen und öffentliche Verteilung sind nicht Teil des dokumentierten Funktionsstands.

## Bekannte Einschränkungen und unbekannte Punkte

- Kein bestätigter aktueller Bug ist dokumentiert. Aktuelle Build-, Test- und UI-Checks sind vor einer neuen Behauptung auszuführen.
- Kein CI-Workflow und keine Lockfile-Datei wurden im Repository gefunden.
- Die Lizenz ist laut README noch nicht festgelegt.
- Nicht geklärt bzw. nicht dokumentiert: Anforderungen für eine spätere Signierung, Notarisierung oder öffentliche Distribution.

Bei größeren fachlichen, Architektur-, Build-, Datenschutz- oder Release-Änderungen diese Datei und [NEXT_STEPS.md](NEXT_STEPS.md) aktualisieren.
