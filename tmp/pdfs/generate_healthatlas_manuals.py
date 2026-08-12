from pathlib import Path

from reportlab.lib import colors
from reportlab.lib.enums import TA_CENTER, TA_LEFT
from reportlab.lib.pagesizes import A4
from reportlab.lib.styles import ParagraphStyle, getSampleStyleSheet
from reportlab.lib.units import mm
from reportlab.pdfbase import pdfmetrics
from reportlab.pdfbase.ttfonts import TTFont
from reportlab.platypus import (
    BaseDocTemplate,
    Frame,
    Image,
    KeepTogether,
    PageBreak,
    Paragraph,
    Spacer,
    Table,
    TableStyle,
)


ROOT = Path(__file__).resolve().parents[2]
OUTPUT = ROOT / "output" / "pdf"
SHOTS = ROOT / "Screenshots"
ICON = ROOT / "HealthAtlas" / "Assets.xcassets" / "AppIcon.appiconset" / "icon-512x512.png"
FONT = "/System/Library/Fonts/Supplemental/Verdana.ttf"
FONT_BOLD = "/System/Library/Fonts/Supplemental/Verdana Bold.ttf"

PAGE_W, PAGE_H = A4
LEFT = RIGHT = 18 * mm
TOP = 20 * mm
BOTTOM = 17 * mm

NAVY = colors.HexColor("#081433")
BLUE = colors.HexColor("#10469B")
VIOLET = colors.HexColor("#3D207D")
CYAN = colors.HexColor("#42C5EE")
TEAL = colors.HexColor("#20B7B1")
PINK = colors.HexColor("#FF5B8A")
GOLD = colors.HexColor("#FFD924")
WHITE = colors.HexColor("#F7FAFF")
MIST = colors.HexColor("#C8D4EC")
MUTED = colors.HexColor("#89A1C8")
PANEL = colors.HexColor("#142857")
PANEL_LIGHT = colors.HexColor("#1B3470")
GREEN = colors.HexColor("#46DE79")


def register_fonts():
    pdfmetrics.registerFont(TTFont("HealthAtlas", FONT))
    pdfmetrics.registerFont(TTFont("HealthAtlasBold", FONT_BOLD))


def make_styles():
    styles = getSampleStyleSheet()
    styles.add(ParagraphStyle(
        name="BodyHA", parent=styles["BodyText"], fontName="HealthAtlas", fontSize=8.9,
        leading=13.3, textColor=MIST, spaceAfter=7,
    ))
    styles.add(ParagraphStyle(
        name="SmallHA", parent=styles["BodyText"], fontName="HealthAtlas", fontSize=7.2,
        leading=10.2, textColor=MUTED,
    ))
    styles.add(ParagraphStyle(
        name="H1HA", parent=styles["Heading1"], fontName="HealthAtlasBold", fontSize=24,
        leading=28, textColor=WHITE, spaceBefore=0, spaceAfter=10,
    ))
    styles.add(ParagraphStyle(
        name="H2HA", parent=styles["Heading2"], fontName="HealthAtlasBold", fontSize=15,
        leading=19, textColor=WHITE, spaceBefore=11, spaceAfter=6,
    ))
    styles.add(ParagraphStyle(
        name="H3HA", parent=styles["Heading3"], fontName="HealthAtlasBold", fontSize=10.5,
        leading=14, textColor=CYAN, spaceBefore=7, spaceAfter=3,
    ))
    styles.add(ParagraphStyle(
        name="CoverTitle", parent=styles["Title"], fontName="HealthAtlasBold", fontSize=34,
        leading=38, textColor=WHITE, alignment=TA_CENTER,
    ))
    styles.add(ParagraphStyle(
        name="CoverSub", parent=styles["BodyText"], fontName="HealthAtlas", fontSize=12,
        leading=18, textColor=MIST, alignment=TA_CENTER,
    ))
    styles.add(ParagraphStyle(
        name="Callout", parent=styles["BodyText"], fontName="HealthAtlas", fontSize=8.5,
        leading=12.4, textColor=WHITE,
    ))
    styles.add(ParagraphStyle(
        name="Caption", parent=styles["BodyText"], fontName="HealthAtlas", fontSize=7.2,
        leading=9.5, textColor=MUTED, alignment=TA_CENTER,
    ))
    return styles


def draw_background(canvas, doc):
    canvas.saveState()
    canvas.setFillColor(NAVY)
    canvas.rect(0, 0, PAGE_W, PAGE_H, fill=1, stroke=0)
    # Soft, static manual backdrop inspired by the Clear Glass palette.
    canvas.setFillColor(colors.Color(0.08, 0.27, 0.65, alpha=0.34))
    canvas.circle(PAGE_W * 0.87, PAGE_H * 0.82, PAGE_W * 0.31, fill=1, stroke=0)
    canvas.setFillColor(colors.Color(0.32, 0.13, 0.65, alpha=0.20))
    canvas.circle(PAGE_W * 0.12, PAGE_H * 0.10, PAGE_W * 0.26, fill=1, stroke=0)
    canvas.setStrokeColor(colors.Color(0.26, 0.77, 0.93, alpha=0.32))
    canvas.setLineWidth(0.7)
    canvas.line(LEFT, PAGE_H - 12 * mm, PAGE_W - RIGHT, PAGE_H - 12 * mm)
    canvas.setFont("HealthAtlasBold", 7.5)
    canvas.setFillColor(MIST)
    canvas.drawString(LEFT, PAGE_H - 9 * mm, "HealthAtlas")
    canvas.setFont("HealthAtlas", 6.7)
    canvas.setFillColor(MUTED)
    canvas.drawRightString(PAGE_W - RIGHT, PAGE_H - 9 * mm, doc.title_short)
    canvas.setStrokeColor(colors.Color(0.26, 0.77, 0.93, alpha=0.26))
    canvas.line(LEFT, 11 * mm, PAGE_W - RIGHT, 11 * mm)
    canvas.setFont("HealthAtlas", 6.5)
    canvas.setFillColor(MUTED)
    canvas.drawString(LEFT, 7.5 * mm, doc.footer_text)
    canvas.drawRightString(PAGE_W - RIGHT, 7.5 * mm, str(doc.page))
    canvas.restoreState()


