# HealthAtlas – Nächste Schritte

Stand: 15. August 2026 · Bezug: öffentliche Beta `v0.1.0-beta.4`

Diese Datei enthält nur bestätigte offene Arbeit. Kontext und feste Regeln
stehen in `PROJECT_CONTEXT.md`.

## Priorität 1 – Beta auf echten Geräten abnehmen

- Beta `0.1.0-beta.4` mit der synthetischen Demo manuell prüfen: Import,
  Quellen-Auswahl, Übersicht, Verläufe, Einblicke sowie Deutsch/Englisch.
- Die unteren Bereiche der Übersicht prüfen: Ringe und gemeinsamer Verlauf
  müssen Daten zeigen; bei leeren Daten muss eine verständliche Erklärung
  erscheinen.
- Gatekeeper-Öffnen auf einem Mac ohne bereits gewährte Ausnahme testen.
- Vor einer weiteren Veröffentlichung `swift test` und
  `Scripts/privacy-check.sh` erneut ausführen.

## Priorität 2 – Produktklärung

- Sichtbares Verhalten und Lesbarkeit der vorhandenen Animationen im Beta-Test
  bewerten; nur konkrete Rückmeldungen als neue Aufgaben aufnehmen.
- Eine Open-Source-Lizenz erst nach bewusster Auswahl ergänzen.
- Anforderungen für Signierung und Notarisierung erst klären, wenn ein
  Developer-Account und eine Veröffentlichung ausdrücklich beauftragt sind.

## Nicht ohne Auftrag beginnen

- Keine reale HealthKit-Integration, Diagnosen oder Behandlungshinweise.
- Keine Releases, Tags, Pushes, Backups oder globalen Abhängigkeitsänderungen.
