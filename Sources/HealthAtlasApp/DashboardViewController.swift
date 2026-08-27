import AppKit
import Combine
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
    private let clearGlassAtmosphere = ClearGlassAtmosphereView(drawsAmbient: true, emitsSparks: false)
    private let clearGlassSparkOverlay = ClearGlassAtmosphereView(drawsAmbient: false, emitsSparks: true)

    override func loadView() {
        let root = NSView()
        root.wantsLayer = true
        root.layer?.backgroundColor = NSColor.clear.cgColor
        view = root

        clearGlassAtmosphere.translatesAutoresizingMaskIntoConstraints = false
        clearGlassAtmosphere.apply(theme: .current)
        clearGlassSparkOverlay.translatesAutoresizingMaskIntoConstraints = false
        clearGlassSparkOverlay.apply(theme: .current)
        root.addSubview(clearGlassAtmosphere)
        NSLayoutConstraint.activate([
            clearGlassAtmosphere.leadingAnchor.constraint(equalTo: root.leadingAnchor),
            clearGlassAtmosphere.trailingAnchor.constraint(equalTo: root.trailingAnchor),
            clearGlassAtmosphere.topAnchor.constraint(equalTo: root.topAnchor),
            clearGlassAtmosphere.bottomAnchor.constraint(equalTo: root.bottomAnchor)
        ])

        addChild(sidebar)
        addChild(workspace)
        let sidebarView = sidebar.view
        let workspaceView = workspace.view
        sidebarView.translatesAutoresizingMaskIntoConstraints = false
        workspaceView.translatesAutoresizingMaskIntoConstraints = false
        root.addSubview(sidebarView)
        root.addSubview(workspaceView)
        root.addSubview(clearGlassSparkOverlay)
        NSLayoutConstraint.activate([
            sidebarView.leadingAnchor.constraint(equalTo: root.leadingAnchor),
            sidebarView.topAnchor.constraint(equalTo: root.topAnchor),
            sidebarView.bottomAnchor.constraint(equalTo: root.bottomAnchor),
            sidebarView.widthAnchor.constraint(equalToConstant: 236),
            workspaceView.leadingAnchor.constraint(equalTo: sidebarView.trailingAnchor),
            workspaceView.topAnchor.constraint(equalTo: root.topAnchor),
            workspaceView.bottomAnchor.constraint(equalTo: root.bottomAnchor),
            workspaceView.trailingAnchor.constraint(equalTo: root.trailingAnchor),
            clearGlassSparkOverlay.leadingAnchor.constraint(equalTo: root.leadingAnchor),
            clearGlassSparkOverlay.trailingAnchor.constraint(equalTo: root.trailingAnchor),
            clearGlassSparkOverlay.topAnchor.constraint(equalTo: root.topAnchor),
            clearGlassSparkOverlay.bottomAnchor.constraint(equalTo: root.bottomAnchor)
        ])
        sidebar.onSelection = { [weak self] section in self?.workspace.show(section: section) }
        workspace.onRequestSection = { [weak self] section in self?.sidebar.select(section) }
        workspace.onThemeChanged = { [weak self] theme in
            self?.sidebar.apply(theme: theme)
            self?.clearGlassAtmosphere.apply(theme: theme)
            self?.clearGlassSparkOverlay.apply(theme: theme)
        }
        workspace.onLanguageChanged = { [weak self] in self?.sidebar.apply(theme: .current) }
        workspace.onImportStateChanged = { [weak self] hasImportedData in
            self?.sidebar.apply(hasImportedData: hasImportedData)
        }
        sidebar.apply(hasImportedData: workspace.hasImportedData)
        workspace.onActivityChanged = { [weak self] isActive in
            self?.clearGlassAtmosphere.setPerformanceSensitive(isActive)
            self?.clearGlassSparkOverlay.setPerformanceSensitive(isActive)
        }
        if let value = ProcessInfo.processInfo.environment["HEALTHATLAS_SCREENSHOT_SECTION"],
           let section = DashboardSection.allCases.first(where: { String(describing: $0) == value }) {
            workspace.show(section: section)
        }
    }
}

private enum DashboardSection: Int, CaseIterable {
    case overview, trends, insights, sources, settings

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

private final class SidebarSelectionModel: ObservableObject {
    @Published var selectedSection: DashboardSection = .overview
    @Published var hasImportedData = false
    @Published private(set) var refreshToken = 0

    func refresh() {
        refreshToken &+= 1
    }
}

private final class SidebarViewController: NSViewController {
    var onSelection: ((DashboardSection) -> Void)?
    private let selectionModel = SidebarSelectionModel()
    private var sidebarRoot: NativeTransparentSidebarRootView<SidebarLiquidGlassView>!

    override func loadView() {
        sidebarRoot = NativeTransparentSidebarRootView()
        sidebarRoot.setRootView(makeSidebar())
        view = sidebarRoot
    }

    func apply(theme: AppTheme) {
        // Die komplette Spalte bleibt auf jedem Theme dieselbe native Liquid-Glass-Fläche.
        // Nur der Arbeitsbereich wechselt seine Hintergrundfarben.
        selectionModel.refresh()
    }

    func apply(hasImportedData: Bool) {
        selectionModel.hasImportedData = hasImportedData
    }

    func select(_ section: DashboardSection) {
        selectionModel.selectedSection = section
        onSelection?(section)
    }

    private func makeSidebar() -> SidebarLiquidGlassView {
        SidebarLiquidGlassView(model: selectionModel) { [weak self] section in
            self?.select(section)
        }
    }
}

/// SwiftUI-Inhalt der Sidebar. Die Transparenz kommt von der AppKit-Wurzelansicht
/// darunter, damit sie über jede gewählte Arbeitsbereichsoberfläche hinweg wirkt.
@available(macOS 26.0, *)
private struct SidebarLiquidGlassView: View {
    @ObservedObject var model: SidebarSelectionModel
    let onSelection: (DashboardSection) -> Void
    @Namespace private var selectionNamespace

    var body: some View {
        let selectedSection = model.selectedSection
        let hasImportedData = model.hasImportedData
        let refreshToken = model.refreshToken
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
                            Text(section == .overview && !hasImportedData
                                ? AppLanguage.current.text(english: "Import", german: "Import")
                                : section.title(for: .current))
                            Spacer(minLength: 0)
                        }
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(section == selectedSection ? Color.black.opacity(0.82) : .white)
                        .padding(.horizontal, 16)
                        .frame(height: 44)
                        .background {
                            if section == selectedSection {
                                RoundedRectangle(cornerRadius: 13, style: .continuous)
                                    .fill(Color.yellow)
                                    .matchedGeometryEffect(id: "sidebarSelection", in: selectionNamespace)
                            }
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 14)
            .padding(.top, 32)

            Spacer(minLength: 0)

            HStack(spacing: 10) {
                CommunityLinkButton(imageName: "GitHubMark", backgroundColor: .white, destination: "https://github.com/Schrotty74/HealthAtlas", label: "HealthAtlas on GitHub")
                CommunityLinkButton(imageName: "DiscordMark", backgroundColor: Color(red: 0.35, green: 0.40, blue: 0.95), destination: "https://discord.gg/RbsvqRCPQ", label: "HealthAtlas community on Discord")
            }
            .padding(.horizontal, 22)
            .padding(.bottom, 12)

            Label(AppLanguage.current.text(english: "Private · Local only", german: "Privat · Nur lokal"), systemImage: "circle.fill")
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(.green)
                .padding(.horizontal, 22)
                .padding(.bottom, 23)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .contentShape(Rectangle())
        .preferredColorScheme(.dark)
        .id(refreshToken)
        .animation(.spring(response: 0.32, dampingFraction: 0.82), value: selectedSection)
    }
}

@available(macOS 26.0, *)
private struct CommunityLinkButton: View {
    let imageName: String
    let backgroundColor: Color
    let destination: String
    let label: String

