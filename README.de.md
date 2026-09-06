# HealthAtlas

HealthAtlas ist eine datenschutzorientierte macOS-App, die einen lokalen Apple-Health-Export verständlich und grafisch aufbereitet.

Die App startet leer, importiert ausschließlich eine vom Nutzer gewählte Datei und zeigt ausgewählte Gesundheitsdaten in einem ruhigen, modernen Dashboard. HealthAtlas konzentriert sich auf Verläufe und persönliche Muster statt auf Rohdaten-Tabellen.

## Was HealthAtlas bietet

- Eine lokale Apple-Health-`Export.xml`-Datei oder ein ZIP-Archiv importieren und die erkannten Datentypen gezielt auswählen.
- Quellen nach Kategorie oder Suche durchsuchen sowie getrennte Pins und lokale Reihenfolgen für Übersicht, Verläufe und Einblicke verwalten.
- 4, 8 oder 12 Übersichtskacheln, ihre Dichte und lokale Reihenfolge festlegen.
- Ein bis vier Datentypen unabhängig für den gemeinsamen Gesundheitsverlauf auswählen.
- Einen Wert über 7T, 15T, 30T, 3M, 6M und 1J verfolgen, mit anklickbaren Punkten und anklickbarem lokalem Kalender.
- Den aktuellen Zeitraum mit dem unmittelbar vorherigen vergleichen und einen Wert in einer Vollbild-Fokusansicht öffnen.
- Lokale Momentaufnahmen, Abdeckung und Erfassungsmuster ohne Diagnose oder Gesundheitsbewertung lesen.
- Einen lokalen PDF-Bericht mit eigener Auswahl für Zeitraum, Datentypen und Theme exportieren.
- Deutsch oder Englisch, eines von vier Glass-Themes und die manuelle oder geplante Prüfung der öffentlichen GitHub-Release-Liste nutzen.
- Die beiden öffentlichen Handbücher getrennt öffnen oder ChatGPT, Gemini beziehungsweise Claude das passende Handbuch anhand einer allgemeinen kopierten Frage erklären lassen. Lokale Gesundheitsdaten sind nicht enthalten.


### Screenshots

Alle Screenshots zeigen die aktuelle HealthAtlas-Oberfläche mit ausschließlich synthetischen Demodaten; persönliche Gesundheitsdaten sind nicht zu sehen.

<table>
  <tr><th align="left">Import</th><th align="left">Quellen</th></tr>
  <tr>
    <td><a href="Screenshots/final-import.png"><img src="Screenshots/final-import.png" alt="Leere HealthAtlas-Startansicht für den Apple-Health-Import" width="100%"></a></td>
    <td><a href="Screenshots/final-sources.png"><img src="Screenshots/final-sources.png" alt="HealthAtlas-Auswahl importierter Apple-Health-Datentypen" width="100%"></a></td>
  </tr>
  <tr><th align="left">Übersicht</th><th align="left">Verläufe</th></tr>
  <tr>
    <td><a href="Screenshots/final-overview.png"><img src="Screenshots/final-overview.png" alt="HealthAtlas-Übersicht mit Verlaufsauswahl und PDF-Bericht" width="100%"></a></td>
    <td><a href="Screenshots/final-trends.png"><img src="Screenshots/final-trends.png" alt="HealthAtlas-Verlauf mit 15-Tage-Zeitraum und lokalem Kalender" width="100%"></a></td>
  </tr>
  <tr><th align="left">Einblicke</th><th align="left">Design-Studio</th></tr>
  <tr>
    <td><a href="Screenshots/final-insights.png"><img src="Screenshots/final-insights.png" alt="Beschreibender lokaler HealthAtlas-Einblick" width="100%"></a></td>
    <td><a href="Screenshots/final-design-studio.png"><img src="Screenshots/final-design-studio.png" alt="HealthAtlas-Themes, Sprache, Handbuchhilfe und App-Aktualisierungen" width="100%"></a></td>
  </tr>
</table>

## Datenschutz an erster Stelle

HealthAtlas ist für lokale Verarbeitung ausgelegt. Persönliche Gesundheitsdaten sollen auf dem Mac des Nutzers bleiben. Das Projekt verwendet keine Analyse, Werbung, Nachverfolgung oder versteckten Cloud-Upload.

Das Projekt enthält weder Analytics, Werbung, Tracking, Konto noch Cloud-Upload. Importierte Daten bleiben nur für die laufende App-Sitzung im Speicher; beim nächsten Öffnen startet die App wieder leer. Wenn du eine Update-Prüfung aktivierst, ruft HealthAtlas ausschließlich die öffentliche GitHub-Release-Liste ab; Gesundheitsdaten werden dabei nie übertragen.

## Lokale Builds und Gatekeeper

Den lokalen Dev-Build erstellst du mit:

```bash
bash Scripts/build-development.sh
```

Die einzige startbare Dev-App liegt anschließend unter `dist/local-test/HealthAtlas-Development/HealthAtlas Dev.app`.
Auch ein direkter Build oder Run des gemeinsamen Dev-Schemes in Xcode aktualisiert genau diese App.
Der Ordner `.build` ist ausschließlich der temporäre Compiler-Arbeitsbereich von Xcode, keine zweite App zum Öffnen.

Dev-, Beta- und Final-Builds sind ad hoc signiert. macOS Gatekeeper kann
beim ersten Öffnen einen Hinweis anzeigen.

So öffnest du einen lokalen Build, ohne Gatekeeper systemweit abzuschalten:

1. Im Finder bei gedrückter Control-Taste auf `HealthAtlas.app`,
   `HealthAtlas Beta.app` oder `HealthAtlas Dev.app` klicken und
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
4. Kacheln, Mehrfach-Verlauf und Ringe unter **Übersicht**, Punkte und Zeiträume unter **Verläufe** sowie Abdeckung und Erfassungsmuster unter **Einblicke** erkunden.

## Beta-Pakete

Das Beta-Skript erzeugt lokal eine ad-hoc-signierte App sowie ZIP, DMG und
SHA-256-Dateien, legt sie lokal ab und veröffentlicht einen GitHub-Pre-Release.

```bash
bash Scripts/create-beta-from-dev.sh
```

Die App liegt danach unter `dist/releases/beta/<version>/`; ZIP, DMG,
Prüfsummen und Changelog unter `Backup/releases/beta/<version>/`.

## Projektstatus

Final 1.0.0 ist die aktuelle stabile Veröffentlichung. HealthAtlas bleibt ein lokales Visualisierungswerkzeug und bietet keine medizinische Integration, Diagnosen oder Behandlungsempfehlungen.

## Lizenz

HealthAtlas steht unter der [GNU General Public License v3.0](LICENSE).
