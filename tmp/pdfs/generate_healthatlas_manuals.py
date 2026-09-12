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
        name="CompactBodyHA", parent=styles["BodyHA"], spaceAfter=4,
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


def bullets(items, styles, style_name="BodyHA"):
    return [P(f'<font color="#42C5EE">&#8226;</font> {item}', styles[style_name]) for item in items]


def callout(title, text, styles, color=CYAN):
    box = Table([[P(f'<font color="#{color.hexval()[2:]}"><b>{title}</b></font><br/>{text}', styles["Callout"])]], colWidths=[PAGE_W - LEFT - RIGHT])
    box.setStyle(TableStyle([
        ("BACKGROUND", (0, 0), (-1, -1), colors.Color(0.08, 0.16, 0.36, alpha=0.88)),
        ("BOX", (0, 0), (-1, -1), 0.6, color),
        ("LEFTPADDING", (0, 0), (-1, -1), 10), ("RIGHTPADDING", (0, 0), (-1, -1), 10),
        ("TOPPADDING", (0, 0), (-1, -1), 8), ("BOTTOMPADDING", (0, 0), (-1, -1), 8),
    ]))
    return box


def image_block(name, caption, styles, notes=None, note_title=None):
    path = SHOTS / name
    image = Image(str(path))
    # Screens are intentionally smaller than a page. The adjacent panel explains
    # the controls shown in the image instead of leaving a mostly empty page.
    max_w = 101 * mm if notes else PAGE_W - LEFT - RIGHT
    max_h = 68 * mm if notes else 82 * mm
    scale = min(max_w / image.imageWidth, max_h / image.imageHeight)
    image.drawWidth = image.imageWidth * scale
    image.drawHeight = image.imageHeight * scale
    if notes:
        explanation = [P(note_title or "Im Bild", styles["H3HA"])]
        explanation += [P(f'<font color="#42C5EE">&#8226;</font> {note}', styles["SmallHA"]) for note in notes]
        panel = Table([[image, explanation]], colWidths=[106 * mm, PAGE_W - LEFT - RIGHT - 106 * mm])
        panel.setStyle(TableStyle([
            ("BACKGROUND", (0, 0), (0, 0), PANEL),
            ("BACKGROUND", (1, 0), (1, 0), colors.Color(0.08, 0.16, 0.36, alpha=0.88)),
            ("BOX", (0, 0), (-1, -1), 0.7, CYAN),
            ("INNERGRID", (0, 0), (-1, -1), 0.35, colors.Color(0.26, 0.77, 0.93, alpha=0.25)),
            ("LEFTPADDING", (0, 0), (-1, -1), 6), ("RIGHTPADDING", (0, 0), (-1, -1), 6),
            ("TOPPADDING", (0, 0), (-1, -1), 6), ("BOTTOMPADDING", (0, 0), (-1, -1), 6),
            ("VALIGN", (0, 0), (-1, -1), "TOP"),
        ]))
    else:
        panel = Table([[image]], colWidths=[max_w])
        panel.setStyle(TableStyle([
            ("BACKGROUND", (0, 0), (-1, -1), PANEL),
            ("BOX", (0, 0), (-1, -1), 0.7, CYAN),
            ("LEFTPADDING", (0, 0), (-1, -1), 5), ("RIGHTPADDING", (0, 0), (-1, -1), 5),
            ("TOPPADDING", (0, 0), (-1, -1), 5), ("BOTTOMPADDING", (0, 0), (-1, -1), 5),
        ]))
    return [panel, Spacer(1, 2.5 * mm), P(caption, styles["Caption"])]


def success_image_block(name, title, text, styles):
    image = Image(str(SHOTS / name))
    max_w = 76 * mm
    max_h = 31 * mm
    scale = min(max_w / image.imageWidth, max_h / image.imageHeight)
    image.drawWidth = image.imageWidth * scale
    image.drawHeight = image.imageHeight * scale
    explanation = [P(title, styles["H3HA"]), P(text, styles["SmallHA"])]
    panel = Table([[image, explanation]], colWidths=[82 * mm, PAGE_W - LEFT - RIGHT - 82 * mm])
    panel.setStyle(TableStyle([
        ("BACKGROUND", (0, 0), (0, 0), PANEL),
        ("BACKGROUND", (1, 0), (1, 0), colors.Color(0.08, 0.16, 0.36, alpha=0.88)),
        ("BOX", (0, 0), (-1, -1), 0.7, GREEN),
        ("INNERGRID", (0, 0), (-1, -1), 0.35, colors.Color(0.27, 0.87, 0.48, alpha=0.30)),
        ("LEFTPADDING", (0, 0), (-1, -1), 6), ("RIGHTPADDING", (0, 0), (-1, -1), 6),
        ("TOPPADDING", (0, 0), (-1, -1), 6), ("BOTTOMPADDING", (0, 0), (-1, -1), 6),
        ("VALIGN", (0, 0), (-1, -1), "MIDDLE"),
    ]))
    return [panel]


def detail_image_block(name, title, text, styles):
    image = Image(str(SHOTS / name))
    max_w = 34 * mm
    max_h = 38 * mm
    scale = min(max_w / image.imageWidth, max_h / image.imageHeight)
    image.drawWidth = image.imageWidth * scale
    image.drawHeight = image.imageHeight * scale
    explanation = [P(title, styles["H3HA"]), P(text, styles["SmallHA"])]
    panel = Table([[image, explanation]], colWidths=[44 * mm, PAGE_W - LEFT - RIGHT - 44 * mm])
    panel.setStyle(TableStyle([
        ("BACKGROUND", (0, 0), (0, 0), PANEL),
        ("BACKGROUND", (1, 0), (1, 0), colors.Color(0.08, 0.16, 0.36, alpha=0.88)),
        ("BOX", (0, 0), (-1, -1), 0.7, CYAN),
        ("INNERGRID", (0, 0), (-1, -1), 0.35, colors.Color(0.26, 0.77, 0.93, alpha=0.25)),
        ("LEFTPADDING", (0, 0), (-1, -1), 6), ("RIGHTPADDING", (0, 0), (-1, -1), 6),
        ("TOPPADDING", (0, 0), (-1, -1), 6), ("BOTTOMPADDING", (0, 0), (-1, -1), 6),
        ("VALIGN", (0, 0), (-1, -1), "MIDDLE"),
    ]))
    return [panel]


