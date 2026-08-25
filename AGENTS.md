# AGENTS.md

Dieser Branch ist der veröffentlichte **Beta-Quellstand** von HealthAtlas. `PROJECT_CONTEXT.md` und `NEXT_STEPS.md` sind auf diesem Branch nicht vorhanden; sie dürfen deshalb hier nicht als Pflichtdateien vorausgesetzt werden.

Vor Projektarbeit zuerst diese Datei, `README.md`, bei Bedarf `README.de.md`, anschließend die für den Auftrag relevanten Quellen, Skripte und Konfigurationen lesen.

## Verbindliche Arbeitsregeln

- Den tatsächlichen Stand dieses Beta-Branches als Quelle für Aussagen über die Beta verwenden. Keine Funktionen, Tests, Builds oder Release-Zustände aus anderen Branches ungeprüft übernehmen.
- `beta` bleibt ein Release-Branch. Neue Entwicklungsarbeit gehört nicht beiläufig auf diesen Branch.
- Bestehende Architektur, Datenformate, Einstellungen und Benutzerabläufe erhalten, sofern eine Änderung nicht ausdrücklich verlangt oder technisch notwendig ist.
- Keine unnötigen Refactorings, neuen Abhängigkeiten oder Funktionsentfernungen ohne klaren Auftrag.
- Keine Projektzustände, Testergebnisse, Builds, Prüfungen oder offenen Punkte erfinden. Einen Erfolg nur behaupten, wenn die betreffende Prüfung tatsächlich ausgeführt wurde.
- Fragen nicht automatisch als Änderungsauftrag behandeln. Dateien, Builds, Tests oder Veröffentlichungsaktionen nur ausführen, wenn der Auftrag dies verlangt oder sie für die ausdrücklich beauftragte Änderung notwendig sind.
- Erklärungen verständlich formulieren und keine besonderen technischen Vorkenntnisse voraussetzen. Keine persönlichen Aussagen über Fähigkeiten, Kenntnisse, Gewohnheiten oder Arbeitsweise des Entwicklers dokumentieren.
- Branch-Grenzen beachten. `beta`, `dev` und `main` nicht ohne ausdrücklichen Auftrag wechseln, zusammenführen oder fortschreiben.
- Keine Versionen, Buildnummern, Commits, Pushes, Tags, Releases oder Veröffentlichungen ohne ausdrücklichen Auftrag erstellen oder ändern.
- Keine Regeln zur Vorbereitung oder Fortsetzung eines neuen Chats aufnehmen. Solche Anweisungen gehören ausschließlich in `CHAT_TEMPLATE.md` beziehungsweise in einen separaten Start-Prompt.

## HealthAtlas-spezifische Grenzen

- Ausschließlich synthetische Apple-Health-Daten für Tests, Screenshots und öffentliche Dokumentation verwenden.
- Keine HealthKit-Integration, Cloud-Synchronisierung, Diagnose- oder Behandlungsaussagen als bestehende Funktion darstellen oder ohne ausdrücklichen Produktauftrag beginnen.
- Die datensparsame KI-Ersthilfe darf keine Gesundheitsdaten oder lokalen Exportinhalte automatisch an externe Dienste übertragen.
- Öffentliche Beta-Artefakte und Dokumentation müssen vor Veröffentlichung nach dem vorhandenen Datenschutz-/Release-Workflow geprüft werden.

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

Pfade in öffentlicher Dokumentation müssen neutral sein, zum Beispiel `/Users/example/...` oder `~/Library/Application Support/AppName/`. Echte lokale Benutzernamen oder persönliche Volume-Namen dürfen nicht verwendet werden.

Informationen über die lokale Entwicklungsumgebung werden nur dokumentiert, wenn sie technisch für das Projekt erforderlich sind. Persönliche oder gerätespezifische Details werden nach Möglichkeit durch allgemeine technische Anforderungen ersetzt.

Vor Commit, Push oder Veröffentlichung ist zu prüfen, dass keine privaten oder sensiblen Daten enthalten sind. Wenn unklar ist, ob eine Information öffentlich sein darf, wird sie nicht veröffentlicht, bis dies eindeutig geklärt ist.