def draw_cover(canvas, doc):
    canvas.saveState()
    canvas.setFillColor(NAVY)
    canvas.rect(0, 0, PAGE_W, PAGE_H, fill=1, stroke=0)
    canvas.setFillColor(colors.Color(0.08, 0.30, 0.78, alpha=0.72))
    canvas.circle(PAGE_W * 0.78, PAGE_H * 0.72, PAGE_W * 0.42, fill=1, stroke=0)
    canvas.setFillColor(colors.Color(0.33, 0.15, 0.78, alpha=0.55))
    canvas.circle(PAGE_W * 0.17, PAGE_H * 0.12, PAGE_W * 0.34, fill=1, stroke=0)
    canvas.setFillColor(colors.Color(0.25, 0.88, 0.94, alpha=0.70))
    canvas.circle(PAGE_W * 0.18, PAGE_H * 0.84, 7, fill=1, stroke=0)
    canvas.setFillColor(colors.Color(1.0, 0.35, 0.62, alpha=0.66))
    canvas.circle(PAGE_W * 0.83, PAGE_H * 0.20, 4, fill=1, stroke=0)
    canvas.restoreState()


class HealthAtlasDoc(BaseDocTemplate):
    def __init__(self, filename, title_short, footer_text):
        self.title_short = title_short
        self.footer_text = footer_text
        super().__init__(str(filename), pagesize=A4, leftMargin=LEFT, rightMargin=RIGHT, topMargin=TOP, bottomMargin=BOTTOM)
        cover = Frame(LEFT, BOTTOM, PAGE_W - LEFT - RIGHT, PAGE_H - TOP - BOTTOM, id="cover")
        content = Frame(LEFT, BOTTOM + 3 * mm, PAGE_W - LEFT - RIGHT, PAGE_H - TOP - BOTTOM - 4 * mm, id="content")
        self.addPageTemplates([
            __import__("reportlab.platypus", fromlist=["PageTemplate"]).PageTemplate(id="Cover", frames=[cover], onPage=draw_cover),
            __import__("reportlab.platypus", fromlist=["PageTemplate"]).PageTemplate(id="Content", frames=[content], onPage=draw_background),
        ])


def P(text, style):
    return Paragraph(text, style)


def bullets(items, styles):
    return [P(f'<font color="#42C5EE">&#8226;</font> {item}', styles["BodyHA"]) for item in items]


def callout(title, text, styles, color=CYAN):
    box = Table([[P(f'<font color="#{color.hexval()[2:]}"><b>{title}</b></font><br/>{text}', styles["Callout"])]], colWidths=[PAGE_W - LEFT - RIGHT])
    box.setStyle(TableStyle([
        ("BACKGROUND", (0, 0), (-1, -1), colors.Color(0.08, 0.16, 0.36, alpha=0.88)),
        ("BOX", (0, 0), (-1, -1), 0.6, color),
        ("LEFTPADDING", (0, 0), (-1, -1), 10), ("RIGHTPADDING", (0, 0), (-1, -1), 10),
        ("TOPPADDING", (0, 0), (-1, -1), 8), ("BOTTOMPADDING", (0, 0), (-1, -1), 8),
    ]))
    return box


def image_block(name, caption, styles):
    path = SHOTS / name
    image = Image(str(path))
    max_w = PAGE_W - LEFT - RIGHT
    max_h = 100 * mm
    scale = min(max_w / image.imageWidth, max_h / image.imageHeight)
    image.drawWidth = image.imageWidth * scale
    image.drawHeight = image.imageHeight * scale
    panel = Table([[image]], colWidths=[max_w])
    panel.setStyle(TableStyle([
        ("BACKGROUND", (0, 0), (-1, -1), PANEL),
        ("BOX", (0, 0), (-1, -1), 0.7, CYAN),
        ("LEFTPADDING", (0, 0), (-1, -1), 5), ("RIGHTPADDING", (0, 0), (-1, -1), 5),
        ("TOPPADDING", (0, 0), (-1, -1), 5), ("BOTTOMPADDING", (0, 0), (-1, -1), 5),
    ]))
    return [panel, Spacer(1, 3 * mm), P(caption, styles["Caption"])]


def section(title, text, styles, screenshot=None, caption=None, bullets_list=None, callout_data=None):
    flow = [P(title, styles["H1HA"]), P(text, styles["BodyHA"])]
    if bullets_list:
        flow += bullets(bullets_list, styles)
    if callout_data:
        title, callout_text, color = callout_data
        flow += [Spacer(1, 2 * mm), callout(title, callout_text, styles, color), Spacer(1, 3 * mm)]
    if screenshot:
        flow += [Spacer(1, 2 * mm)] + image_block(screenshot, caption, styles)
    return flow


def cover(title, subtitle, language, styles):
    icon = Image(str(ICON), width=38 * mm, height=38 * mm)
    icon.hAlign = "CENTER"
    return [
        Spacer(1, 43 * mm), icon, Spacer(1, 10 * mm),
        P(title, styles["CoverTitle"]), Spacer(1, 5 * mm),
        P(subtitle, styles["CoverSub"]), Spacer(1, 34 * mm),
        P(f'<font color="#46DE79"><b>{language}</b></font><br/>Privacy-first local Apple Health visualisation for macOS', styles["CoverSub"]),
        Spacer(1, 14 * mm), P("HealthAtlas - User Manual", styles["Caption"]),
        __import__("reportlab.platypus", fromlist=["NextPageTemplate"]).NextPageTemplate("Content"), PageBreak(),
    ]