def at_a_glance(items, styles):
    cells = [P(f'<font color="#42C5EE"><b>{title}</b></font><br/>{text}', styles["SmallHA"]) for title, text in items]
    panel = Table([cells], colWidths=[(PAGE_W - LEFT - RIGHT) / 3] * 3)
    panel.setStyle(TableStyle([
        ("BACKGROUND", (0, 0), (-1, -1), colors.Color(0.08, 0.16, 0.36, alpha=0.88)),
        ("BOX", (0, 0), (-1, -1), 0.7, CYAN),
        ("INNERGRID", (0, 0), (-1, -1), 0.35, colors.Color(0.26, 0.77, 0.93, alpha=0.25)),
        ("LEFTPADDING", (0, 0), (-1, -1), 10), ("RIGHTPADDING", (0, 0), (-1, -1), 10),
        ("TOPPADDING", (0, 0), (-1, -1), 12), ("BOTTOMPADDING", (0, 0), (-1, -1), 12),
        ("VALIGN", (0, 0), (-1, -1), "TOP"),
    ]))
    return panel


def section(title, text, styles, screenshot=None, caption=None, bullets_list=None, callout_data=None, screenshot_notes=None, screenshot_note_title=None, bullet_style_name="BodyHA"):
    flow = [P(title, styles["H1HA"]), P(text, styles["BodyHA"])]
    if bullets_list:
        flow += bullets(bullets_list, styles, bullet_style_name)
    if callout_data:
        title, callout_text, color = callout_data
        flow += [Spacer(1, 2 * mm), callout(title, callout_text, styles, color), Spacer(1, 3 * mm)]
    if screenshot:
        flow += [Spacer(1, 2 * mm)] + image_block(screenshot, caption, styles, screenshot_notes, screenshot_note_title)
    return flow


def cover(title, subtitle, language, edition, styles):
    icon = Image(str(ICON), width=38 * mm, height=38 * mm)
    icon.hAlign = "CENTER"
    return [
        Spacer(1, 43 * mm), icon, Spacer(1, 10 * mm),
        P(title, styles["CoverTitle"]), Spacer(1, 5 * mm),
        P(subtitle, styles["CoverSub"]), Spacer(1, 34 * mm),
        P(f'<font color="#46DE79"><b>{language}</b></font><br/>{edition}<br/>Privacy-first local Apple Health visualisation for macOS', styles["CoverSub"]),
        Spacer(1, 14 * mm), P("HealthAtlas - User Manual", styles["Caption"]),
        __import__("reportlab.platypus", fromlist=["NextPageTemplate"]).NextPageTemplate("Content"), PageBreak(), Spacer(1, 12 * mm),
    ]


