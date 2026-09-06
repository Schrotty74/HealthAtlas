@preconcurrency import Foundation

enum AppUpdateCadence: String, CaseIterable {
    case everyLaunch, daily, weekly, monthly

    var interval: TimeInterval {
        switch self {
        case .everyLaunch: 0
        case .daily: 24 * 60 * 60
        case .weekly: 7 * 24 * 60 * 60
        case .monthly: 30 * 24 * 60 * 60
        }
    }

    func title(for language: AppLanguage) -> String {
        switch self {
        case .everyLaunch: language.text(english: "At every launch", german: "Bei jedem Start")
        case .daily: language.text(english: "Once a day", german: "Einmal täglich")
        case .weekly: language.text(english: "Once a week", german: "Einmal wöchentlich")
        case .monthly: language.text(english: "Once a month", german: "Einmal monatlich")
        }
    }
}

struct AppReleaseVersion: Comparable, Equatable, Sendable {
    let major: Int
    let minor: Int
    let patch: Int
    let beta: Int?

    init?(_ value: String) {
        let components = value.trimmingCharacters(in: .whitespacesAndNewlines)
            .trimmingCharacters(in: CharacterSet(charactersIn: "vV"))
            .split(separator: "-", maxSplits: 1, omittingEmptySubsequences: false)
        let numbers = components.first?.split(separator: ".").compactMap { Int($0) } ?? []
        guard numbers.count == 3 else { return nil }
        major = numbers[0]
        minor = numbers[1]
        patch = numbers[2]
        if components.count == 2, components[1].lowercased().hasPrefix("beta") {
            beta = components[1].split(whereSeparator: { !$0.isNumber }).compactMap { Int($0) }.first ?? 0
        } else {
            beta = nil
        }
    }

    static func < (lhs: AppReleaseVersion, rhs: AppReleaseVersion) -> Bool {
        let leftNumbers = [lhs.major, lhs.minor, lhs.patch]
        let rightNumbers = [rhs.major, rhs.minor, rhs.patch]
        if leftNumbers != rightNumbers { return leftNumbers.lexicographicallyPrecedes(rightNumbers) }
        return switch (lhs.beta, rhs.beta) {
        case (nil, nil): false
        case (nil, .some): false
        case (.some, nil): true
        case let (.some(left), .some(right)): left < right
        }
    }
}

struct AppUpdateRelease: Equatable, Sendable {
    let version: AppReleaseVersion
    let versionText: String
    let url: URL
    let isPrerelease: Bool
}

enum AppUpdateCheckResult: Equatable, Sendable {
    case upToDate
    case updateAvailable(AppUpdateRelease)
    case unavailable
}

struct GitHubRelease: Decodable, Sendable {
    let tagName: String
    let htmlURL: URL
    let isPrerelease: Bool
    let isDraft: Bool

    enum CodingKeys: String, CodingKey {
        case tagName = "tag_name"
        case htmlURL = "html_url"
        case isPrerelease = "prerelease"
        case isDraft = "draft"
    }
}

final class AppUpdateService {
    static let releasesURL = URL(string: "https://api.github.com/repos/Schrotty74/HealthAtlas/releases")!

    func check(channel: BuildChannel, installedVersion: String, completion: @escaping @Sendable (AppUpdateCheckResult) -> Void) {
        let request = URLRequest(url: Self.releasesURL, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 15)
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard error == nil,
                  let response = response as? HTTPURLResponse,
                  (200...299).contains(response.statusCode),
                  let data,
                  let releases = try? JSONDecoder().decode([GitHubRelease].self, from: data),
                  let installed = AppReleaseVersion(installedVersion) else {
                completion(.unavailable)
                return
            }
            guard let latest = Self.latestRelease(from: releases, for: channel) else {
                completion(.unavailable)
                return
            }
            completion(latest.version > installed ? .updateAvailable(latest) : .upToDate)
        }.resume()
    }

    static func latestRelease(from releases: [GitHubRelease], for channel: BuildChannel) -> AppUpdateRelease? {
        releases.compactMap { release -> AppUpdateRelease? in
            guard !release.isDraft,
                  channel != .final || !release.isPrerelease,
                  let version = AppReleaseVersion(release.tagName) else { return nil }
            return AppUpdateRelease(version: version, versionText: release.tagName, url: release.htmlURL, isPrerelease: release.isPrerelease)
        }.max { $0.version < $1.version }
    }
}

enum InstalledAppVersion {
    static var marketing: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "—"
    }

    static var build: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "—"
    }
}
