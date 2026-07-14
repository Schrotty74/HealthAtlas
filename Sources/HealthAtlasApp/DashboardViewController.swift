import AppKit
import SwiftUI
import UniformTypeIdentifiers

private extension Array {
    func chunked(into size: Int) -> [[Element]] {
        stride(from: 0, to: count, by: size).map { Array(self[$0 ..< Swift.min($0 + size, count)]) }
    }
}

final class DashboardViewController: NSViewController {
    private let sidebar = SidebarViewController()
    private let workspace = HealthWorkspaceViewController()

    override func loadView() {
        let root = NSView()
        root.wantsLayer = true
        root.layer?.backgroundColor = NSColor.clear.cgColor
        view = root

        addChild(sidebar)
        addChild(workspace)
        let sidebarView = sidebar.view
        let workspaceView = workspace.view
        sidebarView.translatesAutoresizingMaskIntoConstraints = false
        workspaceView.translatesAutoresizingMaskIntoConstraints = false
        root.addSubview(sidebarView)
        root.addSubview(workspaceView)
        NSLayoutConstraint.activate([
            sidebarView.leadingAnchor.constraint(equalTo: root.leadingAnchor),
            sidebarView.topAnchor.constraint(equalTo: root.topAnchor),
            sidebarView.bottomAnchor.constraint(equalTo: root.bottomAnchor),
            sidebarView.widthAnchor.constraint(equalToConstant: 236),
            workspaceView.leadingAnchor.constraint(equalTo: sidebarView.trailingAnchor),
            workspaceView.topAnchor.constraint(equalTo: root.topAnchor),
            workspaceView.bottomAnchor.constraint(equalTo: root.bottomAnchor),
            workspaceView.trailingAnchor.constraint(equalTo: root.trailingAnchor)
        ])
        sidebar.onSelection = { [weak self] section in self?.workspace.show(section: section) }
        workspace.onThemeChanged = { [weak self] theme in self?.sidebar.apply(theme: theme) }
        workspace.onLanguageChanged = { [weak self] in self?.sidebar.apply(theme: .current) }
        if let value = ProcessInfo.processInfo.environment["HEALTHATLAS_SCREENSHOT_SECTION"],
           let section = DashboardSection.allCases.first(where: { String(describing: $0) == value }) {
            workspace.show(section: section)
        }
    }
}

private enum DashboardSection: Int, CaseIterable {
    case overview, trends, sources, insights, settings

    var symbol: String {
        switch self {
        case .overview: "square.grid.2x2.fill"
        case .trends: "chart.line.uptrend.xyaxis"
        case .sources: "externaldrive.fill"
        case .insights: "sparkles"
        case .settings: "slider.horizontal.3"
        }
    }

    func title(for language: AppLanguage) -> String {
        switch self {
        case .overview: language.text(english: "Overview", german: "Übersicht")
        case .trends: language.text(english: "Trends", german: "Verläufe")
        case .sources: language.text(english: "Sources", german: "Quellen")
        case .insights: language.text(english: "Insights", german: "Einblicke")
        case .settings: language.text(english: "Design Studio", german: "Design-Studio")
        }
    }
}

private final class SidebarViewController: NSViewController {
    var onSelection: ((DashboardSection) -> Void)?
    private var selectedSection: DashboardSection = .overview
    private var sidebarRoot: NativeTransparentSidebarRootView<SidebarLiquidGlassView>!

    override func loadView() {
        sidebarRoot = NativeTransparentSidebarRootView()
        sidebarRoot.setRootView(makeSidebar())
        view = sidebarRoot
    }

    func apply(theme: AppTheme) {
        // Die komplette Spalte bleibt auf jedem Theme dieselbe native Liquid-Glass-Fläche.
        // Nur der Arbeitsbereich wechselt seine Hintergrundfarben.
        refresh()
    }

    private func select(_ section: DashboardSection) {
        selectedSection = section
        refresh()
        onSelection?(section)
    }

    private func refresh() {
        sidebarRoot?.setRootView(makeSidebar())
    }

    private func makeSidebar() -> SidebarLiquidGlassView {
        SidebarLiquidGlassView(selectedSection: selectedSection) { [weak self] section in
            self?.select(section)
        }
    }
}

/// SwiftUI-Inhalt der Sidebar. Die Transparenz kommt von der AppKit-Wurzelansicht
/// darunter, damit sie über jede gewählte Arbeitsbereichsoberfläche hinweg wirkt.
@available(macOS 26.0, *)
private struct SidebarLiquidGlassView: View {
    let selectedSection: DashboardSection
    let onSelection: (DashboardSection) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 12) {
                Image(systemName: "heart.text.square.fill")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundStyle(.pink)
                VStack(alignment: .leading, spacing: 2) {
                    Text("HealthAtlas")
                        .font(.system(size: 21, weight: .bold))
                    Text(AppLanguage.current.text(english: "Health, in your hands", german: "Gesundheit in deiner Hand"))
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(.white.opacity(0.72))
                }
            }
            .padding(.top, 27)
            .padding(.horizontal, 22)

            VStack(spacing: 7) {
                ForEach(DashboardSection.allCases, id: \.rawValue) { section in
                    Button { onSelection(section) } label: {
                        HStack(spacing: 12) {
                            Image(systemName: section.symbol)
                                .frame(width: 19)
                            Text(section.title(for: .current))
                            Spacer(minLength: 0)
                        }
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(section == selectedSection ? Color.black.opacity(0.82) : .white)
                        .padding(.horizontal, 16)
                        .frame(height: 44)
                        .background(section == selectedSection ? Color.yellow : Color.clear, in: RoundedRectangle(cornerRadius: 13, style: .continuous))
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 14)
            .padding(.top, 32)

            Spacer(minLength: 0)

            Label(AppLanguage.current.text(english: "Private · Local only", german: "Privat · Nur lokal"), systemImage: "circle.fill")
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(.green)
                .padding(.horizontal, 22)
                .padding(.bottom, 23)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .contentShape(Rectangle())
        .preferredColorScheme(.dark)
    }
}

