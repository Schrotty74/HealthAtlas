import AppKit

final class DashboardViewController: NSViewController {
    override func loadView() {
        view = NSView()
        view.wantsLayer = true
        view.layer?.backgroundColor = NSColor.windowBackgroundColor.cgColor

        let title = NSTextField(labelWithString: "Overview")
        title.font = .systemFont(ofSize: 30, weight: .bold)
        title.translatesAutoresizingMaskIntoConstraints = false

        let subtitle = NSTextField(labelWithString: "Your health, in focus.")
        subtitle.textColor = .secondaryLabelColor
        subtitle.translatesAutoresizingMaskIntoConstraints = false

        let privacy = NSTextField(labelWithString: "●  Local only — computed on this Mac")
        privacy.textColor = .systemGreen
        privacy.translatesAutoresizingMaskIntoConstraints = false

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
        view.addSubview(metrics)
        view.addSubview(chart)

        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 36),
            stack.topAnchor.constraint(equalTo: view.topAnchor, constant: 32),
            privacy.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -36),
            privacy.centerYAnchor.constraint(equalTo: title.centerYAnchor),
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

    private func metricCard(_ metric: HealthMetric) -> NSView {
        let box = NSBox()
        box.title = metric.title
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
