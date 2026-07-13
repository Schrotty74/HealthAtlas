import Foundation

struct HealthMetric {
    let title: String
    let value: String
    let detail: String
    let color: String
}

enum HealthDataStore {
    static let demoMetrics = [
        HealthMetric(title: "Activity", value: "7,420", detail: "steps today", color: "blue"),
        HealthMetric(title: "Sleep", value: "7 h 23 m", detail: "last night", color: "purple"),
        HealthMetric(title: "Heart Rate", value: "62 bpm", detail: "resting average", color: "pink"),
        HealthMetric(title: "Wellness", value: "81", detail: "local score", color: "green")
    ]
}
