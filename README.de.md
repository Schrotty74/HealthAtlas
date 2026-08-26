# HealthAtlas

HealthAtlas ist eine datenschutzorientierte macOS-App, die einen lokalen Apple-Health-Export verständlich und grafisch aufbereitet.

Die App startet leer, importiert ausschließlich eine vom Nutzer gewählte Datei und zeigt ausgewählte Gesundheitsdaten in einem ruhigen, modernen Dashboard. HealthAtlas konzentriert sich auf Verläufe und persönliche Muster statt auf Rohdaten-Tabellen.

## Was HealthAtlas bietet

- Native macOS-App mit Swift, SwiftUI und AppKit
- Lokaler Import von Apple-Health-`Export.xml`-Dateien und ZIP-Archiven damit
- Frei wählbare, erkannte Datentypen für die Anzeige
- Dynamische Kennzahlen-Kacheln mit eigener Farbe und grafischem Hintergrund
- Interaktive Verläufe: Datentyp, 7T/30T/3M/1J, Hover-Werte und einzelne Datenpunkte auswählen
- Getrennte Pins für Übersicht, Verläufe und Einblicke sowie lokale Reihenfolge, Kategorien und Suche für große Datentyp-Listen
- Klickbare Kennzahlen-Karten mit eigener Vollbild-Fokusansicht, Verlauf, Zeitraumvergleich und Jahreskalender
- Gemeinsamer Mehrfach-Verlauf, visuelle Tagesringe und lokaler Zeitraumvergleich
- Lokaler Datenkalender in Verläufen mit 1 Woche, 4 Wochen, 3 Monaten, 6 Monaten oder 1 Jahr sowie echte Vollbild-Fokusansicht mit Zeitraumvergleich
- Interaktive Verläufe mit schwebender Wertkarte, Datum, Mini-Trend und sanft pulsierendem ausgewählten Punkt
- Anpassbares Dashboard: Kartenzahl, kompakte/Standard/Fokus-Dichte sowie gespeicherte lokale Kartenanordnung je Layout
- Lokale Datenqualitäts-Übersicht ohne Bewertung der Gesundheitswerte
- Konfigurierbarer lokaler PDF-Bericht: Zeitraum, ausgewählte Datentypen und Bericht-Theme; nur an einen bewusst gewählten Speicherort
- Zum lokalen Datentyp passende Diagramme: Balken für Schritte und Energie, Bereichsdiagramm für Schlaf, Linien für andere numerische Werte und lokale Zeitraum-Ringe
- Lokale Datenverwaltung mit Import ersetzen, Bestätigung zum vollständigen Löschen und sichtbarem Importzeitpunkt der aktuellen Sitzung
- Reine Abdeckungs-Hinweise zu fehlenden lokalen Tagen, wenigen Werten und sachlichen Trend-Höhepunkten — niemals Gesundheitsbewertung oder Diagnose
- Beschreibende lokale Einblicke mit Momentaufnahme, lokaler Abdeckung und Erfassungsmuster — niemals Diagnosen oder Behandlungsempfehlungen
- Deutsche und englische Oberfläche
- Beschreibende Karte „Dein Zeitraum in Kürze“ für die letzten sieben lokalen Erfassungstage — keine Bewertung und keine Diagnose
- Geführte Glas-Leerzustände mit direkter Aktion zu Quellen oder lokalem Import
- Glass-Themes, dezente Karten-/Diagramm-Animationen, Import-Erfolgsschimmer, native Milchglas-Sidebar sowie Glow, Lichtpunkte, Konturen und Gesundheits-Symbole im Clear-Glass-Theme hinter gut lesbaren Inhalten
- Startfenster im 16:9-Format, danach frei skalierbar

## Datenschutz an erster Stelle

HealthAtlas ist für lokale Verarbeitung ausgelegt. Persönliche Gesundheitsdaten sollen auf dem Mac des Nutzers bleiben. Das Projekt verwendet keine Analyse, Werbung, Nachverfolgung oder versteckten Cloud-Upload.

Das Projekt enthält weder Analytics, Werbung, Tracking, Konto noch Cloud-Upload. Importierte Daten bleiben nur für die laufende App-Sitzung im Speicher; beim nächsten Öffnen startet die App wieder leer.

## Lokale Builds und Gatekeeper

Den lokalen Dev-Build erstellst du mit:

```bash
bash Scripts/build-development.sh
```

Die einzige startbare Dev-App liegt anschließend unter `dist/local-test/HealthAtlas-Development/HealthAtlas Dev.app`.
Der Ordner `.build` ist ausschließlich der temporäre Compiler-Arbeitsbereich von Xcode, keine zweite App zum Öffnen.

Die aktuellen Dev- und Beta-Builds sind ad hoc signiert, weil für das Projekt
kein Apple-Developer-Account vorhanden ist. macOS Gatekeeper zeigt beim ersten
Öffnen daher einen Hinweis an.