def manual_de(styles):
    s = []
    s += cover("HealthAtlas", "Ausführliches Benutzerhandbuch\nLokale Apple-Health-Visualisierung für macOS", "Deutsch", "Ausgabe: Beta 1.3.0", styles)
    s += section("Willkommen", "HealthAtlas liest einen von dir ausgewählten Apple-Health-Export lokal auf deinem Mac. Anschließend entscheidest du selbst, welche erkannten Datentypen im Dashboard erscheinen. Die App erstellt keine Diagnose und gibt keine Behandlungsempfehlungen.", styles,
        bullets_list=[
            "Die App startet bei jedem normalen Start ohne importierte Gesundheitsdaten.",
            "Importierte Daten bleiben nur im Arbeitsspeicher der laufenden Sitzung. Sie werden weder hochgeladen noch in ein Konto übertragen.",
            "Einstellungen wie Sprache, Theme, Kartenzahl und deine Datentyp-Auswahl werden getrennt pro Dev-, Beta- oder Final-App gespeichert.",
            "Solange keine eigenen Daten geladen sind, bietet die Startansicht zusätzlich das passende GitHub-Handbuch und eine freiwillige KI-Hilfe. Sie kopiert nur eine allgemeine Frage mit dem öffentlichen Handbuch-Link in die Zwischenablage; Gesundheitswerte und lokale Daten bleiben in der App.",
            "Voraussetzung: macOS 26 oder neuer.",
        ], callout_data=("Wichtig", "HealthAtlas beschreibt Werte und Verläufe. Es ersetzt keine ärztliche Beratung, Untersuchung oder Diagnose.", PINK))
    s += [Spacer(1, 7 * mm), at_a_glance([
        ("Nur lokal", "Importierte Werte bleiben während der offenen Sitzung auf diesem Mac."),
        ("Deine Auswahl", "Quellen bestimmt, welche Datentypen in den Bereichen verfügbar sind."),
        ("Ohne Diagnose", "Diagramme und Einblicke beschreiben Daten, sie bewerten sie nicht."),
    ], styles)]
    s += [PageBreak()]
    s += section("Schnellstart in 5 Schritten", "Für einen sicheren ersten Test liegt im Repository eine vollständig synthetische Demo vor. Sie enthält keine persönlichen Gesundheitsdaten und fiktive Werte für alle aktuell unterstützten, nicht veralteten Apple-Health-Exporttypen.", styles,
        bullets_list=[
            "HealthAtlas öffnen. In der leeren Importansicht erscheint der Import-Button.",
            "Auf " + '"ZIP oder Export.xml importieren ..."' + " klicken.",
            "Die Demo-Datei <b>Demo/AppleHealthDemo/Export.xml</b> oder einen eigenen Apple-Health-Export auswählen.",
            "Nach dem Import zu <b>Quellen</b> wechseln und die gewünschten Datentypen ein- oder ausblenden.",
            "Unter <b>Übersicht</b>, <b>Verläufe</b> und <b>Einblicke</b> die Daten ansehen.",
        ], screenshot="final-import.png", caption="Leere Startansicht mit synthetischer Testoberfläche. Vor dem Import sind keine Gesundheitswerte geladen.",
        screenshot_notes=[
            "Der zentrale Import-Button öffnet ausschließlich einen lokalen Dateidialog für ZIP oder Export.xml.",
            "Handbuch und freiwillige KI-Hilfe erscheinen nur ohne geladenen Import. Die vorbereitete KI-Frage enthält keine Gesundheitswerte.",
        ], screenshot_note_title="Sicher starten")
    s += [Spacer(1, 3 * mm)] + success_image_block("final-import-success.png", "Import abgeschlossen", "Nach einem erfolgreichen Import bestätigt HealthAtlas, dass die ausgewählten Daten auf diesem Mac bleiben. Danach führt Quellen zur Auswahl der angezeigten Datentypen.", styles)
    s += [PageBreak()]
    s += section("Apple-Health-Export importieren", "HealthAtlas akzeptiert genau zwei lokale Dateiformate: eine direkte <b>Export.xml</b> oder ein Apple-Health-<b>ZIP</b>-Archiv, das darin eine Datei namens Export.xml enthält. Das ZIP muss vorher nicht entpackt werden; HealthAtlas liest die Export.xml lokal aus dem Archiv.", styles,
        bullets_list=[
            "Direkte Export.xml-Dateien und ZIP-Archive dürfen jeweils bis zu 5 GiB groß sein. Die enthaltene Export.xml darf nach dem Entpacken ebenfalls höchstens 5 GiB groß sein. Das sind Sicherheitsgrenzen von HealthAtlas, keine Grenze von Apple Health oder macOS.",
            "HealthAtlas liest die ursprüngliche XML sequenziell einmal. Nur relevante Intervallwerte werden für die Quellenregel in einer temporären lokalen Zwischenablage weiterverarbeitet. Vollständig gleiche exportierte Records werden nur einmal gezählt.",
            "<b>Referenzmessung:</b> Auf einem Mac Studio M4 Max mit 36 GB RAM benötigte der Import einer synthetischen 500-MB-Datei ungefähr 41 Sekunden und einer 1-GB-Datei ungefähr 1 Minute 25 Sekunden.",
            "<b>Orientierungswerte:</b> Bei ähnlichem Dateiinhalt ergibt die annähernd lineare Hochrechnung etwa 2:50 Minuten für 2 GB, 4:15 Minuten für 3 GB, 5:40 Minuten für 4 GB und 7:05 Minuten für 5 GB. Auf anderen Macs kann der Import abhängig von Prozessor, SSD, Dateninhalt und Systemauslastung länger dauern.",
            "Schritte, Distanz und aktive Energie werden je 15-Minuten-Intervall gegen Quellenüberlappungen abgegrenzt. Einzelmessungen wie Herzfrequenz und Gewicht bleiben getrennt; Schlaf wird ebenfalls pro Intervall begrenzt. Workouts werden nur bei exakt gleichen Attributen dedupliziert.",
            "Der Export enthält keine nachbildbare Apple-Quellenpriorität. HealthAtlas verwendet deshalb eine feste lokale Regel und behauptet keine identischen Werte zur Health-App. Bei gleicher Abdeckung entscheidet eine stabile alphabetische Quellenreihenfolge ohne Unterschied von Groß- und Kleinschreibung oder Akzenten.",
            "Es kann jeweils nur eine Datei gewählt werden.",
            "Die klinische Zusatzdatei eines Apple-Health-Exports wird bewusst nicht importiert.",
            "Es gibt keine direkte HealthKit-Verbindung und keinen Cloud-Import.",
            "Bei einem nicht passenden ZIP, einer nicht lesbaren XML oder einer zu großen Datei zeigt HealthAtlas eine Erklärung an und importiert nichts.",
        ], callout_data=("Export auf dem iPhone", "In Apple Health: Übersicht öffnen, oben rechts Bild oder Initialen wählen, dann " + '"Alle Gesundheitsdaten exportieren"' + ". Apple kann die Bezeichnung der Oberfläche ändern. Quelle: Apple Support, " + '<font color="#42C5EE">support.apple.com/de-de/guide/iphone/iph5ede58c3d/26/ios/26</font>', TEAL), bullet_style_name="CompactBodyHA")
    s += section("Navigation und Status", "Die linke Milchglas-Sidebar ist in jedem Theme standardmäßig sichtbar. Vor dem ersten lokalen Import heißt ihr erster Eintrag " + '"Import"' + "; nach erfolgreichem Import wird daraus " + '"Übersicht"' + ". Am unteren Rand bleibt " + '"Privat - Nur lokal"' + " als ständige Datenschutzerinnerung sichtbar.", styles,
        bullets_list=[
            "<b>Übersicht:</b> Karten der ausgewählten Datentypen.",
            "<b>Verläufe:</b> Interaktive Zeitreihe eines ausgewählten Typs.",
            "<b>Quellen:</b> Auswahl aller im Import erkannten Datentypen.",
            "<b>Einblicke:</b> Beschreibende Zusammenfassung eines Datentyps.",
            "<b>Design-Studio:</b> Sprache und Erscheinungsbild.",
            "Die native Menüleiste bietet Import, lokalen PDF-Bericht, Design-Studio sowie Fenstersteuerung. Über <b>Ansicht</b> lässt sich die Sidebar ein- oder ausblenden.",
            "Interaktive Karten und Diagramme sind als Bedienelemente für macOS-Assistenzfunktionen erreichbar.",
            "Die GitHub- und Discord-Icons über dem Datenschutz-Status öffnen die Projektseite bzw. die Community im Standardbrowser.",
        ])
    s += section("Übersicht", "Nach einem erfolgreichen Import zeigt die Übersicht nur die Datentypen, die unter Quellen aktiviert sind. Jede Karte hat eine zu ihrem Typ passende Akzentfarbe und grafische Behandlung. Die angezeigten Zahlen beziehen sich auf den jeweils letzten verfügbaren Tageswert.", styles,
        bullets_list=[
            "<b>Dein Zeitraum in Kürze</b> beschreibt nur, wie viele aktivierte Typen in den letzten sieben lokalen Erfassungstagen Werte enthalten — ohne Ziel, Bewertung oder Diagnose.",
            "Mit <b>4</b>, <b>8</b> oder <b>12</b> wird die Kartenzahl pro Seite festgelegt. <b>Kompakt</b>, <b>Standard</b> und <b>Fokus</b> ändern die Kartendichte lokal. Karten lassen sich per Drag &amp; Drop neu anordnen; jede der drei Ansichten speichert ihre eigene Reihenfolge und kann zurückgesetzt werden.",
            "Bei mehr ausgewählten Datentypen erscheinen Vor- und Zurück-Schalter zum Blättern.",
            "Ein Klick auf eine Karte öffnet eine echte Vollbild-Fokusansicht mit Verlauf, Zeitraumvergleich und Jahreskalender; dort führt <b>Verläufe öffnen</b> zur Detailansicht. Mit <b>Vollbild beenden</b> kehrst du zurück. Vor dem lokalen PDF-Bericht wählst du Zeitraum, Datentypen und das Bericht-Theme; gespeichert wird nur an einem selbst gewählten Ort.",
            "Mit <b>Verlauf auswählen ...</b> bestimmst du unabhängig von Karten, Pins und Quellen, welche ein bis vier aktiven Typen im gemeinsamen Gesundheitsverlauf verglichen werden.",
            "In der kompakten Dichte bleibt für den Kartentitel eine feste Textfläche. Der vollständige Apple-Name für die Handgelenktemperatur wird dort zu <b>Handgelenktemperatur</b> verkürzt; Quellen und Detailansichten verwenden weiterhin den vollständigen Namen.",
            "Unter den Karten zeigen ein gemeinsamer Mehrfach-Verlauf und Tagesringe letzte lokale Werte mehrerer Typen. Die Ringe sind weder Ziele noch Bewertungen. Bei schmaleren Fenstern bleiben die Legenden innerhalb ihrer Karte.",
            "Schritte, Energie, Distanz und Stockwerke werden als Tages-Summe dargestellt. Andere numerische Typen werden als Tages-Durchschnitt dargestellt.",
            "Name, Wert, Einheit und Datum stammen aus dem importierten Export und werden gemäß der gewählten App-Sprache formatiert.",
        ], screenshot="final-overview.png", caption="Übersicht mit synthetischen Demodaten. Der gemeinsame Verlauf und der lokale PDF-Bericht sind getrennt konfigurierbar.",
        screenshot_notes=[
            "Verlauf auswählen öffnet eine breite Liste und legt nur die bis zu vier Linien im gemeinsamen Verlauf fest.",
            "Der lokale PDF-Bericht besitzt eine eigene Auswahl für Zeitraum, Datentypen und Theme. Nichts wird hochgeladen.",
            "Kartenzahl, Dichte und Reihenfolge bleiben von der Auswahl für den gemeinsamen Verlauf getrennt.",
        ], screenshot_note_title="Neu in der Übersicht")
    s += [PageBreak(), Spacer(1, 12 * mm)]
    s += section("Quellen", "Quellen ist die zentrale Auswahl. Hier listet HealthAtlas jeden erkannten Datentyp auf: mit Ein-/Aus-Schalter, Anzahl der Messwerte und zusammengefasstem Wert. Kategorie, Suche und <b>Anzeigen &amp; anpinnen</b> bleiben über der Tabelle sichtbar. Die Tabelle kann vertikal scrollen, wenn der Export viele Typen enthält.", styles,
        bullets_list=[
            "<b>Anzeigen &amp; anpinnen</b> bündelt <b>Alle anzeigen</b>, <b>Keine anzeigen</b> und das Ziel für Pin.",
            "Der Schalter in jeder Zeile entscheidet sofort, ob ein Typ in Übersicht, Verläufen und Einblicken zur Verfügung steht.",
            "Wähle im Menü <b>Anpinnen für Übersicht</b>, <b>Verläufe</b> oder <b>Einblicke</b>. Der Stern setzt den Favoriten nur für diesen Bereich. Pfeile ordnen Datentypen für das aktuelle Dashboard-Layout.",
            "Beim ersten eigenen Import werden standardmäßig die ersten vier erkannten Typen gewählt. Eine passende frühere Auswahl wird wiederverwendet, soweit diese Typen im neuen Import vorkommen.",
            "<b>Lokale Datenqualität</b> zählt Auswahl, datierte Typen, lokale Tage und Messwerte. Zusätzlich nennt sie fehlende Tage im aktuellen lokalen Zeitraum sowie Typen mit wenigen Werten. Sie bewertet keine Gesundheitsdaten.",
            "<b>Import ersetzen</b> öffnet den lokalen Dateidialog erneut. <b>Alle lokalen Daten löschen</b> entfernt die aktuelle Sitzung erst nach Bestätigung. Der sichtbare Importzeitpunkt gilt nur für die laufende Sitzung.",
        ], screenshot="final-sources.png", caption="Quellen mit synthetischen Demodaten. Die Auswahl bestimmt die Inhalte aller anderen Bereiche.",
        screenshot_notes=[
            "Kategorie, Suche und Anzeigen &amp; anpinnen bleiben über der Tabelle sichtbar.",
            "Das Menü zeigt oder verbirgt alle Datentypen und legt das Ziel für Pin fest.",
            "Lokale Datenqualität beschreibt nur Abdeckung und Anzahl der importierten Werte.",
        ], screenshot_note_title="Auswahl und Ordnung")
    s += [Spacer(1, 3 * mm)] + detail_image_block("final-sources-menu.png", "Anzeigen &amp; anpinnen", "Das Menü enthält Alle anzeigen, Keine anzeigen sowie Anpinnen für Übersicht, Verläufe oder Einblicke. Anschließend setzt der Stern in einer Zeile den Pin für den gewählten Bereich.", styles)
    s += [PageBreak(), Spacer(1, 12 * mm)]
    s += section("Verläufe", "Dieser Bereich visualisiert einen aktiven Datentyp passend zu seinem lokalen Format: Schritte und Energie als Balken, Schlaf als Bereich und andere Zahlen als Linie. Du wählst oben zunächst den Zeitraum; anschließend kannst du im Auswahlmenü innerhalb der aktivierten Datentypen wechseln.", styles,
        bullets_list=[
            "<b>7T</b>: letzte 7 Tage.", "<b>15T</b>: letzte 15 Tage.", "<b>30T</b>: letzte 30 Tage.", "<b>3M</b>: letzte 90 Tage.", "<b>6M</b>: letzte 182 Tage.", "<b>1J</b>: letzte 365 Tage.",
            "Fahre mit der Maus über einen Punkt, um eine schwebende Wertkarte mit Datum, formatiertem Wert und Mini-Trend zu sehen. Ein Klick markiert den Punkt zusätzlich sichtbar und sanft pulsierend. Sachliche Highlights nennen beispielsweise den höchsten lokalen Wert im Zeitraum oder die Zahl der Tage mit Daten.",
            "Ein lokaler Vergleich zeigt aktuellen und unmittelbar vorherigen Zeitraum nebeneinander. Er ist keine Bewertung oder Diagnose.",
            "Der lokale Datenkalender liegt als eigener Balken unter dem Diagramm, damit Tageskästchen und Linienanimation klar getrennt bleiben. Er bietet 1 Woche, 15 Tage, 4 Wochen, 3 Monate, 6 Monate oder 1 Jahr. Ein Klick auf einen Tag zeigt dessen lokales Datum und seinen Wert.",
            "Wenn im gewählten Zeitraum weniger als zwei Werte vorhanden sind, meldet die Anzeige, dass keine ausreichenden Werte vorliegen.",
        ], screenshot="final-trends.png", caption="Verlauf mit synthetischen Demodaten. Der 15-Tage-Zeitraum steht sowohl für den Verlauf als auch für den Datenkalender bereit.",
        screenshot_notes=[
            "15T ergänzt die vorhandenen Zeiträume im oberen Verlaufsschalter.",
            "Im Kalender ist 15 Tage eine eigene Auswahl neben 1 Woche, 4 Wochen, 3 Monaten, 6 Monaten und 1 Jahr.",
            "Ein Punkt im Diagramm oder ein Kalendertag zeigt ausschließlich lokale Details zum ausgewählten Datum.",
        ], screenshot_note_title="Zeiträume und Kalender")
    s += [PageBreak()]
    s += section("Einblicke", "Einblicke verdichtet einen aktivierten Datentyp zu einer lokalen, beschreibenden Momentaufnahme. Du wählst den Typ im Auswahlmenü. Die Ansicht enthält den letzten Tageswert, dessen Datum, lokale Abdeckung und ein Erfassungsmuster; sie enthält bewusst keinen Detailverlauf oder Datenkalender.", styles,
        bullets_list=[
            "Die lokale Abdeckung nennt nur Tage mit und ohne Wert im aktuellen kurzen Zeitraum. Das Muster nennt den am häufigsten erfassten Wochentag. Beides ist keine Bewertung.",
            "<b>Lokales Muster</b> beschreibt nur, an welchem Wochentag die meisten lokalen Daten vorliegen — nicht Gesundheit oder Verhalten.",
            "Die Darstellung liefert keine Normalwerte, Warnung, Bewertung oder medizinische Schlussfolgerung.",
            "Ist nur ein datierter Wert vorhanden, weist die App darauf hin.",
        ], screenshot="final-insights.png", caption="Einblicke mit synthetischen Demodaten. Die Karte ist eine beschreibende Zusammenfassung, keine Diagnose.",
        screenshot_notes=[
            "Das Menü legt fest, welcher aktivierte Datentyp zusammengefasst wird.",
            "Momentaufnahme, lokale Abdeckung und Erfassungsmuster sind beschreibend und keine medizinische Bewertung.",
        ], screenshot_note_title="Beschreibende Einblicke")
    s += [PageBreak()]
    s += section("Design-Studio", "Im Design-Studio sind Erscheinungsbild, Hilfe zum Handbuch und App-Aktualisierungen in drei Bereiche gegliedert. Änderungen werden sofort übernommen und für die jeweilige App-Variante lokal gespeichert.", styles,
        bullets_list=[
            "<b>Sprache:</b> Deutsch oder English. Navigation, Beschriftungen und bekannte Datentypnamen wechseln mit der Auswahl.",
            "<b>Themes:</b> Clear Glass verbindet eine Milchglasfläche mit ruhigem Cyan-, Blau-, Violett- und Rosaglow; Midnight Glass ist dunkelblau, Aurora türkis und Warmpaper warm rötlich-violett. Das aktive Theme ist umrandet.",
            "Karten und Seiten wechseln sanft. Clear Glass ergänzt das Design um sehr dezente Bewegung, die bei " + '"Bewegung reduzieren"' + " und während des Imports stark reduziert bzw. pausiert wird.",
            "HealthAtlas öffnet neu im 16:9-Format und bleibt danach frei skalierbar. Die Darstellung passt sich der gewählten Fenstergröße an.",
            "Unter <b>Hilfe zum Handbuch</b> öffnen <b>Handbuch Deutsch</b> und <b>Manual English</b> die beiden öffentlichen Handbücher getrennt.",
            "ChatGPT, Gemini und Claude kopieren erst nach einem Klick nur eine allgemeine Frage mit passendem öffentlichen Handbuch-Link in die Zwischenablage und öffnen dann den gewählten Dienst. Lokale oder importierte Gesundheitsdaten werden nicht übertragen; erst mit Cmd+V entscheidest du, ob du die Frage einfügst.",
            "Unter <b>App-Aktualisierungen</b> zeigt HealthAtlas die installierte Version mit Buildnummer. Die Prüfung der öffentlichen GitHub-Release-Liste ist optional: manuell, bei jedem Start, täglich, wöchentlich oder monatlich.",
            "Eine Update-Prüfung überträgt keine Gesundheitsdaten. Ist eine passende neuere Veröffentlichung vorhanden, wird ihre GitHub-Seite erst nach einem bewussten Klick geöffnet.",
        ], screenshot="final-design-studio.png", caption="Design-Studio mit den Bereichen Erscheinungsbild, Hilfe zum Handbuch und App-Aktualisierungen. Handbuchhilfe und optionale Update-Prüfung verwenden ausschließlich öffentliche Links.",
        screenshot_notes=[
            "Das aktive Theme ist mit einer hellen Umrandung markiert.",
            "Die zwei Handbuch-Buttons öffnen die öffentlichen Handbücher getrennt.",
            "Die drei Dienste erhalten nur eine allgemeine Handbuchfrage, keine lokalen Werte.",
            "Automatisch prüfen bleibt optional; die App fragt nur die öffentliche Release-Liste ab.",
        ], screenshot_note_title="Handbuchhilfe und Updates")
    s += [PageBreak(), Spacer(1, 12 * mm)]
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
            "Die App einmal normal öffnen. macOS blockiert den Start.",
            "Systemeinstellungen > Datenschutz & Sicherheit öffnen, zum Bereich Sicherheit scrollen und für genau diesen HealthAtlas-Build " + '"Dennoch öffnen"' + " wählen.",
            "Die Warnung mit " + '"Öffnen"' + " bestätigen und bei Bedarf authentifizieren. " + '"Dennoch öffnen"' + " erscheint nur für begrenzte Zeit nach dem blockierten Startversuch.",
            "Dadurch wird nur für diesen Build eine Ausnahme angelegt; Gatekeeper nicht systemweit deaktivieren. Nur Builds aus dem offiziellen HealthAtlas-GitHub-Release öffnen.",
            "Bei Importfehlern prüfen: ZIP enthält Export.xml, Datei ist nicht leer, innerhalb der HealthAtlas-Grenze von 5 GiB und lokal erreichbar.",
            "Wenn keine Werte erscheinen: zuerst unter Quellen mindestens einen Datentyp aktivieren; für Verläufe sind mindestens zwei Tageswerte im gewählten Zeitraum nötig.",
        ], callout_data=("Build-Varianten", "Dev, Beta und Final verwenden getrennte lokale Einstellungen. Ein Theme oder eine Auswahl in Dev ändert nicht die Einstellungen einer Beta oder Final-App.", GOLD))
    s += [PageBreak()]
    s += section("Funktionsübersicht", "Diese Tabelle fasst alle Bereiche, Bedienoptionen und ihre Wirkung zusammen.", styles)
    rows = [
        ["Bereich", "Option", "Wirkung"],
        ["Kopfzeile", "Theme-Menü", "Wechselt die Darstellung sofort."],
        ["Kopfzeile", "Import", "Öffnet die Auswahl für ZIP oder Export.xml."],
        ["Menüleiste", "Datei / Ansicht / Fenster", "Importiert, exportiert den lokalen PDF-Bericht, öffnet das Design-Studio, zeigt oder verbirgt die Sidebar und steuert das Fenster."],
        ["Übersicht", "Zeitraum", "Beschreibt nur lokale Erfassungstage."],
        ["Übersicht", "4 / 8 / 12 · Dichte", "Legt Kartenzahl und lokale Kartendichte fest."],
        ["Übersicht", "Karte / PDF-Bericht", "Öffnet Fokusansicht bzw. speichert lokal einen PDF-Bericht mit eigener Auswahl."],
        ["Übersicht", "Verlauf auswählen", "Legt unabhängig bis zu vier aktive Typen für den gemeinsamen Verlauf fest."],
        ["Übersicht", "Verlauf / Ringe", "Zeigt mehrere lokale Typen; kein Ziel und keine Bewertung."],
        ["Übersicht", "Pfeile", "Blättert durch weitere ausgewählte Karten."],
        ["Verläufe", "7T / 15T / 30T / 3M / 6M / 1J", "Begrenzt die dargestellten Tage; der Kalender bietet 1W bis 1J inklusive 15T."],
        ["Verläufe", "Datentyp-Menü", "Wechselt die dargestellte Zeitreihe."],
        ["Verläufe", "Punkt / Hover", "Hebt den Punkt hervor bzw. zeigt Datum, Wert und Mini-Trend."],
        ["Quellen", "Zeilen-Schalter", "Aktiviert oder entfernt einen Datentyp."],
        ["Quellen", "Kategorie / Suche", "Filtert die sichtbaren Datentypen."],
        ["Quellen", "Anzeigen &amp; anpinnen", "Zeigt oder verbirgt alle Typen und legt das Ziel für Pin fest."],
        ["Quellen", "Stern / Pfeile", "Pinnt einen Typ für den gewählten Bereich oder ordnet ihn lokal."],
        ["Einblicke", "Datentyp-Menü", "Wechselt die beschreibende Momentaufnahme."],
        ["Design-Studio", "Sprache", "Wechselt Deutsch und English."],
        ["Design-Studio", "Theme-Karten", "Wählt Clear Glass, Midnight Glass, Aurora oder Warmpaper."],
        ["Design-Studio", "Hilfe zum Handbuch", "Öffnet die beiden öffentlichen Handbücher oder bereitet eine allgemeine Frage für einen gewählten KI-Dienst vor; lokale Werte bleiben in HealthAtlas."],
        ["Design-Studio", "App-Aktualisierungen", "Zeigt Version und Build; prüft die öffentliche Release-Liste optional im gewählten Intervall."],
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
    s += cover("HealthAtlas", "Detailed User Manual\nLocal Apple Health visualisation for macOS", "English", "Edition: Beta 1.3.0", styles)
    s += section("Welcome", "HealthAtlas reads an Apple Health export that you choose locally on your Mac. You then decide exactly which recognised data types appear in the dashboard. The app does not diagnose conditions or recommend treatment.", styles,
        bullets_list=[
            "Every normal launch starts without imported health data.",
            "Imported data stays in memory for the current session only. It is not uploaded or sent to an account.",
            "Language, theme, card count and data-type selection are stored separately for the Dev, Beta and Final app variants.",
            "While no personal data is loaded, the start screen also offers the matching GitHub manual and optional AI help. It copies only a general question with the public manual link to the clipboard; health values and local data stay in the app.",
            "Requirement: macOS 26 or later.",
        ], callout_data=("Important", "HealthAtlas describes values and trends. It is not a substitute for professional medical advice, examination or diagnosis.", PINK))
    s += [Spacer(1, 7 * mm), at_a_glance([
        ("Local only", "Imported values remain on this Mac while the current session is open."),
        ("Your choice", "Sources determines which data types are available across the app."),
        ("No diagnosis", "Charts and insights describe data; they do not rate it."),
    ], styles)]
    s += [PageBreak()]
    s += section("Quick start in 5 steps", "The repository includes a fully synthetic demo export for a safe first test. It contains no personal health information and fictional values for every currently supported, non-deprecated Apple Health export type.", styles,
        bullets_list=[
            "Open HealthAtlas. The empty import view presents a central import button.",
            "Click " + '"Import ZIP or Export.xml ..."' + ".",
            "Choose <b>Demo/AppleHealthDemo/Export.xml</b> or your own Apple Health export.",
            "Open <b>Sources</b> after import and turn the data types you want on or off.",
            "Explore the selected data in <b>Overview</b>, <b>Trends</b> and <b>Insights</b>.",
        ], screenshot="final-import.png", caption="Empty start screen with a synthetic test interface. No health values are loaded before import.",
        screenshot_notes=[
            "The central import button opens a local file picker for ZIP or Export.xml only.",
            "The manual and optional AI help appear only before import. The prepared AI question contains no health values.",
        ], screenshot_note_title="Start safely")
    s += [Spacer(1, 3 * mm)] + success_image_block("final-import-success.png", "Import complete", "After a successful import, HealthAtlas confirms that the selected data stays on this Mac. Sources then leads to the selection of displayed data types.", styles)
    s += [PageBreak()]
    s += section("Importing an Apple Health export", "HealthAtlas accepts exactly two local formats: a direct <b>Export.xml</b> file or an Apple Health <b>ZIP</b> archive containing Export.xml. You do not need to unpack the ZIP first; HealthAtlas reads Export.xml locally from the archive.", styles,
        bullets_list=[
            "Direct Export.xml files and ZIP archives can each be up to 5 GiB. The contained Export.xml can also be up to 5 GiB after decompression. These are HealthAtlas safety limits, not Apple Health or macOS limits.", "Only one file can be selected at a time.",
            "HealthAtlas reads the original XML sequentially once. Only relevant interval values are processed further in a temporary local spool for the source rule. Fully identical exported records are counted only once.",
            "<b>Reference measurement:</b> On a Mac Studio M4 Max with 36 GB of RAM, importing a synthetic 500 MB file took about 41 seconds and a 1 GB file took about 1 minute 25 seconds.",
            "<b>Estimated guidance:</b> With similar file contents, near-linear scaling gives about 2:50 minutes for 2 GB, 4:15 minutes for 3 GB, 5:40 minutes for 4 GB and 7:05 minutes for 5 GB. Importing may take longer on other Macs depending on processor, SSD, file contents and current system load.",
            "Steps, distance and active energy use local 15-minute intervals to avoid adding overlapping sources twice. Discrete samples such as heart rate and body mass remain separate; sleep is likewise bounded per interval. Workouts are deduplicated only when their attributes match exactly.",
            "The export does not provide a reproducible Apple source-priority order. HealthAtlas therefore uses a fixed local rule and does not claim identical values to the Health app. Equal coverage uses a stable alphabetical source order that ignores case and diacritics.",
            "The clinical companion file in an Apple Health export is intentionally not imported.",
            "There is no direct HealthKit connection and no cloud import.",
            "For a wrong ZIP, unreadable XML or an oversized file, HealthAtlas explains the issue and imports nothing.",
        ], callout_data=("Export on iPhone", "In Apple Health, open Summary, tap your picture or initials, then select " + '"Export All Health Data"' + ". Apple can change exact interface labels. Source: Apple Support, " + '<font color="#42C5EE">support.apple.com/en-in/guide/iphone/iph5ede58c3d/ios</font>', TEAL), bullet_style_name="CompactBodyHA")
    s += section("Navigation and status", "The frosted sidebar is visible by default in every theme. Before the first local import, its first entry is called " + '"Import"' + "; after a successful import it becomes " + '"Overview"' + ". It shows " + '"Private - Local only"' + " at the bottom as a permanent privacy reminder.", styles,
        bullets_list=[
            "<b>Overview:</b> cards for selected data types.", "<b>Trends:</b> an interactive timeline for one selected type.",
            "<b>Sources:</b> selection of all data types recognised in the import.", "<b>Insights:</b> a descriptive summary for one data type.",
            "<b>Design Studio:</b> language and appearance.",
            "The native menu bar provides import, the local PDF report, Design Studio and window controls. Use <b>View</b> to show or hide the sidebar.",
            "Interactive cards and charts are available as controls for macOS assistive technologies.",
            "The GitHub and Discord icons above the privacy status open the project page and community in the default browser.",
        ])
    s += section("Overview", "After a successful import, Overview shows only the types enabled in Sources. Every card has a type-specific accent colour and graphic treatment. The displayed numbers use the most recent available daily value.", styles,
        bullets_list=[
            "<b>Your period at a glance</b> only describes how many enabled types contain values across the latest seven locally recorded days — never a goal, rating or diagnosis.",
            "Choose <b>4</b>, <b>8</b> or <b>12</b> to control cards per page. <b>Compact</b>, <b>Standard</b> and <b>Focus</b> change card density locally. Drag and drop cards to reorder them; each layout saves its own order and can be reset.",
            "Previous and next controls appear when more selected types exist than fit on one page.",
            "Click a card to open a true full-screen focus view with a trend, period comparison and yearly calendar; <b>Open Trends</b> leads to the detailed view. <b>Exit full screen</b> returns to the app. Before a local PDF report, choose period, data types and report theme; it writes only to a location you choose.",
            "Use <b>Choose timeline ...</b> independently from cards, pins and Sources to select the one to four active types compared in the shared health timeline.",
            "Compact cards reserve a fixed text area for their title. The full Apple name for wrist temperature is shortened to <b>Wrist Temperature</b> there; Sources and detail views keep the full name.",
            "Below the cards, a shared multi-metric timeline and daily rings show recent local values from several types. Rings are neither goals nor ratings. At narrower window sizes, legends remain within their card.",
            "Steps, energy, distance and flights climbed are shown as daily sums. Other numeric types are shown as daily averages.",
            "Name, value, unit and date come from the selected export and follow the app language formatting.",
        ], screenshot="final-overview.png", caption="Overview with synthetic demo data. The shared timeline and local PDF report are configured independently.",
        screenshot_notes=[
            "Choose timeline opens a wide list and changes only the up-to-four lines in the shared timeline.",
            "The local PDF report has its own period, data-type and theme choices. Nothing is uploaded.",
            "Card count, density and order remain separate from the shared-timeline choice.",
        ], screenshot_note_title="New in Overview")
    s += [PageBreak(), Spacer(1, 12 * mm)]
    s += section("Sources", "Sources is the central selection area. It lists every recognised data type with an on/off switch, number of samples and a summary value. Category, search and <b>Show &amp; pin</b> remain visible above the table. The table scrolls vertically when an export contains many types.", styles,
        bullets_list=[
            "<b>Show &amp; pin</b> contains <b>Show all</b>, <b>Show none</b> and the Pin destination.",
            "The switch in each row immediately determines whether a type is available in Overview, Trends and Insights.",
            "Choose <b>Pin for Overview</b>, <b>Trends</b> or <b>Insights</b> from the menu. The star marks a favourite only for that area. Arrows set the order for the current dashboard layout.",
            "For a first personal import, the first four recognised types are selected by default. A compatible earlier selection is reused when its types occur in the new import.",
            "<b>Local data quality</b> counts selection, dated types, local days and samples. It also names missing days in the current local period and types with few values. It does not rate health data.",
            "<b>Replace import</b> opens the local file picker again. <b>Delete all local data</b> clears the current session only after confirmation. The visible import time applies only to the current session.",
        ], screenshot="final-sources.png", caption="Sources with synthetic demo data. This selection controls the content of all other areas.",
        screenshot_notes=[
            "Category, search and Show &amp; pin remain visible above the table.",
            "The menu shows or hides all data types and selects the Pin destination.",
            "Local data quality describes coverage and imported values only.",
        ], screenshot_note_title="Selection and order")
    s += [Spacer(1, 3 * mm)] + detail_image_block("final-sources-menu.png", "Show &amp; pin", "The menu contains Show all, Show none and Pin for Overview, Trends or Insights. The star in a row then sets the Pin for the selected area.", styles)
    s += [PageBreak(), Spacer(1, 12 * mm)]
    s += section("Trends", "This section visualises one active type according to its local format: bars for steps and energy, an area for sleep, and a line for other numeric types. Select a period first, then choose one of the enabled types in the menu.", styles,
        bullets_list=[
            "<b>7D</b>: last 7 days.", "<b>15D</b>: last 15 days.", "<b>30D</b>: last 30 days.", "<b>3M</b>: last 90 days.", "<b>6M</b>: last 182 days.", "<b>1Y</b>: last 365 days.",
            "Hover a point to reveal a floating value card with date, formatted value and mini-trend. Clicking also gives that point a gently pulsing marker. Factual highlights can name the highest local value in the period or the number of dates with data.",
            "A local comparison places the current and immediately preceding periods side by side. It is not a rating or diagnosis.",
            "The local data calendar sits in a separate panel below the chart so day cells and line animation remain clearly separated. It offers 1 week, 15 days, 4 weeks, 3 months, 6 months or 1 year. Click a day to see its local date and value.",
            "If fewer than two values exist in the selected period, the chart reports that there are not enough values.",
        ], screenshot="final-trends.png", caption="Trend with synthetic demo data. The 15-day period is available for both the trend and the data calendar.",
        screenshot_notes=[
            "15D joins the existing ranges in the upper trend control.",
            "The calendar has a dedicated 15-day option alongside 1 week, 4 weeks, 3 months, 6 months and 1 year.",
            "A chart point or calendar day reveals local details for the selected date only.",
        ], screenshot_note_title="Ranges and calendar")
    s += [PageBreak()]
    s += section("Insights", "Insights condenses one enabled data type into a local descriptive snapshot. Choose the type from the menu. The view shows the latest daily value, its date, local coverage and a recording pattern; it intentionally contains no detailed trend or data calendar.", styles,
        bullets_list=[
            "Local coverage only names days with and without a value in the current short period. The pattern names the most frequently recorded weekday. Neither is a rating.",
            "<b>Local pattern</b> only describes which weekday has the most locally recorded dates — not health or behaviour.",
            "The screen does not supply normal ranges, alerts, ratings or medical conclusions.",
            "If only one dated value is available, the app states this clearly.",
        ], screenshot="final-insights.png", caption="Insights with synthetic demo data. The card is a descriptive summary, not a diagnosis.",
        screenshot_notes=[
            "The menu selects the enabled data type to summarise.",
            "Snapshot, local coverage and recording pattern are descriptive, not a medical assessment.",
        ], screenshot_note_title="Descriptive insights")
    s += [PageBreak()]
    s += section("Design Studio", "Design Studio groups Appearance, Manual help and App updates into three sections. Changes take effect immediately and are stored locally for the current app variant.", styles,
        bullets_list=[
            "<b>Language:</b> Deutsch or English. Navigation, labels and known data-type names change with the selection.",
            "<b>Themes:</b> Clear Glass combines a frosted layer with a calm cyan, blue, violet and pink glow; Midnight Glass is dark blue, Aurora teal and Warmpaper warm red-violet. The selected theme has an outline.",
            "Cards and pages use gentle transitions. Clear Glass adds very subtle motion, substantially reduced or paused with macOS Reduce Motion and while importing.",
            "HealthAtlas opens in 16:9 and remains freely resizable afterwards. The layout adapts to the selected window size.",
            "Under <b>Manual help</b>, <b>German manual</b> and <b>English manual</b> open the two public manuals separately.",
            "ChatGPT, Gemini and Claude copy only a general question with the matching public manual link to the clipboard after your click, then open the selected service. No local or imported health data is sent; only Cmd+V lets you decide whether to paste it.",
            "Under <b>App updates</b>, HealthAtlas shows the installed version and build number. Checking the public GitHub release list is optional: manually, at every launch, daily, weekly or monthly.",
            "An update check never sends health data. When a matching newer release is available, its GitHub page opens only after an explicit click.",
        ], screenshot="final-design-studio.png", caption="Design Studio with Appearance, Manual help and App updates. Manual help and the optional update check use public links only.",
        screenshot_notes=[
            "An outline marks the selected theme.",
            "The two manual buttons open the public manuals separately.",
            "The three services receive only a general manual question, never local values.",
            "Automatic checks remain optional and query only the public release list.",
        ], screenshot_note_title="Manual help and updates")
    s += [PageBreak(), Spacer(1, 12 * mm)]
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
            "Open the app normally once. macOS blocks the launch.",
            "Open System Settings > Privacy & Security, scroll to Security and choose " + '"Open Anyway"' + " for that exact HealthAtlas build.",
            "Confirm the warning with " + '"Open"' + " and authenticate if macOS asks. " + '"Open Anyway"' + " is shown only for a limited time after the blocked launch attempt.",
            "This creates an exception only for that build; do not disable Gatekeeper system-wide. Open only a build from the official HealthAtlas GitHub release.",
            "For import errors, confirm that the ZIP contains Export.xml, the file is not empty, is within the 5 GiB HealthAtlas limit and is stored locally.",
            "If no values appear, enable at least one type in Sources. Trends need at least two daily values in the chosen period.",
        ], callout_data=("Build variants", "Dev, Beta and Final use separate local preferences. A theme or selection in Dev does not alter the settings of a Beta or Final app.", GOLD))
    s += [PageBreak()]
    s += section("Complete control reference", "This table summarises every current area, control and outcome.", styles)
    rows = [
        ["Area", "Control", "Outcome"],
        ["Header", "Theme menu", "Changes appearance immediately."], ["Header", "Import", "Opens ZIP or Export.xml picker."],
        ["Menu bar", "File / View / Window", "Imports, exports the local PDF report, opens Design Studio, shows or hides the sidebar, and controls the window."],
        ["Overview", "Period", "Describes only local recording days."], ["Overview", "4 / 8 / 12 · density", "Sets card count and local card density."], ["Overview", "Arrows", "Moves through additional selected cards."],
        ["Overview", "Card / PDF report", "Opens the focus view or saves a local PDF report with its own choices."],
        ["Overview", "Choose timeline", "Independently selects up to four active types for the shared timeline."],
        ["Overview", "Timeline / rings", "Shows several local types; no goal or rating."],
        ["Trends", "7D / 15D / 30D / 3M / 6M / 1Y", "Limits displayed days; the calendar offers 1 week to 1 year including 15 days."], ["Trends", "Data type menu", "Changes the displayed timeline."],
        ["Trends", "Data point / hover", "Highlights a point or shows date, value and mini-trend."], ["Sources", "Row switch", "Enables or removes one type."],
        ["Sources", "Category / search", "Filters the visible data types."],
        ["Sources", "Show &amp; pin", "Shows or hides all types and selects the Pin destination."],
        ["Sources", "Star / arrows", "Pins a type for the selected area or orders it locally."], ["Insights", "Data type menu", "Changes the descriptive snapshot."],
        ["Design Studio", "Language", "Switches Deutsch and English."], ["Design Studio", "Theme cards", "Selects Clear Glass, Midnight Glass, Aurora or Warmpaper."],
        ["Design Studio", "Manual help", "Opens the public manuals or prepares a general question for a chosen AI service; local values stay in HealthAtlas."],
        ["Design Studio", "App updates", "Shows version and build; optionally checks the public release list on the selected schedule."],
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