def manual_de(styles):
    s = []
    s += cover("HealthAtlas", "Ausführliches Benutzerhandbuch\nLokale Apple-Health-Visualisierung für macOS", "Deutsch", styles)
    s += section("Willkommen", "HealthAtlas liest einen von dir ausgewählten Apple-Health-Export lokal auf deinem Mac. Anschließend entscheidest du selbst, welche erkannten Datentypen im Dashboard erscheinen. Die App erstellt keine Diagnose und gibt keine Behandlungsempfehlungen.", styles,
        bullets_list=[
            "Die App startet bei jedem normalen Start ohne importierte Gesundheitsdaten.",
            "Importierte Daten bleiben nur im Arbeitsspeicher der laufenden Sitzung. Sie werden weder hochgeladen noch in ein Konto übertragen.",
            "Einstellungen wie Sprache, Theme, Kartenzahl und deine Datentyp-Auswahl werden getrennt pro Dev-, Beta- oder Final-App gespeichert.",
            "Solange keine eigenen Daten geladen sind, bietet die Startansicht zusätzlich das passende GitHub-Handbuch und eine freiwillige KI-Hilfe. Sie kopiert nur eine allgemeine Frage mit dem öffentlichen Handbuch-Link in die Zwischenablage; Gesundheitswerte und lokale Daten bleiben in der App.",
            "Voraussetzung: macOS 26 oder neuer.",
        ], callout_data=("Wichtig", "HealthAtlas beschreibt Werte und Verläufe. Es ersetzt keine ärztliche Beratung, Untersuchung oder Diagnose.", PINK))
    s += [PageBreak()]
    s += section("Schnellstart in 5 Schritten", "Für einen sicheren ersten Test liegt im Repository eine vollständig synthetische Demo vor. Sie enthält keine persönlichen Gesundheitsdaten.", styles,
        bullets_list=[
            "HealthAtlas öffnen. In der Mitte der leeren Übersicht erscheint der Import-Button.",
            "Auf " + '"ZIP oder Export.xml importieren ..."' + " klicken.",
            "Die Demo-Datei <b>Demo/AppleHealthDemo/Export.xml</b> oder einen eigenen Apple-Health-Export auswählen.",
            "Nach dem Import zu <b>Quellen</b> wechseln und die gewünschten Datentypen ein- oder ausblenden.",
            "Unter <b>Übersicht</b>, <b>Verläufe</b> und <b>Einblicke</b> die Daten ansehen.",
        ], screenshot="import.png", caption="Leere Startansicht. Die abgebildete Oberfläche enthält keine Gesundheitsdaten.")
    s += [PageBreak()]
    s += section("Apple-Health-Export importieren", "HealthAtlas akzeptiert genau zwei lokale Dateiformate: eine direkte <b>Export.xml</b> oder ein Apple-Health-<b>ZIP</b>-Archiv, das darin eine Datei namens Export.xml enthält. Das ZIP muss vorher nicht entpackt werden; HealthAtlas liest die Export.xml direkt aus dem Archiv.", styles,
        bullets_list=[
            "Dateien dürfen zwischen 1 Byte und 100 MB groß sein.",
            "Es kann jeweils nur eine Datei gewählt werden.",
            "Die klinische Zusatzdatei eines Apple-Health-Exports wird bewusst nicht importiert.",
            "Es gibt keine direkte HealthKit-Verbindung und keinen Cloud-Import.",
            "Bei einem nicht passenden ZIP, einer nicht lesbaren XML oder einer zu großen Datei zeigt HealthAtlas eine Erklärung an und importiert nichts.",
        ], callout_data=("Export auf dem iPhone", "In Apple Health: Übersicht öffnen, oben rechts Bild oder Initialen wählen, dann " + '"Alle Gesundheitsdaten exportieren"' + ". Apple kann die Bezeichnung der Oberfläche ändern. Quelle: Apple Support, " + '<font color="#42C5EE">support.apple.com/de-de/guide/iphone/iph5ede58c3d/26/ios/26</font>', TEAL))
    s += section("Navigation und Status", "Die linke Milchglas-Sidebar bleibt in jedem Theme sichtbar. Vor dem ersten lokalen Import heißt ihr erster Eintrag " + '"Import"' + "; nach erfolgreichem Import wird daraus " + '"Übersicht"' + ". Am unteren Rand bleibt " + '"Privat - Nur lokal"' + " als ständige Datenschutzerinnerung sichtbar.", styles,
        bullets_list=[
            "<b>Übersicht:</b> Karten der ausgewählten Datentypen.",
            "<b>Verläufe:</b> Interaktive Zeitreihe eines ausgewählten Typs.",
            "<b>Quellen:</b> Auswahl aller im Import erkannten Datentypen.",
            "<b>Einblicke:</b> Beschreibende Zusammenfassung eines Datentyps.",
            "<b>Design-Studio:</b> Sprache und Erscheinungsbild.",
            "Die GitHub- und Discord-Icons über dem Datenschutz-Status öffnen die Projektseite bzw. die Community im Standardbrowser.",
        ])
    s += [PageBreak()]
    s += section("Übersicht", "Nach einem erfolgreichen Import zeigt die Übersicht nur die Datentypen, die unter Quellen aktiviert sind. Jede Karte hat eine zu ihrem Typ passende Akzentfarbe und grafische Behandlung. Die angezeigten Zahlen beziehen sich auf den jeweils letzten verfügbaren Tageswert.", styles,
        bullets_list=[
            "Oben kann eine <b>Fokus-Kennzahl</b> ausgewählt werden. Sie zeigt den letzten lokalen Wert, einen großen Kurzverlauf und einen sanft animierten Ring. <b>Dein Zeitraum in Kürze</b> beschreibt darunter nur, wie viele aktivierte Typen in den letzten sieben lokalen Erfassungstagen Werte enthalten — ohne Ziel, Bewertung oder Diagnose.",
            "Mit <b>4</b>, <b>8</b> oder <b>12</b> wird die Kartenzahl pro Seite festgelegt. <b>Kompakt</b>, <b>Standard</b> und <b>Fokus</b> ändern die Kartendichte lokal. Karten lassen sich per Drag &amp; Drop frei neu anordnen.",
            "Bei mehr ausgewählten Datentypen erscheinen Vor- und Zurück-Schalter zum Blättern.",
            "Ein Klick auf eine Karte öffnet eine echte Vollbild-Fokusansicht mit Verlauf, Zeitraumvergleich und Jahreskalender; dort führt <b>Verläufe öffnen</b> zur Detailansicht. Mit <b>Vollbild beenden</b> kehrst du zurück. Der PDF-Button schreibt ausschließlich an einen selbst gewählten Speicherort.",
            "Unter den Karten zeigen ein gemeinsamer Mehrfach-Verlauf und Tagesringe letzte lokale Werte mehrerer Typen. Die Ringe sind weder Ziele noch Bewertungen. Bei schmaleren Fenstern bleiben die Legenden innerhalb ihrer Karte.",
            "Schritte, Energie, Distanz und Stockwerke werden als Tages-Summe dargestellt. Andere numerische Typen werden als Tages-Durchschnitt dargestellt.",
            "Name, Wert, Einheit und Datum stammen aus dem importierten Export und werden gemäß der gewählten App-Sprache formatiert.",
        ], screenshot="overview.png", caption="Übersicht mit synthetischen Demodaten. Farben helfen beim Wiedererkennen, sie bewerten keine Gesundheit.")
    s += [PageBreak()]
    s += section("Quellen", "Quellen ist die zentrale Auswahl. Hier listet HealthAtlas jeden erkannten Datentyp auf: mit Ein-/Aus-Schalter, Anzahl der Messwerte und zusammengefasstem Wert. Die Tabelle kann vertikal scrollen, wenn der Export viele Typen enthält.", styles,
        bullets_list=[
            "<b>Alle anzeigen</b> aktiviert alle erkannten Datentypen.",
            "<b>Keine anzeigen</b> deaktiviert alle Datentypen.",
            "Der Schalter in jeder Zeile entscheidet sofort, ob ein Typ in Übersicht, Verläufen und Einblicken zur Verfügung steht.",
            "Suche und Kategorien helfen bei großen Exporten. Der Stern setzt einen Favoriten; Pfeile ordnen Datentypen. Favoriten erscheinen zuerst in der Übersicht.",
            "Beim ersten eigenen Import werden standardmäßig die ersten vier erkannten Typen gewählt. Eine passende frühere Auswahl wird wiederverwendet, soweit diese Typen im neuen Import vorkommen.",
            "<b>Lokale Datenqualität</b> zählt Auswahl, datierte Typen, lokale Tage und Messwerte. Sie bewertet keine Gesundheitsdaten.",
        ], screenshot="sources.png", caption="Quellen mit synthetischen Demodaten. Die Auswahl bestimmt die Inhalte aller anderen Bereiche.")
    s += [PageBreak()]
    s += section("Verläufe", "Dieser Bereich visualisiert einen aktiven Datentyp als Linie. Du wählst oben zunächst den Zeitraum; anschließend kannst du im Auswahlmenü innerhalb der aktivierten Datentypen wechseln.", styles,
        bullets_list=[
            "<b>7T</b>: letzte 7 Tage.", "<b>30T</b>: letzte 30 Tage.", "<b>3M</b>: letzte 90 Tage.", "<b>1J</b>: letzte 365 Tage.",
            "Fahre mit der Maus über einen Punkt, um eine schwebende Wertkarte mit Datum, formatiertem Wert und Mini-Trend zu sehen. Ein Klick markiert den Punkt zusätzlich sichtbar und sanft pulsierend.",
            "Ein lokaler Vergleich zeigt aktuellen und unmittelbar vorherigen Zeitraum nebeneinander. Er ist keine Bewertung oder Diagnose.",
            "Der lokale Datenkalender liegt als eigener Balken unter dem Diagramm, damit Tageskästchen und Linienanimation klar getrennt bleiben.",
            "Wenn im gewählten Zeitraum weniger als zwei Werte vorhanden sind, meldet die Anzeige, dass keine ausreichenden Werte vorliegen.",
        ], screenshot="trends.png", caption="Verlauf mit synthetischen Demodaten. Punkte sind interaktiv und zeigen ihren Wert nach einem Klick.")
    s += [PageBreak()]
    s += section("Einblicke", "Einblicke verdichtet einen aktivierten Datentyp zu einer lokalen, beschreibenden Karte. Du wählst den Typ im Auswahlmenü. Die Ansicht enthält den letzten Tageswert, dessen Datum, die Änderung gegenüber dem vorherigen Wert und eine kurze Linienvorschau der letzten 14 Tage.", styles,
        bullets_list=[
            "Eine positive oder negative Änderung beschreibt nur den Unterschied zum vorherigen vorhandenen Tageswert.",
            "Der Datenkalender liegt als eigener Balken unter der Zusammenfassung und zeigt lokale Tage als Heatmap. Mit <b>12 Wochen</b> oder <b>1 Jahr</b> änderst du den Zeitraum. Intensivere Farben bedeuten nur einen höheren Wert innerhalb dieses Zeitraums.",
            "<b>Lokales Muster</b> beschreibt nur, an welchem Wochentag die meisten lokalen Daten vorliegen — nicht Gesundheit oder Verhalten.",
            "Die Darstellung liefert keine Normalwerte, Warnung, Bewertung oder medizinische Schlussfolgerung.",
            "Ist nur ein datierter Wert vorhanden, weist die App darauf hin.",
        ], screenshot="insights.png", caption="Einblicke mit synthetischen Demodaten. Die Karte ist eine beschreibende Zusammenfassung, keine Diagnose.")
    s += [PageBreak()]
    s += section("Design-Studio", "Im Design-Studio passt du Sprache und Stil der Oberfläche an. Änderungen werden sofort übernommen und für die jeweilige App-Variante lokal gespeichert.", styles,
        bullets_list=[
            "<b>Sprache:</b> Deutsch oder English. Navigation, Beschriftungen und bekannte Datentypnamen wechseln mit der Auswahl.",
            "<b>Clear Glass:</b> Gemeinsame Milchglasfläche mit ruhigem Cyan-, Blau-, Violett- und Rosaglow sowie dezenten Lichtpunkten hinter Karten, Texten und Bedienelementen. Dadurch bleiben Werte in allen Bereichen gut lesbar.",
            "<b>Midnight Glass:</b> dunkle, blaue Glasoberfläche.",
            "<b>Aurora:</b> türkisfarbene Variante.",
            "<b>Warmpaper:</b> warme, rötlich-violette Variante.",
            "Karten erscheinen gestaffelt, reagieren dezent beim Darüberfahren und der Importabschluss zeigt kurz einen Erfolgsschimmer. Bei einem Wechsel von Zeitraum oder Datentyp zeichnet sich das Diagramm erneut weich ein. Seiten- und Sidebar-Wechsel erfolgen sanft.",
            "Clear Glass ergänzt Glow und Lichtpunkte um sehr dezente wandernde Konturen und transparente Gesundheits-Symbole. Bei 'Bewegung reduzieren' und während des Imports werden Animationen stark reduziert.",
            "Bei aktivierter macOS-Einstellung " + '"Bewegung reduzieren"' + " und während des Imports reduziert bzw. pausiert Clear Glass seine Bewegung.",
            "HealthAtlas öffnet neu im 16:9-Format und bleibt danach frei skalierbar. Die Darstellung passt sich der gewählten Fenstergröße an.",
        ], screenshot="design-studio.png", caption="Design-Studio. Die dargestellten Themes verändern nur die Anzeige, niemals die Gesundheitsdaten.")
    s += [PageBreak()]
    s += section("Datenschutz und Grenzen", "HealthAtlas ist als lokale Visualisierung konzipiert. Es gibt weder Konto, Analyse, Werbung, Tracking noch versteckten Upload. Die App sendet importierte Gesundheitswerte nicht an HealthAtlas, GitHub, Discord oder einen anderen Dienst.", styles,
        bullets_list=[
            "Daten bleiben während der offenen Sitzung im Arbeitsspeicher und werden beim nächsten normalen App-Start nicht erneut geladen.",
            "GitHub und Discord werden erst durch einen bewussten Klick auf die unteren Sidebar-Icons im Browser geöffnet. Sie erhalten dadurch keine importierten Werte.",
            "ChatGPT, Gemini oder Claude werden nur nach einem bewussten Klick in der leeren Startansicht geöffnet. Vorher kopiert HealthAtlas lediglich eine feste allgemeine Einführungsfrage mit dem öffentlichen, sprachabhängigen Handbuch-Link in die Zwischenablage. Erst mit Cmd+V entscheidet die Person selbst, ob sie diese Frage beim Dienst einfügt.",
            "Die mitgelieferte Demo ist synthetisch. Sie dient zum Testen der Funktionen ohne persönliche Daten.",
            "HealthAtlas ist keine medizinische Software und keine Notfallhilfe.",
        ], callout_data=("Bei Beschwerden oder Unsicherheit", "Bitte medizinisches Fachpersonal kontaktieren. Eine visuelle Änderung im Diagramm ist keine medizinische Aussage.", PINK))
    s += section("Fehlerbehebung und Gatekeeper", "HealthAtlas wird ohne Apple-Developer-Account ad-hoc signiert. Daher kann macOS Gatekeeper beim ersten Öffnen eines Dev-, Beta- oder Final-Builds warnen.", styles,
        bullets_list=[
            "Im Finder die App mit Control-Klick öffnen und " + '"Öffnen"' + " wählen. Im folgenden Hinweis nochmals bestätigen.",
            "Falls nötig: Systemeinstellungen > Datenschutz & Sicherheit öffnen und für genau diesen HealthAtlas-Build " + '"Dennoch öffnen"' + " wählen.",
            "Gatekeeper nicht systemweit deaktivieren. Nur Builds aus dem offiziellen HealthAtlas-Projekt oder eigene Builds öffnen.",
            "Bei Importfehlern prüfen: ZIP enthält Export.xml, Datei ist nicht leer, kleiner als 100 MB und lokal erreichbar.",
            "Wenn keine Werte erscheinen: zuerst unter Quellen mindestens einen Datentyp aktivieren; für Verläufe sind mindestens zwei Tageswerte im gewählten Zeitraum nötig.",
        ], callout_data=("Build-Varianten", "Dev, Beta und Final verwenden getrennte lokale Einstellungen. Ein Theme oder eine Auswahl in Dev ändert nicht die Einstellungen einer Beta oder Final-App.", GOLD))
    s += [PageBreak()]
    s += section("Funktionsübersicht", "Diese Tabelle fasst alle Bereiche, Bedienoptionen und ihre Wirkung zusammen.", styles)
    rows = [
        ["Bereich", "Option", "Wirkung"],
        ["Kopfzeile", "Theme-Menü", "Wechselt die Darstellung sofort."],
        ["Kopfzeile", "Import", "Öffnet die Auswahl für ZIP oder Export.xml."],
        ["Übersicht", "Fokus-Kennzahl / Zeitraum", "Wählt die große Kennzahl bzw. beschreibt nur lokale Erfassungstage."],
        ["Übersicht", "4 / 8 / 12 · Dichte", "Legt Kartenzahl und lokale Kartendichte fest."],
        ["Übersicht", "Karte / PDF-Bericht", "Öffnet Fokusansicht bzw. speichert lokal einen PDF-Bericht."],
        ["Übersicht", "Verlauf / Ringe", "Zeigt mehrere lokale Typen; kein Ziel und keine Bewertung."],
        ["Übersicht", "Pfeile", "Blättert durch weitere ausgewählte Karten."],
        ["Verläufe", "7T / 30T / 3M / 1J", "Begrenzt die dargestellten Tage."],
        ["Verläufe", "Datentyp-Menü", "Wechselt die dargestellte Zeitreihe."],
        ["Verläufe", "Punkt / Hover", "Hebt den Punkt hervor bzw. zeigt Datum, Wert und Mini-Trend."],
        ["Quellen", "Zeilen-Schalter", "Aktiviert oder entfernt einen Datentyp."],
        ["Quellen", "Suche / Kategorie / Stern / Pfeile", "Filtert, favorisiert und ordnet Datentypen lokal."],
        ["Quellen", "Alle / Keine · Datenqualität", "Aktiviert Typen bzw. zählt nur lokale Abdeckung."],
        ["Einblicke", "Datentyp-Menü / Kalender", "Wechselt Zusammenfassung und 12 Wochen / 1 Jahr."],
        ["Design-Studio", "Sprache", "Wechselt Deutsch und English."],
        ["Design-Studio", "Theme-Karten", "Wählt Clear Glass, Midnight Glass, Aurora oder Warmpaper."],
        ["Sidebar unten", "GitHub / Discord", "Öffnet externe Projekt- bzw. Community-Links im Browser."],
    ]
    table = Table([[P(cell, styles["SmallHA"]) for cell in row] for row in rows], colWidths=[35 * mm, 45 * mm, 84 * mm], repeatRows=1)
    table.setStyle(TableStyle([
        ("BACKGROUND", (0, 0), (-1, 0), PANEL_LIGHT), ("TEXTCOLOR", (0, 0), (-1, 0), WHITE),
        ("FONTNAME", (0, 0), (-1, 0), "HealthAtlasBold"),
        ("GRID", (0, 0), (-1, -1), 0.35, colors.Color(0.26, 0.77, 0.93, alpha=0.30)),
        ("BACKGROUND", (0, 1), (-1, -1), colors.Color(0.06, 0.13, 0.29, alpha=0.84)),
        ("VALIGN", (0, 0), (-1, -1), "TOP"),
        ("LEFTPADDING", (0, 0), (-1, -1), 6), ("RIGHTPADDING", (0, 0), (-1, -1), 6),
        ("TOPPADDING", (0, 0), (-1, -1), 6), ("BOTTOMPADDING", (0, 0), (-1, -1), 6),
    ]))
    s += [table]
    return s