/// Native AppKit-Milchglasfläche wie in FileAtlas. Der Hintergrund wird dabei
/// weichgezeichnet, statt als scharfes Bild unter einem Farbfilter durchzuscheinen.
private final class NativeTransparentSidebarRootView<Content: View>: NSVisualEffectView {
    private var hostingView: NSHostingView<Content>?
    private var isReconfigureScheduled = false

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        configureGlass()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configureGlass()
    }

    override func viewDidMoveToWindow() {
        super.viewDidMoveToWindow()
        scheduleReconfigure()
    }

    override func layout() {
        super.layout()
        scheduleReconfigure()
    }

    func setRootView(_ rootView: Content) {
        if let hostingView {
            hostingView.rootView = rootView
        } else {
            let hostingView = NSHostingView(rootView: rootView)
            hostingView.translatesAutoresizingMaskIntoConstraints = false
            hostingView.wantsLayer = true
            hostingView.layer?.backgroundColor = NSColor.clear.cgColor
            addSubview(hostingView)
            NSLayoutConstraint.activate([
                hostingView.leadingAnchor.constraint(equalTo: leadingAnchor),
                hostingView.trailingAnchor.constraint(equalTo: trailingAnchor),
                hostingView.topAnchor.constraint(equalTo: topAnchor),
                hostingView.bottomAnchor.constraint(equalTo: bottomAnchor)
            ])
            self.hostingView = hostingView
        }
        scheduleReconfigure()
    }

    func scheduleReconfigure() {
        guard !isReconfigureScheduled else { return }
        isReconfigureScheduled = true
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            self.isReconfigureScheduled = false
            self.reconfigureSidebar()
        }
    }

    private func configureGlass() {
        material = .sidebar
        blendingMode = .behindWindow
        state = .active
        wantsLayer = true
        layer?.backgroundColor = NSColor.clear.cgColor
    }

    private func reconfigureSidebar() {
        configureGlass()
        hostingView?.layer?.backgroundColor = NSColor.clear.cgColor
        clearHostedSwiftUIBackgrounds(in: self)
    }

    private func clearHostedSwiftUIBackgrounds(in view: NSView) {
        if let scrollView = view as? NSScrollView {
            scrollView.drawsBackground = false
            scrollView.backgroundColor = .clear
        }
        if let clipView = view as? NSClipView {
            clipView.drawsBackground = false
            clipView.backgroundColor = .clear
        }
        if let tableView = view as? NSTableView {
            tableView.backgroundColor = .clear
            tableView.usesAlternatingRowBackgroundColors = false
        }
        if let effectView = view as? NSVisualEffectView, effectView !== self {
            effectView.material = .sidebar
            effectView.blendingMode = .behindWindow
            effectView.state = .active
        }
        view.wantsLayer = true
        if view !== self {
            view.layer?.backgroundColor = NSColor.clear.cgColor
        }
        view.subviews.forEach { clearHostedSwiftUIBackgrounds(in: $0) }
    }
}

private final class HealthWorkspaceViewController: NSViewController {
    var onThemeChanged: ((AppTheme) -> Void)?
    var onLanguageChanged: (() -> Void)?
    private let backdrop = GradientBackdropView()
    private let clearGlassEffect = NSVisualEffectView()
    private let titleLabel = NSTextField(labelWithString: "")
    private let subtitleLabel = NSTextField(labelWithString: "")
    private let statusLabel = NSTextField(labelWithString: "")
    private let importButton = NSButton(title: "", target: nil, action: nil)
    private let themeButton = NSPopUpButton()
    private let body = NSStackView()
    private var selectedSection: DashboardSection = .overview
    private var importedSummary: ImportedHealthSummary?
    private var selectedTypeIDs = Set<String>()
    private let selectedTypeIDsPreferenceKey = "HealthAtlas.selectedHealthTypeIDs"
    private var selectedTrendTypeID: String?
    private var selectedTrendDate: Date?
    private var selectedInsightTypeID: String?
    private var trendRangeDays = 30
    private var overviewPage = 0
    private var overviewPageSize: Int {
        get {
            let stored = BuildEnvironment.defaults.integer(forKey: "HealthAtlas.overviewPageSize")
            return [4, 8, 12].contains(stored) ? stored : 8
        }
        set { BuildEnvironment.defaults.set(newValue, forKey: "HealthAtlas.overviewPageSize") }
    }

