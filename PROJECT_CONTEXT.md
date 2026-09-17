# HealthAtlas – Projektkontext

Stand: 17. September 2026 · Arbeitsbranch: `dev`

HealthAtlas ist eine native macOS-App zur lokalen Darstellung eines bewusst
ausgewählten Apple-Health-Exports. Sie startet ohne Daten, verarbeitet nur eine
vom Nutzer ausgewählte lokale `Export.xml` oder ZIP-Datei und erstellt weder
Diagnosen noch Behandlungsempfehlungen. Es gibt keinen HealthKit-Zugriff, keine
Cloud-Synchronisierung, keine Telemetrie und kein Daten-Backend.

Repository: `https://github.com/Schrotty74/HealthAtlas`. Die Arbeitskopie ist
der lokale Projektordner beziehungsweise Repository-Root.

Die allgemeinen Arbeits-, Git-, Veröffentlichungs- und Repository-Datenschutzregeln stehen verbindlich in `AGENTS.md`. Diese Datei enthält den branch- und projektspezifischen technischen Kontext.

## Aktueller Stand

- Die aktuelle öffentliche Final-Version ist `v1.0.1` mit ZIP, DMG und SHA-256-Dateien. Sie behebt die Darstellung rechteckiger Hintergrundanteile an abgerundeten Card-Ecken. Die aktuelle öffentliche Vorabversion ist der Diagnose-Testbuild `Bugfix 1.5.3` mit technischem Tag `v1.5.3-beta`. Er verarbeitet relevante nicht-selbstschließende Apple-Health-Records mit untergeordnetem Inhalt in der Quellenregel korrekt und enthält weiterhin eine kopierbare, datensparsame Diagnose für verbleibende Importfehler über Issue #13. Auf GitHub sind für diesen Testbuild ausschließlich ZIP und DMG angehängt. Der vorherige Bugfix 1.5.1 importiert gültige Apple-Health-Exporte mit interner XML-`DOCTYPE` wieder direkt und aus ZIP-Archiven. Das zusätzliche Theme Schwarz & Weiß, dessen native neutrale Flächen der hellen oder dunklen macOS-Darstellung folgen, verlässliche Theme-Wechsel, lesbare Kontraste und dezente Kartenanimationen für Clear Glass und Schwarz & Weiß bleiben enthalten.
- Die Arbeitskopie behält den vorgemerkten Stand, aus dem Bugfix 1.5.1 erstellt wurde. `dev` bleibt ohne Remote-Branch. Den Stand nicht ohne ausdrücklichen Auftrag verwerfen oder in `dev` committen. Vor weiterer Arbeit zuerst `git status` und den Vergleich mit `beta` prüfen; eine weitere Beta entsteht erst aus neuen, ausdrücklich beauftragten Änderungen.
- Der lokale Dev-Build nutzt zusätzlich den geprüften Optimierungsstand: Karten teilen sich einen Animationstakt, nicht sichtbare Hintergrundanimationen pausieren, wiederholt benötigte Datentypnamen und Quellen-Normalisierungen werden zwischengespeichert. Die Scrollleiste erscheint nur bei tatsächlichem vertikalem Überlauf.
- Die App bietet lokale Importansicht, Quellen-Auswahl mit Datentyp-Suche, Übersichten mit separat auswählbarem gemeinsamen Verlauf, Verläufe für 7T, 15T, 30T, 3M, 6M und 1J, beschreibende Einblicke, Zeitraumvergleiche, anklickbare Datenkalendertage für 7T, 15T, 4W, 3M, 6M und 1J mit lokalem Wert, Musterkarte, Vollbild-Fokus, konfigurierbare Karten und Kartensortierung.
- In der kompakten Übersicht hat die obere Titelzeile jeder Karte eine feste, ausreichend hohe Textfläche, damit die Schrift nicht angeschnitten wird. Die besonders lange Apple-Handgelenktemperatur heißt dort verkürzt „Wrist Temperature“ beziehungsweise „Handgelenktemperatur“, ohne den vollständigen Namen in Quellen oder Detailansichten zu verändern.
- Direkte `Export.xml`-Dateien sowie ZIP-Archive werden vollständig lokal bis jeweils 5 GiB verarbeitet. XML wird inkrementell aus einem Dateistream gelesen; dabei überspringt der Stream-Parser auch die interne `DOCTYPE`-Deklaration regulärer Apple-Health-Exporte vollständig. Bei ZIP prüft HealthAtlas zusätzlich die entpackte `Export.xml`, schreibt sie begrenzt temporär lokal und verarbeitet sie anschließend ebenfalls streambasiert. Der laufende Import kann abgebrochen werden, ohne unvollständige Daten zu übernehmen; vor dem Import weist die App darauf hin, dass Dateien über 500 MB lange dauern und Importe ab 1 GB mehrere Minuten benötigen können. Die Grenze ist eine HealthAtlas-Sicherheitsgrenze, keine Grenze von Apple Health oder macOS.
- Bei einem fehlgeschlagenen Import kann der Nutzer eine Diagnose in die Zwischenablage kopieren. Sie enthält nur App-/macOS-Version, Eingabeart, Dateigröße, Importstufe, technischen Fehlercode, gegebenenfalls verfügbare Parserposition und Laufzeit; Dateinamen, Pfade, XML-Inhalt und Gesundheitsdaten bleiben ausgeschlossen.
- Der Import liest die ursprüngliche XML sequenziell einmal. Für die 15-Minuten-Quellenregel werden nur eindeutige summierbare Intervallwerte und schlafende Schlafintervalle gebündelt in einer temporären lokalen Zwischenablage weiterverarbeitet; die übrigen Werte werden direkt aggregiert. Diese Zwischenablage erzeugt aus den geparsten Record-Attributen stets vollständige selbstschließende XML-Elemente und verarbeitet damit auch reguläre nicht-selbstschließende Records mit untergeordnetem Inhalt. Das vermeidet einen zweiten Vollzugriff auf große Exporte. Exakte Records werden anhand aller exportierten Attribute kompakt dedupliziert. Summierbare Intervalltypen verwenden eine deterministische Quellenregel pro 15-Minuten-Intervall; bei gleicher Abdeckung entscheidet die alphabetische Quellenreihenfolge ohne Unterschied von Groß- und Kleinschreibung oder Akzenten. Diskrete Messproben bleiben getrennt. Die ausführbaren Dev-, Beta- und Final-Builds verwenden Swift-Optimierung, damit große lokale Importe nicht wie ein unoptimierter Testlauf behandelt werden. Da der Export keine rekonstruierbare Apple-Quellenpriorität enthält, behauptet HealthAtlas keine identischen Werte zur Health-App.
- Deutsch und Englisch, die Themes Clear Glass, Midnight Glass, Aurora, Warmpaper und Schwarz & Weiß sowie die datensparsame Ersthilfe sind umgesetzt. Schwarz & Weiß verwendet neutrale macOS-Materialien und semantische Farben, folgt der hellen oder dunklen Systemdarstellung und behält farbige Kennzahlen-Akzente sowie unterschiedliche Linienstile für klare Diagramme. Im Design-Studio bleiben die drei KI-Dienste für eine Erklärung des passenden öffentlichen Handbuchs dauerhaft verfügbar; die deutschen und englischen Handbücher lassen sich dort getrennt öffnen. Erscheinungsbild, Handbuchhilfe und App-Aktualisierungen sind als drei zurückhaltende Bereiche gegliedert. Die Theme-Kacheln sind dort kompakter; das aktive Theme ist klar umrandet. Das Design-Studio zeigt zudem die installierte Version und kann die öffentliche GitHub-Release-Liste nach frei wählbarem Intervall oder manuell prüfen; dabei werden keine Gesundheitsdaten übertragen.
- Die App verwendet eine native Menüleiste für Import, PDF-Export, Ansicht und Fenstersteuerung; die Sidebar lässt sich über einen App-Button und das View-Menü ein- und ausblenden. Die aktive Sidebar-Auswahl verwendet die Cyan-Akzentfarbe statt Gelb. Im Design-Studio, der Übersicht sowie für Handbuch öffnen, Import ersetzen und Alle lokalen Daten löschen gelten einheitliche Höhe und Schrift; der Löschbutton verwendet zusätzlich den nativen roten Hintergrund bei unveränderter Form. Der PDF-Export ist ohne importierte Daten deaktiviert.
- In Quellen bleiben Kategorie und Suche direkt sichtbar. „Anzeigen & anpinnen“ bündelt Alle anzeigen, Keine anzeigen sowie die ausdrücklich benannten Ziele für Pin.
- Eigene interaktive Diagramm- und Kartenansichten sind als AppKit-Accessibility-Controls erreichbar; die bestehenden Themes bleiben unverändert.

