# HealthAtlas

HealthAtlas ist eine datenschutzorientierte macOS-App, die persönliche Gesundheitsdaten verständlich und grafisch aufbereitet.

Die App soll Daten aus Apple Health und Google Health/Google Fit in einem ruhigen, modernen Dashboard zusammenführen. HealthAtlas konzentriert sich auf Verläufe und persönliche Muster, statt Nutzer mit reinen Rohdaten und Tabellen zu überladen.

## Was HealthAtlas bietet

- Native macOS-Erfahrung für macOS 26 oder neuer mit Swift und AppKit
- Grafische Übersichten für Aktivität, Schlaf, Herzfrequenz, Wohlbefinden und weitere Gesundheitswerte
- Interaktive Trends mit Zeiträumen, Vergleichen und animierten Diagrammen
- Lokal berechnete, beschreibende Einblicke ohne Diagnosen oder Behandlungsempfehlungen
- Deutsch und Englisch, direkt in der App umschaltbar
- Wählbare Liquid-Glass-Themes und verschiedene visuelle Stile
- Einstellbare Animationen einschließlich Unterstützung für „Bewegung reduzieren“
- Sichtbarer Status für lokale Verarbeitung, damit jederzeit klar ist, wo Berechnungen stattfinden
- Direkter Zugriff auf das öffentliche [HealthAtlas-GitHub-Repository](https://github.com/Schrotty74/HealthAtlas)

## Datenschutz an erster Stelle

HealthAtlas ist für lokale Verarbeitung ausgelegt. Persönliche Gesundheitsdaten sollen auf dem Mac des Nutzers bleiben. Das Projekt verwendet keine Analyse, Werbung, Nachverfolgung oder versteckten Cloud-Upload.

Dev-Builds bleiben lokal. Nur geprüfte Beta- und Final-Artefakte dürfen veröffentlicht werden. Vor jeder Veröffentlichung muss die Datenschutzprüfung erfolgreich durchlaufen werden.

## Datenquellen

Die erste Entwicklungsrichtung verwendet vom Nutzer ausgewählte lokale Importdateien. Eine direkte Synchronisierung mit Apple Health oder Google-Diensten wird erst ergänzt, wenn die erforderlichen Plattform-APIs, Berechtigungen und Datenschutzanforderungen geprüft wurden.

## Projektstatus

HealthAtlas befindet sich derzeit in einer frühen Entwicklungsphase. Dieses Repository enthält das native macOS-Projekt, das erste AppKit-Dashboard, das Liquid-Glass-Designsystem, die Grundlage für die zweisprachige Oberfläche, den Datenschutz-Workflow und das HealthAtlas-Herz-Icon.

Die Oberfläche wird auf Grundlage des enthaltenen visuellen Konzepts entwickelt. Animationen und Interaktionen sind zentrale Bestandteile des Produkts und keine optionale Dekoration.

## Lizenz

Die Lizenz wird vor der ersten öffentlichen Veröffentlichung ergänzt.

Technische Projektinformationen befinden sich in der Dokumentation unter [`Docs/`](Docs/).
