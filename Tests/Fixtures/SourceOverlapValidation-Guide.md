# Quellen-, Dubletten- und Überlappungstest

`SourceOverlapValidation.xml` enthält ausschließlich erfundene Werte vom 15. und 16. Juli 2026. Die Datei ist eine Test-Fixture: Sie liegt nur unter `Tests/` und wird nicht in HealthAtlas gebündelt.

## Automatisch geprüfte Sollwerte

| Testfall | Eingabedaten | Erwartetes Verhalten | Erwarteter Wert |
| --- | --- | --- | --- |
| Schritte: nur iPhone | 08:00–08:15, iPhone | Ein einzelner 15-Minuten-Abschnitt bleibt erhalten. | 10 Schritte |
| Schritte: nur Apple Watch, exakt an Grenze | 08:15–08:30, Apple Watch | Der Abschnitt beginnt exakt an der nächsten 15-Minuten-Grenze und zählt vollständig dort. | 20 Schritte |
| Schritte: vollständige Überlappung | 08:30–08:45, iPhone 30 und Apple Watch 40 | Gleiche Abdeckung: alphabetisch stabile Quellenwahl. Apple Watch gewinnt vor iPhone. | 40 statt 30 |
| Schritte: nicht überlappend | 08:45–09:00 iPhone 50, 09:00–09:15 Apple Watch 60 | Beide getrennten Abschnitte bleiben erhalten. | 110 Schritte |
| Schritte: teilweise Überlappung | iPhone 80 von 09:15–09:45, Apple Watch 100 von 09:30–10:00 | 09:15–09:30 behält die anteiligen iPhone-Werte; die zwei folgenden Abschnitte verwenden Apple Watch. | 140 Schritte |
| Schritte: Drittanbieter und Apple Watch | 10:00–10:15, ThirdParty Fitness 70 und Apple Watch 90 | Bei gleicher Abdeckung gewinnt Apple Watch alphabetisch. | 90 statt 70 |
| Schritte: exaktes Duplikat | Zwei identische iPhone-Records mit 25 von 10:15–10:30 | Der identische zweite Record wird entfernt. | 25 einmal |
| Schritte: gleicher Wert, andere Quelle | iPhone und Apple Watch je 35 von 10:30–10:45 | Kein exaktes Duplikat; Quellenwahl gilt. | 35 einmal, Apple Watch |
| Schritte: gleicher Abdeckungsgrad | iPhone 45, ThirdParty Fitness 55 von 10:45–11:00 | Gleichstand wird alphabetisch und damit stabil aufgelöst. | 45, iPhone |
| Schritte: Gesamtergebnis | Alle Schritt-Records | Alle oben genannten Abschnitte ergeben den Tageswert. | **515 Schritte**, 11 akzeptierte Records |
| Distanz | iPhone 1 km und Apple Watch 2 km gleichzeitig, danach ThirdParty Fitness 0,5 km | Apple Watch gewinnt die Überlappung; der nicht überlappende Drittanbieterwert bleibt. | **2,5 km**, 2 Records |
| Aktive Energie | iPhone 100 kcal von 12:00–12:30, ThirdParty Fitness 120 kcal von 12:15–12:45 | 12:00–12:15 iPhone 50; beim Gleichstand 12:15–12:30 iPhone 50; danach Drittanbieter 60. | **160 kcal**, 2 Records |
| Herzfrequenz | Apple Watch 70, iPhone 80 zur selben Zeit sowie ein exaktes Watch-Duplikat | Messproben verschiedener Quellen bleiben; nur das exakte Duplikat entfällt. | **75 count/min** Durchschnitt, 2 Records |
| Körpergewicht | iPhone 70 kg, ThirdParty Fitness 72 kg, exaktes iPhone-Duplikat | Beide verschiedenen Messungen bleiben; das Duplikat entfällt. | **71 kg** Durchschnitt, 2 Records |
| Schlaf | Apple Watch und iPhone: 23:00–01:00; ThirdParty Fitness: 01:00–02:00 | Watch gewinnt den vollständigen Gleichstand; der anschließende Drittanbieterabschnitt bleibt. | **3 h** gesamt: 1 h am 15. Juli, 2 h am 16. Juli |
| Workouts | Zwei völlig identische 30-Minuten-Läufe und ein ähnlicher 31-Minuten-Lauf | Nur der vollständige Zwilling entfällt. | **2 Workout-Records** |

## Manueller Test in HealthAtlas

Importiere diese Datei über den normalen Importdialog: `Tests/Fixtures/SourceOverlapValidation.xml`. Die folgenden Werte müssen ohne eigene Berechnung sichtbar sein.

| Was in HealthAtlas öffnen | Was dort stehen muss |
| --- | --- |
| Overview → Karte **Steps** | **515 count** am 15. Jul 2026 |
| Overview → Karte **Distance Walking + Running** | **2,5 km** am 15. Jul 2026 |
| Overview → Karte **Active Energy** | **160 kcal** am 15. Jul 2026 |
| Overview → Karte **Heart Rate** | **75 count/min** am 15. Jul 2026 |
| Overview → Karte **Body Mass** | **71 kg** am 15. Jul 2026 |
| Overview → Karte **Sleep Analysis** | **3 h** (verteilt auf 15. und 16. Jul 2026) |
| Trends → **Steps** | Der einzige lokale Tag zeigt **515 count**. |
| Trends → **Active Energy** | Der einzige lokale Tag zeigt **160 kcal**. |
| Sources → **Steps** | 11 Werte, lokaler Wert **515 count**. |
| Sources → **Heart Rate** | 2 Werte, lokaler Wert **75 count/min**. |
| Sources → **Workout** | 2 Werte. |

Die Sources-Ansicht zeigt die zusammengeführten Datentypen, nicht den gewinnenden Produzenten pro 15-Minuten-Abschnitt. Die automatisch geprüften Zahlen oberhalb machen diese Quellenentscheidung dennoch sichtbar und reproduzierbar.