    var body: some View {
        Button {
            guard let url = URL(string: destination) else { return }
            NSWorkspace.shared.open(url)
        } label: {
            Image(imageName)
                .resizable()
                .scaledToFit()
                .padding(7)
                .frame(width: 30, height: 30)
                .background(backgroundColor, in: RoundedRectangle(cornerRadius: 8, style: .continuous))
        }
        .buttonStyle(.plain)
        .help(label)
        .accessibilityLabel(label)
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

private enum MetricPinArea: CaseIterable {
    case overview, trends, insights

    var preferenceKey: String {
        switch self {
        case .overview: "HealthAtlas.favoriteHealthTypeIDs.overview"
        case .trends: "HealthAtlas.favoriteHealthTypeIDs.trends"
        case .insights: "HealthAtlas.favoriteHealthTypeIDs.insights"
        }
    }

    func title(for language: AppLanguage) -> String {
        switch self {
        case .overview: language.text(english: "Overview", german: "Übersicht")
        case .trends: language.text(english: "Trends", german: "Verläufe")
        case .insights: language.text(english: "Insights", german: "Einblicke")
        }
    }
}

private final class FlippedContentView: NSView {
    override var isFlipped: Bool { true }
}

private final class HealthWorkspaceViewController: NSViewController {
    var onThemeChanged: ((AppTheme) -> Void)?
    var onLanguageChanged: (() -> Void)?
    var onImportStateChanged: ((Bool) -> Void)?
    var onActivityChanged: ((Bool) -> Void)?
    var onRequestSection: ((DashboardSection) -> Void)?
    private let backdrop = GradientBackdropView()
    private let clearGlassEffect = NSVisualEffectView()
    private let titleLabel = NSTextField(labelWithString: "")
    private let subtitleLabel = NSTextField(labelWithString: "")
    private let statusLabel = NSTextField(labelWithString: "")
    private let importButton = NSButton(title: "", target: nil, action: nil)
    private let themeButton = NSPopUpButton()
    private let contentScrollView = NSScrollView()
    private let contentDocumentView = FlippedContentView()
    private let body = NSStackView()
    private var selectedSection: DashboardSection = .overview
    private var importedSummary: ImportedHealthSummary?
    private var isScreenshotDemoLoaded = false
    private var selectedTypeIDs = Set<String>()
    private let selectedTypeIDsPreferenceKey = "HealthAtlas.selectedHealthTypeIDs"
    private var favoriteTypeIDs = Set<String>()
    private var favoritesByArea = Dictionary(uniqueKeysWithValues: MetricPinArea.allCases.map { ($0, Set<String>()) })
    private let favoriteTypeIDsPreferenceKey = "HealthAtlas.favoriteHealthTypeIDs"
    private var metricOrder = [String]()
    private let metricOrderPreferenceKey = "HealthAtlas.healthMetricOrder"
    private var selectedTrendTypeID: String?
    private var selectedTrendDate: Date?
    private var selectedInsightTypeID: String?
    private var importTimestamp: Date?
    private var trendRangeDays = 30
    private var heatmapRangeDays: Int {
        get {
            let stored = BuildEnvironment.defaults.integer(forKey: "HealthAtlas.heatmapRangeDays")
            // Earlier Dev builds stored 84 for "12 weeks". Keep that local
            // preference meaningful by moving it to the renamed 3-month range.
            if stored == 84 { return 90 }
            return [7, 28, 90, 182, 365].contains(stored) ? stored : 90
        }
        set { BuildEnvironment.defaults.set(newValue, forKey: "HealthAtlas.heatmapRangeDays") }
    }
    private var dashboardDensity: Int {
        get {
            let stored = BuildEnvironment.defaults.integer(forKey: "HealthAtlas.dashboardDensity")
            return [0, 1, 2].contains(stored) ? stored : 1
        }
        set { BuildEnvironment.defaults.set(newValue, forKey: "HealthAtlas.dashboardDensity") }
    }
    private var metricOrderKey: String { "HealthAtlas.healthMetricOrder.layout.\(dashboardDensity)" }
    private var overviewPage = 0
    private var isImporting = false
    private var importProgressOverlay: ImportProgressOverlayView?
    private var heroMetricID: String? {
        get { BuildEnvironment.defaults.string(forKey: "HealthAtlas.heroMetricID") }
        set { BuildEnvironment.defaults.set(newValue, forKey: "HealthAtlas.heroMetricID") }
    }
    private var overviewPageSize: Int {
        get {
            let stored = BuildEnvironment.defaults.integer(forKey: "HealthAtlas.overviewPageSize")
            return [4, 8, 12].contains(stored) ? stored : 8
        }
        set { BuildEnvironment.defaults.set(newValue, forKey: "HealthAtlas.overviewPageSize") }
    }

    var hasImportedData: Bool {
        importedSummary != nil
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
        statusLabel.textColor = .white

        importButton.bezelStyle = .rounded
        importButton.controlSize = .large
        importButton.font = .systemFont(ofSize: 13, weight: .semibold)
        importButton.cell?.lineBreakMode = .byTruncatingTail
        importButton.setContentCompressionResistancePriority(.required, for: .horizontal)
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
        body.wantsLayer = true
        contentScrollView.drawsBackground = false
        contentScrollView.hasVerticalScroller = true
        contentScrollView.autohidesScrollers = true
        contentScrollView.translatesAutoresizingMaskIntoConstraints = false
        contentDocumentView.translatesAutoresizingMaskIntoConstraints = false
        contentScrollView.documentView = contentDocumentView
        clearGlassEffect.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(clearGlassEffect)
        view.addSubview(contentScrollView)
        contentDocumentView.addSubview(heading)
        contentDocumentView.addSubview(controls)
        contentDocumentView.addSubview(body)
        let bodyBottom = body.bottomAnchor.constraint(equalTo: contentDocumentView.bottomAnchor, constant: -28)
        bodyBottom.priority = .defaultLow
        NSLayoutConstraint.activate([
            clearGlassEffect.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            clearGlassEffect.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            clearGlassEffect.topAnchor.constraint(equalTo: view.topAnchor),
            clearGlassEffect.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            contentScrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            contentScrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            contentScrollView.topAnchor.constraint(equalTo: view.topAnchor),
            contentScrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            contentDocumentView.leadingAnchor.constraint(equalTo: contentScrollView.contentView.leadingAnchor),
            contentDocumentView.trailingAnchor.constraint(equalTo: contentScrollView.contentView.trailingAnchor),
            contentDocumentView.topAnchor.constraint(equalTo: contentScrollView.contentView.topAnchor),
            contentDocumentView.widthAnchor.constraint(equalTo: contentScrollView.contentView.widthAnchor),
            contentDocumentView.heightAnchor.constraint(greaterThanOrEqualTo: contentScrollView.contentView.heightAnchor),
            heading.leadingAnchor.constraint(equalTo: contentDocumentView.leadingAnchor, constant: 34),
            heading.topAnchor.constraint(equalTo: contentDocumentView.topAnchor, constant: 31),
            heading.trailingAnchor.constraint(lessThanOrEqualTo: controls.leadingAnchor, constant: -18),
            controls.trailingAnchor.constraint(equalTo: contentDocumentView.trailingAnchor, constant: -34),
            controls.centerYAnchor.constraint(equalTo: heading.centerYAnchor),
            body.leadingAnchor.constraint(equalTo: contentDocumentView.leadingAnchor, constant: 34),
            body.trailingAnchor.constraint(equalTo: contentDocumentView.trailingAnchor, constant: -34),
            body.topAnchor.constraint(equalTo: heading.bottomAnchor, constant: 25),
            bodyBottom
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
        rebuildBody()
    }

    private func configureClearGlassSurface(for theme: AppTheme) {
        clearGlassEffect.isHidden = theme != .clearGlass
        guard theme == .clearGlass else { return }
        clearGlassEffect.material = .underWindowBackground
        clearGlassEffect.blendingMode = .withinWindow
        clearGlassEffect.state = .active
        clearGlassEffect.wantsLayer = true
        clearGlassEffect.layer?.backgroundColor = NSColor.white.withAlphaComponent(0.055).cgColor
    }

    private func rebuildBody() {
        body.arrangedSubviews.forEach { body.removeArrangedSubview($0); $0.removeFromSuperview() }
        body.layer?.removeAllAnimations()
        body.alphaValue = shouldAnimateInterface ? 0 : 1
        body.layer?.transform = shouldAnimateInterface ? CATransform3DMakeTranslation(0, 12, 0) : CATransform3DIdentity
        let language = AppLanguage.current
        titleLabel.stringValue = selectedSection == .overview && importedSummary == nil
            ? language.text(english: "Import", german: "Import")
            : selectedSection.title(for: language)
        subtitleLabel.stringValue = language.text(english: "A calm, visual view of your health — on this Mac.", german: "Eine ruhige, visuelle Sicht auf deine Gesundheit — auf diesem Mac.")
        statusLabel.stringValue = isScreenshotDemoLoaded
            ? "●  " + language.text(english: "DEMO DATA · Synthetic local data · No account, cloud sync, analytics or tracking", german: "DEMODATEN · Synthetische lokale Daten · Kein Konto, Cloud-Sync, Analytics oder Tracking")
            : "●  " + language.text(english: "LOCAL ONLY · No account, cloud sync, analytics or tracking", german: "NUR LOKAL · Kein Konto, Cloud-Sync, Analytics oder Tracking")
        importButton.title = language.text(english: "Import ZIP or Export.xml…", german: "ZIP oder Export.xml importieren …")
        importButton.isHidden = importedSummary == nil
        onImportStateChanged?(importedSummary != nil)
        body.addArrangedSubview(statusLabel)

        switch selectedSection {
        case .overview: buildOverview()
        case .trends: buildTrends()
        case .sources: buildSources()
        case .insights: buildInsights()
        case .settings: buildSettings()
        }

        animateBodyEntrance()
    }

    private func buildOverview() {
        guard importedSummary != nil else {
            body.addArrangedSubview(emptyImportState())
            return
        }
        let selectedTypes = selectedDataTypes(for: .overview)
        let sourceMessage = NSTextField(labelWithString: AppLanguage.current.text(
            english: "Apple Health is loaded locally. \(selectedTypes.count) selected data types are shown below.",
            german: "Apple Health ist lokal geladen. \(selectedTypes.count) ausgewählte Datentypen werden unten angezeigt."
        ))
        sourceMessage.textColor = NSColor.white.withAlphaComponent(0.72)
        sourceMessage.font = .systemFont(ofSize: 12, weight: .medium)
        body.addArrangedSubview(sourceMessage)
        let periodStory = LocalPeriodStoryView(metrics: selectedTypes, language: AppLanguage.current)
        body.addArrangedSubview(periodStory)
        periodStory.widthAnchor.constraint(equalTo: body.widthAnchor).isActive = true
        periodStory.heightAnchor.constraint(equalToConstant: 92).isActive = true
        let metrics = visibleMetrics()
        let displayControl = NSSegmentedControl(labels: ["4", "8", "12"], trackingMode: .selectOne, target: self, action: #selector(overviewPageSizeChanged(_:)))
        displayControl.selectedSegment = [4, 8, 12].firstIndex(of: overviewPageSize) ?? 1
        displayControl.segmentStyle = .texturedRounded
        let exportReport = NSButton(title: AppLanguage.current.text(english: "Export local PDF report…", german: "Lokalen PDF-Bericht exportieren …"), target: self, action: #selector(exportLocalReport))
        exportReport.bezelStyle = .rounded
        exportReport.contentTintColor = .white
        let densityControl = NSSegmentedControl(
            labels: [
                AppLanguage.current.text(english: "Compact", german: "Kompakt"),
                AppLanguage.current.text(english: "Standard", german: "Standard"),
                AppLanguage.current.text(english: "Focus", german: "Fokus")
            ],
            trackingMode: .selectOne,
            target: self,
            action: #selector(dashboardDensityChanged(_:))
        )
        densityControl.selectedSegment = dashboardDensity
        densityControl.segmentStyle = .texturedRounded
        let resetLayout = NSButton(title: AppLanguage.current.text(english: "Reset layout", german: "Anordnung zurücksetzen"), target: self, action: #selector(resetDashboardLayout))
        resetLayout.bezelStyle = .rounded
        resetLayout.contentTintColor = .white
        let displayRow = NSStackView(views: [
            NSTextField(labelWithString: AppLanguage.current.text(english: "Cards shown", german: "Angezeigte Karten")),
            displayControl,
            densityControl, resetLayout,
            exportReport
        ])
        displayRow.spacing = 10
        displayRow.alignment = .centerY
        body.addArrangedSubview(displayRow)
        let pageCount = max(1, Int(ceil(Double(metrics.count) / Double(overviewPageSize))))
        overviewPage = min(overviewPage, pageCount - 1)
        let start = overviewPage * overviewPageSize
        if !metrics.isEmpty {
            let metricsGrid = metricGrid(metrics: Array(metrics.dropFirst(start).prefix(overviewPageSize)))
            body.addArrangedSubview(metricsGrid)
            metricsGrid.widthAnchor.constraint(equalTo: body.widthAnchor).isActive = true
            animateMetricCards(in: metricsGrid)
        }
        if pageCount > 1 {
            body.addArrangedSubview(overviewPagination(pageCount: pageCount))
        }
        let overviewVisuals = NSStackView()
        overviewVisuals.orientation = .horizontal
        overviewVisuals.distribution = .fillEqually
        overviewVisuals.spacing = 12
        let rings = HealthRingsView(metrics: Array(selectedTypes.prefix(3)), language: AppLanguage.current)
        let timeline = CombinedHealthTimelineView(metrics: Array(selectedTypes.prefix(4)), language: AppLanguage.current) { [weak self] identifier in
            self?.presentMetricFocus(for: identifier)
        }
        overviewVisuals.addArrangedSubview(rings)
        overviewVisuals.addArrangedSubview(timeline)
        overviewVisuals.translatesAutoresizingMaskIntoConstraints = false
        body.addArrangedSubview(overviewVisuals)
        overviewVisuals.widthAnchor.constraint(equalTo: body.widthAnchor).isActive = true
        overviewVisuals.heightAnchor.constraint(equalToConstant: 210).isActive = true

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
        let selectedTypes = selectedDataTypes(for: .trends)
        guard let metric = selectedTrendMetric(from: selectedTypes) else {
            body.addArrangedSubview(emptySelectionState())
            return
        }
        let metricAccent = accent(for: accentKey(for: metric.identifier))
        if let comparison = HealthPeriodComparison.make(values: metric.dailyValues, metric: metric, days: trendRangeDays) {
            let comparisonView = PeriodComparisonView(comparison: comparison, metric: metric, days: trendRangeDays, accent: metricAccent, language: AppLanguage.current)
            body.addArrangedSubview(comparisonView)
            comparisonView.widthAnchor.constraint(equalTo: body.widthAnchor).isActive = true
            comparisonView.heightAnchor.constraint(equalToConstant: 92).isActive = true
        }
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
        detail.textColor = .white
        let graph = TrendGraphView(points: points, tintColor: metricAccent, chartStyle: metric.preferredChartStyle, showsPoints: true, selectedDate: selectedTrendDate, showsDateLabels: true, valueFormatter: metric.formattedValue) { [weak self] point in
            self?.selectedTrendDate = point.date
            self?.rebuildBody()
        }
        let stack = NSStackView(views: [typePicker, name, detail, graph])
        stack.orientation = .vertical
        stack.spacing = 8
        stack.edgeInsets = NSEdgeInsets(top: 14, left: 22, bottom: 14, right: 22)
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
            graph.heightAnchor.constraint(equalToConstant: 94)
        ])
        body.addArrangedSubview(card)
        card.widthAnchor.constraint(equalTo: body.widthAnchor).isActive = true
        let highlights = TrendHighlightsView(metric: metric, points: points, days: trendRangeDays, language: AppLanguage.current)
        body.addArrangedSubview(highlights)
        highlights.widthAnchor.constraint(equalTo: body.widthAnchor).isActive = true
        highlights.heightAnchor.constraint(equalToConstant: 84).isActive = true
        let calendar = localCalendarCard(for: metric, accent: metricAccent)
        body.addArrangedSubview(calendar)
        calendar.widthAnchor.constraint(equalTo: body.widthAnchor).isActive = true
    }

    private func buildSources() {
        let description = NSTextField(labelWithString: importedSummary == nil
            ? AppLanguage.current.text(english: "Import Apple Health to choose which recognised data types are shown.", german: "Importiere Apple Health, um erkannte Datentypen für die Anzeige auszuwählen.")
            : AppLanguage.current.text(english: "Every recognised local data type is listed below. Your selected types are used across the dashboard.", german: "Jeder lokal erkannte Datentyp steht unten. Deine Auswahl wird im gesamten Dashboard verwendet."))
        description.font = .systemFont(ofSize: 12, weight: .medium)
        description.textColor = NSColor.white.withAlphaComponent(0.75)
        body.addArrangedSubview(description)
        guard let importedSummary else {
            body.addArrangedSubview(GuidedEmptyStateView(
                symbol: "tray.and.arrow.down.fill",
                title: AppLanguage.current.text(english: "Choose an Apple Health export", german: "Apple-Health-Export auswählen"),
                message: AppLanguage.current.text(english: "Select a local ZIP or Export.xml file. Nothing is uploaded.", german: "Wähle eine lokale ZIP- oder Export.xml-Datei. Es wird nichts hochgeladen."),
                actionTitle: AppLanguage.current.text(english: "Import Apple Health…", german: "Apple Health importieren …"),
                action: { [weak self] in self?.importFile() }
            ))
            return
        }
        let management = dataManagementRow()
        body.addArrangedSubview(management)
        let quality = DataQualityView(summary: importedSummary, selectedIDs: selectedTypeIDs, language: AppLanguage.current)
        body.addArrangedSubview(quality)
        quality.widthAnchor.constraint(equalTo: body.widthAnchor).isActive = true
        quality.heightAnchor.constraint(equalToConstant: 146).isActive = true
        let panel = MetricSelectionPanel(metrics: importedSummary.dataTypes, selectedIDs: selectedTypeIDs, favoritesByArea: favoritesByArea, metricOrder: metricOrder) { [weak self] selection, favorites, order in
            guard let self else { return }
            self.selectedTypeIDs = selection
            self.favoritesByArea = favorites
            self.favoriteTypeIDs = favorites[.overview] ?? []
            self.metricOrder = order
            self.overviewPage = 0
            BuildEnvironment.defaults.set(Array(selection), forKey: self.selectedTypeIDsPreferenceKey)
            MetricPinArea.allCases.forEach { area in BuildEnvironment.defaults.set(Array(favorites[area] ?? []), forKey: area.preferenceKey) }
            BuildEnvironment.defaults.set(order, forKey: self.metricOrderKey)
            BuildEnvironment.defaults.set(order, forKey: self.metricOrderPreferenceKey)
        }
        panel.translatesAutoresizingMaskIntoConstraints = false
        body.addArrangedSubview(panel)
        panel.widthAnchor.constraint(equalTo: body.widthAnchor).isActive = true
        panel.heightAnchor.constraint(equalToConstant: 420).isActive = true
    }

    private func buildInsights() {
        let intro = NSTextField(labelWithString: AppLanguage.current.text(english: "Descriptive local summaries — never diagnoses.", german: "Beschreibende lokale Zusammenfassungen — niemals Diagnosen."))
        intro.font = .systemFont(ofSize: 12, weight: .bold)
        intro.textColor = .white
        body.addArrangedSubview(intro)
        let metrics = selectedDataTypes(for: .insights).filter { !$0.dailyValues.isEmpty }
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
        let snapshot = InsightSnapshotView(metric: metric, accent: metricAccent, language: AppLanguage.current)
        body.addArrangedSubview(snapshot)
        snapshot.widthAnchor.constraint(equalTo: body.widthAnchor).isActive = true
        snapshot.heightAnchor.constraint(equalToConstant: 144).isActive = true
        let facts = NSStackView()
        facts.orientation = .horizontal
        facts.distribution = .fillEqually
        facts.spacing = 12
        if let comparison = HealthPeriodComparison.make(values: metric.dailyValues, metric: metric, days: 30) {
            facts.addArrangedSubview(PeriodComparisonView(comparison: comparison, metric: metric, days: 30, accent: metricAccent, language: AppLanguage.current))
        }
        facts.addArrangedSubview(InsightCoverageView(metric: metric, accent: metricAccent, language: AppLanguage.current))
        facts.translatesAutoresizingMaskIntoConstraints = false
        body.addArrangedSubview(facts)
        facts.widthAnchor.constraint(equalTo: body.widthAnchor).isActive = true
        facts.heightAnchor.constraint(equalToConstant: 110).isActive = true
        let pattern = LocalPatternView(metric: metric, accent: metricAccent, language: AppLanguage.current)
        body.addArrangedSubview(pattern)
        pattern.widthAnchor.constraint(equalTo: body.widthAnchor).isActive = true
        pattern.heightAnchor.constraint(equalToConstant: 108).isActive = true
    }

    /// Keeps the day squares separate from graphs and their animated backgrounds.
    private func localCalendarCard(for metric: HealthDataTypeSummary, accent: NSColor) -> NSView {
        let card = GlassCardView(accent: accent)
        let title = NSTextField(labelWithString: AppLanguage.current.text(english: "Local activity calendar", german: "Lokaler Datenkalender"))
        title.font = .systemFont(ofSize: 13, weight: .bold)
        title.textColor = .white
        let rangeDays = [7, 28, 90, 182, 365]
        let range = NSSegmentedControl(labels: [
            AppLanguage.current.text(english: "1 week", german: "1 Woche"),
            AppLanguage.current.text(english: "4 weeks", german: "4 Wochen"),
            AppLanguage.current.text(english: "3 months", german: "3 Monate"),
            AppLanguage.current.text(english: "6 months", german: "6 Monate"),
            AppLanguage.current.text(english: "1 year", german: "1 Jahr")
        ], trackingMode: .selectOne, target: self, action: #selector(heatmapRangeChanged(_:)))
        range.selectedSegment = rangeDays.firstIndex(of: heatmapRangeDays) ?? 2
        range.segmentStyle = .texturedRounded
        let header = NSStackView(views: [title, range])
        header.orientation = .horizontal
        header.spacing = 12
        header.alignment = .centerY
        let heatmap = CalendarHeatmapView(values: metric.dailyValues, metric: metric, tintColor: accent, days: heatmapRangeDays)
        let stack = NSStackView(views: [header, heatmap])
        stack.orientation = .vertical
        stack.spacing = 12
        stack.edgeInsets = NSEdgeInsets(top: 18, left: 22, bottom: 18, right: 22)
        stack.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: card.leadingAnchor), stack.trailingAnchor.constraint(equalTo: card.trailingAnchor),
            stack.topAnchor.constraint(equalTo: card.topAnchor), stack.bottomAnchor.constraint(equalTo: card.bottomAnchor),
            heatmap.heightAnchor.constraint(equalToConstant: 112),
            card.heightAnchor.constraint(equalToConstant: 168)
        ])
        return card
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
        rebuildBody()
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
        selectedTrendTypeID = selectedDataTypes(for: .trends).first(where: { $0.localizedDisplayName == sender.titleOfSelectedItem })?.identifier
        selectedTrendDate = nil
        rebuildBody()
    }

    @objc private func insightTypeChanged(_ sender: NSPopUpButton) {
        selectedInsightTypeID = selectedDataTypes(for: .insights).first(where: { $0.localizedDisplayName == sender.titleOfSelectedItem })?.identifier
        rebuildBody()
    }

    @objc private func heatmapRangeChanged(_ sender: NSSegmentedControl) {
        heatmapRangeDays = [7, 28, 90, 182, 365][sender.selectedSegment]
        rebuildBody()
    }

    @objc private func dashboardDensityChanged(_ sender: NSSegmentedControl) {
        dashboardDensity = sender.selectedSegment
        loadMetricOrderForCurrentLayout()
        rebuildBody()
    }

    @objc private func resetDashboardLayout() {
        BuildEnvironment.defaults.removeObject(forKey: metricOrderKey)
        guard let importedSummary else { return }
        metricOrder = importedSummary.dataTypes.map(\.identifier)
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

    private func selectedHeroMetric(from metrics: [HealthDataTypeSummary]) -> HealthDataTypeSummary? {
        if let heroMetricID, let metric = metrics.first(where: { $0.identifier == heroMetricID }) {
            return metric
        }
        return metrics.first
    }

    private func visibleMetrics() -> [HealthMetric] {
        guard importedSummary != nil else { return [] }
        let selected = selectedDataTypes()
        return selected.map { item in
            HealthMetric(identifier: item.identifier, title: item.localizedDisplayName, value: item.latestValueText, detail: item.latestDetailText, color: accentKey(for: item.identifier))
        }
    }

    private func selectedDataTypes(for area: MetricPinArea = .overview) -> [HealthDataTypeSummary] {
        guard let importedSummary else { return [] }
        let orderIndex = Dictionary(uniqueKeysWithValues: metricOrder.enumerated().map { ($0.element, $0.offset) })
        let favorites = favoritesByArea[area] ?? []
        return importedSummary.dataTypes
            .filter { selectedTypeIDs.contains($0.identifier) }
            .sorted {
                let leftFavorite = favorites.contains($0.identifier)
                let rightFavorite = favorites.contains($1.identifier)
                if leftFavorite != rightFavorite { return leftFavorite }
                return (orderIndex[$0.identifier] ?? .max) < (orderIndex[$1.identifier] ?? .max)
            }
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
        guard let latest = metric.dailyValues.last?.date else { return [] }
        let cutoff = Calendar.current.date(byAdding: .day, value: -trendRangeDays + 1, to: latest) ?? .distantPast
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
        let help = FirstLaunchHelpContent(language: AppLanguage.current)
        let hero = AnimatedImportHeroView()
        let title = NSTextField(labelWithString: help.title)
        title.font = .systemFont(ofSize: 25, weight: .bold)
        title.textColor = .white
        let detail = NSTextField(labelWithString: help.introduction)
        detail.font = .systemFont(ofSize: 13, weight: .medium)
        detail.textColor = NSColor.white.withAlphaComponent(0.72)
        let button = NSButton(title: AppLanguage.current.text(english: "Import ZIP or Export.xml…", german: "ZIP oder Export.xml importieren …"), target: self, action: #selector(importFile))
        stylePrimaryButton(button)
        button.font = .systemFont(ofSize: 13, weight: .semibold)
        button.cell?.lineBreakMode = .byTruncatingTail
        let manualButton = NSButton(title: help.manualButtonTitle, target: self, action: #selector(openFirstLaunchManual))
        manualButton.bezelStyle = .rounded
        manualButton.contentTintColor = .white
        manualButton.toolTip = help.manualButtonTitle
        let actionRow = NSStackView(views: [button, manualButton])
        actionRow.orientation = .horizontal
        actionRow.spacing = 10
        actionRow.alignment = .centerY

        let aiHeading = NSTextField(labelWithString: help.aiHeading)
        aiHeading.font = .systemFont(ofSize: 14, weight: .bold)
        aiHeading.textColor = .white
        let aiButtons = NSStackView()
        aiButtons.orientation = .horizontal
        aiButtons.spacing = 10
        aiButtons.alignment = .centerY
        FirstLaunchAIService.allCases.enumerated().forEach { index, service in
            let serviceButton = aiServiceButton(for: service, tag: index, help: help)
            aiButtons.addArrangedSubview(serviceButton)
            serviceButton.widthAnchor.constraint(equalToConstant: 172).isActive = true
            serviceButton.heightAnchor.constraint(equalToConstant: 42).isActive = true
        }
        let privacy = NSTextField(labelWithString: AppLanguage.current.text(english: "Local import · no upload · no account", german: "Lokaler Import · kein Upload · kein Konto"))
        privacy.font = .systemFont(ofSize: 11, weight: .semibold)
        privacy.textColor = .white
        let aiPrivacy = NSTextField(labelWithString: help.privacyNote)
        aiPrivacy.font = .systemFont(ofSize: 11, weight: .medium)
        aiPrivacy.textColor = NSColor.white.withAlphaComponent(0.72)
        aiPrivacy.alignment = .center
        aiPrivacy.maximumNumberOfLines = 2
        aiPrivacy.lineBreakMode = .byWordWrapping
        let stack = NSStackView(views: [hero, title, detail, actionRow, aiHeading, aiButtons, aiPrivacy, privacy])
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
            aiPrivacy.widthAnchor.constraint(lessThanOrEqualToConstant: 570),
            container.heightAnchor.constraint(equalToConstant: 560)
        ])
        return container
    }

    private func aiServiceButton(for service: FirstLaunchAIService, tag: Int, help: FirstLaunchHelpContent) -> NSButton {
        let button = NSButton(title: service.title, target: self, action: #selector(copyFirstLaunchPromptAndOpen(_:)))
        button.tag = tag
        button.bezelStyle = .rounded
        button.font = .systemFont(ofSize: 13, weight: .semibold)
        button.contentTintColor = .white
        button.imagePosition = .imageLeading
        button.imageScaling = .scaleProportionallyDown
        button.image = aiServiceLogo(for: service)
        button.toolTip = help.serviceHelp(service)
        return button
    }

    private func aiServiceLogo(for service: FirstLaunchAIService) -> NSImage? {
        guard let url = Bundle.main.url(forResource: service.logoResource.name, withExtension: service.logoResource.fileExtension),
              let image = NSImage(contentsOf: url) else {
            return nil
        }
        image.size = NSSize(width: 28, height: 28)
        image.isTemplate = false
        return image
    }

    @objc private func openFirstLaunchManual() {
        FirstLaunchHelpAction.openManual(for: AppLanguage.current)
    }

    @objc private func copyFirstLaunchPromptAndOpen(_ sender: NSButton) {
        let services = FirstLaunchAIService.allCases
        guard services.indices.contains(sender.tag) else { return }
        FirstLaunchHelpAction.copyPromptAndOpen(services[sender.tag], language: AppLanguage.current)
    }

    private func stylePrimaryButton(_ button: NSButton) {
        button.isBordered = false
        button.wantsLayer = true
        button.layer?.backgroundColor = NSColor.systemCyan.withAlphaComponent(0.90).cgColor
        button.layer?.cornerRadius = 15
        button.layer?.borderWidth = 1
        button.layer?.borderColor = NSColor.white.withAlphaComponent(0.26).cgColor
        button.font = .systemFont(ofSize: 14, weight: .bold)
        button.contentTintColor = .white
    }

    private func emptySelectionState() -> NSView {
        GuidedEmptyStateView(
            symbol: "waveform.path.ecg",
            title: AppLanguage.current.text(english: "No selected values yet", german: "Noch keine ausgewählten Werte"),
            message: AppLanguage.current.text(english: "Choose a numeric Apple Health data type in Sources to view local values.", german: "Wähle unter Quellen einen numerischen Apple-Health-Datentyp für lokale Werte aus."),
            actionTitle: AppLanguage.current.text(english: "Open Sources", german: "Quellen öffnen"),
            action: { [weak self] in self?.onRequestSection?(.sources) }
        )
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
        let columns = dashboardDensity == 2 ? 2 : 4
        for rowMetrics in metrics.chunked(into: columns) {
            let row = metricRow(metrics: rowMetrics)
            grid.addArrangedSubview(row)
            row.widthAnchor.constraint(equalTo: grid.widthAnchor).isActive = true
        }
        grid.translatesAutoresizingMaskIntoConstraints = false
        return grid
    }

    private func metricCard(_ metric: HealthMetric) -> NSView {
        let card = DraggableMetricCard(identifier: metric.identifier, accent: accent(for: metric.color)) { [weak self] source, destination in
            self?.moveDashboardMetric(source, before: destination)
        } onOpen: { [weak self] identifier in
            self?.presentMetricFocus(for: identifier)
        }
        card.toolTip = "\(metric.localizedTitle)\n\(metric.value) · \(metric.localizedDetail)\n" + AppLanguage.current.text(english: "Open focus view", german: "Fokusansicht öffnen")
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
            card.heightAnchor.constraint(equalToConstant: dashboardDensity == 0 ? 96 : (dashboardDensity == 2 ? 178 : 126))
        ])
        return card
    }

    private func moveDashboardMetric(_ source: String, before destination: String) {
        guard source != destination, let importedSummary else { return }
        let availableIDs = Set(importedSummary.dataTypes.map(\.identifier))
        var order = metricOrder.filter { availableIDs.contains($0) }
        for identifier in importedSummary.dataTypes.map(\.identifier) where !order.contains(identifier) { order.append(identifier) }
        guard let sourceIndex = order.firstIndex(of: source), let destinationIndex = order.firstIndex(of: destination) else { return }
        let moved = order.remove(at: sourceIndex)
        let target = order.firstIndex(of: destination) ?? destinationIndex
        order.insert(moved, at: target)
        metricOrder = order
        BuildEnvironment.defaults.set(order, forKey: metricOrderKey)
        rebuildBody()
    }

    private func presentMetricFocus(for identifier: String) {
        guard let metric = selectedDataTypes().first(where: { $0.identifier == identifier }) else { return }
        let controller = MetricFocusViewController(metric: metric, accent: accent(for: accentKey(for: identifier)), language: AppLanguage.current)
        controller.onOpenTrend = { [weak self, weak controller] in
            guard let self else { return }
            controller?.close()
            self.selectedTrendTypeID = identifier
            self.selectedTrendDate = nil
            self.onRequestSection?(.trends)
        }
        MetricFocusWindowController.present(controller)
    }

    @objc private func exportLocalReport() {
        guard let importedSummary else { return }
        presentReportConfiguration(for: importedSummary)
    }

    private func presentReportConfiguration(for importedSummary: ImportedHealthSummary) {
        let language = AppLanguage.current
        let alert = NSAlert()
        alert.messageText = language.text(english: "Configure local PDF report", german: "Lokalen PDF-Bericht konfigurieren")
        alert.informativeText = language.text(english: "Choose a local period, data types and the report theme. Nothing is uploaded.", german: "Wähle einen lokalen Zeitraum, Datentypen und das Bericht-Theme. Es wird nichts hochgeladen.")
        alert.addButton(withTitle: language.text(english: "Continue", german: "Weiter"))
        alert.addButton(withTitle: language.text(english: "Cancel", german: "Abbrechen"))
        let period = NSSegmentedControl(labels: ["7D", "30D", "3M", language.text(english: "All", german: "Alle")], trackingMode: .selectOne, target: nil, action: nil)
        period.selectedSegment = 1
        period.segmentStyle = .texturedRounded
        let theme = NSPopUpButton()
        theme.addItems(withTitles: AppTheme.allCases.map(\.displayName))
        theme.selectItem(withTitle: AppTheme.current.displayName)
        let typeButtons = importedSummary.dataTypes.map { metric -> NSButton in
            let button = NSButton(checkboxWithTitle: metric.localizedDisplayName, target: nil, action: nil)
            button.identifier = NSUserInterfaceItemIdentifier(metric.identifier)
            button.state = selectedTypeIDs.contains(metric.identifier) ? .on : .off
            button.contentTintColor = .white
            return button
        }
        let typeStack = NSStackView(views: typeButtons)
        typeStack.orientation = .vertical
        typeStack.alignment = .leading
        typeStack.spacing = 4
        let scroll = NSScrollView()
        scroll.drawsBackground = false
        scroll.hasVerticalScroller = typeButtons.count > 6
        scroll.documentView = typeStack
        scroll.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([scroll.heightAnchor.constraint(equalToConstant: min(190, CGFloat(max(1, typeButtons.count)) * 24))])
        let periodLabel = NSTextField(labelWithString: language.text(english: "Period", german: "Zeitraum"))
        let themeLabel = NSTextField(labelWithString: language.text(english: "Theme", german: "Theme"))
        [periodLabel, themeLabel].forEach { $0.font = .systemFont(ofSize: 12, weight: .semibold) }
        let stack = NSStackView(views: [periodLabel, period, themeLabel, theme, NSTextField(labelWithString: language.text(english: "Data types", german: "Datentypen")), scroll])
        stack.orientation = .vertical
        stack.alignment = .leading
        stack.spacing = 8
        stack.frame = NSRect(x: 0, y: 0, width: 360, height: 330)
        alert.accessoryView = stack
        alert.beginSheetModal(for: view.window!) { [weak self] response in
            guard response == .alertFirstButtonReturn, let self else { return }
            let days = [7, 30, 90, 0][period.selectedSegment]
            let chosen = importedSummary.dataTypes.filter { metric in
                typeButtons.first(where: { $0.identifier?.rawValue == metric.identifier })?.state == .on
            }
            guard !chosen.isEmpty else { return }
            let configuration = LocalReportConfiguration(days: days, themeName: theme.titleOfSelectedItem ?? AppTheme.current.displayName)
            self.saveLocalReport(summary: importedSummary, metrics: chosen, configuration: configuration)
        }
    }

    private func saveLocalReport(summary: ImportedHealthSummary, metrics: [HealthDataTypeSummary], configuration: LocalReportConfiguration) {
        let savePanel = NSSavePanel()
        savePanel.title = AppLanguage.current.text(english: "Save local HealthAtlas report", german: "Lokalen HealthAtlas-Bericht sichern")
        savePanel.message = AppLanguage.current.text(english: "The report is created only at the location you select.", german: "Der Bericht wird nur am von dir gewählten Ort erstellt.")
        savePanel.nameFieldStringValue = "HealthAtlas-Report-\(Date().formatted(.iso8601.year().month().day())).pdf"
        savePanel.allowedContentTypes = [.pdf]
        savePanel.canCreateDirectories = true
        savePanel.beginSheetModal(for: view.window!) { [weak self] response in
            guard response == .OK, let url = savePanel.url, let self else { return }
            do {
                try LocalHealthReport(summary: summary, metrics: metrics, language: AppLanguage.current, configuration: configuration).write(to: url)
                self.showReportResult(success: true, destination: url)
            } catch {
                self.showReportResult(success: false, destination: url)
            }
        }
    }

    private func showReportResult(success: Bool, destination: URL) {
        let alert = NSAlert()
        alert.alertStyle = success ? .informational : .warning
        alert.messageText = success
            ? AppLanguage.current.text(english: "Local PDF report created", german: "Lokaler PDF-Bericht erstellt")
            : AppLanguage.current.text(english: "PDF report could not be created", german: "PDF-Bericht konnte nicht erstellt werden")
        alert.informativeText = success
            ? AppLanguage.current.text(english: "Only the location you chose received the report.", german: "Nur der von dir gewählte Speicherort hat den Bericht erhalten.")
            : AppLanguage.current.text(english: "No health data was uploaded.", german: "Es wurden keine Gesundheitsdaten hochgeladen.")
        alert.addButton(withTitle: "OK")
        alert.beginSheetModal(for: view.window!)
    }

    private var shouldAnimateInterface: Bool {
        !isImporting && !NSWorkspace.shared.accessibilityDisplayShouldReduceMotion
    }

    private func animateBodyEntrance() {
        guard shouldAnimateInterface else {
            body.alphaValue = 1
            body.layer?.transform = CATransform3DIdentity
            return
        }
        NSAnimationContext.runAnimationGroup { context in
            context.duration = 0.28
            context.timingFunction = CAMediaTimingFunction(name: .easeOut)
            body.animator().alphaValue = 1
        }
        CATransaction.begin()
        CATransaction.setAnimationDuration(0.28)
        CATransaction.setAnimationTimingFunction(CAMediaTimingFunction(name: .easeOut))
        body.layer?.transform = CATransform3DIdentity
        CATransaction.commit()
    }

    private func animateMetricCards(in grid: NSView) {
        guard shouldAnimateInterface,
              let rows = grid as? NSStackView else { return }
        let cards = rows.arrangedSubviews
            .compactMap { $0 as? NSStackView }
            .flatMap(\.arrangedSubviews)
        for (index, card) in cards.enumerated() {
            card.wantsLayer = true
            card.alphaValue = 0
            card.layer?.transform = CATransform3DMakeTranslation(0, 14, 0)
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) * 0.055) { [weak self, weak card] in
                guard let self, let card, self.shouldAnimateInterface else { return }
                NSAnimationContext.runAnimationGroup { context in
                    context.duration = 0.26
                    context.timingFunction = CAMediaTimingFunction(name: .easeOut)
                    card.animator().alphaValue = 1
                }
                CATransaction.begin()
                CATransaction.setAnimationDuration(0.26)
                CATransaction.setAnimationTimingFunction(CAMediaTimingFunction(name: .easeOut))
                card.layer?.transform = CATransform3DIdentity
                CATransaction.commit()
            }
        }
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
        panel.message = AppLanguage.current.text(english: "Select an Apple Health ZIP archive or Export.xml file. The data is read directly from the ZIP and stays on this Mac.", german: "Wähle ein Apple-Health-ZIP-Archiv oder eine Export.xml-Datei. Die Daten werden direkt aus der ZIP gelesen und bleiben auf diesem Mac.")
        panel.prompt = AppLanguage.current.text(english: "Import", german: "Importieren")
        panel.canChooseFiles = true
        panel.canChooseDirectories = false
        panel.allowsMultipleSelection = false
        panel.allowedContentTypes = [.zip, .xml]
        panel.allowsOtherFileTypes = false
        panel.beginSheetModal(for: view.window!) { [weak self] response in
            guard response == .OK, let url = panel.url else { return }
            self?.beginImport(from: url)
        }
    }

    private func dataManagementRow() -> NSView {
        let language = AppLanguage.current
        let replace = NSButton(title: language.text(english: "Replace import…", german: "Import ersetzen …"), target: self, action: #selector(importFile))
        replace.bezelStyle = .rounded
        replace.contentTintColor = .white
        let delete = NSButton(title: language.text(english: "Delete all local data…", german: "Alle lokalen Daten löschen …"), target: self, action: #selector(confirmDeleteLocalData))
        delete.bezelStyle = .rounded
        delete.contentTintColor = .systemRed
        let timestamp = importTimestamp.map { date in
            language.text(english: "Imported in this session: \(date.formatted(date: .abbreviated, time: .shortened))", german: "In dieser Sitzung importiert: \(date.formatted(date: .abbreviated, time: .shortened))")
        } ?? language.text(english: "No local import in this session", german: "Kein lokaler Import in dieser Sitzung")
        let label = NSTextField(labelWithString: timestamp)
        label.font = .systemFont(ofSize: 11, weight: .medium)
        label.textColor = NSColor.white.withAlphaComponent(0.70)
        let row = NSStackView(views: [replace, delete, label])
        row.orientation = .horizontal
        row.spacing = 10
        row.alignment = .centerY
        return row
    }

    @objc private func confirmDeleteLocalData() {
        let language = AppLanguage.current
        let alert = NSAlert()
        alert.alertStyle = .warning
        alert.messageText = language.text(english: "Delete all local health data?", german: "Alle lokalen Gesundheitsdaten löschen?")
        alert.informativeText = language.text(english: "This removes the imported session data and HealthAtlas selections, pins and saved dashboard layouts on this Mac. Themes and language remain unchanged.", german: "Dadurch werden die importierten Sitzungsdaten sowie HealthAtlas-Auswahl, Pins und gespeicherte Dashboard-Anordnungen auf diesem Mac gelöscht. Theme und Sprache bleiben erhalten.")
        alert.addButton(withTitle: language.text(english: "Delete local data", german: "Lokale Daten löschen"))
        alert.addButton(withTitle: language.text(english: "Cancel", german: "Abbrechen"))
        alert.beginSheetModal(for: view.window!) { [weak self] response in
            guard response == .alertFirstButtonReturn else { return }
            self?.deleteLocalHealthData()
        }
    }

    private func deleteLocalHealthData() {
        importedSummary = nil
        importTimestamp = nil
        selectedTypeIDs = []
        favoriteTypeIDs = []
        favoritesByArea = Dictionary(uniqueKeysWithValues: MetricPinArea.allCases.map { ($0, Set<String>()) })
        metricOrder = []
        selectedTrendTypeID = nil
        selectedInsightTypeID = nil
        selectedTrendDate = nil
        overviewPage = 0
        let keys = [selectedTypeIDsPreferenceKey, favoriteTypeIDsPreferenceKey, metricOrderPreferenceKey, heroMetricID == nil ? "" : "HealthAtlas.heroMetricID"]
            + MetricPinArea.allCases.map(\.preferenceKey)
            + ["HealthAtlas.healthMetricOrder.layout.0", "HealthAtlas.healthMetricOrder.layout.1", "HealthAtlas.healthMetricOrder.layout.2"]
        keys.filter { !$0.isEmpty }.forEach { BuildEnvironment.defaults.removeObject(forKey: $0) }
        rebuildBody()
    }

    private func beginImport(from url: URL) {
        guard !isImporting else { return }
        isImporting = true
        onActivityChanged?(true)
        showImportProgress()
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            let result = LocalImportValidator.validate(url: url)
            DispatchQueue.main.async {
                self?.finishImport(with: result)
            }
        }
    }

    private func showImportProgress() {
        importProgressOverlay?.removeFromSuperview()
        let overlay = ImportProgressOverlayView(language: AppLanguage.current)
        overlay.translatesAutoresizingMaskIntoConstraints = false
        overlay.alphaValue = 0
        view.addSubview(overlay)
        NSLayoutConstraint.activate([
            overlay.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            overlay.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            overlay.widthAnchor.constraint(equalToConstant: 350),
            overlay.heightAnchor.constraint(equalToConstant: 154)
        ])
        importProgressOverlay = overlay
        guard !NSWorkspace.shared.accessibilityDisplayShouldReduceMotion else {
            overlay.alphaValue = 1
            return
        }
        overlay.wantsLayer = true
        overlay.layer?.transform = CATransform3DMakeTranslation(0, 10, 0)
        NSAnimationContext.runAnimationGroup { context in
            context.duration = 0.2
            overlay.animator().alphaValue = 1
        }
        CATransaction.begin()
        CATransaction.setAnimationDuration(0.2)
        CATransaction.setAnimationTimingFunction(CAMediaTimingFunction(name: .easeOut))
        overlay.layer?.transform = CATransform3DIdentity
        CATransaction.commit()
    }

    private func finishImport(with result: LocalImportResult) {
        let overlay = importProgressOverlay
        importProgressOverlay = nil
        let completeImport: @MainActor () -> Void = { [weak self, weak overlay] in
            overlay?.removeFromSuperview()
            guard let self else { return }
            self.isImporting = false
            self.onActivityChanged?(false)
            if case let .imported(summary) = result, !NSWorkspace.shared.accessibilityDisplayShouldReduceMotion {
                self.applyImportedSummary(summary)
                self.showImportSuccessShimmer()
            } else {
                self.showImportResult(result)
            }
        }
        guard let overlay, !NSWorkspace.shared.accessibilityDisplayShouldReduceMotion else {
            completeImport()
            return
        }
        NSAnimationContext.runAnimationGroup { context in
            context.duration = 0.16
            overlay.animator().alphaValue = 0
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.17) { @MainActor in
            completeImport()
        }
    }

    private func showImportSuccessShimmer() {
        let shimmer = ImportSuccessShimmerView(language: AppLanguage.current) { [weak self] in
            self?.view.window?.makeFirstResponder(nil)
        }
        shimmer.translatesAutoresizingMaskIntoConstraints = false
        shimmer.alphaValue = 0
        view.addSubview(shimmer)
        NSLayoutConstraint.activate([
            shimmer.centerXAnchor.constraint(equalTo: view.centerXAnchor), shimmer.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            shimmer.widthAnchor.constraint(equalToConstant: 460), shimmer.heightAnchor.constraint(equalToConstant: 176)
        ])
        NSAnimationContext.runAnimationGroup { context in context.duration = 0.16; shimmer.animator().alphaValue = 1 }
    }

    private func showImportResult(_ result: LocalImportResult) {
        let alert = NSAlert()
        switch result {
        case .imported(let summary):
            applyImportedSummary(summary)
            alert.alertStyle = .informational
            alert.messageText = AppLanguage.current.text(english: "Apple Health imported locally", german: "Apple Health lokal importiert")
            alert.informativeText = summary.fileName.lowercased().hasSuffix(".zip")
                ? AppLanguage.current.text(english: "The ZIP archive was read directly. Recognised data types are ready in Sources.", german: "Das ZIP-Archiv wurde direkt gelesen. Erkannte Datentypen sind unter Quellen bereit.")
                : AppLanguage.current.text(english: "Recognised data types are ready in Sources. Select exactly what you want to display.", german: "Erkannte Datentypen sind unter Quellen bereit. Wähle dort genau aus, was angezeigt werden soll.")
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
        isScreenshotDemoLoaded = true
        applyImportedSummary(summary, selectAll: true)
    }

    private func applyImportedSummary(_ summary: ImportedHealthSummary, selectAll: Bool = false) {
        importedSummary = summary
        importTimestamp = Date()
        let savedIDs = Set(BuildEnvironment.defaults.stringArray(forKey: selectedTypeIDsPreferenceKey) ?? [])
        let validSavedIDs = Set(summary.dataTypes.map(\.identifier)).intersection(savedIDs)
        let validIDs = Set(summary.dataTypes.map(\.identifier))
        let legacyFavorites = Set(BuildEnvironment.defaults.stringArray(forKey: favoriteTypeIDsPreferenceKey) ?? []).intersection(validIDs)
        favoritesByArea = Dictionary(uniqueKeysWithValues: MetricPinArea.allCases.map { area in
            let saved = Set(BuildEnvironment.defaults.stringArray(forKey: area.preferenceKey) ?? [])
            return (area, (saved.isEmpty ? legacyFavorites : saved).intersection(validIDs))
        })
        favoriteTypeIDs = favoritesByArea[.overview] ?? []
        loadMetricOrderForCurrentLayout(validIDs: validIDs, fallback: summary.dataTypes.map(\.identifier))
        selectedTypeIDs = selectAll
            ? Set(summary.dataTypes.map(\.identifier))
            : (validSavedIDs.isEmpty ? Set(summary.dataTypes.prefix(4).map(\.identifier)) : validSavedIDs)
        selectedTrendTypeID = nil
        selectedTrendDate = nil
        overviewPage = 0
        rebuildBody()
    }

    private func loadMetricOrderForCurrentLayout(validIDs: Set<String>? = nil, fallback: [String]? = nil) {
        let available = validIDs ?? Set(importedSummary?.dataTypes.map(\.identifier) ?? [])
        let defaultOrder = fallback ?? importedSummary?.dataTypes.map(\.identifier) ?? []
        let saved = BuildEnvironment.defaults.stringArray(forKey: metricOrderKey) ?? []
        metricOrder = saved.filter { available.contains($0) }
        metricOrder.append(contentsOf: defaultOrder.filter { !metricOrder.contains($0) })
    }
}

private final class ImportProgressOverlayView: NSVisualEffectView {
    init(language: AppLanguage) {
        super.init(frame: .zero)
        material = .hudWindow
        blendingMode = .withinWindow
        state = .active
        wantsLayer = true
        layer?.cornerRadius = 20
        layer?.borderWidth = 1
        layer?.borderColor = NSColor.white.withAlphaComponent(0.22).cgColor

        let spinner = NSProgressIndicator()
        spinner.style = .spinning
        spinner.controlSize = .regular
        spinner.startAnimation(nil)
        let title = NSTextField(labelWithString: language.text(english: "Reading Apple Health locally…", german: "Apple Health wird lokal gelesen …"))
        title.font = .systemFont(ofSize: 16, weight: .bold)
        title.textColor = .white
        title.alignment = .center
        let detail = NSTextField(wrappingLabelWithString: language.text(english: "The ZIP or Export.xml stays on this Mac. Nothing is uploaded.", german: "Die ZIP oder Export.xml bleibt auf diesem Mac. Es wird nichts hochgeladen."))
        detail.font = .systemFont(ofSize: 12, weight: .medium)
        detail.textColor = NSColor.white.withAlphaComponent(0.72)
        detail.alignment = .center
        detail.maximumNumberOfLines = 2
        detail.lineBreakMode = .byWordWrapping
        let stack = NSStackView(views: [spinner, title, detail])
        stack.orientation = .vertical
        stack.alignment = .centerX
        stack.spacing = 10
        stack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stack)
        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 26),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -26),
            stack.centerYAnchor.constraint(equalTo: centerYAnchor),
            spinner.widthAnchor.constraint(equalToConstant: 26),
            spinner.heightAnchor.constraint(equalToConstant: 26)
        ])
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}

