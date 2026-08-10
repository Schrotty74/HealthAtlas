import AppKit
import Foundation

/// Privacy-safe first-launch assistance. It never includes imported or local app data.
enum FirstLaunchAIService: String, CaseIterable {
    case chatGPT
    case gemini
    case claude

    var title: String {
        switch self {
        case .chatGPT: "ChatGPT"
        case .gemini: "Gemini"
        case .claude: "Claude"
        }
    }

    var logoResource: (name: String, fileExtension: String) {
        switch self {
        case .chatGPT: ("healthatlas-chatgpt-logo", "jpg")
        case .gemini: ("healthatlas-gemini-logo", "svg")
        case .claude: ("healthatlas-claude-logo", "png")
        }
    }

    var websiteURL: URL {
        switch self {
        case .chatGPT: URL(string: "https://chatgpt.com/")!
        case .gemini: URL(string: "https://gemini.google.com/")!
        case .claude: URL(string: "https://claude.ai/")!
        }
    }
}

struct FirstLaunchHelpContent {
    let language: AppLanguage

    init(language: AppLanguage) {
        self.language = language
    }

    var handbookURL: URL {
        switch language {
        case .german:
            URL(string: "https://github.com/Schrotty74/HealthAtlas/blob/main/output/pdf/HealthAtlas-Handbuch-DE.pdf")!
        case .english:
            URL(string: "https://github.com/Schrotty74/HealthAtlas/blob/main/output/pdf/HealthAtlas-Manual-EN.pdf")!
        }
    }

    var prompt: String {
        switch language {
        case .german:
            """
            Ich habe HealthAtlas gerade zum ersten Mal geöffnet. Erkläre mir die App freundlich und in einfacher Sprache. Führe mich Schritt für Schritt durch den ersten sinnvollen Start. Erkläre die wichtigsten Funktionen, wo ich sie in der App finde und wann sie sinnvoll sind. Frage mich am Ende, wobei ich Hilfe benötige. Verwende dieses offizielle Handbuch auf GitHub:
            \(handbookURL.absoluteString)
            """
        case .english:
            """
            I have just opened HealthAtlas for the first time. Explain the app in a friendly and simple way. Guide me step by step through the first useful start. Explain the most important features, where to find them in the app, and when they are useful. At the end, ask me what I need help with. Use this official manual on GitHub:
            \(handbookURL.absoluteString)
            """
        }
    }

    var title: String {
        language.text(english: "Welcome to HealthAtlas", german: "Willkommen bei HealthAtlas")
    }

    var introduction: String {
        language.text(
            english: "Import an Apple Health export locally, or use the guide for a calm first start.",
            german: "Importiere einen Apple-Health-Export lokal oder nutze die Hilfe für einen ruhigen ersten Start."
        )
    }

    var manualButtonTitle: String {
        language.text(english: "Open Manual", german: "Handbuch öffnen")
    }

    var aiHeading: String {
        language.text(english: "Get Started with AI Help", german: "Erste Hilfe mit KI")
    }

    var privacyNote: String {
        language.text(
            english: "The prepared question contains no local data. It is copied only to the clipboard; paste it into the selected service yourself with Cmd+V.",
            german: "Die vorbereitete Frage enthält keine lokalen Daten. Sie wird nur in die Zwischenablage kopiert; füge sie beim gewählten Dienst selbst mit Cmd+V ein."
        )
    }

    func serviceHelp(_ service: FirstLaunchAIService) -> String {
        language.text(
            english: "Copy the question and open \(service.title)",
            german: "Frage kopieren und \(service.title) öffnen"
        )
    }
}

@MainActor
enum FirstLaunchHelpAction {
    static func copyPromptAndOpen(_ service: FirstLaunchAIService, language: AppLanguage) {
        let content = FirstLaunchHelpContent(language: language)
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(content.prompt, forType: .string)
        NSWorkspace.shared.open(service.websiteURL)
    }

    static func openManual(for language: AppLanguage) {
        NSWorkspace.shared.open(FirstLaunchHelpContent(language: language).handbookURL)
    }
}