def manual_en(styles):
    s = []
    s += cover("HealthAtlas", "Detailed User Manual\nLocal Apple Health visualisation for macOS", "English", styles)
    s += section("Welcome", "HealthAtlas reads an Apple Health export that you choose locally on your Mac. You then decide exactly which recognised data types appear in the dashboard. The app does not diagnose conditions or recommend treatment.", styles,
        bullets_list=[
            "Every normal launch starts without imported health data.",
            "Imported data stays in memory for the current session only. It is not uploaded or sent to an account.",
            "Language, theme, card count and data-type selection are stored separately for the Dev, Beta and Final app variants.",
            "While no personal data is loaded, the start screen also offers the matching GitHub manual and optional AI help. It copies only a general question with the public manual link to the clipboard; health values and local data stay in the app.",
            "Requirement: macOS 26 or later.",
        ], callout_data=("Important", "HealthAtlas describes values and trends. It is not a substitute for professional medical advice, examination or diagnosis.", PINK))
    s += [PageBreak()]
    s += section("Quick start in 5 steps", "The repository includes a fully synthetic demo export for a safe first test. It contains no personal health information.", styles,
        bullets_list=[
            "Open HealthAtlas. The empty overview presents a central import button.",
            "Click " + '"Import ZIP or Export.xml ..."' + ".",
            "Choose <b>Demo/AppleHealthDemo/Export.xml</b> or your own Apple Health export.",
            "Open <b>Sources</b> after import and turn the data types you want on or off.",
            "Explore the selected data in <b>Overview</b>, <b>Trends</b> and <b>Insights</b>.",
        ], screenshot="en/import.png", caption="Empty start screen. The shown interface contains no health information.")
    s += [PageBreak()]
    s += section("Importing an Apple Health export", "HealthAtlas accepts exactly two local formats: a direct <b>Export.xml</b> file or an Apple Health <b>ZIP</b> archive containing Export.xml. You do not need to unpack the ZIP first; HealthAtlas reads Export.xml directly from the archive.", styles,
        bullets_list=[
            "Files must be between 1 byte and 100 MB.", "Only one file can be selected at a time.",
            "The clinical companion file in an Apple Health export is intentionally not imported.",
            "There is no direct HealthKit connection and no cloud import.",
            "For a wrong ZIP, unreadable XML or an oversized file, HealthAtlas explains the issue and imports nothing.",
        ], callout_data=("Export on iPhone", "In Apple Health, open Summary, tap your picture or initials, then select " + '"Export All Health Data"' + ". Apple can change exact interface labels. Source: Apple Support, " + '<font color="#42C5EE">support.apple.com/en-in/guide/iphone/iph5ede58c3d/ios</font>', TEAL))
    s += section("Navigation and status", "The frosted sidebar remains visible in every theme. Before the first local import, its first entry is called " + '"Import"' + "; after a successful import it becomes " + '"Overview"' + ". It shows " + '"Private - Local only"' + " at the bottom as a permanent privacy reminder.", styles,
        bullets_list=[
            "<b>Overview:</b> cards for selected data types.", "<b>Trends:</b> an interactive timeline for one selected type.",
            "<b>Sources:</b> selection of all data types recognised in the import.", "<b>Insights:</b> a descriptive summary for one data type.",
            "<b>Design Studio:</b> language and appearance.",
            "The GitHub and Discord icons above the privacy status open the project page and community in the default browser.",
        ])
    s += [PageBreak()]
    s += section("Overview", "After a successful import, Overview shows only the types enabled in Sources. Every card has a type-specific accent colour and graphic treatment. The displayed numbers use the most recent available daily value.", styles,
        bullets_list=[
            "Choose a <b>Hero metric</b> at the top. It shows the latest local value, a large short trend and a gently animated orbit. <b>Your period at a glance</b> below only describes how many enabled types contain values across the latest seven locally recorded days — never a goal, rating or diagnosis.",
            "Choose <b>4</b>, <b>8</b> or <b>12</b> to control cards per page. <b>Compact</b>, <b>Standard</b> and <b>Focus</b> change card density locally. Drag and drop cards to freely reorder them.",
            "Previous and next controls appear when more selected types exist than fit on one page.",
            "Click a card to open a true full-screen focus view with a trend, period comparison and yearly calendar; <b>Open Trends</b> leads to the detailed view. <b>Exit full screen</b> returns to the app. The PDF button writes only to a location you choose.",
            "Below the cards, a shared multi-metric timeline and daily rings show recent local values from several types. Rings are neither goals nor ratings. At narrower window sizes, legends remain within their card.",
            "Steps, energy, distance and flights climbed are shown as daily sums. Other numeric types are shown as daily averages.",
            "Name, value, unit and date come from the selected export and follow the app language formatting.",
        ], screenshot="en/overview.png", caption="Overview with synthetic demo data. Colours aid recognition; they do not assess health.")
    s += [PageBreak()]
    s += section("Sources", "Sources is the central selection area. It lists every recognised data type with an on/off switch, number of samples and a summary value. The table scrolls vertically when an export contains many types.", styles,
        bullets_list=[
            "<b>Show all</b> enables every recognised data type.", "<b>Show none</b> disables all data types.",
            "The switch in each row immediately determines whether a type is available in Overview, Trends and Insights.",
            "Search and categories help with large exports. The star marks a favourite; arrows set the order. Favourites appear first in Overview.",
            "For a first personal import, the first four recognised types are selected by default. A compatible earlier selection is reused when its types occur in the new import.",
            "<b>Local data quality</b> counts selection, dated types, local days and samples. It does not rate health data.",
        ], screenshot="en/sources.png", caption="Sources with synthetic demo data. This selection controls the content of all other areas.")
    s += [PageBreak()]
    s += section("Trends", "This section visualises one active data type as a line. Select a period first, then choose one of the enabled types in the menu.", styles,
        bullets_list=[
            "<b>7D</b>: last 7 days.", "<b>30D</b>: last 30 days.", "<b>3M</b>: last 90 days.", "<b>1Y</b>: last 365 days.",
            "Hover a point to reveal a floating value card with date, formatted value and mini-trend. Clicking also gives that point a gently pulsing marker.",
            "A local comparison places the current and immediately preceding periods side by side. It is not a rating or diagnosis.",
            "The local data calendar sits in a separate panel below the chart so day cells and line animation remain clearly separated.",
            "If fewer than two values exist in the selected period, the chart reports that there are not enough values.",
        ], screenshot="en/trends.png", caption="Trend with synthetic demo data. Points are interactive and reveal their value after a click.")
    s += [PageBreak()]
    s += section("Insights", "Insights condenses one enabled data type into a local descriptive card. Choose the type from the menu. The view shows the latest daily value, its date, the change from the previous value and a short 14-day line preview.", styles,
        bullets_list=[
            "A positive or negative change only describes the difference from the preceding available daily value.",
            "The data calendar sits in its own panel below the summary and shows local days as a heatmap. Use <b>12 weeks</b> or <b>1 year</b> to change its period. Stronger colour only means a higher value within that period.",
            "<b>Local pattern</b> only describes which weekday has the most locally recorded dates — not health or behaviour.",
            "The screen does not supply normal ranges, alerts, ratings or medical conclusions.",
            "If only one dated value is available, the app states this clearly.",
        ], screenshot="en/insights.png", caption="Insights with synthetic demo data. The card is a descriptive summary, not a diagnosis.")
    s += [PageBreak()]
    s += section("Design Studio", "Use Design Studio to set the interface language and appearance. Changes take effect immediately and are stored locally for the current app variant.", styles,
        bullets_list=[
            "<b>Language:</b> Deutsch or English. Navigation, labels and known data-type names change with the selection.",
            "<b>Clear Glass:</b> a shared frosted layer with a calm cyan, blue, violet and pink glow plus subtle light points behind cards, text and controls. This keeps values readable throughout the app.",
            "<b>Midnight Glass:</b> a dark blue glass surface.", "<b>Aurora:</b> a teal variation.", "<b>Warmpaper:</b> a warm red-violet variation.",
            "Cards enter in a staggered sequence, react subtly on hover, and import completion briefly shows a success shimmer. Changing a range or data type redraws the chart softly. Page and sidebar changes use gentle transitions.",
            "Clear Glass adds very subtle moving contours and transparent health symbols to its glow and sparks. Reduce Motion and importing substantially reduce animation.",
            "When macOS Reduce Motion is enabled and while importing, Clear Glass reduces or pauses motion.",
            "HealthAtlas opens in 16:9 and remains freely resizable afterwards. The layout adapts to the selected window size.",
        ], screenshot="en/design-studio.png", caption="Design Studio. Themes change appearance only, never the health data.")
    s += [PageBreak()]
    s += section("Privacy and limits", "HealthAtlas is designed as a local visualisation. It has no account, analytics, advertising, tracking or hidden upload. The app does not send imported health values to HealthAtlas, GitHub, Discord or another service.", styles,
        bullets_list=[
            "Data remains in memory while the app is open and is not loaded again at the next normal launch.",
            "GitHub and Discord are opened only by an explicit click on the lower sidebar icons. They receive no imported values.",
            "ChatGPT, Gemini or Claude open only after an explicit click on the empty start screen. Before that, HealthAtlas only copies a fixed general introduction question with the public, language-specific manual link to the clipboard. Only Cmd+V lets the person decide whether to paste the question into that service.",
            "The bundled demo is synthetic and allows feature testing without personal data.",
            "HealthAtlas is not medical software and not emergency assistance.",
        ], callout_data=("Symptoms or uncertainty", "Please contact qualified healthcare professionals. A visual change in a chart is not a medical statement.", PINK))
    s += section("Troubleshooting and Gatekeeper", "HealthAtlas is ad-hoc signed because the project has no Apple Developer account. macOS Gatekeeper may therefore warn when opening a Dev, Beta or Final build for the first time.", styles,
        bullets_list=[
            "In Finder, Control-click the app and choose " + '"Open"' + ". Confirm Open in the following dialog.",
            "If necessary, go to System Settings > Privacy & Security and choose " + '"Open Anyway"' + " for that exact HealthAtlas build.",
            "Do not disable Gatekeeper system-wide. Open only your own build or one from the official HealthAtlas project.",
            "For import errors, confirm that the ZIP contains Export.xml, the file is not empty, is below 100 MB and is stored locally.",
            "If no values appear, enable at least one type in Sources. Trends need at least two daily values in the chosen period.",
        ], callout_data=("Build variants", "Dev, Beta and Final use separate local preferences. A theme or selection in Dev does not alter the settings of a Beta or Final app.", GOLD))
    s += [PageBreak()]
    s += section("Complete control reference", "This table summarises every current area, control and outcome.", styles)
    rows = [
        ["Area", "Control", "Outcome"],
        ["Header", "Theme menu", "Changes appearance immediately."], ["Header", "Import", "Opens ZIP or Export.xml picker."],
        ["Overview", "Hero metric / period", "Selects the large metric or describes only local recording days."], ["Overview", "4 / 8 / 12 · density", "Sets card count and local card density."], ["Overview", "Arrows", "Moves through additional selected cards."],
        ["Overview", "Card / PDF report", "Opens the focus view or saves a local PDF report."],
        ["Overview", "Timeline / rings", "Shows several local types; no goal or rating."],
        ["Trends", "7D / 30D / 3M / 1Y", "Limits displayed days."], ["Trends", "Data type menu", "Changes the displayed timeline."],
        ["Trends", "Data point / hover", "Highlights a point or shows date, value and mini-trend."], ["Sources", "Row switch", "Enables or removes one type."],
        ["Sources", "Search / category / star / arrows", "Filters, favourites and orders types locally."],
        ["Sources", "Show all / none · data quality", "Enables types or counts local coverage only."], ["Insights", "Data type menu / calendar", "Changes the summary and 12 weeks / 1 year."],
        ["Design Studio", "Language", "Switches Deutsch and English."], ["Design Studio", "Theme cards", "Selects Clear Glass, Midnight Glass, Aurora or Warmpaper."],
        ["Lower sidebar", "GitHub / Discord", "Opens the external project or community link in the browser."],
    ]
    table = Table([[P(cell, styles["SmallHA"]) for cell in row] for row in rows], colWidths=[35 * mm, 45 * mm, 84 * mm], repeatRows=1)
    table.setStyle(TableStyle([
        ("BACKGROUND", (0, 0), (-1, 0), PANEL_LIGHT), ("TEXTCOLOR", (0, 0), (-1, 0), WHITE), ("FONTNAME", (0, 0), (-1, 0), "HealthAtlasBold"),
        ("GRID", (0, 0), (-1, -1), 0.35, colors.Color(0.26, 0.77, 0.93, alpha=0.30)),
        ("BACKGROUND", (0, 1), (-1, -1), colors.Color(0.06, 0.13, 0.29, alpha=0.84)), ("VALIGN", (0, 0), (-1, -1), "TOP"),
        ("LEFTPADDING", (0, 0), (-1, -1), 6), ("RIGHTPADDING", (0, 0), (-1, -1), 6), ("TOPPADDING", (0, 0), (-1, -1), 6), ("BOTTOMPADDING", (0, 0), (-1, -1), 6),
    ]))
    s += [table]
    return s


def build_manual(filename, title_short, footer, story):
    OUTPUT.mkdir(parents=True, exist_ok=True)
    doc = HealthAtlasDoc(OUTPUT / filename, title_short, footer)
    doc.build(story)


if __name__ == "__main__":
    register_fonts()
    styles = make_styles()
    build_manual("HealthAtlas-Handbuch-DE.pdf", "Handbuch - Deutsch", "HealthAtlas - Lokale Gesundheitsvisualisierung", manual_de(styles))
    build_manual("HealthAtlas-Manual-EN.pdf", "Manual - English", "HealthAtlas - Local health visualisation", manual_en(styles))
