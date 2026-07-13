import AppKit

final class DashboardViewController: NSViewController {
    override func loadView() {
        view = NSView()
        view.wantsLayer = true
        view.layer?.backgroundColor = NSColor.windowBackgroundColor.cgColor

        let language = AppLanguage.current
        let title = NSTextField(labelWithString: language.text(english: "Overview", german: "Übersicht"))
        title.font = .systemFont(ofSize: 30, weight: .bold)
        title.translatesAutoresizingMaskIntoConstraints = false

        let subtitle = NSTextField(labelWithString: language.text(english: "Your health, in focus.", german: "Deine Gesundheit im Blick."))
        subtitle.textColor = .secondaryLabelColor
        subtitle.translatesAutoresizingMaskIntoConstraints = false

        let privacy = NSTextField(labelWithString: language.text(english: "●  Local only — computed on this Mac", german: "●  Nur lokal — auf diesem Mac berechnet"))
        privacy.textColor = .systemGreen
        privacy.translatesAutoresizingMaskIntoConstraints = false

        let languageLabel = NSTextField(labelWithString: language.text(english: "Language", german: "Sprache"))
        languageLabel.textColor = .secondaryLabelColor
        languageLabel.translatesAutoresizingMaskIntoConstraints = false

        let languagePopup = NSPopUpButton()
        languagePopup.addItems(withTitles: AppLanguage.allCases.map(\.displayName))
        languagePopup.selectItem(withTitle: language.displayName)
        languagePopup.target = self
        languagePopup.action = #selector(languageChanged(_:))
        languagePopup.translatesAutoresizingMaskIntoConstraints = false

        let githubButton = NSButton(title: "GitHub", target: self, action: #selector(openGitHub))
        githubButton.bezelStyle = .rounded
        githubButton.translatesAutoresizingMaskIntoConstraints = false

        let stack = NSStackView()
        stack.orientation = .vertical
        stack.spacing = 6
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.addArrangedSubview(title)
        stack.addArrangedSubview(subtitle)

        let metrics = NSStackView()
        metrics.orientation = .horizontal
        metrics.distribution = .fillEqually
        metrics.spacing = 14
        metrics.translatesAutoresizingMaskIntoConstraints = false
        HealthDataStore.demoMetrics.forEach { metrics.addArrangedSubview(metricCard($0)) }

        let chart = NSBox()
        chart.title = "Activity over time"
        chart.boxType = .custom
        chart.cornerRadius = 18
        chart.fillColor = NSColor.controlBackgroundColor.withAlphaComponent(0.55)
        chart.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(stack)
        view.addSubview(privacy)
        view.addSubview(languageLabel)
        view.addSubview(languagePopup)
        view.addSubview(githubButton)
        view.addSubview(metrics)
        view.addSubview(chart)

        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 36),
            stack.topAnchor.constraint(equalTo: view.topAnchor, constant: 32),
            privacy.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -36),
            privacy.centerYAnchor.constraint(equalTo: title.centerYAnchor),
            githubButton.trailingAnchor.constraint(equalTo: privacy.leadingAnchor, constant: -14),
            githubButton.centerYAnchor.constraint(equalTo: title.centerYAnchor),
            languagePopup.trailingAnchor.constraint(equalTo: githubButton.leadingAnchor, constant: -14),
            languagePopup.centerYAnchor.constraint(equalTo: title.centerYAnchor),
            languageLabel.trailingAnchor.constraint(equalTo: languagePopup.leadingAnchor, constant: -6),
            languageLabel.centerYAnchor.constraint(equalTo: languagePopup.centerYAnchor),
            metrics.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 36),
            metrics.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -36),
            metrics.topAnchor.constraint(equalTo: stack.bottomAnchor, constant: 32),
            metrics.heightAnchor.constraint(equalToConstant: 145),
            chart.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 36),
            chart.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -36),
            chart.topAnchor.constraint(equalTo: metrics.bottomAnchor, constant: 24),
            chart.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -36)
        ])
    }

    @objc private func languageChanged(_ sender: NSPopUpButton) {
        let selected = AppLanguage.allCases[sender.indexOfSelectedItem]
        selected.save()
        view.window?.title = selected.text(english: "HealthAtlas", german: "HealthAtlas")
        view.window?.contentViewController = DashboardViewController()
    }

    @objc private func openGitHub() {
        guard let url = URL(string: "https://github.com/Schrotty74/HealthAtlas") else { return }
        NSWorkspace.shared.open(url)
    }

    private func metricCard(_ metric: HealthMetric) -> NSView {
        let box = NSBox()
        let language = AppLanguage.current
        let localizedTitle: String
        switch metric.title {
        case "Activity": localizedTitle = language.text(english: "Activity", german: "Aktivität")
        case "Sleep": localizedTitle = language.text(english: "Sleep", german: "Schlaf")
        case "Heart Rate": localizedTitle = language.text(english: "Heart Rate", german: "Herzfrequenz")
        case "Wellness": localizedTitle = language.text(english: "Wellness", german: "Wohlbefinden")
        default: localizedTitle = metric.title
        }
        box.title = localizedTitle
        box.boxType = .custom
        box.cornerRadius = 18
        box.fillColor = NSColor.controlBackgroundColor.withAlphaComponent(0.65)
        let value = NSTextField(labelWithString: metric.value)
        value.font = .systemFont(ofSize: 26, weight: .semibold)
        value.translatesAutoresizingMaskIntoConstraints = false
        let detail = NSTextField(labelWithString: metric.detail)
        detail.textColor = .secondaryLabelColor
        detail.translatesAutoresizingMaskIntoConstraints = false
        box.addSubview(value)
        box.addSubview(detail)
        NSLayoutConstraint.activate([
            value.leadingAnchor.constraint(equalTo: box.leadingAnchor, constant: 18),
            value.topAnchor.constraint(equalTo: box.topAnchor, constant: 42),
            detail.leadingAnchor.constraint(equalTo: value.leadingAnchor),
            detail.topAnchor.constraint(equalTo: value.bottomAnchor, constant: 6)
        ])
        return box
    }
}