private final class ImportSuccessShimmerView: NSVisualEffectView {
    private let onDismiss: () -> Void

    init(language: AppLanguage, onDismiss: @escaping () -> Void) {
        self.onDismiss = onDismiss
        super.init(frame: .zero)
        material = .hudWindow
        blendingMode = .withinWindow
        state = .active
        wantsLayer = true
        layer?.cornerRadius = 20
        layer?.borderWidth = 1
        layer?.borderColor = NSColor.systemGreen.withAlphaComponent(0.72).cgColor
        let icon = NSImageView(image: NSImage(systemSymbolName: "checkmark.circle.fill", accessibilityDescription: nil) ?? NSImage())
        icon.contentTintColor = .systemGreen
        let title = NSTextField(labelWithString: language.text(english: "Import successful", german: "Import erfolgreich"))
        title.font = .systemFont(ofSize: 18, weight: .bold); title.textColor = .white
        let detail = NSTextField(wrappingLabelWithString: language.text(english: "Your selected data stays on this Mac. You can choose the displayed types in Sources.", german: "Deine ausgewählten Daten bleiben auf diesem Mac. Unter Quellen wählst du die angezeigten Datentypen."))
        detail.font = .systemFont(ofSize: 12, weight: .medium); detail.textColor = NSColor.white.withAlphaComponent(0.74); detail.maximumNumberOfLines = 2
        let labels = NSStackView(views: [title, detail]); labels.orientation = .vertical; labels.alignment = .leading; labels.spacing = 5
        let stack = NSStackView(views: [icon, labels]); stack.orientation = .horizontal; stack.alignment = .centerY; stack.spacing = 13; stack.translatesAutoresizingMaskIntoConstraints = false
        let dismiss = NSButton(title: language.text(english: "Close", german: "Schließen"), target: self, action: #selector(dismissSuccess))
        dismiss.bezelStyle = .rounded
        dismiss.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stack)
        addSubview(dismiss)
        NSLayoutConstraint.activate([
            icon.widthAnchor.constraint(equalToConstant: 34), icon.heightAnchor.constraint(equalToConstant: 34),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 30), stack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -30),
            stack.topAnchor.constraint(equalTo: topAnchor, constant: 34), detail.widthAnchor.constraint(lessThanOrEqualToConstant: 340),
            dismiss.topAnchor.constraint(equalTo: stack.bottomAnchor, constant: 18), dismiss.centerXAnchor.constraint(equalTo: centerXAnchor),
            dismiss.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -24)
        ])
    }

    @objc private func dismissSuccess() {
        onDismiss()
        removeFromSuperview()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}

