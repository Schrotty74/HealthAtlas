import Foundation

enum BuildChannel: String {
    case dev, beta, final

    static var current: BuildChannel {
        let value = Bundle.main.object(forInfoDictionaryKey: "HealthAtlasBuildChannel") as? String
        return value.flatMap(BuildChannel.init(rawValue:)) ?? .dev
    }

    var displayName: String {
        switch self {
        case .dev: "HealthAtlas Dev"
        case .beta: "HealthAtlas Beta"
        case .final: "HealthAtlas"
        }
    }
}

enum BuildEnvironment {
    static var defaults: UserDefaults {
        UserDefaults(suiteName: "com.healthatlas.app.\(BuildChannel.current.rawValue).preferences") ?? .standard
    }
}

enum AppLanguage: String, CaseIterable {
    case english = "en"
    case german = "de"

    static let preferenceKey = "HealthAtlas.appLanguage"

    static var current: AppLanguage {
        if let stored = BuildEnvironment.defaults.string(forKey: preferenceKey),
           let language = AppLanguage(rawValue: stored) {
            return language
        }
        return Locale.preferredLanguages.first?.hasPrefix("de") == true ? .german : .english
    }

    var displayName: String {
        switch self {
        case .english: "English"
        case .german: "Deutsch"
        }
    }

    func text(english: String, german: String) -> String {
        self == .german ? german : english
    }

    func save() {
        BuildEnvironment.defaults.set(rawValue, forKey: Self.preferenceKey)
    }
}
