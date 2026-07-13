import Foundation

enum AppLanguage: String, CaseIterable {
    case english = "en"
    case german = "de"

    static let preferenceKey = "HealthAtlas.appLanguage"

    static var current: AppLanguage {
        if let stored = UserDefaults.standard.string(forKey: preferenceKey),
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
        UserDefaults.standard.set(rawValue, forKey: Self.preferenceKey)
    }
}