So öffnest du einen lokalen Build, ohne Gatekeeper systemweit abzuschalten:

1. Im Finder bei gedrückter Control-Taste auf `HealthAtlas Beta.app` (oder
   `HealthAtlas Dev.app`) klicken und
   **Öffnen** wählen.
2. Im Hinweisfenster nochmals **Öffnen** bestätigen.
3. Falls macOS die App weiter blockiert: **Systemeinstellungen → Datenschutz &
   Sicherheit** öffnen und bei genau diesem HealthAtlas-Build **Dennoch
   öffnen** wählen.

Mach das nur bei einem Build, den du selbst erstellt oder vom offiziellen
HealthAtlas-GitHub-Release erhalten hast. Gatekeeper wird dadurch nicht
systemweit deaktiviert.

## Datenquellen

Apple-Health-ZIP-Archive mit `Export.xml` und direkte `Export.xml`-Dateien werden lokal gelesen; die klinische Zusatzdatei wird bewusst nicht importiert. Es gibt keine direkte HealthKit- oder Cloud-Anbindung.

## Demo ohne persönliche Daten

Für einen sicheren Test liegt eine vollständig synthetische Apple-Health-Datei im Repository: [`Demo/AppleHealthDemo/Export.xml`](Demo/AppleHealthDemo/Export.xml). Sie enthält fiktive Werte für alle aktuell unterstützten, nicht veralteten Apple-Health-Exporttypen; persönliche Exportwerte werden nicht übernommen.

In HealthAtlas **Apple Health importieren …** wählen und diese Datei öffnen. Unter **Quellen** Datentypen wählen, unter **Übersicht** Kartenzahl und Dichte festlegen und unter **Verläufe** Datentyp, Zeitraum und einzelne Punkte ausprobieren. Es werden keine persönlichen Daten benötigt oder hochgeladen.

## Sicher testen

Zum Testen liegt eine vollständig synthetische Demo bei:

1. HealthAtlas öffnen und **Apple Health importieren …** wählen.
2. [`Demo/AppleHealthDemo/Export.xml`](Demo/AppleHealthDemo/Export.xml) auswählen.
3. Unter **Quellen** die gewünschten Werte wählen.
4. Kacheln, Mehrfach-Verlauf und Ringe unter **Übersicht**, Punkte und Zeiträume unter **Verläufe** sowie Kalender und Muster unter **Einblicke** erkunden.

## Screenshots

Alle folgenden Screenshots zeigen die aktuelle HealthAtlas-Oberfläche mit ausschließlich synthetischen Demodaten – es sind keine persönlichen Gesundheitsdaten zu sehen.

### Import

<a href="Screenshots/import.png"><img src="Screenshots/import.png" alt="Leere HealthAtlas-Startansicht für den Apple-Health-Import" width="50%"></a>

### Übersicht

<a href="Screenshots/overview.png"><img src="Screenshots/overview.png" alt="HealthAtlas-Übersicht mit ausgewählten Gesundheits-Kacheln" width="50%"></a>

### Quellen

<a href="Screenshots/sources.png"><img src="Screenshots/sources.png" alt="HealthAtlas-Auswahl importierter Apple-Health-Datentypen" width="50%"></a>

### Verläufe

<a href="Screenshots/trends.png"><img src="Screenshots/trends.png" alt="Interaktiver Herzfrequenz-Verlauf in HealthAtlas" width="50%"></a>

### Einblicke

<a href="Screenshots/insights.png"><img src="Screenshots/insights.png" alt="Lokaler Herzfrequenz-Einblick in HealthAtlas" width="50%"></a>

### Design-Studio

<a href="Screenshots/design-studio.png"><img src="Screenshots/design-studio.png" alt="HealthAtlas-Theme- und Spracheinstellungen" width="50%"></a>

## Beta-Pakete

Das Beta-Skript erzeugt lokal eine ad-hoc-signierte App sowie ZIP, DMG und
SHA-256-Dateien, legt sie lokal ab und veröffentlicht einen GitHub-Pre-Release.

```bash
bash Scripts/create-beta-from-dev.sh
```

Die App liegt danach unter `dist/releases/beta/<version>/`; ZIP, DMG,
Prüfsummen und Changelog unter `Backup/releases/beta/<version>/`.

## Projektstatus

HealthAtlas ist eine frühe Beta. Testdaten, Oberfläche und lokaler Import sind
bereit für Feedback; medizinische Integration, Diagnosefunktionen und eine
öffentliche Verteilung sind ausdrücklich nicht Teil dieses Standes.

## Community

Fragen, Feedback und Diskussionen sind auf [Discord](https://discord.gg/Zy93AaYFaj) willkommen.

## Lizenz

Die Lizenz wird vor der ersten öffentlichen Veröffentlichung ergänzt.