## Architektur

| Bereich | Aufgabe |
| --- | --- |
| `Sources/HealthAtlasApp/` | AppKit-/SwiftUI-App, Import, Datenaggregation, Oberfläche, KI-Ersthilfe und optionale Release-Prüfung |
| `Tests/HealthAtlasTests/` | Swift-Tests für Import, Datenverarbeitung und datensparsame Hilfe; `Fixtures/SourceOverlapValidation.xml` ist ein vollständig synthetischer, nicht gebündelter manueller und automatischer Quellenregeltest |
| `HealthAtlasUITests/` | Xcode-UI-Regressionstest für die stabile Positionierung der Design-Studio-Einstellungen bei Sprach- und Themewechsel |
| `Demo/AppleHealthDemo/` | sichere synthetische Testdaten |
| `Scripts/` | Dev-Build, Beta-/Final-Release, Paketierung, Backup und Datenschutzprüfung |
| `output/pdf/` | öffentliche deutsche und englische Handbücher |
| `tmp/pdfs/generate_healthatlas_manuals.py` | Generator der Handbücher |
| `HealthAtlas.xcodeproj/`, `Package.swift` | Xcode- und Swift-Package-Konfiguration |

`Package.swift` deklariert keine externen Swift-Package-Abhängigkeiten. Das Projekt benötigt Xcode/Swift sowie die für die vorhandenen Bash- und zsh-Skripte verfügbare Shell-Umgebung. Projektabhängigkeiten, Anmeldungen, Zertifikate oder Tokens werden nicht automatisch installiert, angelegt oder geändert.

