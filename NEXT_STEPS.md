# HealthAtlas – Nächste Schritte

Stand: 2026-08-10. Bei größeren Änderungen aktualisieren. Kontext und feste Regeln stehen in [PROJECT_CONTEXT.md](PROJECT_CONTEXT.md).

## Priorität 1 – Vor der nächsten Beta gezielt prüfen

- Beta `0.1.0-beta.2` mit ZIP-Export und synthetischer Demo manuell prüfen:
  Import, Quellen-Auswahl, Übersicht, Verläufe, Einblicke sowie Deutsch/Englisch.
- Die unteren Bereiche der Übersicht prüfen: Ringe und gemeinsamer Verlauf müssen
  Daten anzeigen; bei leeren Daten muss eine verständliche Erklärung erscheinen.
- Gatekeeper-Öffnen der Beta auf einem Mac ohne bereits gewährte Ausnahme testen.
- `swift test` und `Scripts/privacy-check.sh` vor einem weiteren Release erneut
  ausführen. Keine privaten Apple-Health-Exporte für Tests oder Screenshots nutzen.

## Priorität 2 – Geplante visuelle Weiterentwicklung

Die bestehenden Animationen sollen gezielt erweitert werden, ohne die ruhige Oberfläche zu überladen:

- Sichtbares Verhalten und Lesbarkeit der vorhandenen Animationen im Beta-Test
  bewerten; nur konkrete Rückmeldungen daraus als neue Aufgaben übernehmen.

Diese Punkte sind Wünsche aus der bisherigen Produktarbeit, keine bereits zugesagten oder implementierten Aufgaben.

## Priorität 3 – Produkt- und Release-Klärungen

- Eine konkrete Open-Source-Lizenz auswählen und als Lizenzdatei ergänzen.
- Anforderungen für Apple-Signierung und Notarisierung erst klären, wenn ein Developer-Account und eine Veröffentlichung tatsächlich beauftragt sind.

## Keine offenen Aufgaben ohne Auftrag

- Keine reale HealthKit-Integration beginnen.
- Keine medizinischen Bewertungen, Diagnosen oder Behandlungshinweise entwickeln.
- Keine Releases, Tags, Pushes, Backups oder globalen Abhängigkeitsinstallationen ohne ausdrücklichen Auftrag starten.
