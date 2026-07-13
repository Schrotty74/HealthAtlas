# HealthAtlas

Datenschutzorientierte macOS-App zur grafischen Aufbereitung persönlicher Gesundheitsdaten aus lokalen Importdateien.

## Aktueller Stand

Dieses Repository ist ein sauberer Ausgangspunkt für Xcode und Codex. Es enthält ein natives AppKit-Grundgerüst, ausschließlich künstliche Testdaten, das ausgewählte HealthAtlas-Herz-Icon, die verbindliche Liquid-Glass-Designgrundlage, Animationsvorgaben, Datenschutzregeln und eine Datenschutzprüfung vor Veröffentlichungen.

Die erste Implementierung arbeitet mit lokalen Importdateien. Ein direkter Zugriff auf Apple-Health-Daten unter macOS darf nicht vorausgesetzt werden. Eine direkte Synchronisierung mit Apple Health oder Google Health/Google Fit wird erst umgesetzt, wenn die aktuelle technische API-Verfügbarkeit, Berechtigungen und Datenschutzanforderungen nachweislich geprüft wurden.

## Grundsätze

- macOS 26 oder neuer.
- Native Entwicklung mit Swift und AppKit.
- Liquid-Glass-Design auf Grundlage des HealthAtlas-Mockups.
- Umfangreiche, aber ruhige Animationen: Karten, Diagramme, Ringe, Übergänge und Sidebar-Auswahl.
- Unterstützung für Reduced Motion und hohen Kontrast.
- Lokale Verarbeitung ohne Tracking, Werbung, Analyse-SDKs oder Cloud-Upload.
- Keine privaten Daten, Benutzernamen, Gerätenamen, absoluten Pfade, Zugangsdaten oder Gesundheitsdateien in GitHub.
- Dev-Builds bleiben ausschließlich lokal.
- Beta- und Final-Artefakte dürfen nur nach Datenschutzprüfung veröffentlicht werden.
- Dev, Beta und Final werden immer getrennt und aus einem sauberen Zustand gebaut.

## Xcode

Öffne `HealthAtlas.xcodeproj` in Xcode und wähle das gemeinsame Scheme `HealthAtlas`. Das Projekt enthält bereits ein macOS-App-Target, das Ziel macOS 26, den Bundle-Identifier, das Asset-Katalog-Grundgerüst und ein AppIcon-Set.

## Codex

Verwende `Docs/CODEX_HANDOFF.md` als zentrale Arbeitsanweisung. Die verbindliche Design- und Animationsspezifikation befindet sich in `Docs/DESIGN_SYSTEM.md`.

## Datenschutzprüfung

Vor jedem Beta- oder Final-Upload aus dem Projektordner ausführen:

```bash
./Scripts/privacy-check.sh
```

Ein Fehlschlag blockiert die Veröffentlichung.

## Wichtiger Hinweis

Die enthaltenen Gesundheitswerte sind ausschließlich künstliche Demo-Werte. Das Icon ist ein vorbereiteter Liquid-Glass-Entwurf und muss vor einer Veröffentlichung in Xcode bei allen Größen visuell geprüft werden.

Weitere Informationen:

- [English README](README.md)
- [Codex-Übergabe](Docs/CODEX_HANDOFF.md)
- [Design- und Animationssystem](Docs/DESIGN_SYSTEM.md)
- [Datenschutzvertrag](Docs/PRIVACY.md)
- [Release-Workflow](Docs/RELEASE_WORKFLOW.md)
