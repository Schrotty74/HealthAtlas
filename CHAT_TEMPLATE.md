# Vorlage für einen neuen Codex-Chat

Arbeite ausschließlich im HealthAtlas-Projekt.

1. Lies zuerst vollständig `PROJECT_CONTEXT.md` und `NEXT_STEPS.md`.
2. Lies vor App-Arbeit die vorhandenen READMEs, Manifeste, Build-Skripte und
   betroffene Tests. Verwende bei Bash-Aufgaben `/opt/homebrew/bin/bash`.
3. HealthAtlas verarbeitet Apple-Health-Exporte nur lokal. Keine Gesundheits-,
   Nutzungs- oder lokalen Dateidaten an externe Dienste senden.
4. Keine Commits, Pushes, Tags, Releases oder Builds für Beta/Final ohne
   ausdrücklichen Auftrag. Dev bleibt lokal, sofern nicht ausdrücklich anders
   gewünscht.
5. Bei UI- oder Funktionsänderungen deutsche und englische Texte, READMEs und
   beide PDF-Handbücher aktualisieren. Verwende nur synthetische Demodaten für
   öffentliche Dateien.
6. Vor Release-Arbeit `swift test` und `Scripts/privacy-check.sh` ausführen;
   Beta und Final müssen ZIP, DMG und SHA-256-Dateien enthalten.
7. Nach größeren Änderungen `PROJECT_CONTEXT.md` und `NEXT_STEPS.md` mit
   bestätigten Fakten aktualisieren. Keine persönlichen Daten oder lokalen Pfade
   dokumentieren.
