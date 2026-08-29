# AGENTS.md

Vor jeder Projektarbeit zuerst `PROJECT_CONTEXT.md` und `NEXT_STEPS.md` lesen.

## Verbindliche Arbeitsregeln

- `PROJECT_CONTEXT.md` ist die dauerhafte Quelle für den aktuellen Projektkontext.
- `NEXT_STEPS.md` enthält nur tatsächlich offene Aufgaben, bestätigte Bugs und konkrete nächste Schritte.
- Bei relevanten Änderungen an Funktionen, Architektur, Datenformaten, Datenschutz, Build/Release oder offenen Aufgaben die betroffenen Kontextdateien im selben Auftrag aktualisieren.
- Erledigte Punkte aus `NEXT_STEPS.md` entfernen oder nach vorhandenen Projektregeln archivieren.
- Weitere projektspezifische Regeln und Dokumente beachten.
- Bestehende Architektur, Datenformate, Einstellungen und Benutzerabläufe erhalten, sofern eine Änderung nicht ausdrücklich verlangt oder technisch notwendig ist.
- Keine unnötigen Refactorings, neuen Abhängigkeiten oder Funktionsentfernungen ohne klaren Auftrag.
- Keine Projektzustände, Testergebnisse, Builds, Scans, Prüfungen oder offenen Punkte erfinden. Einen Erfolg nur behaupten, wenn die betreffende Prüfung tatsächlich ausgeführt wurde.
- Fragen nicht automatisch als Änderungsauftrag behandeln. Dateien, Builds, Tests oder Veröffentlichungsaktionen nur ausführen, wenn der Auftrag dies verlangt oder sie für die ausdrücklich beauftragte Änderung notwendig sind.
- Erklärungen verständlich formulieren und keine besonderen technischen Vorkenntnisse voraussetzen. Keine persönlichen Aussagen über Fähigkeiten, Kenntnisse, Gewohnheiten oder Arbeitsweise des Entwicklers dokumentieren.
- Bei Git-Projekten dokumentierte Branch-Grenzen beachten. Branches nicht ohne ausdrücklichen Auftrag wechseln oder zusammenführen.
- Keine Versionen, Buildnummern, Commits, Pushes, Tags, Releases oder Veröffentlichungen ohne ausdrücklichen Auftrag erstellen oder ändern.
- Keine Regeln zur Vorbereitung oder Fortsetzung eines neuen Chats aufnehmen. Solche Anweisungen gehören ausschließlich in `CHAT_TEMPLATE.md` beziehungsweise in einen separaten Start-Prompt.

## Datenschutzregel für das öffentliche Repository

Dieses Repository und seine Git-Historie sind öffentlich. Jeder eingecheckte Inhalt muss deshalb ohne weitere Bereinigung öffentlich vertretbar sein.

Nicht veröffentlicht oder dokumentiert werden dürfen insbesondere:

- private, personenbezogene oder vertrauliche Daten
- reale Namen oder private Kontaktdaten; für öffentliche Entwicklerangaben ausschließlich `Schrotty74`
- Informationen über persönliche Fähigkeiten, Kenntnisse, Gewohnheiten oder Arbeitsweise des Entwicklers
- lokale Benutzernamen, Home-Verzeichnisse sowie konkrete lokale Benutzer-, Volume- oder Backup-Pfade
- private Hostnamen, interne Netzwerkadressen oder interne URLs
- Gerätekennungen, Seriennummern, Hardware-IDs oder vergleichbare Identifikatoren
- Passwörter, API-Keys, Tokens, Secrets, Zugangsdaten oder private Accountdaten
- private Signing-Informationen, Zertifikatsgeheimnisse oder andere vertrauliche Release-Zugangsdaten
- Lizenzschlüssel oder private Lizenzdaten
- echte Benutzer-, Gesundheits-, Finanz-, Katalog-, Scan-, Mess-, Export- oder sonstige Nutzerdaten
- echte Backups, Datenbanken oder private Arbeitsdateien
- Logs, Crashreports oder Diagnoseausgaben mit privaten oder identifizierenden Informationen
- Screenshots oder Medien mit realen Nutzerdaten oder identifizierenden Informationen
- Metadaten, aus denen private Informationen rekonstruiert werden können
- Inhalte aus privaten Chats, E-Mails oder anderen nicht öffentlichen Quellen

Beispiele, Testdaten, Demo-Dateien, Screenshots und Dokumentation müssen ausschließlich synthetische, anonymisierte oder eindeutig fiktive Daten verwenden.

Pfade in öffentlicher Dokumentation müssen neutral sein, zum Beispiel `~/Library/Application Support/AppName/`. Echte lokale Benutzernamen oder persönliche Volume-Namen dürfen nicht verwendet werden.

Informationen über die lokale Entwicklungsumgebung werden nur dokumentiert, wenn sie technisch für das Projekt erforderlich sind. Persönliche oder gerätespezifische Details werden nach Möglichkeit durch allgemeine technische Anforderungen ersetzt.

Vor Commit, Push oder Veröffentlichung ist zu prüfen, dass keine privaten oder sensiblen Daten enthalten sind. Vor finalen Veröffentlichungen gelten zusätzlich die im Projekt dokumentierten erweiterten Datenschutz- und Release-Prüfungen.

Wenn unklar ist, ob eine Information öffentlich sein darf, wird sie nicht veröffentlicht, bis dies eindeutig geklärt ist.