private final class MetricSelectionPanel: GlassCardView, NSTableViewDataSource, NSTableViewDelegate {
    private let table = NSTableView()
    private var metrics: [HealthDataTypeSummary]
    private var selectedIDs: Set<String>
    private var favoritesByArea: [MetricPinArea: Set<String>]
    private var selectedPinArea: MetricPinArea = .overview
    private var metricOrder: [String]
    private var searchTerm = ""
    private var selectedCategory: HealthDataCategory?
    private let onChange: (Set<String>, [MetricPinArea: Set<String>], [String]) -> Void

    private var visibleMetrics: [HealthDataTypeSummary] = []

    private func refreshVisibleMetrics() {
        visibleMetrics = metrics.filter { metric in
            let matchesCategory = selectedCategory.map { HealthDataCategory.category(for: metric.identifier) == $0 } ?? true
            let matchesSearch = searchTerm.isEmpty || metric.localizedDisplayName.localizedCaseInsensitiveContains(searchTerm)
            return matchesCategory && matchesSearch
        }.sorted { lhs, rhs in
            let lhsCategory = HealthDataCategory.category(for: lhs.identifier)
            let rhsCategory = HealthDataCategory.category(for: rhs.identifier)
            if lhsCategory != rhsCategory { return lhsCategory.sortOrder < rhsCategory.sortOrder }
            return lhs.localizedDisplayName.localizedStandardCompare(rhs.localizedDisplayName) == .orderedAscending
        }
        table.reloadData()
    }

