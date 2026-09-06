# Sicherheitsrichtlinie

[English](SECURITY.md)

## Unterstützte Versionen

Sicherheitskorrekturen werden für die aktuelle stabile Version von HealthAtlas bereitgestellt.

| Version | Unterstützt |
| --- | --- |
| 1.0.x | Ja |
| Frühere Versionen | Nein |

Bitte aktualisiere HealthAtlas auf die neueste verfügbare Version, bevor du ein Sicherheitsproblem meldest, das möglicherweise bereits behoben wurde.

## Sicherheitslücke melden

Bitte melde Sicherheitslücken nicht in einem öffentlichen GitHub-Issue.

Wenn du glaubst, eine Sicherheitslücke in HealthAtlas gefunden zu haben, kontaktiere den Maintainer bitte privat über die im Entwicklerprofil oder Portfolio verlinkten Kontaktinformationen. Gib nach Möglichkeit genügend Informationen an, um das Problem nachvollziehen und reproduzieren zu können, zum Beispiel:

- die getestete HealthAtlas-Version
- deine macOS-Version
- eine klare Beschreibung der Sicherheitslücke und ihrer möglichen Auswirkungen
- Schritte zum Reproduzieren
- relevante Logs oder Screenshots, aus denen persönliche Gesundheitsdaten entfernt wurden

Bitte füge einer Sicherheitsmeldung keine echten Apple-Health-Exporte oder andere sensible persönliche Gesundheitsinformationen bei.

Meldungen werden so bald wie vernünftigerweise möglich geprüft. Wenn das Problem bestätigt wird, wird nach Möglichkeit eine Korrektur vorbereitet und veröffentlicht, bevor detaillierte Informationen zur Sicherheitslücke öffentlich gemacht werden.

## Geltungsbereich

Sicherheitsmeldungen können unter anderem Probleme bei der lokalen Dateiverarbeitung, beim Parsen von Apple-Health-Exporten, bei erzeugten Berichten, bei der Update-Prüfung oder bei anderem Verhalten betreffen, das die Vertraulichkeit, Integrität oder den sicheren Betrieb von HealthAtlas beeinträchtigen könnte.

HealthAtlas verarbeitet ausgewählte Apple-Health-Exporte lokal, benötigt kein Benutzerkonto und lädt importierte Gesundheitsdaten nicht zu einem HealthAtlas-Dienst hoch. Die optionale Update-Prüfung greift ausschließlich auf die öffentliche GitHub-Release-Liste zu.

Vielen Dank, dass du dabei hilfst, HealthAtlas und seine Nutzer sicher zu halten.
