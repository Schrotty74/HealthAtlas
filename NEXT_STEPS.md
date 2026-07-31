# HealthAtlas – Nächste Schritte

Stand: 2026-07-31. Bei größeren Änderungen aktualisieren. Kontext und feste Regeln stehen in [PROJECT_CONTEXT.md](PROJECT_CONTEXT.md).

## Priorität 1 – Vor der nächsten Beta gezielt prüfen

- `swift test` ist am 2026-07-31 erfolgreich mit fünf Tests gelaufen: XML-Import, ZIP mit `Export.xml`, Dienst-URLs, datensparsamer Prompt und sprachabhängige Handbuch-Links.
- Der Dev-Build vom 2026-07-31 enthält die drei lokalen KI-Logos; der Bundle-Inhalt und die Ad-hoc-Signatur wurden geprüft.
- Den kompletten sichtbaren Importfluss mit der synthetischen Demo weiter manuell prüfen: Auswahl unter Quellen, 4/8/12 Karten, Zeiträume, anklickbare Verlaufspunkte und Einblicke.
- Datenschutzprüfung vor einem Release ausführen. Keine privaten Apple-Health-Exporte für Tests oder Screenshots verwenden.

## Priorität 2 – Geplante visuelle Weiterentwicklung

Die bestehenden Animationen sollen gezielt erweitert werden, ohne die ruhige Oberfläche zu überladen:

- Gestaffelte Einblendung der Übersichtskarten und animiertes Zeichnen der Mini- und Verlaufslinien.
- Weiche Übergänge bei 7T/30T/3M/1J, Datentypwechsel und Seitenwechsel.
- Deutlichere, gut lesbare Datenpunkt-Details beim Anklicken im Verlauf.
- Subtile, theme-abhängige Hintergrundbewegung bzw. Lichtreflexe.
- Sanfter animierter Auswahlindikator in der Sidebar und verfeinerter Importfortschritt.

Diese Punkte sind Wünsche aus der bisherigen Produktarbeit, keine bereits zugesagten oder implementierten Aufgaben.

## Priorität 3 – Produkt- und Release-Klärungen

- Eine konkrete Open-Source-Lizenz auswählen und als Lizenzdatei ergänzen.
- Anforderungen für Apple-Signierung und Notarisierung erst klären, wenn ein Developer-Account und eine Veröffentlichung tatsächlich beauftragt sind.

## Keine offenen Aufgaben ohne Auftrag

- Keine reale HealthKit-Integration beginnen.
- Keine medizinischen Bewertungen, Diagnosen oder Behandlungshinweise entwickeln.
- Keine Releases, Tags, Pushes, Backups oder globalen Abhängigkeitsinstallationen ohne ausdrücklichen Auftrag starten.