## Build- und UI-Prüfung

- Vor einer Funktionsprüfung den tatsächlich laufenden HealthAtlas-Prozess anhand des exakten Pfads des Dev-App-Bundles beenden und danach ausschließlich dieses Bundle starten.
- Erst bestätigen, dass der laufende Prozess zu diesem Build-Pfad gehört. Ohne diese Bestätigung keine Aussage über sichtbare Änderungen oder eine erfolgreiche Korrektur treffen.
- Keine Bildschirmaufnahme, Bildschirm- oder UI-Steuerung verwenden, sofern der Nutzer dies nicht ausdrücklich verlangt. Bei einer unklaren Prüfung „nicht verifiziert“ sagen, statt ein Ergebnis zu behaupten.

## Branch-Grenzen

| Branch | Zweck | Grenze |
| --- | --- | --- |
| `dev` | ausschließlich lokale Arbeitslinie | wird nicht nach GitHub gepusht; Änderungen erst nach ausdrücklichem Beta-Auftrag übernehmen |
| `beta` | öffentliche Vorabversion auf GitHub | enthält die veröffentlichte Vorabversion `Bugfix 1.5.3` |
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
- `Scripts/create-beta-from-dev.sh` erstellt vom lokalen Branch `dev` eine Beta `X.Y.0` oder einen Beta-Bugfix `X.Y.Z` und veröffentlicht ihn nach `beta`.
- `Scripts/publish-beta-as-final.sh` erstellt einen Final-Snapshot `X.0.0` aus der freigegebenen `beta`-Linie auf `main`. Die getrennten Branch-Historien bleiben dabei erhalten.
- Beide Veröffentlichungswege sind technisch gesperrt: Eine Beta startet nur mit `Scripts/create-beta-from-dev.sh [X.Y.Z] --publish-beta --confirm-publish-beta`; ein Final oder Bugfix auf `main` nur mit `Scripts/publish-beta-as-final.sh [X.Y.Z] --publish-final --confirm-publish-final`. Die Versionsnummer ist optional; ohne sie verwenden die Skripte die konfigurierte Marketing-Version. Die Flags sind ausschließlich eine technische Sperre und keine zusätzliche Anforderung an den Nutzer: Nur ein direkter Auftrag des Nutzers wie „Baue eine Beta“ oder „Baue ein Final“ genügt. Ohne beide passenden Flags brechen die Skripte vor Build, Commit, Tag, Release und Push ab.
- Vor Releases `Scripts/privacy-check.sh` ausführen; Release-Paketierung und Backups benötigen ihre jeweils explizite Umgebungsfreigabe.
- Nach jeder Neuerstellung oder Änderung der PDF-Handbücher beide Ausgaben rendern und jede Seite visuell prüfen. Seitenumbrüche so anpassen, dass keine überwiegend leeren Inhaltsseiten entstehen; Text, Tabellen, Grafiken und Bildbeschriftungen dürfen weder überlappen noch abgeschnitten werden.
- Die allgemeinen Regeln für Builds, Commits, Pushes, Tags, Releases und Backups stehen in `AGENTS.md`.
- GitHub-Changelog-Titel beginnen ausschließlich mit `Final X.0.0`, `Beta X.Y.0` oder `Bugfix X.Y.Z`. Bei Final-Releases steigt die erste Stelle, bei Betas die zweite und bei Bugfixes die dritte Stelle auf Basis der letzten Veröffentlichung. Technische Git-Tags bleiben maschinenlesbar, etwa `v1.0.0` oder `v1.1.0-beta`.
- Das Beta-Skript bestimmt die vorherige Beta anhand der öffentlichen GitHub-Releases. Nach jeder Veröffentlichung lädt es den neuen technischen Tag lokal nach und prüft, dass er auf denselben Beta-Commit verweist. Dadurch bleiben lokale Tag-Referenzen, `beta` und die öffentliche Vorabversion nachvollziehbar synchron.

## Projektspezifische Regeln

- Dev, Beta und Final verwenden getrennte App-IDs und lokale Einstellungen.
- Bei sichtbaren Funktions-, Bedienungs- oder Datenschutzänderungen README, beide Handbücher und die Kontextdateien gegen den tatsächlichen Stand abgleichen.
