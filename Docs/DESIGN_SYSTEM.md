# HealthAtlas — verbindliche Designgrundlage

Das ausgewählte HealthAtlas-Mockup ist die visuelle Referenz für die gesamte App. Es definiert nicht nur Farben, sondern auch Hierarchie, räumliche Tiefe, Transparenz, Kartenstruktur, Diagramme und Bewegungsverhalten.

## Visuelle Sprache

- macOS-native Fensterstruktur mit Sidebar, Toolbar und klarer Inhaltsfläche.
- Liquid-Glass-Oberflächen mit mehreren transparenten Ebenen, feinen Konturen, weichen Schatten und dezenter Lichtbrechung.
- Dunkle Grundstimmung mit Midnight Navy, Violett, Blau und Cyan; Coral/Rosa nur als gezielter Gesundheits- und Herz-Akzent.
- Karten sind ruhig, großzügig und klar lesbar. Keine überfüllten Dashboards.
- Jede Information erhält eine visuelle Priorität: Hauptwert, Veränderung, Zeitraum, Quelle.
- Apple Health und Google Health/Google Fit werden als getrennte Datenquellen sichtbar gekennzeichnet.
- Der Status „Local only“ bleibt dauerhaft leicht auffindbar.
- Keine medizinische Alarmästhetik, keine aggressiven roten Warnfarben und keine Diagnoseformulierung.

## Verbindliche Ansichten

1. Overview: animierte Kennzahlenkarten, Ringdiagramme und ein Verlauf.
2. Trends: großer interaktiver Zeitverlauf mit Auswahl und Vergleichszeitraum.
3. Sources: lokale Importquellen, Berechtigungen, letzter Import und Datenumfang.
4. Insights: lokal berechnete, beschreibende Zusammenhänge ohne medizinische Diagnose.
5. Settings/Design Studio: wählbare Themes, Diagrammstile, Animationen, Kontrast und Reduced Motion.

## Animationsprinzipien

Animationen sind ein zentraler Bestandteil des Designs, dürfen aber niemals Daten verfälschen oder die Bedienung verlangsamen.

- Beim Öffnen einer Ansicht erscheinen Karten mit kurzer, weicher Opacity-/Blur-/Scale-Animation.
- Diagrammlinien werden beim ersten Anzeigen kontrolliert aufgebaut; Werte dürfen nicht „springen“.
- Ringdiagramme animieren ihren Fortschritt einmalig und zeigen danach einen stabilen Zustand.
- Hover und Auswahl erzeugen Lichtreflexion, leichte Tiefenänderung und eine klare Markierung.
- Beim Wechsel des Zeitraums gleiten Daten kontrolliert über, statt hart zu wechseln.
- Die Sidebar markiert die aktuelle Ansicht mit einer fließenden Liquid-Glass-Auswahlfläche.
- Hintergrund-Partikel oder Lichtverläufe dürfen nur dekorativ sein und müssen bei Reduced Motion deaktiviert werden.
- Keine dauerhaften, unruhigen Endlosschleifen in Diagrammen oder Zahlen.
- Animationen müssen mit macOS Reduced Motion und High Contrast funktionieren.
- Zielwerte: kurze UI-Reaktionen, keine Animation länger als nötig; Bewegungen sollen informativ und nicht dekorativ um ihrer selbst willen sein.

## Theme-System

- Clear Glass: helle, transparente Oberfläche mit blauem und cyanfarbenem Licht.
- Midnight Glass: dunkle Navy-/Violett-Oberfläche wie im Mockup.
- Aurora: Cyan, Türkis, Blau und Violett mit sanften Lichtverläufen.
- Warm Paper: helle, warme Oberfläche mit dezenter Coral- und Goldakzentfarbe.

Themes dürfen keine Datenschutz- oder Informationszustände verändern. Sie ändern ausschließlich Darstellung, Kontrastregeln und Animationseinstellungen.

## Icon

Das Herzsymbol mit integrierter Pulslinie ist das verbindliche HealthAtlas-Markenzeichen. Es wird als App-Icon, leerer-Daten-Zustand, Quellenvisualisierung und dezentes App-Branding verwendet. Die Icon-Datei im Projekt ist zunächst ein Master-Konzept; vor einer Veröffentlichung muss daraus ein vollständiges macOS-AppIcon-Set erzeugt werden.