    init(metrics: [HealthDataTypeSummary], selectedIDs: Set<String>, favoritesByArea: [MetricPinArea: Set<String>], metricOrder: [String], onChange: @escaping (Set<String>, [MetricPinArea: Set<String>], [String]) -> Void) {
        self.metrics = metrics
        self.selectedIDs = selectedIDs
        self.favoritesByArea = favoritesByArea
        self.metricOrder = metricOrder
        self.onChange = onChange
        super.init(accent: .systemCyan)
        let all = NSButton(title: AppLanguage.current.text(english: "Show all", german: "Alle anzeigen"), target: self, action: #selector(showAllMetrics))
        all.bezelStyle = .rounded
        let none = NSButton(title: AppLanguage.current.text(english: "Show none", german: "Keine anzeigen"), target: self, action: #selector(selectNone))
        none.bezelStyle = .rounded
        let categoryButton = NSPopUpButton()
        categoryButton.addItem(withTitle: AppLanguage.current.text(english: "All categories", german: "Alle Kategorien"))
        HealthDataCategory.allCases.forEach { category in categoryButton.addItem(withTitle: category.displayName(for: .current)) }
        categoryButton.target = self
        categoryButton.action = #selector(categoryChanged(_:))
        let search = NSSearchField()
        search.placeholderString = AppLanguage.current.text(english: "Search data types", german: "Datentypen suchen")
        search.target = self
        search.action = #selector(searchChanged(_:))
        let pinPicker = NSSegmentedControl(labels: MetricPinArea.allCases.map { $0.title(for: .current) }, trackingMode: .selectOne, target: self, action: #selector(pinAreaChanged(_:)))
        pinPicker.selectedSegment = 0
        pinPicker.segmentStyle = .texturedRounded
        pinPicker.toolTip = AppLanguage.current.text(english: "Choose where the star pins a data type", german: "Wähle, wo der Stern einen Datentyp anpinnt")
        let controls = NSStackView(views: [all, none, categoryButton, search, pinPicker])
        controls.spacing = 8
        controls.translatesAutoresizingMaskIntoConstraints = false

        let scroll = NSScrollView()
        scroll.drawsBackground = false
        scroll.hasVerticalScroller = true
        scroll.translatesAutoresizingMaskIntoConstraints = false
        table.headerView = NSTableHeaderView()
        table.rowHeight = 31
        table.gridStyleMask = [.solidHorizontalGridLineMask]
        table.gridColor = NSColor.white.withAlphaComponent(0.08)
        table.backgroundColor = .clear
        table.delegate = self
        table.dataSource = self
        let columnTitles = [
            "show": AppLanguage.current.text(english: "Show", german: "Anzeigen"),
            "favorite": AppLanguage.current.text(english: "Pin", german: "Pin"),
            "dataType": AppLanguage.current.text(english: "Data type", german: "Datentyp"),
            "category": AppLanguage.current.text(english: "Category", german: "Kategorie"),
            "samples": AppLanguage.current.text(english: "Values", german: "Werte"),
            "value": AppLanguage.current.text(english: "Local value", german: "Lokaler Wert"),
            "order": AppLanguage.current.text(english: "Order", german: "Reihenfolge")
        ]
        ["show", "favorite", "dataType", "category", "samples", "value", "order"].forEach { id in
            let column = NSTableColumn(identifier: NSUserInterfaceItemIdentifier(id))
            column.title = columnTitles[id] ?? id
            column.width = switch id {
            case "show": 104
            case "favorite": 56
            case "dataType": 220
            case "category": 88
            case "order": 74
            default: 92
            }
            table.addTableColumn(column)
        }
        scroll.documentView = table
        addSubview(controls)
        addSubview(scroll)
        refreshVisibleMetrics()
        NSLayoutConstraint.activate([
            controls.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16), controls.topAnchor.constraint(equalTo: topAnchor, constant: 14),
            scroll.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12), scroll.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
            scroll.topAnchor.constraint(equalTo: controls.bottomAnchor, constant: 10), scroll.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12)
        ])
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    func numberOfRows(in tableView: NSTableView) -> Int { visibleMetrics.count }
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        guard let id = tableColumn?.identifier.rawValue else { return nil }
        let metric = visibleMetrics[row]
        if id == "show" {
            let checkbox = NSButton(checkboxWithTitle: "", target: self, action: #selector(toggleMetric(_:)))
            checkbox.tag = row
            checkbox.state = selectedIDs.contains(metric.identifier) ? .on : .off
            return checkbox
        }
        if id == "favorite" {
            let favorites = favoritesByArea[selectedPinArea] ?? []
            let favorite = NSButton(title: favorites.contains(metric.identifier) ? "★" : "☆", target: self, action: #selector(toggleFavorite(_:)))
            favorite.tag = row
            favorite.isBordered = false
            favorite.font = .systemFont(ofSize: 17, weight: .medium)
            favorite.contentTintColor = favorites.contains(metric.identifier) ? .systemYellow : .white.withAlphaComponent(0.55)
            favorite.toolTip = AppLanguage.current.text(english: "Pin in \(selectedPinArea.title(for: .current))", german: "In \(selectedPinArea.title(for: .current)) anpinnen")
            return favorite
        }
        if id == "order" {
            let up = NSButton(title: "↑", target: self, action: #selector(moveMetricUp(_:)))
            let down = NSButton(title: "↓", target: self, action: #selector(moveMetricDown(_:)))
            [up, down].forEach { $0.tag = row; $0.isBordered = false; $0.contentTintColor = .white }
            let controls = NSStackView(views: [up, down])
            controls.spacing = 2
            return controls
        }
        let text: String
        switch id {
        case "dataType": text = metric.localizedDisplayName
        case "category": text = HealthDataCategory.category(for: metric.identifier).displayName(for: .current)
        case "samples": text = metric.recordCount.formatted()
        default: text = metric.valueText
        }
        let label = NSTextField(labelWithString: text)
        let category = HealthDataCategory.category(for: metric.identifier)
        label.font = .systemFont(ofSize: 12, weight: id == "dataType" ? .semibold : (id == "category" ? .medium : .regular))
        label.textColor = id == "category" ? category.sourcesColor : .white.withAlphaComponent(id == "dataType" ? 0.92 : 0.68)
        label.translatesAutoresizingMaskIntoConstraints = false
        let container = NSView()
        container.addSubview(label)
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            label.trailingAnchor.constraint(lessThanOrEqualTo: container.trailingAnchor),
            label.centerYAnchor.constraint(equalTo: container.centerYAnchor)
        ])
        return container
    }
    @objc private func toggleMetric(_ sender: NSButton) {
        let id = visibleMetrics[sender.tag].identifier
        if sender.state == .on { selectedIDs.insert(id) } else { selectedIDs.remove(id) }
        publishChange()
    }
    @objc private func toggleFavorite(_ sender: NSButton) {
        let id = visibleMetrics[sender.tag].identifier
        var favorites = favoritesByArea[selectedPinArea] ?? []
        if favorites.contains(id) { favorites.remove(id) } else { favorites.insert(id) }
        favoritesByArea[selectedPinArea] = favorites
        table.reloadData()
        publishChange()
    }
    @objc private func pinAreaChanged(_ sender: NSSegmentedControl) {
        selectedPinArea = MetricPinArea.allCases[sender.selectedSegment]
        table.reloadData()
    }
    @objc private func moveMetricUp(_ sender: NSButton) { moveMetric(at: sender.tag, direction: -1) }
    @objc private func moveMetricDown(_ sender: NSButton) { moveMetric(at: sender.tag, direction: 1) }
    @objc private func searchChanged(_ sender: NSSearchField) { searchTerm = sender.stringValue; refreshVisibleMetrics() }
    @objc private func categoryChanged(_ sender: NSPopUpButton) {
        selectedCategory = sender.indexOfSelectedItem == 0 ? nil : HealthDataCategory.allCases[sender.indexOfSelectedItem - 1]
        refreshVisibleMetrics()
    }
    @objc private func showAllMetrics() { selectedIDs = Set(metrics.map(\.identifier)); table.reloadData(); publishChange() }
    @objc private func selectNone() { selectedIDs = []; table.reloadData(); publishChange() }

    private func moveMetric(at visibleIndex: Int, direction: Int) {
        let id = visibleMetrics[visibleIndex].identifier
        guard let index = metricOrder.firstIndex(of: id) else { return }
        let destination = index + direction
        guard metricOrder.indices.contains(destination) else { return }
        metricOrder.swapAt(index, destination)
        metrics.sort { (metricOrder.firstIndex(of: $0.identifier) ?? .max) < (metricOrder.firstIndex(of: $1.identifier) ?? .max) }
        refreshVisibleMetrics()
        publishChange()
    }

    private func publishChange() {
        onChange(selectedIDs, favoritesByArea, metricOrder)
    }
}

private extension HealthDataCategory {
    var sourcesColor: NSColor {
        switch self {
        case .activity: .systemGreen
        case .body: .systemOrange
        case .cycleTracking: .systemPink
        case .hearing: .systemIndigo
        case .heart: .systemRed
        case .mindfulness: .systemPurple
        case .mobility: .systemTeal
        case .nutrition: .systemYellow
        case .respiratory: .systemCyan
        case .sleep: .systemBlue
        case .symptoms: .systemBrown
        case .vitals: .systemMint
        case .selfCare: .systemGray
        case .other: .secondaryLabelColor
        }
    }
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
    private var phase: CGFloat = 0
    private var timer: Timer?

    func apply(theme: AppTheme) { self.theme = theme; needsDisplay = true }
    override var isOpaque: Bool { false }

    override func viewDidMoveToWindow() {
        super.viewDidMoveToWindow()
        guard window != nil, timer == nil, !NSWorkspace.shared.accessibilityDisplayShouldReduceMotion else { return }
        timer = Timer.scheduledTimer(timeInterval: 1.0 / 30.0, target: self, selector: #selector(advance), userInfo: nil, repeats: true)
        RunLoop.main.add(timer!, forMode: .common)
    }

    override func viewWillMove(toWindow newWindow: NSWindow?) {
        if newWindow == nil { timer?.invalidate(); timer = nil }
        super.viewWillMove(toWindow: newWindow)
    }

    @objc private func advance() {
        phase += 0.008
        needsDisplay = true
    }

    override func draw(_ dirtyRect: NSRect) {
        guard theme != .clearGlass else { return }
        NSGradient(colors: theme.colors)?.draw(in: bounds, angle: -35)
        let x = bounds.width * (0.34 + 0.025 * sin(phase))
        let y = bounds.height * (0.40 + 0.035 * cos(phase * 0.8))
        let glow = NSBezierPath(ovalIn: NSRect(x: x, y: y, width: bounds.width * 0.65, height: bounds.height * 0.85))
        theme.accent.withAlphaComponent(0.12).setFill()
        glow.fill()
        let secondaryGlow = NSBezierPath(ovalIn: NSRect(x: bounds.width * 0.06, y: bounds.height * (0.04 + 0.03 * sin(phase * 0.6)), width: bounds.width * 0.32, height: bounds.height * 0.28))
        NSColor.white.withAlphaComponent(0.025).setFill()
        secondaryGlow.fill()
    }
}

/// A single, window-wide Clear Glass layer. It deliberately sits above every
/// column so the atmosphere remains continuous instead of restarting per pane.
private final class ClearGlassAtmosphereView: NSView {
    private struct Spark {
        let unitPosition: CGPoint
        let color: NSColor
        let radius: CGFloat
        let bornAt: TimeInterval
        let lifetime: TimeInterval
        let drift: CGVector
    }

    private var theme = AppTheme.current
    private var phase: CGFloat = 0
    private var timer: Timer?
    private var sparks: [Spark] = []
    private var lastSparkAt: TimeInterval = 0
    private var nextSparkDelay: TimeInterval = 0.28
    private var isPerformanceSensitive = false
    private let drawsAmbient: Bool
    private let emitsSparks: Bool

    init(drawsAmbient: Bool, emitsSparks: Bool) {
        self.drawsAmbient = drawsAmbient
        self.emitsSparks = emitsSparks
        super.init(frame: .zero)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override var isOpaque: Bool { false }

    func apply(theme: AppTheme) {
        self.theme = theme
        isHidden = theme != .clearGlass
        refreshAnimationState()
        needsDisplay = true
    }

    func setPerformanceSensitive(_ isPerformanceSensitive: Bool) {
        self.isPerformanceSensitive = isPerformanceSensitive
        refreshAnimationState()
        needsDisplay = true
    }

    override func hitTest(_ point: NSPoint) -> NSView? { nil }

    override func viewDidMoveToWindow() {
        super.viewDidMoveToWindow()
        refreshAnimationState()
    }

    override func viewWillMove(toWindow newWindow: NSWindow?) {
        if newWindow == nil { stopTimer() }
        super.viewWillMove(toWindow: newWindow)
    }

    private var shouldReduceMotion: Bool {
        NSWorkspace.shared.accessibilityDisplayShouldReduceMotion
    }

    private func refreshAnimationState() {
        guard window != nil, theme == .clearGlass, !isPerformanceSensitive, !shouldReduceMotion else {
            stopTimer()
            return
        }
        guard timer == nil else { return }
        let timer = Timer.scheduledTimer(timeInterval: 1.0 / 30.0, target: self, selector: #selector(advance), userInfo: nil, repeats: true)
        self.timer = timer
        RunLoop.main.add(timer, forMode: .common)
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }

    @objc private func advance() {
        guard !shouldReduceMotion, !isPerformanceSensitive, theme == .clearGlass else {
            refreshAnimationState()
            return
        }
        phase += 0.00022
        let now = ProcessInfo.processInfo.systemUptime
        sparks.removeAll { now - $0.bornAt >= $0.lifetime }
        if emitsSparks, now - lastSparkAt >= nextSparkDelay {
            for _ in 0..<Int.random(in: 3 ... 6) {
                sparks.append(makeSpark(now: now))
            }
            lastSparkAt = now
            nextSparkDelay = Double.random(in: 0.24 ... 0.62)
        }
        needsDisplay = true
    }

    private func makeSpark(now: TimeInterval) -> Spark {
        let colors: [NSColor] = [.systemCyan, .systemTeal, .systemBlue, .systemPurple, .systemPink, .systemYellow]
        return Spark(
            unitPosition: CGPoint(x: CGFloat.random(in: 0.04 ... 0.96), y: CGFloat.random(in: 0.05 ... 0.95)),
            color: colors.randomElement() ?? .systemCyan,
            radius: CGFloat.random(in: 1.4 ... 3.2),
            bornAt: now,
            lifetime: Double.random(in: 1.6 ... 3.8),
            drift: CGVector(dx: CGFloat.random(in: -8 ... 8), dy: CGFloat.random(in: -7 ... 7))
        )
    }

    override func draw(_ dirtyRect: NSRect) {
        guard theme == .clearGlass, !bounds.isEmpty else { return }

        if drawsAmbient {
            NSColor(calibratedRed: 0.09, green: 0.18, blue: 0.40, alpha: 0.055).setFill()
            bounds.fill()

            let colors: [NSColor] = [.systemCyan, .systemTeal, .systemBlue, .systemPurple, .systemPink]
            for index in colors.indices {
                let travel = (phase + CGFloat(index) * 0.27).truncatingRemainder(dividingBy: 1)
                let center = NSPoint(x: bounds.width * (travel * 1.62 - 0.32), y: bounds.height * (travel * 1.38 - 0.19))
                let radius = max(bounds.width, bounds.height) * (0.56 + CGFloat(index % 2) * 0.12)
                NSGradient(starting: colors[index].withAlphaComponent(0.21), ending: colors[index].withAlphaComponent(0))?.draw(fromCenter: center, radius: 0, toCenter: center, radius: radius, options: [])
            }

            for index in 0..<3 {
                let line = NSBezierPath(); line.lineWidth = 0.8
                let baseline = bounds.height * (0.16 + CGFloat(index) * 0.31)
                for x in stride(from: CGFloat(0), through: bounds.width, by: 18) {
                    let y = baseline + sin(x / max(bounds.width, 1) * .pi * 2.4 + phase * 8 + CGFloat(index) * 1.8) * 18
                    x == 0 ? line.move(to: NSPoint(x: x, y: y)) : line.line(to: NSPoint(x: x, y: y))
                }
                let contourColors: [NSColor] = [.systemCyan, .systemPurple, .systemPink]
                contourColors[index].withAlphaComponent(0.055).setStroke()
                line.stroke()
            }
            let glyphs = ["heart.fill", "waveform.path.ecg", "figure.walk", "moon.stars.fill"]
            for (index, glyph) in glyphs.enumerated() {
                let x = bounds.width * [0.16, 0.46, 0.72, 0.88][index]
                let y = bounds.height * [0.74, 0.28, 0.64, 0.18][index] + sin(phase * 5 + CGFloat(index)) * 8
                let image = NSImage(systemSymbolName: glyph, accessibilityDescription: nil)
                image?.withSymbolConfiguration(NSImage.SymbolConfiguration(pointSize: 32, weight: .regular))?.draw(in: NSRect(x: x - 16, y: y - 16, width: 32, height: 32), from: .zero, operation: .sourceOver, fraction: 0.045)
            }
        }

        guard emitsSparks, !shouldReduceMotion, !isPerformanceSensitive else { return }
        let now = ProcessInfo.processInfo.systemUptime
        for spark in sparks {
            let age = CGFloat((now - spark.bornAt) / spark.lifetime)
            guard (0 ... 1).contains(age) else { continue }
            let brightness = sin(age * .pi)
            let position = NSPoint(
                x: spark.unitPosition.x * bounds.width + spark.drift.dx * age,
                y: spark.unitPosition.y * bounds.height + spark.drift.dy * age
            )
            let haloRadius = spark.radius * (3.2 + brightness * 1.4)
            NSGradient(
                starting: spark.color.withAlphaComponent(0.16 * brightness),
                ending: spark.color.withAlphaComponent(0)
            )?.draw(fromCenter: position, radius: 0, toCenter: position, radius: haloRadius, options: [])
            spark.color.withAlphaComponent(0.48 * brightness).setFill()
            NSBezierPath(ovalIn: NSRect(x: position.x - spark.radius, y: position.y - spark.radius, width: spark.radius * 2, height: spark.radius * 2)).fill()
        }
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
        guard window != nil, !NSWorkspace.shared.accessibilityDisplayShouldReduceMotion else { return }
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

private final class GuidedEmptyStateView: GlassCardView {
    private let action: () -> Void

    init(symbol: String, title: String, message: String, actionTitle: String, action: @escaping () -> Void) {
        self.action = action
        super.init(accent: .systemCyan)
        let illustration = EmptyGlassIllustrationView(symbol: symbol)
        illustration.translatesAutoresizingMaskIntoConstraints = false
        let heading = NSTextField(labelWithString: title)
        heading.font = .systemFont(ofSize: 18, weight: .bold)
        heading.textColor = .white
        heading.alignment = .center
        let detail = NSTextField(wrappingLabelWithString: message)
        detail.font = .systemFont(ofSize: 12, weight: .medium)
        detail.textColor = NSColor.white.withAlphaComponent(0.76)
        detail.alignment = .center
        detail.maximumNumberOfLines = 2
        let button = NSButton(title: actionTitle, target: self, action: #selector(runAction))
        button.bezelStyle = .rounded
        button.contentTintColor = .white
        button.font = .systemFont(ofSize: 13, weight: .semibold)
        let stack = NSStackView(views: [illustration, heading, detail, button])
        stack.orientation = .vertical
        stack.alignment = .centerX
        stack.spacing = 10
        stack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stack)
        NSLayoutConstraint.activate([
            illustration.widthAnchor.constraint(equalToConstant: 74), illustration.heightAnchor.constraint(equalToConstant: 74),
            detail.widthAnchor.constraint(lessThanOrEqualToConstant: 420),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 22), stack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -22),
            stack.topAnchor.constraint(equalTo: topAnchor, constant: 24), stack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -24),
            heightAnchor.constraint(greaterThanOrEqualToConstant: 220)
        ])
    }

    @objc private func runAction() { action() }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}

private final class EmptyGlassIllustrationView: NSView {
    private let symbol: String
    private var phase: CGFloat = 0
    private var timer: Timer?

    init(symbol: String) { self.symbol = symbol; super.init(frame: .zero) }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    override var isOpaque: Bool { false }
    override func viewDidMoveToWindow() {
        super.viewDidMoveToWindow()
        guard window != nil, !NSWorkspace.shared.accessibilityDisplayShouldReduceMotion else { return }
        timer = Timer.scheduledTimer(timeInterval: 1.0 / 30.0, target: self, selector: #selector(advance), userInfo: nil, repeats: true)
        if let timer { RunLoop.main.add(timer, forMode: .common) }
    }
    override func viewWillMove(toWindow newWindow: NSWindow?) { if newWindow == nil { timer?.invalidate(); timer = nil }; super.viewWillMove(toWindow: newWindow) }
    @objc private func advance() { phase += 0.045; needsDisplay = true }
    override func draw(_ dirtyRect: NSRect) {
        let center = NSPoint(x: bounds.midX, y: bounds.midY)
        for index in 0..<3 {
            let radius = CGFloat(21 + index * 9) + sin(phase + CGFloat(index)) * 2
            let ring = NSBezierPath(ovalIn: NSRect(x: center.x - radius, y: center.y - radius, width: radius * 2, height: radius * 2))
            ring.lineWidth = 1.1
            NSColor.systemCyan.withAlphaComponent(0.30 - CGFloat(index) * 0.07).setStroke()
            ring.stroke()
        }
        let image = NSImage(systemSymbolName: symbol, accessibilityDescription: nil)
        image?.withSymbolConfiguration(NSImage.SymbolConfiguration(pointSize: 30, weight: .semibold))?.draw(in: NSRect(x: center.x - 16, y: center.y - 16, width: 32, height: 32))
    }
}

private final class LocalPeriodStoryView: GlassCardView {
    init(metrics: [HealthDataTypeSummary], language: AppLanguage) {
        super.init(accent: .systemTeal)
        let latestDate = metrics.compactMap { $0.dailyValues.last?.date }.max()
        let cutoff = latestDate.flatMap { Calendar.current.date(byAdding: .day, value: -6, to: $0) }
        let active = metrics.filter { metric in
            guard let cutoff else { return false }
            return metric.dailyValues.contains { $0.date >= cutoff }
        }
        let dates = Set(active.flatMap { metric in
            metric.dailyValues.filter { value in cutoff.map { value.date >= $0 } ?? false }.map { Calendar.current.startOfDay(for: $0.date) }
        })
        let heading = NSTextField(labelWithString: language.text(english: "Your period at a glance", german: "Dein Zeitraum in Kürze"))
        heading.font = .systemFont(ofSize: 14, weight: .bold); heading.textColor = .white
        let text = language.text(
            english: "Across the latest 7 recorded days, \(active.count) selected data types contain values on \(dates.count) local dates.",
            german: "In den letzten 7 erfassten Tagen enthalten \(active.count) ausgewählte Datentypen Werte an \(dates.count) lokalen Tagen."
        )
        let detail = NSTextField(wrappingLabelWithString: text)
        detail.font = .systemFont(ofSize: 12, weight: .medium); detail.textColor = NSColor.white.withAlphaComponent(0.76); detail.maximumNumberOfLines = 2
        let textStack = NSStackView(views: [heading, detail]); textStack.orientation = .vertical; textStack.spacing = 6
        let animation = StorySymbolsView()
        animation.translatesAutoresizingMaskIntoConstraints = false
        let stack = NSStackView(views: [animation, textStack]); stack.orientation = .horizontal; stack.alignment = .centerY; stack.spacing = 16; stack.edgeInsets = NSEdgeInsets(top: 14, left: 18, bottom: 14, right: 18); stack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stack)
        NSLayoutConstraint.activate([animation.widthAnchor.constraint(equalToConstant: 68), animation.heightAnchor.constraint(equalToConstant: 58), stack.leadingAnchor.constraint(equalTo: leadingAnchor), stack.trailingAnchor.constraint(equalTo: trailingAnchor), stack.topAnchor.constraint(equalTo: topAnchor), stack.bottomAnchor.constraint(equalTo: bottomAnchor)])
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}

private final class StorySymbolsView: NSView {
    private var phase: CGFloat = 0; private var timer: Timer?
    private let icons = ["heart.fill", "figure.walk", "moon.fill"]
    private let colors: [NSColor] = [.systemRed, .systemOrange, .systemPurple]
    override var isOpaque: Bool { false }
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        for index in icons.indices {
            let imageView = NSImageView(image: NSImage(systemSymbolName: icons[index], accessibilityDescription: nil) ?? NSImage())
            imageView.contentTintColor = colors[index]
            imageView.symbolConfiguration = NSImage.SymbolConfiguration(pointSize: 15, weight: .semibold)
            imageView.translatesAutoresizingMaskIntoConstraints = false
            addSubview(imageView)
            NSLayoutConstraint.activate([
                imageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: CGFloat(10 + index * 23)),
                imageView.centerYAnchor.constraint(equalTo: centerYAnchor),
                imageView.widthAnchor.constraint(equalToConstant: 15), imageView.heightAnchor.constraint(equalToConstant: 15)
            ])
        }
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    override func viewDidMoveToWindow() { super.viewDidMoveToWindow(); guard window != nil, !NSWorkspace.shared.accessibilityDisplayShouldReduceMotion else { return }; timer = Timer.scheduledTimer(timeInterval: 1.0 / 24.0, target: self, selector: #selector(advance), userInfo: nil, repeats: true); if let timer { RunLoop.main.add(timer, forMode: .common) } }
    override func viewWillMove(toWindow newWindow: NSWindow?) { if newWindow == nil { timer?.invalidate(); timer = nil }; super.viewWillMove(toWindow: newWindow) }
    @objc private func advance() { phase += 0.055; needsDisplay = true }
    override func draw(_ dirtyRect: NSRect) {
        for index in icons.indices {
            let x = CGFloat(10 + index * 23)
            let bob = sin(phase + CGFloat(index) * 1.7) * 4
            colors[index].withAlphaComponent(0.13).setFill()
            NSBezierPath(ovalIn: NSRect(x: x - 8, y: bounds.midY - 10 + bob, width: 28, height: 28)).fill()
        }
    }
}

private final class HeroMetricCardView: GlassCardView {
    private let onChoose: (String) -> Void
    private let metrics: [HealthDataTypeSummary]
    init(metric: HealthDataTypeSummary, metrics: [HealthDataTypeSummary], accent: NSColor, language: AppLanguage, onChoose: @escaping (String) -> Void) {
        self.metrics = metrics; self.onChoose = onChoose
        super.init(accent: accent)
        let background = MetricCardBackgroundView(title: metric.localizedDisplayName, accent: accent)
        background.translatesAutoresizingMaskIntoConstraints = false
        addSubview(background)
        let label = NSTextField(labelWithString: language.text(english: "HERO METRIC", german: "FOKUS-KENNZAHL"))
        label.font = .systemFont(ofSize: 10, weight: .bold); label.textColor = accent
        let picker = NSPopUpButton()
        picker.addItems(withTitles: metrics.map(\.localizedDisplayName)); picker.selectItem(withTitle: metric.localizedDisplayName); picker.target = self; picker.action = #selector(metricChanged(_:))
        let value = NSTextField(labelWithString: metric.latestValueText)
        value.font = .systemFont(ofSize: 34, weight: .bold); value.textColor = .white
        let detail = NSTextField(labelWithString: metric.latestDetailText)
        detail.font = .systemFont(ofSize: 12, weight: .medium); detail.textColor = NSColor.white.withAlphaComponent(0.74)
        let graph = TrendGraphView(points: metric.dailyValues.suffix(28).map { HealthTrendPoint(date: $0.date, value: metric.displayValue(for: $0)) }, tintColor: accent, chartStyle: metric.preferredChartStyle, showsPoints: false, selectedDate: nil, valueFormatter: metric.formattedValue) { _ in }
        let orbit = HeroMetricOrbitView(accent: accent, title: metric.localizedDisplayName)
        orbit.translatesAutoresizingMaskIntoConstraints = false
        let stack = NSStackView(views: [label, picker, value, detail, graph]); stack.orientation = .vertical; stack.spacing = 7; stack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stack); addSubview(orbit)
        NSLayoutConstraint.activate([
            background.leadingAnchor.constraint(equalTo: leadingAnchor), background.trailingAnchor.constraint(equalTo: trailingAnchor), background.topAnchor.constraint(equalTo: topAnchor), background.bottomAnchor.constraint(equalTo: bottomAnchor),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 22), stack.topAnchor.constraint(equalTo: topAnchor, constant: 18), stack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16), stack.trailingAnchor.constraint(equalTo: orbit.leadingAnchor, constant: -20),
            graph.heightAnchor.constraint(equalToConstant: 72),
            orbit.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -26), orbit.centerYAnchor.constraint(equalTo: centerYAnchor), orbit.widthAnchor.constraint(equalToConstant: 132), orbit.heightAnchor.constraint(equalToConstant: 132)
        ])
    }
    @objc private func metricChanged(_ sender: NSPopUpButton) { guard let title = sender.titleOfSelectedItem, let metric = metrics.first(where: { $0.localizedDisplayName == title }) else { return }; onChoose(metric.identifier) }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}

private final class HeroMetricOrbitView: NSView {
    private let accent: NSColor; private var phase: CGFloat = 0; private var timer: Timer?
    init(accent: NSColor, title: String) {
        self.accent = accent
        super.init(frame: .zero)
        let icon = NSImageView(image: NSImage(systemSymbolName: MetricCardBackgroundView.symbolName(for: title), accessibilityDescription: nil) ?? NSImage())
        icon.contentTintColor = accent
        icon.symbolConfiguration = NSImage.SymbolConfiguration(pointSize: 35, weight: .semibold)
        icon.translatesAutoresizingMaskIntoConstraints = false
        addSubview(icon)
        NSLayoutConstraint.activate([
            icon.centerXAnchor.constraint(equalTo: centerXAnchor), icon.centerYAnchor.constraint(equalTo: centerYAnchor),
            icon.widthAnchor.constraint(equalToConstant: 38), icon.heightAnchor.constraint(equalToConstant: 38)
        ])
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    override var isOpaque: Bool { false }
    override func viewDidMoveToWindow() { super.viewDidMoveToWindow(); guard window != nil, !NSWorkspace.shared.accessibilityDisplayShouldReduceMotion else { return }; timer = Timer.scheduledTimer(timeInterval: 1.0 / 30.0, target: self, selector: #selector(advance), userInfo: nil, repeats: true); if let timer { RunLoop.main.add(timer, forMode: .common) } }
    override func viewWillMove(toWindow newWindow: NSWindow?) { if newWindow == nil { timer?.invalidate(); timer = nil }; super.viewWillMove(toWindow: newWindow) }
    @objc private func advance() { phase += 0.025; needsDisplay = true }
    override func draw(_ dirtyRect: NSRect) {
        let center = NSPoint(x: bounds.midX, y: bounds.midY)
        for index in 0..<3 { let radius = CGFloat(27 + index * 16); let ring = NSBezierPath(ovalIn: NSRect(x: center.x - radius, y: center.y - radius, width: radius * 2, height: radius * 2)); ring.lineWidth = index == 1 ? 3 : 1; accent.withAlphaComponent(index == 1 ? 0.55 : 0.20).setStroke(); ring.stroke() }
        let angle = phase * 2.4; let dot = NSPoint(x: center.x + cos(angle) * 43, y: center.y + sin(angle) * 43); accent.setFill(); NSBezierPath(ovalIn: NSRect(x: dot.x - 4, y: dot.y - 4, width: 8, height: 8)).fill()
    }
}

private final class DraggableMetricCard: GlassCardView, NSDraggingSource {
    private static let metricIdentifierPasteboardType = NSPasteboard.PasteboardType("com.schrotty74.healthatlas.metric-card")
    private let metricIdentifier: String
    private let onMove: (String, String) -> Void
    private let onOpen: (String) -> Void
    private var mouseDownPoint: NSPoint?
    private var hasStartedDrag = false
    private var trackingArea: NSTrackingArea?

    init(identifier: String, accent: NSColor, onMove: @escaping (String, String) -> Void, onOpen: @escaping (String) -> Void) {
        self.metricIdentifier = identifier
        self.onMove = onMove
        self.onOpen = onOpen
        super.init(accent: accent)
        self.identifier = NSUserInterfaceItemIdentifier(identifier)
        registerForDraggedTypes([Self.metricIdentifierPasteboardType])
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func mouseDown(with event: NSEvent) {
        mouseDownPoint = convert(event.locationInWindow, from: nil)
        hasStartedDrag = false
    }

    override func mouseDragged(with event: NSEvent) {
        guard let mouseDownPoint, !hasStartedDrag else { return }
        let location = convert(event.locationInWindow, from: nil)
        guard hypot(location.x - mouseDownPoint.x, location.y - mouseDownPoint.y) > 6 else { return }
        hasStartedDrag = true
        let item = NSPasteboardItem()
        item.setString(metricIdentifier, forType: Self.metricIdentifierPasteboardType)
        let draggingItem = NSDraggingItem(pasteboardWriter: item)
        let image = NSImage(size: bounds.size)
        if let bitmap = bitmapImageRepForCachingDisplay(in: bounds) {
            cacheDisplay(in: bounds, to: bitmap)
            image.addRepresentation(bitmap)
        }
        draggingItem.setDraggingFrame(bounds, contents: image)
        let session = beginDraggingSession(with: [draggingItem], event: event, source: self)
        session.animatesToStartingPositionsOnCancelOrFail = true
    }

    override func mouseUp(with event: NSEvent) {
        defer { mouseDownPoint = nil }
        guard !hasStartedDrag else { return }
        onOpen(metricIdentifier)
    }

    override func updateTrackingAreas() {
        if let trackingArea { removeTrackingArea(trackingArea) }
        let area = NSTrackingArea(rect: bounds, options: [.activeInKeyWindow, .mouseEnteredAndExited, .inVisibleRect], owner: self, userInfo: nil)
        addTrackingArea(area)
        trackingArea = area
        super.updateTrackingAreas()
    }

    override func mouseEntered(with event: NSEvent) {
        guard !NSWorkspace.shared.accessibilityDisplayShouldReduceMotion else { return }
        NSAnimationContext.runAnimationGroup { context in
            context.duration = 0.16
            animator().alphaValue = 0.98
        }
        CATransaction.begin(); CATransaction.setAnimationDuration(0.16); layer?.transform = CATransform3DMakeTranslation(0, -3, 0); layer?.shadowOpacity = 0.48; CATransaction.commit()
    }

    override func mouseExited(with event: NSEvent) {
        guard !NSWorkspace.shared.accessibilityDisplayShouldReduceMotion else { return }
        NSAnimationContext.runAnimationGroup { context in context.duration = 0.16; animator().alphaValue = 1 }
        CATransaction.begin(); CATransaction.setAnimationDuration(0.16); layer?.transform = CATransform3DIdentity; layer?.shadowOpacity = 0.18; CATransaction.commit()
    }

    override func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation {
        guard sender.draggingPasteboard.string(forType: Self.metricIdentifierPasteboardType) != nil else { return [] }
        layer?.borderWidth = 2
        return .move
    }

    override func draggingExited(_ sender: NSDraggingInfo?) { layer?.borderWidth = 1 }

    override func performDragOperation(_ sender: NSDraggingInfo) -> Bool {
        defer { layer?.borderWidth = 1 }
        guard let source = sender.draggingPasteboard.string(forType: Self.metricIdentifierPasteboardType) else { return false }
        onMove(source, metricIdentifier)
        return true
    }

    func draggingSession(_ session: NSDraggingSession, sourceOperationMaskFor context: NSDraggingContext) -> NSDragOperation { .move }
}

private final class AnimatedImportHeroView: NSView {
    private var phase: CGFloat = 0
    private var timer: Timer?

    override var isFlipped: Bool { true }

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        let icon = NSImageView(image: NSImage(systemSymbolName: "heart.text.square.fill", accessibilityDescription: nil) ?? NSImage())
        icon.contentTintColor = .systemPink
        icon.symbolConfiguration = NSImage.SymbolConfiguration(pointSize: 44, weight: .semibold)
        icon.translatesAutoresizingMaskIntoConstraints = false
        addSubview(icon)
        NSLayoutConstraint.activate([
            icon.centerXAnchor.constraint(equalTo: centerXAnchor), icon.centerYAnchor.constraint(equalTo: centerYAnchor),
            icon.widthAnchor.constraint(equalToConstant: 50), icon.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

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
    private var phase: CGFloat = 0
    private var timer: Timer?
    private let icon: NSImageView

    init(title: String, accent: NSColor) {
        self.title = title.lowercased()
        self.accent = accent
        icon = NSImageView(image: NSImage(systemSymbolName: Self.symbolName(for: title), accessibilityDescription: nil) ?? NSImage())
        super.init(frame: .zero)
        icon.contentTintColor = accent
        icon.symbolConfiguration = NSImage.SymbolConfiguration(pointSize: 34, weight: .medium)
        icon.translatesAutoresizingMaskIntoConstraints = false
        icon.wantsLayer = true
        addSubview(icon)
        NSLayoutConstraint.activate([
            icon.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -22),
            icon.topAnchor.constraint(equalTo: topAnchor, constant: 18),
            icon.widthAnchor.constraint(equalToConstant: 32), icon.heightAnchor.constraint(equalToConstant: 32)
        ])
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    override var isOpaque: Bool { false }

    override func viewDidMoveToWindow() {
        super.viewDidMoveToWindow()
        guard !NSWorkspace.shared.accessibilityDisplayShouldReduceMotion else { return }
        guard window != nil, timer == nil else { return }
        timer = Timer.scheduledTimer(timeInterval: 1.0 / 24.0, target: self, selector: #selector(advance), userInfo: nil, repeats: true)
        RunLoop.main.add(timer!, forMode: .common)
    }

    override func viewWillMove(toWindow newWindow: NSWindow?) {
        if newWindow == nil { timer?.invalidate(); timer = nil }
        super.viewWillMove(toWindow: newWindow)
    }

    @objc private func advance() {
        phase += 0.11
        if title.contains("herz") || title.contains("heart") {
            // Hearts pulse in place. Translating and rotating a small symbol
            // makes it look like jitter rather than a calm heartbeat.
            let pulse = max(0, sin(phase * 1.15))
            let scale = 1 + pulse * 0.075
            icon.layer?.setAffineTransform(CGAffineTransform(scaleX: scale, y: scale))
            icon.alphaValue = 0.84 + pulse * 0.16
            needsDisplay = true
            return
        }
        let lift = sin(phase * 0.74) * 4
        let turn = sin(phase * 0.37) * 0.045
        icon.layer?.setAffineTransform(CGAffineTransform(translationX: 0, y: lift).rotated(by: turn))
        icon.alphaValue = 0.78 + CGFloat((sin(phase * 0.74) + 1) * 0.11)
        needsDisplay = true
    }

    override func draw(_ dirtyRect: NSRect) {
        NSGradient(colors: [
            accent.withAlphaComponent(0.34),
            accent.withAlphaComponent(0.14),
            NSColor(calibratedWhite: 0.03, alpha: 0.10)
        ])?.draw(in: bounds, angle: -24)
        guard AppTheme.current != .clearGlass else { return }
        let waveform = NSBezierPath()
        waveform.lineWidth = 2
        let baseline = bounds.height * 0.34
        let width = max(bounds.width, 1)
        // Keep the visual spacing of heartbeats stable in both compact cards
        // and wide trend panels instead of stretching a fixed number of beats.
        let heartBeatsAcross = max(CGFloat(2.6), width / 190)
        for x in stride(from: CGFloat(0), through: bounds.width, by: 4) {
            let position = x / width
            let y: CGFloat
            if title.contains("herz") || title.contains("heart") {
                // A smooth, continuous ECG pulse. The earlier piecewise line
                // changed abruptly between samples and shimmered in small cards.
                let beat = (position * heartBeatsAcross).truncatingRemainder(dividingBy: 1)
                let peak = exp(-pow((beat - 0.21) / 0.026, 2)) * 22
                let dip = exp(-pow((beat - 0.275) / 0.032, 2)) * 9
                let recovery = exp(-pow((beat - 0.345) / 0.036, 2)) * 10
                y = baseline - peak + dip - recovery
            } else if title.contains("schritt") || title.contains("step") || title.contains("walking") || title.contains("distance") || title.contains("distanz") {
                // Moving cadence, deliberately less clinical than an ECG.
                y = baseline + sin(position * .pi * 6 + phase * 0.62) * 5 + sin(position * .pi * 12 + phase * 0.62) * 2
            } else if title.contains("schlaf") || title.contains("sleep") {
                // Slow, calm sleep rhythm.
                y = baseline + sin(position * .pi * 2 + phase * 0.24) * 7
            } else if title.contains("gewicht") || title.contains("mass") || title.contains("bmi") {
                // Stable measurement line with a very restrained local variation.
                y = baseline + sin(position * .pi * 1.2 + phase * 0.18) * 1.5
            } else if title.contains("energie") || title.contains("energy") {
                y = baseline + sin(position * .pi * 3 + phase * 0.48) * 5 - position * 4
            } else if title.contains("audio") || title.contains("lärm") {
                y = baseline + sin(position * .pi * 10 + phase * 0.9) * 5
            } else {
                y = baseline + sin(position * .pi * 4 + phase) * 6
            }
            x == 0 ? waveform.move(to: NSPoint(x: x, y: y)) : waveform.line(to: NSPoint(x: x, y: y))
        }
        accent.withAlphaComponent(0.52).setStroke()
        waveform.stroke()
        if title.contains("herz") || title.contains("heart") {
            // Keep the ECG path stable and animate one soft impulse along it.
            // This reads as a heartbeat without shifting the whole line.
            let position = (phase * 0.12).truncatingRemainder(dividingBy: 1)
            let beat = (position * heartBeatsAcross).truncatingRemainder(dividingBy: 1)
            let peak = exp(-pow((beat - 0.21) / 0.026, 2)) * 22
            let dip = exp(-pow((beat - 0.275) / 0.032, 2)) * 9
            let recovery = exp(-pow((beat - 0.345) / 0.036, 2)) * 10
            let point = NSPoint(x: position * width, y: baseline - peak + dip - recovery)
            accent.withAlphaComponent(0.18).setFill()
            NSBezierPath(ovalIn: NSRect(x: point.x - 7, y: point.y - 7, width: 14, height: 14)).fill()
            accent.withAlphaComponent(0.92).setFill()
            NSBezierPath(ovalIn: NSRect(x: point.x - 2.5, y: point.y - 2.5, width: 5, height: 5)).fill()
        }
    }

    static func symbolName(for title: String) -> String {
        let lower = title.lowercased()
        if lower.contains("schritt") || lower.contains("step") || lower.contains("walking") { return "figure.walk" }
        if lower.contains("herz") || lower.contains("heart") { return "heart.fill" }
        if lower.contains("schlaf") || lower.contains("sleep") { return "moon.stars.fill" }
        if lower.contains("gewicht") || lower.contains("mass") { return "scalemass.fill" }
        if lower.contains("energie") || lower.contains("energy") { return "bolt.heart.fill" }
        return "waveform.path.ecg"
    }
}

private struct HealthTrendPoint {
    let date: Date
    let value: Double

    func detail(for metric: HealthDataTypeSummary) -> String {
        "\(date.formatted(date: .long, time: .omitted))  ·  \(metric.formattedValue(value))"
    }
}

private final class CalendarHeatmapView: NSView {
    private let values: [HealthDailyValue]
    private let metric: HealthDataTypeSummary
    private let tintColor: NSColor
    private let days: Int

    init(values: [HealthDailyValue], metric: HealthDataTypeSummary, tintColor: NSColor, days: Int = 84) {
        self.values = values
        self.metric = metric
        self.tintColor = tintColor
        self.days = days
        super.init(frame: .zero)
        toolTip = AppLanguage.current.text(english: "Each square represents one local day. Stronger colour means a higher value relative to this displayed period.", german: "Jedes Feld steht für einen lokalen Tag. Eine stärkere Farbe bedeutet einen höheren Wert innerhalb dieses angezeigten Zeitraums.")
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    override var isFlipped: Bool { true }

    override func draw(_ dirtyRect: NSRect) {
        let calendar = Calendar.current
        guard let latest = values.map(\.date).max() else { return }
        let latestDay = calendar.startOfDay(for: latest)
        let valueByDay = Dictionary(uniqueKeysWithValues: values.map { (calendar.startOfDay(for: $0.date), metric.displayValue(for: $0)) })
        let shownValues = Array(valueByDay.values)
        let minimum = shownValues.min() ?? 0
        let span = max((shownValues.max() ?? 0) - minimum, 0.000_001)
        let weeks = max(1, Int(ceil(Double(days) / 7)))
        let cell = min(days > 100 ? 8 : 13, floor((bounds.width - 26) / CGFloat(weeks)))
        let gap: CGFloat = 3
        let gridHeight = CGFloat(7) * cell + CGFloat(6) * gap
        let startY = max(6, (bounds.height - gridHeight) / 2)
        for week in 0..<weeks {
            for weekday in 0..<7 {
                let dayOffset = -((weeks - 1 - week) * 7 + (6 - weekday))
                guard let date = calendar.date(byAdding: .day, value: dayOffset, to: latestDay) else { continue }
                let rect = NSRect(x: 4 + CGFloat(week) * (cell + gap), y: startY + CGFloat(weekday) * (cell + gap), width: cell, height: cell)
                let value = valueByDay[date]
                let intensity = value.map { 0.16 + 0.72 * CGFloat(($0 - minimum) / span) } ?? 0.05
                tintColor.withAlphaComponent(intensity).setFill()
                NSBezierPath(roundedRect: rect, xRadius: 3, yRadius: 3).fill()
            }
        }
    }
}

/// Informational only: coverage and sample counts, never a health assessment.
private final class DataQualityView: GlassCardView {
    init(summary: ImportedHealthSummary, selectedIDs: Set<String>, language: AppLanguage) {
        super.init(accent: .systemCyan)
        let dated = summary.dataTypes.filter { !$0.dailyValues.isEmpty }
        let totalDays = Set(dated.flatMap { $0.dailyValues.map { Calendar.current.startOfDay(for: $0.date) } }).count
        let samples = summary.recordCount.formatted()
        let items: [(String, String)] = [
            (language.text(english: "Selected", german: "Ausgewählt"), "\(selectedIDs.count) / \(summary.dataTypes.count)"),
            (language.text(english: "Dated types", german: "Datierte Typen"), dated.count.formatted()),
            (language.text(english: "Local days", german: "Lokale Tage"), totalDays.formatted()),
            (language.text(english: "Imported samples", german: "Importierte Messwerte"), samples)
        ]
        let heading = NSTextField(labelWithString: language.text(english: "Local data quality", german: "Lokale Datenqualität"))
        heading.font = .systemFont(ofSize: 14, weight: .bold); heading.textColor = .white
        let note = NSTextField(labelWithString: language.text(english: "Coverage only — no rating or medical interpretation.", german: "Nur Abdeckung — keine Bewertung oder medizinische Interpretation."))
        note.font = .systemFont(ofSize: 11, weight: .medium); note.textColor = NSColor.white.withAlphaComponent(0.7)
        let values = NSStackView(); values.orientation = .horizontal; values.distribution = .fillEqually; values.spacing = 10
        for item in items {
            let name = NSTextField(labelWithString: item.0); name.font = .systemFont(ofSize: 10, weight: .medium); name.textColor = NSColor.white.withAlphaComponent(0.65)
            let value = NSTextField(labelWithString: item.1); value.font = .systemFont(ofSize: 16, weight: .bold); value.textColor = .white
            let column = NSStackView(views: [name, value]); column.orientation = .vertical; column.spacing = 2
            values.addArrangedSubview(column)
        }
        let selectedMetrics = summary.dataTypes.filter { selectedIDs.contains($0.identifier) }
        let coverage = LocalDataCoverage.make(metrics: selectedMetrics)
        let missingText = coverage.missingDays == 0
            ? language.text(english: "Values exist on each of the last 7 local dates.", german: "Werte liegen an allen letzten 7 lokalen Tagen vor.")
            : language.text(english: "\(coverage.missingDays) of the last 7 local dates have no selected value.", german: "An \(coverage.missingDays) der letzten 7 lokalen Tage liegt kein ausgewählter Wert vor.")
        let sparseText = coverage.sparseTypes.isEmpty
            ? language.text(english: "No selected type has only one or two dated values.", german: "Kein ausgewählter Typ hat nur einen oder zwei datierte Werte.")
            : language.text(english: "Only one or two dated values: \(coverage.sparseTypes.joined(separator: ", ")).", german: "Nur ein oder zwei datierte Werte: \(coverage.sparseTypes.joined(separator: ", ")).")
        let coverageLabel = NSTextField(wrappingLabelWithString: "• \(missingText)\n• \(sparseText)")
        coverageLabel.font = .systemFont(ofSize: 10.5, weight: .medium)
        coverageLabel.textColor = NSColor.white.withAlphaComponent(0.76)
        coverageLabel.maximumNumberOfLines = 2
        let stack = NSStackView(views: [heading, note, values, coverageLabel]); stack.orientation = .vertical; stack.spacing = 7; stack.edgeInsets = NSEdgeInsets(top: 14, left: 18, bottom: 14, right: 18); stack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stack)
        NSLayoutConstraint.activate([stack.leadingAnchor.constraint(equalTo: leadingAnchor), stack.trailingAnchor.constraint(equalTo: trailingAnchor), stack.topAnchor.constraint(equalTo: topAnchor), stack.bottomAnchor.constraint(equalTo: bottomAnchor)])
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}

private final class TrendHighlightsView: GlassCardView {
    init(metric: HealthDataTypeSummary, points: [HealthTrendPoint], days: Int, language: AppLanguage) {
        super.init(accent: .systemCyan)
        let title = NSTextField(labelWithString: language.text(english: "Local trend highlights", german: "Lokale Trend-Hinweise"))
        title.font = .systemFont(ofSize: 12, weight: .bold)
        title.textColor = .white
        let maximum = points.max(by: { $0.value < $1.value })
        let latest = points.map(\.date).max()
        let recordedDays = Set(points.map { Calendar.current.startOfDay(for: $0.date) }).count
        let first = maximum.map { point in
            language.text(english: "Highest local value: \(metric.formattedValue(point.value)) on \(point.date.formatted(date: .abbreviated, time: .omitted)).", german: "Höchster lokaler Wert: \(metric.formattedValue(point.value)) am \(point.date.formatted(date: .abbreviated, time: .omitted)).")
        } ?? language.text(english: "No local value is available in this period.", german: "In diesem Zeitraum liegt kein lokaler Wert vor.")
        let relevantDays: Int
        if let latest, let start = Calendar.current.date(byAdding: .day, value: -(days - 1), to: latest) {
            relevantDays = Calendar.current.dateComponents([.day], from: start, to: latest).day.map { $0 + 1 } ?? days
        } else { relevantDays = days }
        let second = language.text(english: "Data exists on \(recordedDays) of \(relevantDays) local days.", german: "Daten liegen an \(recordedDays) von \(relevantDays) lokalen Tagen vor.")
        let detail = NSTextField(wrappingLabelWithString: "\(first)\n\(second)")
        detail.font = .systemFont(ofSize: 11, weight: .medium)
        detail.textColor = NSColor.white.withAlphaComponent(0.78)
        detail.maximumNumberOfLines = 2
        let stack = NSStackView(views: [title, detail]); stack.orientation = .vertical; stack.spacing = 6; stack.edgeInsets = NSEdgeInsets(top: 13, left: 18, bottom: 12, right: 18); stack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stack)
        NSLayoutConstraint.activate([stack.leadingAnchor.constraint(equalTo: leadingAnchor), stack.trailingAnchor.constraint(equalTo: trailingAnchor), stack.topAnchor.constraint(equalTo: topAnchor), stack.bottomAnchor.constraint(equalTo: bottomAnchor)])
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}

private final class PeriodComparisonView: GlassCardView {
    init(comparison: HealthPeriodComparison, metric: HealthDataTypeSummary, days: Int, accent: NSColor, language: AppLanguage) {
        super.init(accent: accent)
        let title = NSTextField(labelWithString: language.text(english: "Local period comparison", german: "Lokaler Zeitraumvergleich"))
        title.font = .systemFont(ofSize: 12, weight: .bold); title.textColor = .white
        let current = comparisonValue(title: language.text(english: "Current", german: "Aktuell"), value: metric.formattedValue(comparison.current))
        let previous = comparisonValue(title: language.text(english: "Previous", german: "Vorher"), value: metric.formattedValue(comparison.previous))
        let sign = comparison.difference >= 0 ? "+" : ""
        let percentage = comparison.percentage.map { String(format: "%@%.1f%%", $0 >= 0 ? "+" : "", $0) } ?? "—"
        let change = comparisonValue(title: language.text(english: "Difference", german: "Differenz"), value: "\(sign)\(metric.formattedValue(comparison.difference)) · \(percentage)")
        let row = NSStackView(views: [current, previous, change]); row.orientation = .horizontal; row.distribution = .fillEqually; row.spacing = 12
        let stack = NSStackView(views: [title, row]); stack.orientation = .vertical; stack.spacing = 9; stack.edgeInsets = NSEdgeInsets(top: 14, left: 18, bottom: 13, right: 18); stack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stack)
        NSLayoutConstraint.activate([stack.leadingAnchor.constraint(equalTo: leadingAnchor), stack.trailingAnchor.constraint(equalTo: trailingAnchor), stack.topAnchor.constraint(equalTo: topAnchor), stack.bottomAnchor.constraint(equalTo: bottomAnchor)])
        toolTip = language.text(english: "Comparison of two adjacent local \(days)-day periods.", german: "Vergleich zweier direkt aufeinander folgender lokaler \(days)-Tage-Zeiträume.")
    }
    private func comparisonValue(title: String, value: String) -> NSView {
        let titleLabel = NSTextField(labelWithString: title); titleLabel.font = .systemFont(ofSize: 10, weight: .medium); titleLabel.textColor = NSColor.white.withAlphaComponent(0.65)
        let valueLabel = NSTextField(labelWithString: value); valueLabel.font = .systemFont(ofSize: 15, weight: .bold); valueLabel.textColor = .white
        let stack = NSStackView(views: [titleLabel, valueLabel]); stack.orientation = .vertical; stack.spacing = 2; return stack
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}

private final class HealthRingsView: GlassCardView {
    init(metrics: [HealthDataTypeSummary], language: AppLanguage) {
        super.init(accent: .systemCyan)
        toolTip = language.text(english: "A visual summary of the latest local value relative to the last seven local days. It is not a goal or rating.", german: "Visuelle Zusammenfassung des letzten lokalen Werts relativ zu den letzten sieben lokalen Tagen. Kein Ziel und keine Bewertung.")
        let canvas = HealthRingsCanvasView(metrics: metrics, language: language)
        canvas.translatesAutoresizingMaskIntoConstraints = false
        addSubview(canvas)
        NSLayoutConstraint.activate([canvas.leadingAnchor.constraint(equalTo: leadingAnchor), canvas.trailingAnchor.constraint(equalTo: trailingAnchor), canvas.topAnchor.constraint(equalTo: topAnchor), canvas.bottomAnchor.constraint(equalTo: bottomAnchor)])
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}

private final class HealthRingsCanvasView: NSView {
    private let metrics: [HealthDataTypeSummary]
    private let language: AppLanguage
    init(metrics: [HealthDataTypeSummary], language: AppLanguage) { self.metrics = metrics; self.language = language; super.init(frame: .zero) }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    override var isOpaque: Bool { false }
    override func draw(_ dirtyRect: NSRect) {
        let title = language.text(english: "Latest local values", german: "Letzte lokale Werte")
        title.draw(at: NSPoint(x: 18, y: bounds.height - 28), withAttributes: [.font: NSFont.systemFont(ofSize: 13, weight: .bold), .foregroundColor: NSColor.white])
        let center = NSPoint(x: 82, y: 92)
        let colors: [NSColor] = [.systemCyan, .systemPink, .systemPurple]
        for (index, metric) in metrics.enumerated() {
            let values = metric.dailyValues.suffix(7).map(metric.displayValue(for:))
            guard let latest = values.last, let maxValue = values.max(), maxValue > 0 else { continue }
            let radius = CGFloat(46 - index * 11)
            let background = NSBezierPath(); background.appendArc(withCenter: center, radius: radius, startAngle: 90, endAngle: 450, clockwise: false); background.lineWidth = 7
            NSColor.white.withAlphaComponent(0.11).setStroke(); background.stroke()
            let progress = max(0.05, min(1, latest / maxValue))
            let path = NSBezierPath(); path.appendArc(withCenter: center, radius: radius, startAngle: 90, endAngle: 90 + 360 * CGFloat(progress), clockwise: false); path.lineWidth = 7
            colors[index].withAlphaComponent(0.92).setStroke(); path.stroke()
        }
        let labels = metrics.enumerated().map { index, metric in
            "\(index + 1). \(metric.localizedDisplayName): \(metric.latestValueText)"
        }
        labels.enumerated().forEach { index, text in
            text.draw(at: NSPoint(x: 146, y: 130 - CGFloat(index * 31)), withAttributes: [.font: NSFont.systemFont(ofSize: 11, weight: .medium), .foregroundColor: NSColor.white.withAlphaComponent(0.83)])
        }
    }
}

private final class CombinedHealthTimelineView: GlassCardView {
    init(metrics: [HealthDataTypeSummary], language: AppLanguage, onSelect: @escaping (String) -> Void) {
        super.init(accent: .systemBlue)
        toolTip = language.text(english: "Selected local data types over their last 30 local days. Click to open the first metric in focus view.", german: "Ausgewählte lokale Datentypen über ihre letzten 30 lokalen Tage. Klicke für die Fokusansicht des ersten Datentyps.")
        let canvas = CombinedHealthTimelineCanvasView(metrics: metrics, language: language, onSelect: onSelect)
        canvas.translatesAutoresizingMaskIntoConstraints = false
        addSubview(canvas)
        NSLayoutConstraint.activate([canvas.leadingAnchor.constraint(equalTo: leadingAnchor), canvas.trailingAnchor.constraint(equalTo: trailingAnchor), canvas.topAnchor.constraint(equalTo: topAnchor), canvas.bottomAnchor.constraint(equalTo: bottomAnchor)])
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}

private final class CombinedHealthTimelineCanvasView: NSView {
    private let metrics: [HealthDataTypeSummary]
    private let language: AppLanguage
    private let onSelect: (String) -> Void
    init(metrics: [HealthDataTypeSummary], language: AppLanguage, onSelect: @escaping (String) -> Void) { self.metrics = metrics; self.language = language; self.onSelect = onSelect; super.init(frame: .zero) }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    override var isOpaque: Bool { false }
    override func draw(_ dirtyRect: NSRect) {
        let title = language.text(english: "Shared health timeline", german: "Gemeinsamer Gesundheitsverlauf")
        title.draw(at: NSPoint(x: 18, y: bounds.height - 28), withAttributes: [.font: NSFont.systemFont(ofSize: 13, weight: .bold), .foregroundColor: NSColor.white])
        let area = NSRect(x: 18, y: 24, width: max(1, bounds.width - 36), height: max(1, bounds.height - 62))
        let colors: [NSColor] = [.systemCyan, .systemPink, .systemPurple, .systemOrange]
        for (index, metric) in metrics.enumerated() {
            let values = metric.dailyValues.suffix(30).map(metric.displayValue(for:))
            guard values.count > 1, let minimum = values.min(), let maximum = values.max() else { continue }
            let span = Swift.max(maximum - minimum, 0.000_001)
            let line = NSBezierPath(); line.lineWidth = 2; line.lineJoinStyle = .round
            for (position, value) in values.enumerated() {
                let x = area.minX + area.width * CGFloat(position) / CGFloat(values.count - 1)
                let y = area.maxY - area.height * CGFloat((value - minimum) / span)
                position == 0 ? line.move(to: NSPoint(x: x, y: y)) : line.line(to: NSPoint(x: x, y: y))
            }
            colors[index].withAlphaComponent(0.84).setStroke(); line.stroke()
            let labelWidth = area.width / CGFloat(max(metrics.count, 1))
            let paragraph = NSMutableParagraphStyle()
            paragraph.lineBreakMode = .byTruncatingTail
            let labelFrame = NSRect(x: area.minX + CGFloat(index) * labelWidth, y: 5, width: max(20, labelWidth - 6), height: 15)
            metric.localizedDisplayName.draw(in: labelFrame, withAttributes: [
                .font: NSFont.systemFont(ofSize: 9, weight: .medium),
                .foregroundColor: colors[index],
                .paragraphStyle: paragraph
            ])
        }
    }
    override func mouseDown(with event: NSEvent) { if let identifier = metrics.first?.identifier { onSelect(identifier) } }
}

private final class InsightSnapshotView: GlassCardView {
    init(metric: HealthDataTypeSummary, accent: NSColor, language: AppLanguage) {
        super.init(accent: accent)
        let eyebrow = NSTextField(labelWithString: language.text(english: "LOCAL SNAPSHOT", german: "LOKALE MOMENTAUFNAHME"))
        eyebrow.font = .systemFont(ofSize: 10, weight: .bold); eyebrow.textColor = accent
        let title = NSTextField(labelWithString: metric.localizedDisplayName)
        title.font = .systemFont(ofSize: 16, weight: .bold); title.textColor = .white
        let value = NSTextField(labelWithString: metric.latestValueText)
        value.font = .systemFont(ofSize: 30, weight: .bold); value.textColor = .white
        let latestDate = metric.dailyValues.last?.date.formatted(date: .long, time: .omitted) ?? "—"
        let datedDays = Set(metric.dailyValues.map { Calendar.current.startOfDay(for: $0.date) }).count
        let detail = NSTextField(wrappingLabelWithString: language.text(english: "Latest local value from \(latestDate). Values are recorded on \(datedDays) local days.", german: "Letzter lokaler Wert vom \(latestDate). Werte liegen an \(datedDays) lokalen Tagen vor."))
        detail.font = .systemFont(ofSize: 12, weight: .medium); detail.textColor = NSColor.white.withAlphaComponent(0.76); detail.maximumNumberOfLines = 2
        let stack = NSStackView(views: [eyebrow, title, value, detail])
        stack.orientation = .vertical; stack.alignment = .leading; stack.spacing = 4; stack.edgeInsets = NSEdgeInsets(top: 17, left: 22, bottom: 16, right: 22); stack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stack)
        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: leadingAnchor), stack.trailingAnchor.constraint(equalTo: trailingAnchor), stack.topAnchor.constraint(equalTo: topAnchor), stack.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}

private final class InsightCoverageView: GlassCardView {
    init(metric: HealthDataTypeSummary, accent: NSColor, language: AppLanguage) {
        super.init(accent: accent)
        let coverage = LocalDataCoverage.make(metrics: [metric])
        let title = NSTextField(labelWithString: language.text(english: "Local coverage", german: "Lokale Abdeckung"))
        title.font = .systemFont(ofSize: 12, weight: .bold); title.textColor = .white
        let recorded = NSTextField(labelWithString: language.text(english: "\(coverage.observedDays) of 7 local days", german: "\(coverage.observedDays) von 7 lokalen Tagen"))
        recorded.font = .systemFont(ofSize: 19, weight: .bold); recorded.textColor = .white
        let missing = coverage.missingDays == 0
            ? language.text(english: "No missing date in this local period.", german: "Kein fehlendes Datum in diesem lokalen Zeitraum.")
            : language.text(english: "\(coverage.missingDays) local dates have no value.", german: "An \(coverage.missingDays) lokalen Tagen liegt kein Wert vor.")
        let detail = NSTextField(wrappingLabelWithString: missing)
        detail.font = .systemFont(ofSize: 11, weight: .medium); detail.textColor = NSColor.white.withAlphaComponent(0.74); detail.maximumNumberOfLines = 2
        let stack = NSStackView(views: [title, recorded, detail]); stack.orientation = .vertical; stack.spacing = 6; stack.edgeInsets = NSEdgeInsets(top: 15, left: 18, bottom: 14, right: 18); stack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stack)
        NSLayoutConstraint.activate([stack.leadingAnchor.constraint(equalTo: leadingAnchor), stack.trailingAnchor.constraint(equalTo: trailingAnchor), stack.topAnchor.constraint(equalTo: topAnchor), stack.bottomAnchor.constraint(equalTo: bottomAnchor)])
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}

private final class LocalPatternView: GlassCardView {
    init(metric: HealthDataTypeSummary, accent: NSColor, language: AppLanguage) {
        super.init(accent: accent)
        let calendar = Calendar.current
        let counts = Dictionary(grouping: metric.dailyValues, by: { calendar.component(.weekday, from: $0.date) })
        let busiest = counts.max { $0.value.count < $1.value.count }
        let dayName = busiest.map { calendar.weekdaySymbols[$0.key - 1] } ?? "—"
        let occurrences = busiest?.value.count ?? 0
        let heading = NSTextField(labelWithString: language.text(english: "Local pattern", german: "Lokales Muster")); heading.font = .systemFont(ofSize: 13, weight: .bold); heading.textColor = .white
        let result = NSTextField(wrappingLabelWithString: language.text(english: "Most recorded weekday: \(dayName) (\(occurrences) local dates). This describes recording frequency only.", german: "Am häufigsten erfasster Wochentag: \(dayName) (\(occurrences) lokale Daten). Beschreibt nur die Erfassungshäufigkeit."))
        result.font = .systemFont(ofSize: 12, weight: .medium); result.textColor = NSColor.white.withAlphaComponent(0.78); result.maximumNumberOfLines = 2
        let stack = NSStackView(views: [heading, result]); stack.orientation = .vertical; stack.spacing = 7; stack.edgeInsets = NSEdgeInsets(top: 17, left: 18, bottom: 14, right: 18); stack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stack); NSLayoutConstraint.activate([stack.leadingAnchor.constraint(equalTo: leadingAnchor), stack.trailingAnchor.constraint(equalTo: trailingAnchor), stack.topAnchor.constraint(equalTo: topAnchor), stack.bottomAnchor.constraint(equalTo: bottomAnchor)])
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}

private final class MetricFocusBackdropView: NSView {
    private let accent: NSColor
    private let symbolName: String

    init(accent: NSColor, title: String) {
        self.accent = accent
        symbolName = MetricCardBackgroundView.symbolName(for: title)
        super.init(frame: .zero)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    override var isOpaque: Bool { false }

    override func draw(_ dirtyRect: NSRect) {
        let topGlow = NSPoint(x: bounds.midX, y: bounds.maxY * 0.76)
        NSGradient(starting: accent.withAlphaComponent(0.14), ending: accent.withAlphaComponent(0))?.draw(fromCenter: topGlow, radius: 0, toCenter: topGlow, radius: max(bounds.width, bounds.height) * 0.46, options: [])
        let sideGlow = NSPoint(x: bounds.width * 0.08, y: bounds.height * 0.26)
        NSGradient(starting: accent.withAlphaComponent(0.07), ending: accent.withAlphaComponent(0))?.draw(fromCenter: sideGlow, radius: 0, toCenter: sideGlow, radius: bounds.width * 0.36, options: [])
        guard let image = NSImage(systemSymbolName: symbolName, accessibilityDescription: nil) else { return }
        let configuration = NSImage.SymbolConfiguration(pointSize: min(bounds.width, bounds.height) * 0.30, weight: .ultraLight)
        let symbol = image.withSymbolConfiguration(configuration) ?? image
        let rect = NSRect(x: bounds.midX - bounds.height * 0.22, y: bounds.midY - bounds.height * 0.22, width: bounds.height * 0.44, height: bounds.height * 0.44)
        symbol.draw(in: rect, from: .zero, operation: .sourceOver, fraction: 0.035)
    }
}

private final class MetricFocusViewController: NSViewController {
    var onOpenTrend: (() -> Void)?
    private let metric: HealthDataTypeSummary
    private let accent: NSColor
    private let language: AppLanguage
    init(metric: HealthDataTypeSummary, accent: NSColor, language: AppLanguage) { self.metric = metric; self.accent = accent; self.language = language; super.init(nibName: nil, bundle: nil) }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    override func loadView() {
        let root = GlassCardView(accent: accent); root.frame = NSRect(x: 0, y: 0, width: 960, height: 640); view = root
        let backdrop = MetricFocusBackdropView(accent: accent, title: metric.localizedDisplayName)
        backdrop.translatesAutoresizingMaskIntoConstraints = false
        root.addSubview(backdrop)
        let eyebrow = NSTextField(labelWithString: language.text(english: "LOCAL FOCUS", german: "LOKALER FOKUS")); eyebrow.font = .systemFont(ofSize: 11, weight: .bold); eyebrow.textColor = accent
        let title = NSTextField(labelWithString: metric.localizedDisplayName); title.font = .systemFont(ofSize: 30, weight: .bold); title.textColor = .white
        let latest = NSTextField(labelWithString: metric.latestValueText); latest.font = .systemFont(ofSize: 46, weight: .bold); latest.textColor = .white
        let note = NSTextField(labelWithString: language.text(english: "Local focus view · descriptive values only", german: "Lokale Fokusansicht · nur beschreibende Werte")); note.font = .systemFont(ofSize: 12, weight: .medium); note.textColor = NSColor.white.withAlphaComponent(0.72)
        let orbit = HeroMetricOrbitView(accent: accent, title: metric.localizedDisplayName)
        orbit.translatesAutoresizingMaskIntoConstraints = false
        let graph = TrendGraphView(points: metric.dailyValues.suffix(90).map { HealthTrendPoint(date: $0.date, value: metric.displayValue(for: $0)) }, tintColor: accent, chartStyle: metric.preferredChartStyle, showsPoints: true, selectedDate: nil, valueFormatter: metric.formattedValue) { _ in }
        let graphCard = focusGraphCard(graph)
        let heatmap = CalendarHeatmapView(values: metric.dailyValues, metric: metric, tintColor: accent, days: 365)
        let comparison = HealthPeriodComparison.make(values: metric.dailyValues, metric: metric, days: 30).map { PeriodComparisonView(comparison: $0, metric: metric, days: 30, accent: accent, language: language) }
        let openTrend = NSButton(title: language.text(english: "Open Trends", german: "Verläufe öffnen"), target: self, action: #selector(openTrends)); openTrend.bezelStyle = .rounded; openTrend.contentTintColor = .white
        let close = NSButton(title: language.text(english: "Exit full screen", german: "Vollbild beenden"), target: self, action: #selector(closeFocus)); close.bezelStyle = .rounded; close.contentTintColor = .white
        let buttons = NSStackView(views: [openTrend, close]); buttons.spacing = 10
        let headerLabels = NSStackView(views: [eyebrow, title, latest, note]); headerLabels.orientation = .vertical; headerLabels.alignment = .centerX; headerLabels.spacing = 7
        let header = NSStackView(views: [headerLabels, orbit]); header.orientation = .horizontal; header.spacing = 24; header.alignment = .centerY
        let calendarCard = GlassCardView(accent: accent)
        let calendarTitle = NSTextField(labelWithString: language.text(english: "Local recording calendar", german: "Lokaler Erfassungskalender")); calendarTitle.font = .systemFont(ofSize: 12, weight: .bold); calendarTitle.textColor = .white
        let calendarNote = NSTextField(labelWithString: language.text(english: "One square per local day", german: "Ein Feld pro lokalem Tag")); calendarNote.font = .systemFont(ofSize: 10, weight: .medium); calendarNote.textColor = NSColor.white.withAlphaComponent(0.62)
        let calendarStack = NSStackView(views: [calendarTitle, calendarNote, heatmap]); calendarStack.orientation = .vertical; calendarStack.spacing = 7; calendarStack.edgeInsets = NSEdgeInsets(top: 15, left: 18, bottom: 15, right: 18); calendarStack.translatesAutoresizingMaskIntoConstraints = false
        calendarCard.addSubview(calendarStack)
        NSLayoutConstraint.activate([calendarStack.leadingAnchor.constraint(equalTo: calendarCard.leadingAnchor), calendarStack.trailingAnchor.constraint(equalTo: calendarCard.trailingAnchor), calendarStack.topAnchor.constraint(equalTo: calendarCard.topAnchor), calendarStack.bottomAnchor.constraint(equalTo: calendarCard.bottomAnchor)])
        let lowerRow = NSStackView(views: (comparison.map { [$0, calendarCard] } ?? [calendarCard])); lowerRow.orientation = .horizontal; lowerRow.distribution = .fillEqually; lowerRow.spacing = 14
        let views: [NSView] = [header, graphCard, lowerRow, buttons]
        let stack = NSStackView(views: views); stack.orientation = .vertical; stack.alignment = .centerX; stack.spacing = 16; stack.translatesAutoresizingMaskIntoConstraints = false
        root.addSubview(stack)
        var constraints = [
            backdrop.leadingAnchor.constraint(equalTo: root.leadingAnchor), backdrop.trailingAnchor.constraint(equalTo: root.trailingAnchor), backdrop.topAnchor.constraint(equalTo: root.topAnchor), backdrop.bottomAnchor.constraint(equalTo: root.bottomAnchor),
            stack.leadingAnchor.constraint(equalTo: root.leadingAnchor, constant: 54), stack.trailingAnchor.constraint(equalTo: root.trailingAnchor, constant: -54),
            stack.centerYAnchor.constraint(equalTo: root.centerYAnchor, constant: 8), stack.topAnchor.constraint(greaterThanOrEqualTo: root.topAnchor, constant: 36), stack.bottomAnchor.constraint(lessThanOrEqualTo: root.bottomAnchor, constant: -30),
            graphCard.widthAnchor.constraint(equalTo: stack.widthAnchor), graphCard.heightAnchor.constraint(equalToConstant: 270),
            lowerRow.widthAnchor.constraint(equalTo: stack.widthAnchor), lowerRow.heightAnchor.constraint(equalToConstant: 156),
            heatmap.heightAnchor.constraint(equalToConstant: 94), orbit.widthAnchor.constraint(equalToConstant: 124), orbit.heightAnchor.constraint(equalToConstant: 124)
        ]
        if let comparison { constraints.append(comparison.widthAnchor.constraint(equalTo: calendarCard.widthAnchor)) }
        NSLayoutConstraint.activate(constraints)
    }

    private func focusGraphCard(_ graph: NSView) -> NSView {
        let card = GlassCardView(accent: accent)
        let title = NSTextField(labelWithString: language.text(english: "Local course", german: "Lokaler Verlauf")); title.font = .systemFont(ofSize: 13, weight: .bold); title.textColor = .white
        let detail = NSTextField(labelWithString: language.text(english: "Latest 90 recorded local days", german: "Letzte 90 erfasste lokale Tage")); detail.font = .systemFont(ofSize: 10, weight: .medium); detail.textColor = NSColor.white.withAlphaComponent(0.62)
        let header = NSStackView(views: [title, detail]); header.orientation = .vertical; header.spacing = 3
        let stack = NSStackView(views: [header, graph]); stack.orientation = .vertical; stack.spacing = 10; stack.edgeInsets = NSEdgeInsets(top: 16, left: 20, bottom: 17, right: 20); stack.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(stack)
        NSLayoutConstraint.activate([stack.leadingAnchor.constraint(equalTo: card.leadingAnchor), stack.trailingAnchor.constraint(equalTo: card.trailingAnchor), stack.topAnchor.constraint(equalTo: card.topAnchor), stack.bottomAnchor.constraint(equalTo: card.bottomAnchor)])
        return card
    }
    @objc private func openTrends() { onOpenTrend?() }
    @objc private func closeFocus() { close() }
    func close() { view.window?.close() }
}

private final class MetricFocusWindowController: NSWindowController, NSWindowDelegate {
    private static var activeController: MetricFocusWindowController?

    static func present(_ content: MetricFocusViewController) {
        activeController?.window?.close()
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 1280, height: 720),
            styleMask: [.titled, .closable, .resizable, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )
        window.title = content.title ?? "HealthAtlas"
        window.isOpaque = false
        window.backgroundColor = .clear
        window.collectionBehavior.insert(.fullScreenPrimary)
        window.minSize = NSSize(width: 960, height: 540)
        window.contentViewController = content
        let controller = MetricFocusWindowController(window: window)
        controller.window?.delegate = controller
        activeController = controller
        window.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
        DispatchQueue.main.async { window.toggleFullScreen(nil) }
    }

    func windowWillClose(_ notification: Notification) {
        Self.activeController = nil
    }
}

@MainActor
private struct LocalReportConfiguration {
    /// Zero means all locally imported dates.
    let days: Int
    let themeName: String

    func periodTitle(language: AppLanguage) -> String {
        guard days > 0 else { return language.text(english: "All imported local dates", german: "Alle importierten lokalen Tage") }
        return language.text(english: "Last \(days) local days", german: "Letzte \(days) lokale Tage")
    }
}

private struct LocalHealthReport {
    let summary: ImportedHealthSummary
    let metrics: [HealthDataTypeSummary]
    let language: AppLanguage
    let configuration: LocalReportConfiguration

    @MainActor func write(to url: URL) throws {
        let height = max(842, 250 + CGFloat(metrics.count) * 44)
        let reportView = LocalHealthReportView(summary: summary, metrics: metrics, language: language, configuration: configuration, frame: NSRect(x: 0, y: 0, width: 595, height: height))
        try reportView.dataWithPDF(inside: reportView.bounds).write(to: url, options: .atomic)
    }
}

private final class LocalHealthReportView: NSView {
    private let summary: ImportedHealthSummary
    private let metrics: [HealthDataTypeSummary]
    private let language: AppLanguage
    private let configuration: LocalReportConfiguration

    init(summary: ImportedHealthSummary, metrics: [HealthDataTypeSummary], language: AppLanguage, configuration: LocalReportConfiguration, frame: NSRect) {
        self.summary = summary
        self.metrics = metrics
        self.language = language
        self.configuration = configuration
        super.init(frame: frame)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    override var isFlipped: Bool { true }

    override func draw(_ dirtyRect: NSRect) {
        let palette = reportPalette
        palette.background.setFill()
        bounds.fill()
        palette.accent.withAlphaComponent(0.25).setFill()
        NSBezierPath(ovalIn: NSRect(x: 330, y: -130, width: 360, height: 360)).fill()
        let title = language.text(english: "HealthAtlas local report", german: "HealthAtlas Lokaler Bericht")
        let subtitle = language.text(english: "Created locally • no upload • descriptive values only", german: "Lokal erstellt • kein Upload • nur beschreibende Werte")
        title.draw(at: NSPoint(x: 42, y: 46), withAttributes: [.font: NSFont.systemFont(ofSize: 28, weight: .bold), .foregroundColor: NSColor.white])
        subtitle.draw(at: NSPoint(x: 42, y: 86), withAttributes: [.font: NSFont.systemFont(ofSize: 12, weight: .medium), .foregroundColor: NSColor.white.withAlphaComponent(0.72)])
        let date = Date().formatted(date: .long, time: .shortened)
        date.draw(at: NSPoint(x: 42, y: 116), withAttributes: [.font: NSFont.systemFont(ofSize: 11, weight: .medium), .foregroundColor: palette.accent])
        let configurationText = "\(configuration.periodTitle(language: language)) · \(configuration.themeName)"
        configurationText.draw(at: NSPoint(x: 42, y: 136), withAttributes: [.font: NSFont.systemFont(ofSize: 10, weight: .medium), .foregroundColor: NSColor.white.withAlphaComponent(0.66)])
        let heading = language.text(english: "Selected data types", german: "Ausgewählte Datentypen")
        heading.draw(at: NSPoint(x: 42, y: 164), withAttributes: [.font: NSFont.systemFont(ofSize: 16, weight: .bold), .foregroundColor: NSColor.white])
        let lineAttributes: [NSAttributedString.Key: Any] = [.font: NSFont.systemFont(ofSize: 13, weight: .medium), .foregroundColor: NSColor.white]
        let detailAttributes: [NSAttributedString.Key: Any] = [.font: NSFont.systemFont(ofSize: 11, weight: .regular), .foregroundColor: NSColor.white.withAlphaComponent(0.68)]
        for (index, metric) in metrics.enumerated() {
            let y = 204 + CGFloat(index) * 44
            palette.accent.withAlphaComponent(0.16).setFill()
            NSBezierPath(roundedRect: NSRect(x: 38, y: y - 7, width: 519, height: 34), xRadius: 8, yRadius: 8).fill()
            metric.localizedDisplayName.draw(at: NSPoint(x: 52, y: y), withAttributes: lineAttributes)
            let values = configuration.days > 0 ? metric.values(inLast: configuration.days) : metric.dailyValues
            let latest = values.last.map { metric.formattedValue(metric.displayValue(for: $0)) } ?? "—"
            let latestDate = values.last?.date.formatted(date: .abbreviated, time: .omitted) ?? "—"
            latest.draw(at: NSPoint(x: 370, y: y), withAttributes: lineAttributes)
            latestDate.draw(at: NSPoint(x: 52, y: y + 18), withAttributes: detailAttributes)
        }
        let footer = language.text(english: "HealthAtlas does not diagnose, evaluate or transmit health data.", german: "HealthAtlas diagnostiziert, bewertet oder überträgt keine Gesundheitsdaten.")
        footer.draw(at: NSPoint(x: 42, y: bounds.height - 42), withAttributes: [.font: NSFont.systemFont(ofSize: 10, weight: .medium), .foregroundColor: NSColor.white.withAlphaComponent(0.58)])
    }

    private var reportPalette: (background: NSColor, accent: NSColor) {
        guard let theme = AppTheme.allCases.first(where: { $0.displayName == configuration.themeName }) else {
            return (NSColor(calibratedRed: 0.025, green: 0.06, blue: 0.16, alpha: 1), NSColor.systemCyan)
        }
        return switch theme {
        case .clearGlass: (NSColor(calibratedRed: 0.10, green: 0.18, blue: 0.34, alpha: 1), NSColor.systemCyan)
        case .midnightGlass: (NSColor(calibratedRed: 0.025, green: 0.06, blue: 0.16, alpha: 1), NSColor.systemCyan)
        case .aurora: (NSColor(calibratedRed: 0.02, green: 0.15, blue: 0.19, alpha: 1), NSColor.systemTeal)
        case .warmPaper: (NSColor(calibratedRed: 0.19, green: 0.08, blue: 0.12, alpha: 1), NSColor.systemOrange)
        }
    }
}

private final class TrendGraphView: NSView {
    private let points: [HealthTrendPoint]
    private let tintColor: NSColor
    private let chartStyle: HealthChartStyle
    private let showsPoints: Bool
    private let selectedDate: Date?
    private let showsDateLabels: Bool
    private let valueFormatter: (Double) -> String
    private let onSelect: (HealthTrendPoint) -> Void
    private var progress: CGFloat
    private var timer: Timer?
    private var hitTargets: [(location: NSPoint, point: HealthTrendPoint)] = []
    private var trackingArea: NSTrackingArea?
    private var hoveredTarget: (location: NSPoint, point: HealthTrendPoint)?
    private var selectedPulsePhase: CGFloat = 0
    init(points: [HealthTrendPoint], tintColor: NSColor, chartStyle: HealthChartStyle = .line, showsPoints: Bool = false, selectedDate: Date?, showsDateLabels: Bool = false, valueFormatter: @escaping (Double) -> String = { $0.formatted(.number.precision(.fractionLength(0...1))) }, onSelect: @escaping (HealthTrendPoint) -> Void) {
        self.points = points
        self.tintColor = tintColor
        self.chartStyle = chartStyle
        self.showsPoints = showsPoints
        self.selectedDate = selectedDate
        self.showsDateLabels = showsDateLabels
        self.valueFormatter = valueFormatter
        self.onSelect = onSelect
        self.progress = NSWorkspace.shared.accessibilityDisplayShouldReduceMotion ? 1 : 0
        super.init(frame: .zero)
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    override var isFlipped: Bool { true }
    override func viewDidMoveToWindow() {
        super.viewDidMoveToWindow()
        guard !NSWorkspace.shared.accessibilityDisplayShouldReduceMotion else { return }
        guard window != nil, timer == nil else { return }
        timer = Timer.scheduledTimer(timeInterval: 1.0 / 60.0, target: self, selector: #selector(advance), userInfo: nil, repeats: true)
        RunLoop.main.add(timer!, forMode: .common)
    }
    override func viewWillMove(toWindow newWindow: NSWindow?) {
        if newWindow == nil { timer?.invalidate(); timer = nil }
        super.viewWillMove(toWindow: newWindow)
    }
    override func updateTrackingAreas() {
        if let trackingArea { removeTrackingArea(trackingArea) }
        let area = NSTrackingArea(rect: bounds, options: [.activeInKeyWindow, .mouseMoved, .mouseEnteredAndExited, .inVisibleRect], owner: self, userInfo: nil)
        addTrackingArea(area)
        trackingArea = area
        super.updateTrackingAreas()
    }
    @objc private func advance() {
        progress = min(1, progress + 0.032)
        selectedPulsePhase += 0.09
        needsDisplay = true
        if progress == 1, selectedDate == nil, hoveredTarget == nil { timer?.invalidate(); timer = nil }
    }
    override func draw(_ dirtyRect: NSRect) {
        let bottomInset: CGFloat = showsDateLabels ? 32 : 12
        let inset = NSRect(x: 8, y: 12, width: max(0, bounds.width - 16), height: max(0, bounds.height - 12 - bottomInset))
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
        var locations = [NSPoint]()
        for (index, trendPoint) in points.prefix(visibleCount).enumerated() {
            let normalized = (trendPoint.value - minimum) / span
            let location = NSPoint(x: inset.minX + inset.width * CGFloat(index) / CGFloat(points.count - 1), y: inset.maxY - inset.height * CGFloat(normalized))
            index == 0 ? line.move(to: location) : line.line(to: location)
            locations.append(location)
            hitTargets.append((location, trendPoint))
            if showsPoints && chartStyle != .bar { tintColor.setFill(); NSBezierPath(ovalIn: NSRect(x: location.x - 5, y: location.y - 5, width: 10, height: 10)).fill() }
        }
        switch chartStyle {
        case .line:
            tintColor.setStroke(); line.stroke()
        case .area:
            let fill = line.copy() as! NSBezierPath
            if let first = locations.first, let last = locations.last {
                fill.line(to: NSPoint(x: last.x, y: inset.maxY))
                fill.line(to: NSPoint(x: first.x, y: inset.maxY))
                fill.close()
                tintColor.withAlphaComponent(0.22).setFill(); fill.fill()
            }
            tintColor.setStroke(); line.stroke()
        case .bar:
            let width = max(4, min(26, inset.width / CGFloat(max(visibleCount, 1)) * 0.62))
            for location in locations {
                let rect = NSRect(x: location.x - width / 2, y: location.y, width: width, height: max(2, inset.maxY - location.y))
                tintColor.withAlphaComponent(0.68).setFill()
                NSBezierPath(roundedRect: rect, xRadius: min(4, width / 2), yRadius: min(4, width / 2)).fill()
            }
        }
        if showsDateLabels, let first = points.first?.date, let last = points.last?.date {
            let middle = points[points.count / 2].date
            let formatter = DateFormatter()
            formatter.locale = Locale(identifier: AppLanguage.current == .german ? "de_DE" : "en_US")
            formatter.setLocalizedDateFormatFromTemplate("dMMM")
            let labels = [(first, inset.minX), (middle, inset.midX), (last, inset.maxX)]
            let attributes: [NSAttributedString.Key: Any] = [
                .font: NSFont.systemFont(ofSize: 10, weight: .medium),
                .foregroundColor: NSColor.white.withAlphaComponent(0.68)
            ]
            for (date, x) in labels {
                let label = formatter.string(from: date)
                let size = label.size(withAttributes: attributes)
                label.draw(at: NSPoint(x: min(max(inset.minX, x - size.width / 2), inset.maxX - size.width), y: bounds.height - 18), withAttributes: attributes)
            }
        }
        if let selectedDate,
           let selected = hitTargets.first(where: { Calendar.current.isDate($0.point.date, inSameDayAs: selectedDate) }) {
            let pulse = 14 + sin(selectedPulsePhase) * 2.4
            tintColor.withAlphaComponent(0.20 + (sin(selectedPulsePhase) + 1) * 0.03).setFill()
            NSBezierPath(ovalIn: NSRect(x: selected.location.x - pulse, y: selected.location.y - pulse, width: pulse * 2, height: pulse * 2)).fill()
            NSColor.white.setFill()
            NSBezierPath(ovalIn: NSRect(x: selected.location.x - 5, y: selected.location.y - 5, width: 10, height: 10)).fill()
        }
        if let hoveredTarget {
            let date = hoveredTarget.point.date.formatted(date: .long, time: .omitted)
            let value = valueFormatter(hoveredTarget.point.value)
            let width: CGFloat = 190
            let originX = min(max(inset.minX, hoveredTarget.location.x - width / 2), inset.maxX - width)
            let originY = max(inset.minY, hoveredTarget.location.y - 68)
            let bubble = NSRect(x: originX, y: originY, width: width, height: 56)
            NSColor.black.withAlphaComponent(0.76).setFill()
            NSBezierPath(roundedRect: bubble, xRadius: 10, yRadius: 10).fill()
            date.draw(at: NSPoint(x: bubble.minX + 10, y: bubble.minY + 34), withAttributes: [.font: NSFont.systemFont(ofSize: 10, weight: .medium), .foregroundColor: NSColor.white.withAlphaComponent(0.68)])
            value.draw(at: NSPoint(x: bubble.minX + 10, y: bubble.minY + 13), withAttributes: [.font: NSFont.systemFont(ofSize: 14, weight: .bold), .foregroundColor: NSColor.white])
            let allValues = points.map(\.value)
            if let index = points.firstIndex(where: { Calendar.current.isDate($0.date, inSameDayAs: hoveredTarget.point.date) }) {
                let localValues = Array(allValues[max(0, index - 2)...min(allValues.count - 1, index + 2)])
                if localValues.count > 1, let low = localValues.min(), let high = localValues.max() {
                    let spark = NSBezierPath(); spark.lineWidth = 1.5
                    for (sparkIndex, number) in localValues.enumerated() {
                        let x = bubble.maxX - 60 + CGFloat(sparkIndex) / CGFloat(localValues.count - 1) * 48
                        let y = bubble.minY + 14 + (number - low) / max(high - low, 0.000_001) * 26
                        sparkIndex == 0 ? spark.move(to: NSPoint(x: x, y: y)) : spark.line(to: NSPoint(x: x, y: y))
                    }
                    tintColor.setStroke(); spark.stroke()
                }
            }
            NSColor.white.withAlphaComponent(0.88).setFill()
            NSBezierPath(ovalIn: NSRect(x: hoveredTarget.location.x - 4, y: hoveredTarget.location.y - 4, width: 8, height: 8)).fill()
        }
    }

    override func mouseDown(with event: NSEvent) {
        let click = convert(event.locationInWindow, from: nil)
        guard let target = hitTargets.min(by: { hypot($0.location.x - click.x, $0.location.y - click.y) < hypot($1.location.x - click.x, $1.location.y - click.y) }),
              hypot(target.location.x - click.x, target.location.y - click.y) < 18 else { return }
        onSelect(target.point)
    }

    override func mouseMoved(with event: NSEvent) {
        let location = convert(event.locationInWindow, from: nil)
        let target = nearestTarget(to: location, maximumDistance: 18)
        if (target?.point.date != hoveredTarget?.point.date) {
            hoveredTarget = target
            if timer == nil, target != nil, !NSWorkspace.shared.accessibilityDisplayShouldReduceMotion {
                timer = Timer.scheduledTimer(timeInterval: 1.0 / 60.0, target: self, selector: #selector(advance), userInfo: nil, repeats: true)
                if let timer { RunLoop.main.add(timer, forMode: .common) }
            }
            needsDisplay = true
        }
    }

    override func mouseExited(with event: NSEvent) {
        guard hoveredTarget != nil else { return }
        hoveredTarget = nil
        needsDisplay = true
    }

    private func nearestTarget(to location: NSPoint, maximumDistance: CGFloat) -> (location: NSPoint, point: HealthTrendPoint)? {
        guard let target = hitTargets.min(by: { hypot($0.location.x - location.x, $0.location.y - location.y) < hypot($1.location.x - location.x, $1.location.y - location.y) }), hypot(target.location.x - location.x, target.location.y - location.y) < maximumDistance else { return nil }
        return target
    }
}
