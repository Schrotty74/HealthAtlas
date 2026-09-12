# HealthAtlas-Funktionsübersicht

[English](FEATURES.md)

Diese Seite beschreibt die aktuellen HealthAtlas-Funktionen ausführlich.

## Was ist neu

- Der gemeinsame Gesundheitsverlauf besitzt jetzt eine eigene Auswahl: Ein bis vier aktive Datentypen wählen, ohne Karten, Pins oder andere Bereiche zu ändern.
- Verläufe und lokaler Datenkalender enthalten einen eigenen 15-Tage-Zeitraum; ein Kalendertag lässt sich anklicken und zeigt lokales Datum und Wert.
- Der lokale PDF-Bericht besitzt eine eigene Auswahl für Zeitraum, Datentypen und Theme, unabhängig von Übersicht und Verlaufsauswahl.
- Das Design-Studio zeigt die installierte Version und kann die öffentliche GitHub-Release-Liste manuell, bei jedem Start, täglich, wöchentlich oder monatlich prüfen.
- Das Design-Studio hält deutsche und englische öffentliche Handbücher sowie die drei datensparsamen Dienste zur Handbuch-Erklärung dauerhaft bereit.

## Import und Quellen

- Eine lokale Apple-Health-`Export.xml`-Datei oder ein ZIP-Archiv damit importieren. Die klinische Zusatzdatei wird bewusst nicht importiert.
- Die ursprüngliche XML wird einmal sequenziell gelesen und bis 5 GiB unterstützt. Nur Werte, die für die Überlappungslogik benötigt werden, landen begrenzt in einer lokalen temporären Zwischenablage. Exakte exportierte Records werden einmal gezählt; summierbare Intervalltypen verwenden eine deterministische Quellenregel in 15-Minuten-Intervallen. Bei gleicher Abdeckung entscheidet die alphabetische Quellenreihenfolge ohne Unterschied von Groß- und Kleinschreibung oder Akzenten; einzelne Messproben bleiben getrennt, sofern sie keine exakten Dubletten sind.
- HealthAtlas behauptet nicht, Apples interne Quellenpriorität nachzubilden. Schlaf wird auf eine Quelle pro lokalem Intervall begrenzt; Workouts werden nur bei vollständig gleichen exportierten Attributen dedupliziert.
- Unter **Quellen** jeden erkannten lokalen Datentyp nach Kategorie gruppiert prüfen. Kategorie und Suche bleiben sichtbar; **Anzeigen & anpinnen** enthält Alle anzeigen, Keine anzeigen und das Ziel für Pin.
- Datentypen getrennt für Übersicht, Verläufe und Einblicke anpinnen und lokal anordnen.
- Einen Import ersetzen, alle lokalen Daten nach Bestätigung löschen und den Importzeitpunkt der aktuellen Sitzung sehen.
- Die Datenqualitäts-Karte beschreibt lokale Abdeckung, fehlende Tage und selten erfasste Typen, ohne Gesundheitswerte zu bewerten.

## Übersicht

- 4, 8 oder 12 Kennzahlen-Kacheln wählen und die Dichte Kompakt, Standard oder Fokus nutzen. Jede Dichte speichert ihre eigene lokale Kartenreihenfolge.
- Eine Kennzahlen-Kachel in einer eigenen Vollbild-Fokusansicht öffnen.
- Ein bis vier aktive Datentypen unabhängig für den gemeinsamen Gesundheitsverlauf auswählen und ihre jüngsten Muster neben visuellen Tagesringen vergleichen.
- Einen lokalen PDF-Bericht mit eigenem Zeitraum, ausgewählten Datentypen und Theme exportieren. Der Speicherort wird bewusst gewählt.
- Die Übersicht verwendet Balken für Schritte und Energie, ein Bereichsdiagramm für Schlaf und Linien für andere numerische Werte.

## Verläufe und Fokusansicht