    override func loadView() {
        view = backdrop
        backdrop.apply(theme: .current)
        configureClearGlassSurface(for: .current)
        titleLabel.font = .systemFont(ofSize: 30, weight: .bold)
        titleLabel.textColor = .white
        subtitleLabel.font = .systemFont(ofSize: 13, weight: .medium)
        subtitleLabel.textColor = NSColor.white.withAlphaComponent(0.72)
        statusLabel.font = .systemFont(ofSize: 11, weight: .bold)
        statusLabel.textColor = .systemGreen

        importButton.bezelStyle = .rounded
        importButton.controlSize = .large
        importButton.target = self
        importButton.action = #selector(importFile)
        importButton.contentTintColor = .white
        themeButton.addItems(withTitles: AppTheme.allCases.map(\.displayName))
        themeButton.selectItem(withTitle: AppTheme.current.displayName)
        themeButton.target = self
        themeButton.action = #selector(themeChanged(_:))

        let heading = NSStackView(views: [titleLabel, subtitleLabel])
        heading.orientation = .vertical
        heading.spacing = 4
        heading.translatesAutoresizingMaskIntoConstraints = false
        let controls = NSStackView(views: [themeButton, importButton])
        controls.spacing = 10
        controls.translatesAutoresizingMaskIntoConstraints = false

        body.orientation = .vertical
        body.spacing = 16
        body.translatesAutoresizingMaskIntoConstraints = false
        body.alignment = .leading
        clearGlassEffect.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(clearGlassEffect)
        view.addSubview(heading)
        view.addSubview(controls)
        view.addSubview(body)
        NSLayoutConstraint.activate([
            clearGlassEffect.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            clearGlassEffect.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            clearGlassEffect.topAnchor.constraint(equalTo: view.topAnchor),
            clearGlassEffect.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            heading.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 34),
            heading.topAnchor.constraint(equalTo: view.topAnchor, constant: 31),
            heading.trailingAnchor.constraint(lessThanOrEqualTo: controls.leadingAnchor, constant: -18),
            controls.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -34),
            controls.centerYAnchor.constraint(equalTo: heading.centerYAnchor),
            body.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 34),
            body.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -34),
            body.topAnchor.constraint(equalTo: heading.bottomAnchor, constant: 25),
            body.bottomAnchor.constraint(lessThanOrEqualTo: view.bottomAnchor, constant: -28)
        ])
        loadScreenshotDemoIfRequested()
        rebuildBody()
    }

    func show(section: DashboardSection) {
        selectedSection = section
        rebuildBody()
    }

    @objc private func themeChanged(_ sender: NSPopUpButton) {
        guard let title = sender.titleOfSelectedItem, let theme = AppTheme.allCases.first(where: { $0.displayName == title }) else { return }
        theme.save()
        backdrop.apply(theme: theme)
        configureClearGlassSurface(for: theme)
        onThemeChanged?(theme)
    }

    private func configureClearGlassSurface(for theme: AppTheme) {
        clearGlassEffect.isHidden = theme != .clearGlass
        guard theme == .clearGlass else { return }
        clearGlassEffect.material = .underWindowBackground
        clearGlassEffect.blendingMode = .behindWindow
        clearGlassEffect.state = .active
        clearGlassEffect.wantsLayer = true
        clearGlassEffect.layer?.backgroundColor = NSColor.systemBlue.withAlphaComponent(0.14).cgColor
    }

    private func rebuildBody() {
        body.arrangedSubviews.forEach { body.removeArrangedSubview($0); $0.removeFromSuperview() }
        let language = AppLanguage.current
        titleLabel.stringValue = selectedSection.title(for: language)
        subtitleLabel.stringValue = language.text(english: "A calm, visual view of your health — on this Mac.", german: "Eine ruhige, visuelle Sicht auf deine Gesundheit — auf diesem Mac.")
        statusLabel.stringValue = "●  " + language.text(english: "LOCAL ONLY · No account, cloud sync, analytics or tracking", german: "NUR LOKAL · Kein Konto, Cloud-Sync, Analytics oder Tracking")
        importButton.title = language.text(english: "Import Apple Health…", german: "Apple Health importieren …")
        importButton.isHidden = importedSummary == nil
        body.addArrangedSubview(statusLabel)

        switch selectedSection {
        case .overview: buildOverview()
        case .trends: buildTrends()
        case .sources: buildSources()
        case .insights: buildInsights()
        case .settings: buildSettings()
        }
    }

    private func buildOverview() {
        guard importedSummary != nil else {
            body.addArrangedSubview(emptyImportState())
            return
        }
        let selectedTypes = selectedDataTypes()
        let sourceMessage = NSTextField(labelWithString: AppLanguage.current.text(
            english: "Apple Health is loaded locally. \(selectedTypes.count) selected data types are shown below.",
            german: "Apple Health ist lokal geladen. \(selectedTypes.count) ausgewählte Datentypen werden unten angezeigt."
        ))
        sourceMessage.textColor = NSColor.white.withAlphaComponent(0.72)
        sourceMessage.font = .systemFont(ofSize: 12, weight: .medium)
        body.addArrangedSubview(sourceMessage)
        let metrics = visibleMetrics()
        let displayControl = NSSegmentedControl(labels: ["4", "8", "12"], trackingMode: .selectOne, target: self, action: #selector(overviewPageSizeChanged(_:)))
        displayControl.selectedSegment = [4, 8, 12].firstIndex(of: overviewPageSize) ?? 1
        displayControl.segmentStyle = .texturedRounded
        let displayRow = NSStackView(views: [
            NSTextField(labelWithString: AppLanguage.current.text(english: "Cards shown", german: "Angezeigte Karten")),
            displayControl
        ])
        displayRow.spacing = 10
        displayRow.alignment = .centerY
        body.addArrangedSubview(displayRow)
        let pageCount = max(1, Int(ceil(Double(metrics.count) / Double(overviewPageSize))))
        overviewPage = min(overviewPage, pageCount - 1)
        let start = overviewPage * overviewPageSize
        let metricsGrid = metricGrid(metrics: Array(metrics.dropFirst(start).prefix(overviewPageSize)))
        body.addArrangedSubview(metricsGrid)
        metricsGrid.widthAnchor.constraint(equalTo: body.widthAnchor).isActive = true
        if pageCount > 1 {
            body.addArrangedSubview(overviewPagination(pageCount: pageCount))
        }

    }

    private func buildTrends() {
        guard importedSummary != nil else {
            body.addArrangedSubview(emptyImportState())
            return
        }
        let range = segmentedControl(labels: ["7D", "30D", "3M", "1Y"])
        range.selectedSegment = [7, 30, 90, 365].firstIndex(of: trendRangeDays) ?? 1
        range.target = self
        range.action = #selector(trendRangeChanged(_:))
        body.addArrangedSubview(range)
        let selectedTypes = selectedDataTypes()
        guard let metric = selectedTrendMetric(from: selectedTypes) else {
            body.addArrangedSubview(emptySelectionState())
            return
        }
        let metricAccent = accent(for: accentKey(for: metric.identifier))
        let card = GlassCardView(accent: metricAccent)
        let typePicker = NSPopUpButton()
        typePicker.addItems(withTitles: selectedTypes.map(\.localizedDisplayName))
        typePicker.selectItem(withTitle: metric.localizedDisplayName)
        typePicker.target = self
        typePicker.action = #selector(trendTypeChanged(_:))
        let name = NSTextField(labelWithString: "\(metric.localizedDisplayName) · \(trendRangeDays)D")
        name.font = .systemFont(ofSize: 17, weight: .bold)
        name.textColor = .white
        let points = trendPoints(for: metric)
        let detail = NSTextField(labelWithString: selectedTrendPoint(from: points)?.detail(for: metric) ?? AppLanguage.current.text(english: "Click a point for its value", german: "Klicke auf einen Punkt für den Wert"))
        detail.font = .systemFont(ofSize: 12, weight: .semibold)
        detail.textColor = metricAccent
        let graph = TrendGraphView(points: points, tintColor: metricAccent, showsPoints: true) { [weak self] point in
            self?.selectedTrendDate = point.date
            self?.rebuildBody()
        }
        let stack = NSStackView(views: [typePicker, name, detail, graph])
        stack.orientation = .vertical
        stack.spacing = 14
        stack.edgeInsets = NSEdgeInsets(top: 20, left: 22, bottom: 20, right: 22)
        stack.translatesAutoresizingMaskIntoConstraints = false
        let background = MetricCardBackgroundView(title: metric.localizedDisplayName, accent: metricAccent)
        background.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(background)
        card.addSubview(stack)
        NSLayoutConstraint.activate([
            background.leadingAnchor.constraint(equalTo: card.leadingAnchor), background.trailingAnchor.constraint(equalTo: card.trailingAnchor),
            background.topAnchor.constraint(equalTo: card.topAnchor), background.bottomAnchor.constraint(equalTo: card.bottomAnchor),
            stack.leadingAnchor.constraint(equalTo: card.leadingAnchor), stack.trailingAnchor.constraint(equalTo: card.trailingAnchor),
            stack.topAnchor.constraint(equalTo: card.topAnchor), stack.bottomAnchor.constraint(equalTo: card.bottomAnchor),
            graph.heightAnchor.constraint(equalToConstant: 270)
        ])
        body.addArrangedSubview(card)
        card.widthAnchor.constraint(equalTo: body.widthAnchor).isActive = true
    }

    private func buildSources() {
        let description = NSTextField(labelWithString: importedSummary == nil
            ? AppLanguage.current.text(english: "Import Apple Health to choose which recognised data types are shown.", german: "Importiere Apple Health, um erkannte Datentypen für die Anzeige auszuwählen.")
            : AppLanguage.current.text(english: "Every recognised local data type is listed below. Your selected types are used across the dashboard.", german: "Jeder lokal erkannte Datentyp steht unten. Deine Auswahl wird im gesamten Dashboard verwendet."))
        description.font = .systemFont(ofSize: 12, weight: .medium)
        description.textColor = NSColor.white.withAlphaComponent(0.75)
        body.addArrangedSubview(description)
        guard let importedSummary else { return }
        let panel = MetricSelectionPanel(metrics: importedSummary.dataTypes, selectedIDs: selectedTypeIDs) { [weak self] selection in
            self?.selectedTypeIDs = selection
            self?.overviewPage = 0
            BuildEnvironment.defaults.set(Array(selection), forKey: self?.selectedTypeIDsPreferenceKey ?? "HealthAtlas.selectedHealthTypeIDs")
        }
        panel.translatesAutoresizingMaskIntoConstraints = false
        body.addArrangedSubview(panel)
        panel.widthAnchor.constraint(equalTo: body.widthAnchor).isActive = true
        panel.heightAnchor.constraint(equalToConstant: 420).isActive = true
    }

    private func buildInsights() {
        let intro = NSTextField(labelWithString: AppLanguage.current.text(english: "Descriptive local summaries — never diagnoses.", german: "Beschreibende lokale Zusammenfassungen — niemals Diagnosen."))
        intro.font = .systemFont(ofSize: 12, weight: .bold)
        intro.textColor = .systemPink
        body.addArrangedSubview(intro)
        let metrics = selectedDataTypes().filter { !$0.dailyValues.isEmpty }
        guard let metric = selectedInsightMetric(from: metrics) else {
            body.addArrangedSubview(emptySelectionState())
            return
        }
        let picker = NSPopUpButton()
        picker.addItems(withTitles: metrics.map(\.localizedDisplayName))
        picker.selectItem(withTitle: metric.localizedDisplayName)
        picker.target = self
        picker.action = #selector(insightTypeChanged(_:))
        body.addArrangedSubview(picker)

        let metricAccent = accent(for: accentKey(for: metric.identifier))
        let card = GlassCardView(accent: metricAccent)
        let background = MetricCardBackgroundView(title: metric.localizedDisplayName, accent: metricAccent)
        background.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(background)
        let latest = metric.latestValueText
        let changeText: String
        if metric.dailyValues.count >= 2 {
            let current = metric.displayValue(for: metric.dailyValues[metric.dailyValues.count - 1])
            let previous = metric.displayValue(for: metric.dailyValues[metric.dailyValues.count - 2])
            let difference = current - previous
            let sign = difference >= 0 ? "+" : ""
            changeText = AppLanguage.current.text(english: "Change from previous value: \(sign)\(metric.formattedValue(difference))", german: "Änderung zum vorherigen Wert: \(sign)\(metric.formattedValue(difference))")
        } else {
            changeText = AppLanguage.current.text(english: "Only one dated value is available.", german: "Es liegt ein datierter Wert vor.")
        }
        let title = NSTextField(labelWithString: metric.localizedDisplayName)
        title.font = .systemFont(ofSize: 22, weight: .bold)
        title.textColor = .white
        let value = NSTextField(labelWithString: latest)
        value.font = .systemFont(ofSize: 38, weight: .bold)
        value.textColor = .white
        let detail = NSTextField(labelWithString: "\(metric.latestDetailText) · \(changeText)")
        detail.font = .systemFont(ofSize: 13, weight: .medium)
        detail.textColor = NSColor.white.withAlphaComponent(0.78)
        let graph = TrendGraphView(points: metric.dailyValues.suffix(14).map { HealthTrendPoint(date: $0.date, value: metric.displayValue(for: $0)) }, tintColor: metricAccent, showsPoints: false) { _ in }
        let stack = NSStackView(views: [title, value, detail, graph])
        stack.orientation = .vertical
        stack.spacing = 8
        stack.edgeInsets = NSEdgeInsets(top: 22, left: 24, bottom: 20, right: 24)
        stack.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(stack)
        NSLayoutConstraint.activate([
            background.leadingAnchor.constraint(equalTo: card.leadingAnchor), background.trailingAnchor.constraint(equalTo: card.trailingAnchor), background.topAnchor.constraint(equalTo: card.topAnchor), background.bottomAnchor.constraint(equalTo: card.bottomAnchor),
            stack.leadingAnchor.constraint(equalTo: card.leadingAnchor), stack.trailingAnchor.constraint(equalTo: card.trailingAnchor), stack.topAnchor.constraint(equalTo: card.topAnchor), stack.bottomAnchor.constraint(equalTo: card.bottomAnchor),
            graph.heightAnchor.constraint(equalToConstant: 150), card.heightAnchor.constraint(equalToConstant: 310)
        ])
        body.addArrangedSubview(card)
        card.widthAnchor.constraint(equalTo: body.widthAnchor).isActive = true
    }

    private func buildSettings() {
        let label = NSTextField(labelWithString: AppLanguage.current.text(english: "Appearance", german: "Erscheinungsbild"))
        label.font = .systemFont(ofSize: 16, weight: .bold)
        label.textColor = .white
        body.addArrangedSubview(label)
        let languageButton = NSPopUpButton()
        languageButton.addItems(withTitles: AppLanguage.allCases.map(\.displayName))
        languageButton.selectItem(withTitle: AppLanguage.current.displayName)
        languageButton.target = self
        languageButton.action = #selector(languageChanged(_:))
        let languageRow = NSStackView(views: [
            NSTextField(labelWithString: AppLanguage.current.text(english: "Language", german: "Sprache")),
            languageButton
        ])
        languageRow.spacing = 10
        languageRow.alignment = .centerY
        body.addArrangedSubview(languageRow)
        let row = NSStackView()
        row.orientation = .horizontal
        row.distribution = .fillEqually
        row.spacing = 12
        for theme in AppTheme.allCases {
            let card = NSButton(title: theme.displayName, target: self, action: #selector(themeTileSelected(_:)))
            card.identifier = NSUserInterfaceItemIdentifier(theme.rawValue)
            card.bezelStyle = .rounded
            card.contentTintColor = theme.accent
            card.wantsLayer = true
            card.layer?.backgroundColor = theme.previewColor.cgColor
            card.layer?.cornerRadius = 14
            card.heightAnchor.constraint(equalToConstant: 104).isActive = true
            row.addArrangedSubview(card)
        }
        row.translatesAutoresizingMaskIntoConstraints = false
        body.addArrangedSubview(row)
        row.widthAnchor.constraint(equalTo: body.widthAnchor).isActive = true
        let note = NSTextField(wrappingLabelWithString: AppLanguage.current.text(english: "Clear Glass keeps the blue surface slightly transparent. The sidebar is a translucent glass layer in every theme.", german: "Clear Glass hält die blaue Oberfläche leicht durchscheinend. Die Sidebar bleibt in jedem Theme eine transparente Glasfläche."))
        note.font = .systemFont(ofSize: 12, weight: .medium)
        note.textColor = NSColor.white.withAlphaComponent(0.75)
        body.addArrangedSubview(note)
        note.widthAnchor.constraint(equalTo: body.widthAnchor).isActive = true
    }

    @objc private func themeTileSelected(_ sender: NSButton) {
        guard let id = sender.identifier?.rawValue, let theme = AppTheme(rawValue: id) else { return }
        themeButton.selectItem(withTitle: theme.displayName)
        theme.save()
        backdrop.apply(theme: theme)
        configureClearGlassSurface(for: theme)
        onThemeChanged?(theme)
    }

    @objc private func languageChanged(_ sender: NSPopUpButton) {
        guard let title = sender.titleOfSelectedItem,
              let language = AppLanguage.allCases.first(where: { $0.displayName == title }) else { return }
        language.save()
        onLanguageChanged?()
        rebuildBody()
    }

    @objc private func trendRangeChanged(_ sender: NSSegmentedControl) {
        trendRangeDays = [7, 30, 90, 365][sender.selectedSegment]
        selectedTrendDate = nil
        rebuildBody()
    }

    @objc private func trendTypeChanged(_ sender: NSPopUpButton) {
        selectedTrendTypeID = selectedDataTypes().first(where: { $0.localizedDisplayName == sender.titleOfSelectedItem })?.identifier
        selectedTrendDate = nil
        rebuildBody()
    }

    @objc private func insightTypeChanged(_ sender: NSPopUpButton) {
        selectedInsightTypeID = selectedDataTypes().first(where: { $0.localizedDisplayName == sender.titleOfSelectedItem })?.identifier
        rebuildBody()
    }

    @objc private func previousOverviewPage() {
        overviewPage = max(0, overviewPage - 1)
        rebuildBody()
    }

    @objc private func nextOverviewPage() {
        overviewPage += 1
        rebuildBody()
    }

    @objc private func overviewPageSizeChanged(_ sender: NSSegmentedControl) {
        overviewPageSize = [4, 8, 12][sender.selectedSegment]
        overviewPage = 0
        rebuildBody()
    }

    private func visibleMetrics() -> [HealthMetric] {
        guard importedSummary != nil else { return [] }
        let selected = selectedDataTypes()
        return selected.map { item in
            HealthMetric(title: item.localizedDisplayName, value: item.latestValueText, detail: item.latestDetailText, color: accentKey(for: item.identifier))
        }
    }

    private func selectedDataTypes() -> [HealthDataTypeSummary] {
        guard let importedSummary else { return [] }
        return importedSummary.dataTypes.filter { selectedTypeIDs.contains($0.identifier) }
    }

    private func selectedTrendMetric(from metrics: [HealthDataTypeSummary]) -> HealthDataTypeSummary? {
        if let selectedTrendTypeID,
           let metric = metrics.first(where: { $0.identifier == selectedTrendTypeID && !$0.dailyValues.isEmpty }) {
            return metric
        }
        return metrics.first(where: { !$0.dailyValues.isEmpty })
    }

    private func selectedInsightMetric(from metrics: [HealthDataTypeSummary]) -> HealthDataTypeSummary? {
        if let selectedInsightTypeID, let metric = metrics.first(where: { $0.identifier == selectedInsightTypeID }) { return metric }
        return metrics.first
    }

    private func trendPoints(for metric: HealthDataTypeSummary) -> [HealthTrendPoint] {
        let cutoff = Calendar.current.date(byAdding: .day, value: -trendRangeDays + 1, to: Date()) ?? .distantPast
        return metric.dailyValues
            .filter { $0.date >= cutoff }
            .map { HealthTrendPoint(date: $0.date, value: metric.displayValue(for: $0)) }
    }

    private func selectedTrendPoint(from points: [HealthTrendPoint]) -> HealthTrendPoint? {
        guard let selectedTrendDate else { return nil }
        return points.first(where: { Calendar.current.isDate($0.date, inSameDayAs: selectedTrendDate) })
    }

    private func overviewPagination(pageCount: Int) -> NSView {
        let previous = NSButton(title: "‹", target: self, action: #selector(previousOverviewPage))
        let next = NSButton(title: "›", target: self, action: #selector(nextOverviewPage))
        previous.isBordered = false
        next.isBordered = false
        previous.contentTintColor = .white
        next.contentTintColor = .white
        previous.font = .systemFont(ofSize: 22, weight: .bold)
        next.font = .systemFont(ofSize: 22, weight: .bold)
        previous.isEnabled = overviewPage > 0
        next.isEnabled = overviewPage < pageCount - 1
        let label = NSTextField(labelWithString: "\(overviewPage + 1) / \(pageCount)")
        label.font = .systemFont(ofSize: 12, weight: .bold)
        label.textColor = NSColor.white.withAlphaComponent(0.72)
        let row = NSStackView(views: [previous, label, next])
        row.spacing = 10
        row.alignment = .centerY
        return row
    }

    private func emptyImportState() -> NSView {
        let hero = AnimatedImportHeroView()
        let title = NSTextField(labelWithString: AppLanguage.current.text(english: "Import your Apple Health export", german: "Apple-Health-Export importieren"))
        title.font = .systemFont(ofSize: 25, weight: .bold)
        title.textColor = .white
        let detail = NSTextField(labelWithString: AppLanguage.current.text(english: "Select a local ZIP or Export.xml file to begin.", german: "Wähle eine lokale ZIP- oder Export.xml-Datei, um zu beginnen."))
        detail.font = .systemFont(ofSize: 13, weight: .medium)
        detail.textColor = NSColor.white.withAlphaComponent(0.72)
        let button = NSButton(title: AppLanguage.current.text(english: "Import Apple Health…", german: "Apple Health importieren …"), target: self, action: #selector(importFile))
        stylePrimaryButton(button)
        let privacy = NSTextField(labelWithString: AppLanguage.current.text(english: "Local import · no upload · no account", german: "Lokaler Import · kein Upload · kein Konto"))
        privacy.font = .systemFont(ofSize: 11, weight: .semibold)
        privacy.textColor = NSColor.systemGreen.withAlphaComponent(0.92)
        let stack = NSStackView(views: [hero, title, detail, button, privacy])
        stack.orientation = .vertical
        stack.alignment = .centerX
        stack.spacing = 13
        stack.translatesAutoresizingMaskIntoConstraints = false
        let container = NSView()
        container.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.centerXAnchor.constraint(equalTo: container.centerXAnchor), stack.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            hero.widthAnchor.constraint(equalToConstant: 126), hero.heightAnchor.constraint(equalToConstant: 126),
            button.widthAnchor.constraint(greaterThanOrEqualToConstant: 244), button.heightAnchor.constraint(equalToConstant: 46),
            container.heightAnchor.constraint(equalToConstant: 430)
        ])
        return container
    }

    private func stylePrimaryButton(_ button: NSButton) {
        button.isBordered = false
        button.wantsLayer = true
        button.layer?.backgroundColor = NSColor.systemCyan.withAlphaComponent(0.90).cgColor
        button.layer?.cornerRadius = 15
        button.layer?.borderWidth = 1
        button.layer?.borderColor = NSColor.white.withAlphaComponent(0.26).cgColor
        button.font = .systemFont(ofSize: 15, weight: .bold)
        button.contentTintColor = .white
    }

    private func emptySelectionState() -> NSView {
        let label = NSTextField(labelWithString: AppLanguage.current.text(english: "Select a numeric Apple Health data type in Sources to view its trend.", german: "Wähle unter Quellen einen numerischen Apple-Health-Datentyp für den Verlauf aus."))
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textColor = NSColor.white.withAlphaComponent(0.78)
        return label
    }

    private func metricRow(metrics: [HealthMetric]) -> NSView {
        let row = NSStackView()
        row.orientation = .horizontal
        row.distribution = .fillEqually
        row.spacing = 12
        metrics.forEach { row.addArrangedSubview(metricCard($0)) }
        row.translatesAutoresizingMaskIntoConstraints = false
        return row
    }

    private func metricGrid(metrics: [HealthMetric]) -> NSView {
        let grid = NSStackView()
        grid.orientation = .vertical
        grid.spacing = 12
        grid.alignment = .leading
        for rowMetrics in metrics.chunked(into: 4) {
            let row = metricRow(metrics: rowMetrics)
            grid.addArrangedSubview(row)
            row.widthAnchor.constraint(equalTo: grid.widthAnchor).isActive = true
        }
        grid.translatesAutoresizingMaskIntoConstraints = false
        return grid
    }

    private func metricCard(_ metric: HealthMetric) -> NSView {
        let card = GlassCardView(accent: accent(for: metric.color))
        let background = MetricCardBackgroundView(title: metric.localizedTitle, accent: accent(for: metric.color))
        background.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(background)
        let title = NSTextField(labelWithString: metric.localizedTitle)
        title.font = .systemFont(ofSize: 12, weight: .semibold)
        title.textColor = NSColor.white.withAlphaComponent(0.74)
        let value = NSTextField(labelWithString: metric.value)
        value.font = .systemFont(ofSize: 25, weight: .bold)
        value.textColor = .white
        let detail = NSTextField(labelWithString: metric.localizedDetail)
        detail.font = .systemFont(ofSize: 11, weight: .medium)
        detail.textColor = NSColor.white.withAlphaComponent(0.62)
        let stack = NSStackView(views: [title, value, detail])
        stack.orientation = .vertical
        stack.alignment = .leading
        stack.spacing = 5
        stack.edgeInsets = NSEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        stack.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(stack)
        NSLayoutConstraint.activate([
            background.leadingAnchor.constraint(equalTo: card.leadingAnchor), background.trailingAnchor.constraint(equalTo: card.trailingAnchor),
            background.topAnchor.constraint(equalTo: card.topAnchor), background.bottomAnchor.constraint(equalTo: card.bottomAnchor),
            stack.leadingAnchor.constraint(equalTo: card.leadingAnchor), stack.trailingAnchor.constraint(equalTo: card.trailingAnchor),
            stack.topAnchor.constraint(equalTo: card.topAnchor), stack.bottomAnchor.constraint(equalTo: card.bottomAnchor),
            card.heightAnchor.constraint(equalToConstant: 126)
        ])
        return card
    }

    private func accent(for color: String) -> NSColor {
        switch color {
        case "purple": .systemPurple
        case "pink": .systemPink
        case "green": .systemGreen
        case "red": .systemRed
        case "orange": .systemOrange
        case "yellow": .systemYellow
        case "teal": .systemTeal
        case "indigo": .systemIndigo
        default: .systemCyan
        }
    }

    private func accentKey(for identifier: String) -> String {
        let lower = identifier.lowercased()
        if lower.contains("heartrate") { return "red" }
        if lower.contains("stepcount") { return "orange" }
        if lower.contains("sleep") { return "indigo" }
        if lower.contains("bodymass") { return "teal" }
        if lower.contains("distance") { return "cyan" }
        if lower.contains("energy") { return "yellow" }
        if lower.contains("audio") { return "purple" }
        if lower.contains("walking") { return "pink" }
        let palette = ["cyan", "purple", "pink", "green", "orange", "teal", "indigo", "red"]
        return palette[identifier.utf8.reduce(0) { $0 + Int($1) } % palette.count]
    }

    private func segmentedControl(labels: [String]) -> NSSegmentedControl {
        let control = NSSegmentedControl(labels: labels, trackingMode: .selectOne, target: nil, action: nil)
        control.selectedSegment = 1
        control.segmentStyle = .texturedRounded
        return control
    }

    @objc private func importFile() {
        let panel = NSOpenPanel()
        panel.title = AppLanguage.current.text(english: "Import local health data", german: "Lokale Gesundheitsdaten importieren")
        panel.message = AppLanguage.current.text(english: "Select an Apple Health ZIP or XML export. The file stays on this Mac.", german: "Wähle einen Apple-Health-ZIP- oder XML-Export. Die Datei bleibt auf diesem Mac.")
        panel.prompt = AppLanguage.current.text(english: "Import", german: "Importieren")
        panel.canChooseFiles = true
        panel.canChooseDirectories = false
        panel.allowsMultipleSelection = false
        panel.allowedContentTypes = [.zip, .xml, .json, .commaSeparatedText]
        panel.allowsOtherFileTypes = false
        panel.beginSheetModal(for: view.window!) { [weak self] response in
            guard response == .OK, let url = panel.url else { return }
            self?.showImportResult(LocalImportValidator.validate(url: url))
        }
    }

    private func showImportResult(_ result: LocalImportResult) {
        let alert = NSAlert()
        switch result {
        case .imported(let summary):
            applyImportedSummary(summary)
            alert.alertStyle = .informational
            alert.messageText = AppLanguage.current.text(english: "Apple Health imported locally", german: "Apple Health lokal importiert")
            alert.informativeText = AppLanguage.current.text(english: "Recognised data types are ready in Sources. Select exactly what you want to display.", german: "Erkannte Datentypen sind unter Quellen bereit. Wähle dort genau aus, was angezeigt werden soll.")
        case .ready(let file):
            alert.alertStyle = .informational
            alert.messageText = AppLanguage.current.text(english: "File checked locally", german: "Datei lokal geprüft")
            alert.informativeText = "\(file.fileName) · \(file.format)"
        case .rejected(let reason):
            alert.alertStyle = .warning
            alert.messageText = AppLanguage.current.text(english: "File not imported", german: "Datei nicht importiert")
            alert.informativeText = reason
        }
        alert.addButton(withTitle: "OK")
        alert.beginSheetModal(for: view.window!)
    }

    /// Exclusively for repository screenshots. Normal launches never read this
    /// environment variable and always start without data.
    private func loadScreenshotDemoIfRequested() {
        guard let path = ProcessInfo.processInfo.environment["HEALTHATLAS_SCREENSHOT_DEMO_FILE"] else { return }
        let url = URL(fileURLWithPath: path)
        guard case .imported(let summary) = LocalImportValidator.validate(url: url) else { return }
        applyImportedSummary(summary, selectAll: true)
    }

    private func applyImportedSummary(_ summary: ImportedHealthSummary, selectAll: Bool = false) {
        importedSummary = summary
        let savedIDs = Set(BuildEnvironment.defaults.stringArray(forKey: selectedTypeIDsPreferenceKey) ?? [])
        let validSavedIDs = Set(summary.dataTypes.map(\.identifier)).intersection(savedIDs)
        selectedTypeIDs = selectAll
            ? Set(summary.dataTypes.map(\.identifier))
            : (validSavedIDs.isEmpty ? Set(summary.dataTypes.prefix(4).map(\.identifier)) : validSavedIDs)
        selectedTrendTypeID = nil
        selectedTrendDate = nil
        overviewPage = 0
        rebuildBody()
    }
}

private final class MetricSelectionPanel: GlassCardView, NSTableViewDataSource, NSTableViewDelegate {
    private let table = NSTableView()
    private var metrics: [HealthDataTypeSummary]
    private var selectedIDs: Set<String>
    private let onChange: (Set<String>) -> Void

    init(metrics: [HealthDataTypeSummary], selectedIDs: Set<String>, onChange: @escaping (Set<String>) -> Void) {
        self.metrics = metrics
        self.selectedIDs = selectedIDs
        self.onChange = onChange
        super.init(accent: .systemCyan)
        let all = NSButton(title: AppLanguage.current.text(english: "Show all", german: "Alle anzeigen"), target: self, action: #selector(showAllMetrics))
        all.bezelStyle = .rounded
        let none = NSButton(title: AppLanguage.current.text(english: "Show none", german: "Keine anzeigen"), target: self, action: #selector(selectNone))
        none.bezelStyle = .rounded
        let controls = NSStackView(views: [all, none])
        controls.spacing = 8
        controls.translatesAutoresizingMaskIntoConstraints = false

        let scroll = NSScrollView()
        scroll.drawsBackground = false
        scroll.hasVerticalScroller = true
        scroll.translatesAutoresizingMaskIntoConstraints = false
        table.headerView = nil
        table.rowHeight = 31
        table.backgroundColor = .clear
        table.delegate = self
        table.dataSource = self
        ["show", "dataType", "samples", "value"].forEach { id in
            let column = NSTableColumn(identifier: NSUserInterfaceItemIdentifier(id))
            column.width = id == "dataType" ? 280 : (id == "show" ? 54 : 110)
            table.addTableColumn(column)
        }
        scroll.documentView = table
        addSubview(controls)
        addSubview(scroll)
        NSLayoutConstraint.activate([
            controls.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16), controls.topAnchor.constraint(equalTo: topAnchor, constant: 14),
            scroll.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12), scroll.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
            scroll.topAnchor.constraint(equalTo: controls.bottomAnchor, constant: 10), scroll.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12)
        ])
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    func numberOfRows(in tableView: NSTableView) -> Int { metrics.count }
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        guard let id = tableColumn?.identifier.rawValue else { return nil }
        let metric = metrics[row]
        if id == "show" {
            let checkbox = NSButton(checkboxWithTitle: "", target: self, action: #selector(toggleMetric(_:)))
            checkbox.tag = row
            checkbox.state = selectedIDs.contains(metric.identifier) ? .on : .off
            return checkbox
        }
        let text: String
        switch id { case "dataType": text = metric.localizedDisplayName; case "samples": text = metric.recordCount.formatted(); default: text = metric.valueText }
        let label = NSTextField(labelWithString: text)
        label.font = .systemFont(ofSize: 12, weight: id == "dataType" ? .semibold : .regular)
        label.textColor = .white.withAlphaComponent(id == "dataType" ? 0.92 : 0.68)
        return label
    }
    @objc private func toggleMetric(_ sender: NSButton) {
        let id = metrics[sender.tag].identifier
        if sender.state == .on { selectedIDs.insert(id) } else { selectedIDs.remove(id) }
        onChange(selectedIDs)
    }
    @objc private func showAllMetrics() { selectedIDs = Set(metrics.map(\.identifier)); table.reloadData(); onChange(selectedIDs) }
    @objc private func selectNone() { selectedIDs = []; table.reloadData(); onChange(selectedIDs) }
}

private enum AppTheme: String, CaseIterable {
    case clearGlass, midnightGlass, aurora, warmPaper
    static var current: AppTheme { AppTheme(rawValue: BuildEnvironment.defaults.string(forKey: "HealthAtlas.theme") ?? "") ?? .midnightGlass }
    var displayName: String { rawValue.replacingOccurrences(of: "Glass", with: " Glass").capitalized }
    var accent: NSColor { self == .warmPaper ? .systemOrange : (self == .aurora ? .systemTeal : .systemCyan) }
    var sidebarColor: NSColor {
        switch self {
        case .clearGlass: NSColor(calibratedRed: 0.08, green: 0.28, blue: 0.57, alpha: 0.78)
        case .midnightGlass: NSColor(calibratedRed: 0.035, green: 0.10, blue: 0.28, alpha: 0.90)
        case .aurora: NSColor(calibratedRed: 0.03, green: 0.25, blue: 0.34, alpha: 0.88)
        case .warmPaper: NSColor(calibratedRed: 0.20, green: 0.11, blue: 0.17, alpha: 0.88)
        }
    }
    var colors: [NSColor] {
        switch self {
        case .clearGlass: [NSColor(calibratedRed: 0.14, green: 0.46, blue: 0.85, alpha: 0.80), NSColor(calibratedRed: 0.15, green: 0.19, blue: 0.57, alpha: 0.84), NSColor(calibratedRed: 0.08, green: 0.06, blue: 0.28, alpha: 0.86)]
        case .midnightGlass: [NSColor(calibratedRed: 0.04, green: 0.18, blue: 0.45, alpha: 1), NSColor(calibratedRed: 0.10, green: 0.06, blue: 0.34, alpha: 1), NSColor(calibratedRed: 0.015, green: 0.025, blue: 0.12, alpha: 1)]
        case .aurora: [NSColor(calibratedRed: 0.02, green: 0.42, blue: 0.45, alpha: 1), NSColor(calibratedRed: 0.12, green: 0.16, blue: 0.60, alpha: 1), NSColor(calibratedRed: 0.04, green: 0.05, blue: 0.20, alpha: 1)]
        case .warmPaper: [NSColor(calibratedRed: 0.45, green: 0.23, blue: 0.27, alpha: 1), NSColor(calibratedRed: 0.22, green: 0.10, blue: 0.16, alpha: 1), NSColor(calibratedRed: 0.06, green: 0.04, blue: 0.10, alpha: 1)]
        }
    }
    var previewColor: NSColor { colors[0].withAlphaComponent(0.72) }
    func save() { BuildEnvironment.defaults.set(rawValue, forKey: "HealthAtlas.theme") }
}

private final class GradientBackdropView: NSView {
    private var theme = AppTheme.current
    func apply(theme: AppTheme) { self.theme = theme; needsDisplay = true }
    override var isOpaque: Bool { false }
    override func draw(_ dirtyRect: NSRect) {
        guard theme != .clearGlass else { return }
        NSGradient(colors: theme.colors)?.draw(in: bounds, angle: -35)
        let glow = NSBezierPath(ovalIn: NSRect(x: bounds.width * 0.34, y: bounds.height * 0.40, width: bounds.width * 0.65, height: bounds.height * 0.85))
        theme.accent.withAlphaComponent(0.10).setFill()
        glow.fill()
    }
}

private class GlassCardView: NSVisualEffectView {
    init(accent: NSColor = .systemCyan) {
        super.init(frame: .zero)
        material = .hudWindow
        blendingMode = .withinWindow
        state = .active
        wantsLayer = true
        layer?.backgroundColor = NSColor(calibratedWhite: 0.04, alpha: 0.46).cgColor
        layer?.cornerRadius = 18
        layer?.masksToBounds = true
        layer?.borderWidth = 1
        layer?.borderColor = accent.withAlphaComponent(0.38).cgColor
        shadow = NSShadow()
        shadow?.shadowColor = accent.withAlphaComponent(0.18)
        shadow?.shadowBlurRadius = 15
    }
    override func viewDidMoveToWindow() {
        super.viewDidMoveToWindow()
        guard window != nil else { return }
        alphaValue = 0
        layer?.setAffineTransform(CGAffineTransform(scaleX: 0.96, y: 0.96))
        NSAnimationContext.runAnimationGroup { context in
            context.duration = 0.34
            context.timingFunction = CAMediaTimingFunction(name: .easeOut)
            animator().alphaValue = 1
            layer?.setAffineTransform(.identity)
        }
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}

private final class AnimatedImportHeroView: NSView {
    private var phase: CGFloat = 0
    private var timer: Timer?

    override var isFlipped: Bool { true }

    override func viewDidMoveToWindow() {
        super.viewDidMoveToWindow()
        guard window != nil, timer == nil else { return }
        timer = Timer.scheduledTimer(timeInterval: 1.0 / 30.0, target: self, selector: #selector(advance), userInfo: nil, repeats: true)
        RunLoop.main.add(timer!, forMode: .common)
    }

    override func viewWillMove(toWindow newWindow: NSWindow?) {
        if newWindow == nil { timer?.invalidate(); timer = nil }
        super.viewWillMove(toWindow: newWindow)
    }

    @objc private func advance() {
        phase += 0.035
        needsDisplay = true
    }

    override func draw(_ dirtyRect: NSRect) {
        let center = NSPoint(x: bounds.midX, y: bounds.midY)
        for index in 0..<3 {
            let radius = CGFloat(31 + index * 15) + sin(phase + CGFloat(index)) * 2
            let ring = NSBezierPath(ovalIn: NSRect(x: center.x - radius, y: center.y - radius, width: radius * 2, height: radius * 2))
            ring.lineWidth = 1.3
            NSColor.systemCyan.withAlphaComponent(0.18 - CGFloat(index) * 0.035).setStroke()
            ring.stroke()
        }
        let pulse = (sin(phase * 1.7) + 1) / 2
        NSColor.systemPink.withAlphaComponent(0.14 + pulse * 0.12).setFill()
        NSBezierPath(ovalIn: NSRect(x: center.x - 30, y: center.y - 30, width: 60, height: 60)).fill()
        let icon = NSImage(systemSymbolName: "heart.text.square.fill", accessibilityDescription: nil)!
        let config = NSImage.SymbolConfiguration(pointSize: 44, weight: .semibold)
        icon.withSymbolConfiguration(config)?.draw(in: NSRect(x: center.x - 25, y: center.y - 25, width: 50, height: 50))
        for index in 0..<5 {
            let angle = phase + CGFloat(index) * (.pi * 2 / 5)
            let point = NSPoint(x: center.x + cos(angle) * 57, y: center.y + sin(angle) * 57)
            NSColor.systemCyan.withAlphaComponent(0.55).setFill()
            NSBezierPath(ovalIn: NSRect(x: point.x - 2, y: point.y - 2, width: 4, height: 4)).fill()
        }
    }
}

private final class MetricCardBackgroundView: NSView {
    private let title: String
    private let accent: NSColor

    init(title: String, accent: NSColor) {
        self.title = title.lowercased()
        self.accent = accent
        super.init(frame: .zero)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    override var isOpaque: Bool { false }

    override func draw(_ dirtyRect: NSRect) {
        NSGradient(colors: [
            accent.withAlphaComponent(0.34),
            accent.withAlphaComponent(0.14),
            NSColor(calibratedWhite: 0.03, alpha: 0.10)
        ])?.draw(in: bounds, angle: -24)
        let topGlow = NSBezierPath(rect: NSRect(x: 0, y: 0, width: bounds.width, height: bounds.height * 0.30))
        NSColor.white.withAlphaComponent(0.045).setFill()
        topGlow.fill()
        let symbol: String
        if title.contains("schritt") || title.contains("step") { symbol = "figure.walk" }
        else if title.contains("herz") || title.contains("heart") { symbol = "heart.fill" }
        else if title.contains("schlaf") || title.contains("sleep") { symbol = "moon.stars.fill" }
        else if title.contains("gewicht") || title.contains("mass") { symbol = "scalemass.fill" }
        else { symbol = "waveform.path.ecg" }
        accent.withAlphaComponent(0.70).set()
        let image = NSImage(systemSymbolName: symbol, accessibilityDescription: nil)
        image?.withSymbolConfiguration(NSImage.SymbolConfiguration(pointSize: 34, weight: .medium))?.draw(in: NSRect(x: bounds.width - 54, y: bounds.height - 51, width: 30, height: 30))
    }
}

private struct HealthTrendPoint {
    let date: Date
    let value: Double

    func detail(for metric: HealthDataTypeSummary) -> String {
        "\(date.formatted(date: .long, time: .omitted))  ·  \(metric.formattedValue(value))"
    }
}

private final class TrendGraphView: NSView {
    private let points: [HealthTrendPoint]
    private let tintColor: NSColor
    private let showsPoints: Bool
    private let onSelect: (HealthTrendPoint) -> Void
    private var progress: CGFloat = 0
    private var timer: Timer?
    private var hitTargets: [(location: NSPoint, point: HealthTrendPoint)] = []
    init(points: [HealthTrendPoint], tintColor: NSColor, showsPoints: Bool = false, onSelect: @escaping (HealthTrendPoint) -> Void) {
        self.points = points
        self.tintColor = tintColor
        self.showsPoints = showsPoints
        self.onSelect = onSelect
        super.init(frame: .zero)
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    override var isFlipped: Bool { true }
    override func viewDidMoveToWindow() {
        super.viewDidMoveToWindow()
        guard window != nil, timer == nil else { return }
        timer = Timer.scheduledTimer(timeInterval: 1.0 / 60.0, target: self, selector: #selector(advance), userInfo: nil, repeats: true)
        RunLoop.main.add(timer!, forMode: .common)
    }
    override func viewWillMove(toWindow newWindow: NSWindow?) {
        if newWindow == nil { timer?.invalidate(); timer = nil }
        super.viewWillMove(toWindow: newWindow)
    }
    @objc private func advance() {
        progress = min(1, progress + 0.055)
        needsDisplay = true
        if progress == 1 { timer?.invalidate(); timer = nil }
    }
    override func draw(_ dirtyRect: NSRect) {
        let inset = bounds.insetBy(dx: 8, dy: 12)
        let grid = NSBezierPath(); grid.lineWidth = 1
        NSColor.white.withAlphaComponent(0.12).setStroke()
        for fraction in [0.2, 0.5, 0.8] { let y = inset.minY + inset.height * fraction; grid.move(to: NSPoint(x: inset.minX, y: y)); grid.line(to: NSPoint(x: inset.maxX, y: y)) }
        grid.stroke()
        guard points.count > 1,
              let minimum = points.map(\.value).min(), let maximum = points.map(\.value).max() else {
            let label = AppLanguage.current.text(english: "No values in this period", german: "Keine Werte in diesem Zeitraum")
            let attributes: [NSAttributedString.Key: Any] = [.font: NSFont.systemFont(ofSize: 13, weight: .medium), .foregroundColor: NSColor.white.withAlphaComponent(0.65)]
            label.draw(at: NSPoint(x: inset.midX - 60, y: inset.midY), withAttributes: attributes)
            return
        }
        let span = max(maximum - minimum, 0.000_001)
        let line = NSBezierPath(); line.lineWidth = 3; line.lineJoinStyle = .round
        hitTargets = []
        let visibleCount = max(2, Int(ceil(CGFloat(points.count) * progress)))
        for (index, trendPoint) in points.prefix(visibleCount).enumerated() {
            let normalized = (trendPoint.value - minimum) / span
            let location = NSPoint(x: inset.minX + inset.width * CGFloat(index) / CGFloat(points.count - 1), y: inset.maxY - inset.height * CGFloat(normalized))
            index == 0 ? line.move(to: location) : line.line(to: location)
            hitTargets.append((location, trendPoint))
            if showsPoints && index < visibleCount - 1 { tintColor.setFill(); NSBezierPath(ovalIn: NSRect(x: location.x - 5, y: location.y - 5, width: 10, height: 10)).fill() }
        }
        tintColor.setStroke(); line.stroke()
    }

    override func mouseDown(with event: NSEvent) {
        let click = convert(event.locationInWindow, from: nil)
        guard let target = hitTargets.min(by: { hypot($0.location.x - click.x, $0.location.y - click.y) < hypot($1.location.x - click.x, $1.location.y - click.y) }),
              hypot(target.location.x - click.x, target.location.y - click.y) < 18 else { return }
        onSelect(target.point)
    }
}
