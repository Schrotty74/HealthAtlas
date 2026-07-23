# HealthAtlas – Nächste Schritte

Stand: 2026-07-23. Bei größeren Änderungen aktualisieren. Kontext und feste Regeln stehen in [PROJECT_CONTEXT.md](PROJECT_CONTEXT.md).

## Priorität 1 – Vor der nächsten Beta gezielt prüfen

- Lokalen Dev-Build und `swift test` ausführen; aktuelle Ergebnisse hier erst danach eintragen.
- Den kompletten Importfluss mit der synthetischen Demo prüfen: Import, Auswahl unter Quellen, 4/8/12 Karten, Zeiträume, anklickbare Verlaufspunkte und Einblicke.
- Einen ZIP-Export mit enthaltenem `Export.xml` testen. Ein dokumentiertes Testergebnis liegt noch nicht vor.
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

- Entscheiden, welche Lizenz vor einer öffentlichen Veröffentlichung gelten soll.
- Anforderungen für Apple-Signierung und Notarisierung erst klären, wenn ein Developer-Account und eine Veröffentlichung tatsächlich beauftragt sind.
- Falls JSON/CSV dauerhaft nicht unterstützt werden sollen, Dateiauswahl und Validierung auf ZIP/XML begrenzen. Derzeit werden JSON/CSV nur geprüft, nicht in ein Dashboard importiert.

## Keine offenen Aufgaben ohne Auftrag

- Keine reale HealthKit-Integration beginnen.
- Keine medizinischen Bewertungen, Diagnosen oder Behandlungshinweise entwickeln.
- Keine Releases, Tags, Pushes, Backups oder globalen Abhängigkeitsinstallationen ohne ausdrücklichen Auftrag starten.