- Einen ausgewählten Wert zwischen 7T, 15T, 30T, 3M, 6M und 1J umschalten. Einen Punkt anklicken oder mit der Maus darüberfahren, um Datum, Wert und einen kompakten lokalen Trend zu sehen.
- Einen sachlichen Vergleich des aktuellen Zeitraums mit dem vorherigen ansehen, wenn genügend lokale Daten vorliegen.
- Den lokalen Datenkalender für 1 Woche, 15 Tage, 4 Wochen, 3 Monate, 6 Monate oder 1 Jahr nutzen. Einen Tag anklicken, um sein lokales Datum und seinen Wert zu sehen.
- Trend-Hinweise nennen Fakten wie einen lokalen Höchstwert oder die Anzahl der Tage mit Daten, ohne Gesundheitswerte zu bewerten.
- Die Vollbild-Fokusansicht verbindet den Verlauf des ausgewählten Werts mit Zeitraumvergleich und lokalem Datenkalender.

## Einblicke

- Eine lokale Momentaufnahme zeigt den letzten lokalen Wert und die Anzahl der lokalen Tage mit Werten.
- Die lokale Abdeckung nennt Tage mit und ohne Werte im aktuellen Zeitraum.
- Das Erfassungsmuster nennt den Wochentag mit den meisten lokalen Einträgen. Es beschreibt nur die Erfassungshäufigkeit.
- Einblicke sind beschreibende lokale Zusammenfassungen, niemals Diagnosen oder Behandlungsempfehlungen.

## Erscheinungsbild und lokale Nutzung

- Deutsche oder englische Oberfläche verwenden.
- Die native Menüleiste für Import, lokalen PDF-Bericht, Design-Studio und Fenstersteuerung verwenden; die Sidebar lässt sich im Menü „Ansicht“ ein- oder ausblenden.
- Clear Glass, Midnight Glass, Aurora oder Warmpaper wählen. Die App startet im 16:9-Format und bleibt frei skalierbar.
- Im Design-Studio die installierte Veröffentlichung sehen und die öffentliche GitHub-Release-Liste bei jedem Start, täglich, wöchentlich oder monatlich automatisch oder manuell prüfen. Eine neuere passende Veröffentlichung wird erst nach Klick auf ihren Link geöffnet.
- Geführte Leerzustände führen zu Quellen oder lokalem Import, wenn Daten oder eine Auswahl fehlen.
- Die Oberfläche nutzt native Glasflächen und dezente Animationen und berücksichtigt die macOS-Einstellung „Bewegung reduzieren“.
- Interaktive Karten und Diagramme sind als Bedienelemente für macOS-Assistenzfunktionen erreichbar.

## Freiwillige Ersthilfe

- Das passende öffentliche Handbuch direkt aus der leeren Importansicht öffnen.
- Für eine Erklärung zum Einstieg optional ChatGPT, Gemini oder Claude wählen. HealthAtlas kopiert eine feste allgemeine Frage mit dem öffentlichen Handbuch-Link in die Zwischenablage und öffnet den gewählten Dienst erst nach deinem Klick.
- Die vorbereitete Frage enthält nie importierte Werte oder andere lokale Gesundheitsdaten. Du entscheidest selbst, ob du sie beim gewählten Dienst einfügst.
- Im Design-Studio stehen dieselben drei Dienste dauerhaft bereit. Dort lassen sich das deutsche und englische öffentliche Handbuch außerdem getrennt öffnen.

## Datenschutz

- HealthAtlas verwendet weder Konto, Analytics, Werbung, Tracking noch versteckten Cloud-Upload.
- Eine optionale Update-Prüfung ruft ausschließlich die öffentliche GitHub-Release-Liste ab; importierte Gesundheitswerte werden nie übertragen.
- Importierte Daten bleiben nur für die aktuelle App-Sitzung im Speicher. Nach dem erneuten Öffnen startet die App wieder leer.
- Es gibt keine direkte HealthKit- oder Cloud-Service-Anbindung.
