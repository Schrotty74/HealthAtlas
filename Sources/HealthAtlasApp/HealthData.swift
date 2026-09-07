import Foundation

struct HealthMetric {
    let identifier: String
    let title: String
    let value: String
    let detail: String
    let color: String

    var localizedTitle: String {
        switch title {
        case "Activity": AppLanguage.current.text(english: "Activity", german: "Aktivität")
        case "Sleep": AppLanguage.current.text(english: "Sleep", german: "Schlaf")
        case "Heart Rate": AppLanguage.current.text(english: "Heart Rate", german: "Herzfrequenz")
        case "Wellness": AppLanguage.current.text(english: "Wellness", german: "Wohlbefinden")
        default: title
        }
    }

    var localizedDetail: String {
        switch detail {
        case "steps today": AppLanguage.current.text(english: "steps today", german: "Schritte heute")
        case "last night": AppLanguage.current.text(english: "last night", german: "letzte Nacht")
        case "resting average": AppLanguage.current.text(english: "resting average", german: "Ruhedurchschnitt")
        case "local score": AppLanguage.current.text(english: "local score", german: "lokaler Wert")
        case "steps in export": AppLanguage.current.text(english: "steps in export", german: "Schritte im Export")
        case "sleep samples": AppLanguage.current.text(english: "sleep samples", german: "Schlafproben")
        case "average bpm": AppLanguage.current.text(english: "average bpm", german: "Durchschnitt bpm")
        case "health records": AppLanguage.current.text(english: "health records", german: "Gesundheitsdatensätze")
        default: detail
        }
    }
}

enum HealthDataCategory: String, CaseIterable {
    case activity, body, cycleTracking, hearing, heart, mindfulness, mobility, nutrition, respiratory, sleep, symptoms, vitals, selfCare, other

    static func category(for identifier: String) -> HealthDataCategory {
        let value = identifier.lowercased()
        if value.contains("dietary") || value.contains("food") || value.contains("water") || value.contains("alcohol") { return .nutrition }
        if value.contains("menstrual") || value.contains("pregnancy") || value.contains("cervical") || value.contains("ovulation") || value.contains("contraceptive") || value.contains("lactation") || value.contains("vaginal") || value.contains("breastpain") || value.contains("hotflashes") || value.contains("menopausal") || value.contains("intermenstrual") { return .cycleTracking }
        if value.contains("symptom") || value.contains("cramp") || value.contains("acne") || value.contains("appetite") || value.contains("bloating") || value.contains("chills") || value.contains("constipation") || value.contains("cough") || value.contains("diarrhea") || value.contains("dizziness") || value.contains("dryskin") || value.contains("fainting") || value.contains("fatigue") || value.contains("fever") || value.contains("ache") || value.contains("hairloss") || value.contains("headache") || value.contains("heartburn") || value.contains("lowerbackpain") || value.contains("nausea") || value.contains("nightsweats") || value.contains("pelvicpain") || value.contains("runnynose") || value.contains("sorethroat") || value.contains("vomiting") || value.contains("wheezing") { return .symptoms }
        if value.contains("respiratory") || value.contains("oxygen") || value.contains("inhaler") || value.contains("forcedexpiratory") || value.contains("forcedvital") || value.contains("peakexpiratory") || value.contains("shortnessofbreath") { return .respiratory }
        if value.contains("walking") || value.contains("sixminutewalk") || value.contains("stair") || value.contains("fall") || value.contains("wheelchair") { return .mobility }
        if value.contains("heart") || value.contains("cardio") || value.contains("atrial") || value.contains("bloodpressure") || value.contains("irregularrhythm") { return .heart }
        if value.contains("sleep") { return .sleep }
        if value.contains("bodymass") || value.contains("bodyfat") || value.contains("leanbody") || value.contains("bmi") || value.contains("height") { return .body }
        if value.contains("audio") || value.contains("hearing") { return .hearing }
        if value.contains("mindful") || value.contains("stateofmind") { return .mindfulness }
        if value.contains("toothbrushing") || value.contains("handwashing") { return .selfCare }
        if value.contains("bloodglucose") || value.contains("temperature") || value.contains("electrodermal") || value.contains("insulin") || value.contains("peripheralperfusion") { return .vitals }
        if value.contains("step") || value.contains("distance") || value.contains("energy") || value.contains("running") || value.contains("flight") || value.contains("workout") || value.contains("activity") || value.contains("cycling") || value.contains("swimming") || value.contains("rowing") || value.contains("skating") || value.contains("skiing") || value.contains("paddle") || value.contains("pushcount") || value.contains("stand") || value.contains("exercise") { return .activity }
        return .other
    }

    var sortOrder: Int { HealthDataCategory.allCases.firstIndex(of: self) ?? .max }

    func displayName(for language: AppLanguage) -> String {
        switch self {
        case .activity: language.text(english: "Activity", german: "Aktivität")
        case .body: language.text(english: "Body", german: "Körper")
        case .cycleTracking: language.text(english: "Cycle Tracking", german: "Zyklusprotokoll")
        case .hearing: language.text(english: "Hearing", german: "Hören")
        case .heart: language.text(english: "Heart", german: "Herz")
        case .mindfulness: language.text(english: "Mindfulness", german: "Achtsamkeit")
        case .mobility: language.text(english: "Mobility", german: "Mobilität")
        case .nutrition: language.text(english: "Nutrition", german: "Ernährung")
        case .respiratory: language.text(english: "Respiratory", german: "Atmung")
        case .sleep: language.text(english: "Sleep", german: "Schlaf")
        case .symptoms: language.text(english: "Symptoms", german: "Symptome")
        case .vitals: language.text(english: "Vitals", german: "Vitalwerte")
        case .selfCare: language.text(english: "Self Care", german: "Selbstpflege")
        case .other: language.text(english: "Other", german: "Weitere")
        }
    }
}

struct HealthPeriodComparison: Equatable {
    let current: Double
    let previous: Double

    var difference: Double { current - previous }
    var percentage: Double? { previous == 0 ? nil : difference / abs(previous) * 100 }

    static func make(values: [HealthDailyValue], metric: HealthDataTypeSummary, days: Int) -> HealthPeriodComparison? {
        guard days > 0, let latestDate = values.map(\.date).max() else { return nil }
        let calendar = Calendar.current
        guard let currentStart = calendar.date(byAdding: .day, value: -(days - 1), to: latestDate),
              let previousStart = calendar.date(byAdding: .day, value: -days, to: currentStart) else { return nil }
        let currentValues = values.filter { $0.date >= currentStart && $0.date <= latestDate }.map(metric.displayValue(for:))
        let previousValues = values.filter { $0.date >= previousStart && $0.date < currentStart }.map(metric.displayValue(for:))
        guard !currentValues.isEmpty, !previousValues.isEmpty else { return nil }
        return HealthPeriodComparison(
            current: currentValues.reduce(0, +) / Double(currentValues.count),
            previous: previousValues.reduce(0, +) / Double(previousValues.count)
        )
    }
}

struct LocalImportSummary: Equatable {
    let fileName: String
    let format: String
    let byteCount: Int
}

struct ImportedHealthSummary: Equatable {
    let fileName: String
    let recordCount: Int
    let dataTypes: [HealthDataTypeSummary]
}

struct HealthDataTypeSummary: Equatable, Identifiable {
    let identifier: String
    let displayName: String
    let recordCount: Int
    let sum: Double
    let average: Double?
    let unit: String?
    let dailyValues: [HealthDailyValue]

    var id: String { identifier }

    var localizedDisplayName: String {
        HealthDataTypeName.displayName(for: identifier, language: .current)
    }

    var valueText: String {
        guard let average else { return recordCount.formatted() }
        let value: Double
        if HealthDataAggregationRule.rule(for: identifier).usesTotalValue {
            value = sum
        } else {
            value = average
        }
        return formattedValue(value)
    }

    var detailText: String {
        "\(recordCount.formatted()) " + AppLanguage.current.text(english: "samples", german: "Messwerte")
    }

    var latestValueText: String {
        guard let latest = dailyValues.last else { return valueText }
        return formattedValue(displayValue(for: latest))
    }

    var latestDetailText: String {
        dailyValues.last?.date.formatted(date: .abbreviated, time: .omitted) ?? detailText
    }

    func displayValue(for dailyValue: HealthDailyValue) -> Double {
        HealthDataAggregationRule.rule(for: identifier).usesTotalValue
            ? dailyValue.sum : dailyValue.average
    }

    func formattedValue(_ value: Double) -> String {
        let formatted = value.formatted(.number.precision(.fractionLength(0...1)))
        return unit.map { "\(formatted) \(localizedUnit($0))" } ?? formatted
    }

    var preferredChartStyle: HealthChartStyle {
        let identifier = identifier.lowercased()
        if identifier.contains("sleep") { return .area }
        if identifier.contains("stepcount") || identifier.contains("energy") { return .bar }
        return .line
    }

    func values(inLast days: Int, calendar: Calendar = .current) -> [HealthDailyValue] {
        guard days > 0, let latest = dailyValues.last?.date,
              let cutoff = calendar.date(byAdding: .day, value: -(days - 1), to: latest) else { return [] }
        return dailyValues.filter { $0.date >= cutoff }
    }

    private func localizedUnit(_ unit: String) -> String {
        guard AppLanguage.current == .german else { return unit }
        return switch unit {
        case "count": "Anz."
        case "count/min": "Anz./min"
        default: unit
        }
    }
}

enum HealthChartStyle: Equatable {
    case line
    case bar
    case area
}

struct LocalDataCoverage: Equatable {
    let observedDays: Int
    let missingDays: Int
    let sparseTypes: [String]

    static func make(metrics: [HealthDataTypeSummary], days: Int = 7, calendar: Calendar = .current) -> LocalDataCoverage {
        let dates = metrics.flatMap(\.dailyValues).map { calendar.startOfDay(for: $0.date) }
        let latest = dates.max()
        let expectedDays: Int
        if let latest, let start = calendar.date(byAdding: .day, value: -(days - 1), to: latest) {
            expectedDays = Set((0..<days).compactMap { calendar.date(byAdding: .day, value: $0, to: start) }.map { calendar.startOfDay(for: $0) }).count
        } else {
            expectedDays = 0
        }
        let observedDays: Int
        if let latest, let start = calendar.date(byAdding: .day, value: -(days - 1), to: latest) {
            observedDays = Set(dates.filter { $0 >= start && $0 <= latest }).count
        } else {
            observedDays = 0
        }
        let sparse = metrics.filter { $0.dailyValues.count <= 2 }.map(\.localizedDisplayName)
        return LocalDataCoverage(observedDays: observedDays, missingDays: max(0, expectedDays - observedDays), sparseTypes: sparse)
    }
}

struct HealthDailyValue: Equatable {
    let date: Date
    let sum: Double
    let average: Double
}

enum LocalImportResult: Equatable {
    case ready(LocalImportSummary)
    case imported(ImportedHealthSummary)
    case rejected(String)
}

enum LocalImportValidator {
    private static let supportedExtensions: Set<String> = ["xml", "zip"]
    /// HealthAtlas supports local XML exports up to 500 MiB. The limit keeps
    /// import work bounded without claiming an Apple Health or macOS limit.
    static let maximumBytes = 500 * 1024 * 1024

    static func supportsXMLByteCount(_ byteCount: Int) -> Bool {
        byteCount > 0 && byteCount <= maximumBytes
    }

    static func validate(url: URL) -> LocalImportResult {
        let extensionName = url.pathExtension.lowercased()
        guard supportedExtensions.contains(extensionName) else {
            return .rejected(AppLanguage.current.text(english: "Select an Apple Health ZIP archive or Export.xml file.", german: "Wähle ein Apple-Health-ZIP-Archiv oder eine Export.xml-Datei aus."))
        }
        guard let values = try? url.resourceValues(forKeys: [.fileSizeKey, .isRegularFileKey]), values.isRegularFile == true else {
            return .rejected(AppLanguage.current.text(english: "Please select a regular local file.", german: "Bitte wähle eine normale lokale Datei aus."))
        }
        let byteCount = values.fileSize ?? 0
        guard byteCount > 0 else {
            return .rejected(AppLanguage.current.text(english: "The selected file is empty.", german: "Die ausgewählte Datei ist leer."))
        }
        if extensionName == "zip" {
            guard AppleHealthImporter.supportsArchiveByteCount(byteCount) else {
                return .rejected(AppLanguage.current.text(english: "HealthAtlas supports local Apple Health ZIP archives up to 500 MB. This is an app safety limit.", german: "HealthAtlas unterstützt lokale Apple-Health-ZIP-Archive bis 500 MB. Das ist eine Sicherheitsgrenze der App."))
            }
            return AppleHealthImporter.importArchive(at: url, fileSize: byteCount)
        }
        guard supportsXMLByteCount(byteCount) else {
            return .rejected(AppLanguage.current.text(english: "HealthAtlas supports local Apple Health XML files up to 500 MB. This is an app safety limit.", german: "HealthAtlas unterstützt lokale Apple-Health-XML-Dateien bis 500 MB. Das ist eine Sicherheitsgrenze der App."))
        }
        guard isReadableTextExport(at: url) else {
            return .rejected(AppLanguage.current.text(english: "The selected file is not a readable text export.", german: "Die ausgewählte Datei ist kein lesbarer Textexport."))
        }
        if extensionName == "xml", let summary = AppleHealthImporter.importXML(at: url, fileName: url.lastPathComponent) {
            return .imported(summary)
        }
        return .rejected(AppLanguage.current.text(english: "The selected file does not contain readable Apple Health data.", german: "Die ausgewählte Datei enthält keine lesbaren Apple-Health-Daten."))
    }

    private static func isReadableTextExport(at url: URL) -> Bool {
        guard let handle = try? FileHandle(forReadingFrom: url) else { return false }
        defer { try? handle.close() }
        guard let prefix = try? handle.read(upToCount: 512), !prefix.isEmpty else { return false }
        return !prefix.contains(0)
    }
}

enum AppleHealthImporter {
    static let maximumArchiveBytes = 500 * 1024 * 1024
    private static let maximumXMLBytes = LocalImportValidator.maximumBytes
    private static let maximumZIPListingBytes = 2 * 1024 * 1024
    private static let maximumZIPEntryInfoBytes = 64 * 1024

    static func supportsArchiveByteCount(_ byteCount: Int) -> Bool {
        byteCount > 0 && byteCount <= maximumArchiveBytes
    }

    static func importArchive(at url: URL, fileSize: Int) -> LocalImportResult {
        guard supportsArchiveByteCount(fileSize) else {
            return .rejected(AppLanguage.current.text(english: "HealthAtlas supports local Apple Health ZIP archives up to 500 MB. This is an app safety limit.", german: "HealthAtlas unterstützt lokale Apple-Health-ZIP-Archive bis 500 MB. Das ist eine Sicherheitsgrenze der App."))
        }
        guard let entries = unzipOutput(arguments: ["-Z1", url.path], maximumBytes: maximumZIPListingBytes),
              let listing = String(data: entries, encoding: .utf8) else {
            return .rejected(AppLanguage.current.text(english: "The ZIP contents could not be read safely.", german: "Der Inhalt der ZIP-Datei konnte nicht sicher gelesen werden."))
        }
        let exportEntries = listing.split(whereSeparator: \.isNewline).filter { entry in
            entry.split(separator: "/").last?.lowercased() == "export.xml"
        }
        guard exportEntries.count == 1, let exportEntry = exportEntries.first.map(String.init) else {
            return .rejected(AppLanguage.current.text(english: "This ZIP does not contain the required Export.xml data file.", german: "Dieses ZIP enthält nicht die erforderliche Datendatei Export.xml."))
        }
        guard let uncompressedBytes = uncompressedSize(of: exportEntry, in: url) else {
            return .rejected(AppLanguage.current.text(english: "The Export.xml size in this ZIP could not be verified safely.", german: "Die Größe von Export.xml in dieser ZIP-Datei konnte nicht sicher geprüft werden."))
        }
        guard uncompressedBytes > 0, uncompressedBytes <= maximumXMLBytes else {
            return .rejected(AppLanguage.current.text(english: "HealthAtlas supports an Export.xml up to 500 MB after decompression. This archive was not imported.", german: "HealthAtlas unterstützt eine Export.xml bis 500 MB nach dem Entpacken. Dieses Archiv wurde nicht importiert."))
        }
        guard let temporaryXMLURL = extractExportXML(entry: exportEntry, from: url) else {
            return .rejected(AppLanguage.current.text(english: "Apple Health data could not be read safely from this ZIP.", german: "Die Apple-Health-Daten konnten nicht sicher aus diesem ZIP gelesen werden."))
        }
        defer { try? FileManager.default.removeItem(at: temporaryXMLURL) }
        guard let summary = importXML(at: temporaryXMLURL, fileName: url.lastPathComponent) else {
            return .rejected(AppLanguage.current.text(english: "The ZIP does not contain readable Apple Health data.", german: "Das ZIP enthält keine lesbaren Apple-Health-Daten."))
        }
        return .imported(summary)
    }

    static func importXML(at url: URL, fileName: String) -> ImportedHealthSummary? {
        guard let byteCount = try? url.resourceValues(forKeys: [.fileSizeKey]).fileSize,
              byteCount > 0, byteCount <= maximumXMLBytes else { return nil }
        return importXML(fileName: fileName) {
            InputStream(url: url).map(XMLParser.init(stream:))
        }
    }

    static func importXML(data: Data, fileName: String) -> ImportedHealthSummary? {
        guard data.count <= maximumXMLBytes else { return nil }
        return importXML(fileName: fileName) { XMLParser(data: data) }
    }

    private static func importXML(fileName: String, makeParser: () -> XMLParser?) -> ImportedHealthSummary? {
        guard let plan = makeAggregationPlan(makeParser: makeParser),
              let summaryParser = makeParser() else { return nil }

        let parserDelegate = AppleHealthXMLDelegate(plan: plan)
        summaryParser.delegate = parserDelegate
        guard summaryParser.parse(), parserDelegate.recordCount > 0 else { return nil }
        return ImportedHealthSummary(
            fileName: fileName,
            recordCount: parserDelegate.recordCount,
            dataTypes: parserDelegate.dataTypes
        )
    }

    private static func makeAggregationPlan(makeParser: () -> XMLParser?) -> HealthAggregationPlan? {
        guard let parser = makeParser() else { return nil }
        let planner = AppleHealthAggregationPlanner()
        parser.delegate = planner
        guard parser.parse() else { return nil }
        return planner.makePlan()
    }

    private static func uncompressedSize(of entry: String, in archive: URL) -> Int? {
        guard let output = unzipOutput(arguments: ["-l", archive.path, entry], maximumBytes: maximumZIPEntryInfoBytes),
              let listing = String(data: output, encoding: .utf8) else { return nil }
        for line in listing.split(whereSeparator: \.isNewline).reversed() where line.hasSuffix(entry) {
            guard let firstField = line.split(maxSplits: 1, whereSeparator: \.isWhitespace).first,
                  let byteCount = Int(firstField) else { continue }
            return byteCount
        }
        return nil
    }

    private static func extractExportXML(entry: String, from archive: URL) -> URL? {
        let temporaryURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("HealthAtlas-Import-\(UUID().uuidString)")
            .appendingPathExtension("xml")
        guard FileManager.default.createFile(atPath: temporaryURL.path, contents: nil),
              let destination = try? FileHandle(forWritingTo: temporaryURL) else { return nil }

        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/unzip")
        process.arguments = ["-p", archive.path, entry]
        let output = Pipe()
        process.standardOutput = output
        process.standardError = FileHandle.nullDevice
        do {
            try process.run()
            var writtenBytes = 0
            while let chunk = try output.fileHandleForReading.read(upToCount: 64 * 1024), !chunk.isEmpty {
                writtenBytes += chunk.count
                guard writtenBytes <= maximumXMLBytes else {
                    process.terminate()
                    process.waitUntilExit()
                    try? destination.close()
                    try? FileManager.default.removeItem(at: temporaryURL)
                    return nil
                }
                try destination.write(contentsOf: chunk)
            }
            process.waitUntilExit()
            try destination.close()
            guard process.terminationStatus == 0, writtenBytes > 0 else {
                try? FileManager.default.removeItem(at: temporaryURL)
                return nil
            }
            return temporaryURL
        } catch {
            process.terminate()
            process.waitUntilExit()
            try? destination.close()
            try? FileManager.default.removeItem(at: temporaryURL)
            return nil
        }
    }

    private static func unzipOutput(arguments: [String], maximumBytes: Int) -> Data? {
        let temporaryURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("HealthAtlas-ZIP-Listing-\(UUID().uuidString)")
        guard FileManager.default.createFile(atPath: temporaryURL.path, contents: nil),
              let output = try? FileHandle(forWritingTo: temporaryURL) else { return nil }
        defer {
            try? output.close()
            try? FileManager.default.removeItem(at: temporaryURL)
        }

        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/unzip")
        process.arguments = arguments
        process.standardOutput = output
        process.standardError = FileHandle.nullDevice
        do {
            try process.run()
            process.waitUntilExit()
            let byteCount = try temporaryURL.resourceValues(forKeys: [.fileSizeKey]).fileSize ?? 0
            guard process.terminationStatus == 0, byteCount <= maximumBytes else { return nil }
            return try Data(contentsOf: temporaryURL, options: [.mappedIfSafe])
        } catch {
            return nil
        }
    }
}

private enum HealthDataAggregationRule {
    case cumulativeInterval
    case sleepInterval
    case sample

    static func rule(for identifier: String) -> Self {
        let value = identifier.lowercased()
        if identifier == "HKCategoryTypeIdentifierSleepAnalysis" { return .sleepInterval }
        if value.contains("stepcount") || value.contains("distance") || value.contains("activeenergyburned") || value.contains("basalenergyburned") || value.contains("flightsclimbed") || value.contains("pushcount") || value.contains("swimmingstrokecount") || value.contains("appleexercisetime") || value.contains("applemovetime") || value.contains("applestandtime") {
            return .cumulativeInterval
        }
        return .sample
    }

    var usesTotalValue: Bool {
        self == .cumulativeInterval || self == .sleepInterval
    }
}

private struct AppleHealthSource: Hashable {
    let name: String
    let version: String
    let device: String

    init(attributes: [String: String]) {
        name = attributes["sourceName"] ?? ""
        version = attributes["sourceVersion"] ?? ""
        device = attributes["device"] ?? ""
    }

    var stableName: String {
        let locale = Locale(identifier: "en_US_POSIX")
        let normalized = [name, version, device].map {
            $0.folding(options: [.caseInsensitive, .diacriticInsensitive, .widthInsensitive], locale: locale)
        }
        // The raw form breaks the rare case-insensitive tie without making the
        // normal alphabetical order depend on dictionary iteration.
        return normalized.joined(separator: "\u{1F}") + "\u{1E}" + [name, version, device].joined(separator: "\u{1F}")
    }
}

private struct RecordFingerprint: Hashable {
    let first: UInt64
    let second: UInt64

    init(elementName: String, attributes: [String: String]) {
        let canonical = ([elementName] + attributes.sorted { $0.key < $1.key }.flatMap { [$0.key, $0.value] }).joined(separator: "\u{1E}")
        first = Self.hash(canonical.utf8, seed: 0xcbf29ce484222325)
        second = Self.hash(canonical.utf8, seed: 0x84222325cbf29ce4)
    }

    private static func hash(_ bytes: String.UTF8View, seed: UInt64) -> UInt64 {
        bytes.reduce(seed) { ($0 ^ UInt64($1)) &* 0x100000001b3 }
    }
}

private struct AppleHealthRecord {
    let elementName: String
    let identifier: String
    let valueText: String
    let numericValue: Double?
    let unit: String?
    let source: AppleHealthSource
    let startDate: Date?
    let endDate: Date?
    let creationDate: Date?
    let fingerprint: RecordFingerprint

    init(elementName: String, attributes: [String: String]) {
        self.elementName = elementName
        identifier = attributes["type"] ?? elementName
        valueText = attributes["value"] ?? ""
        numericValue = Double(valueText)
        unit = attributes["unit"]
        source = AppleHealthSource(attributes: attributes)
        startDate = AppleHealthDateParser.date(from: attributes["startDate"])
        endDate = AppleHealthDateParser.date(from: attributes["endDate"])
        creationDate = AppleHealthDateParser.date(from: attributes["creationDate"])
        fingerprint = RecordFingerprint(elementName: elementName, attributes: attributes)
    }

    var rule: HealthDataAggregationRule { HealthDataAggregationRule.rule(for: identifier) }
    var isAsleep: Bool { valueText.localizedCaseInsensitiveContains("asleep") }
}

private struct AggregationSlot: Hashable {
    let typeIndex: Int
    let day: Date
    let bucket: Int
}

private struct SourceAggregationSlot: Hashable {
    let slot: AggregationSlot
    let sourceIndex: Int
}

private struct IntervalContribution {
    let slot: AggregationSlot
    let day: Date
    let duration: TimeInterval
    let fraction: Double
}

private enum IntervalGrid {
    static let bucketDuration: TimeInterval = 15 * 60
    private static let maximumBucketsPerRecord = 10_000

    static func contributions(for start: Date, end: Date, typeIndex: Int) -> [IntervalContribution] {
        let calendar = Calendar.current
        if end <= start {
            let day = calendar.startOfDay(for: start)
            let bucket = Int(start.timeIntervalSince(day) / bucketDuration)
            return [IntervalContribution(slot: AggregationSlot(typeIndex: typeIndex, day: day, bucket: bucket), day: day, duration: 1, fraction: 1)]
        }

        let totalDuration = end.timeIntervalSince(start)
        var result: [IntervalContribution] = []
        var cursor = start
        while cursor < end, result.count < maximumBucketsPerRecord {
            let absoluteBucket = floor(cursor.timeIntervalSinceReferenceDate / bucketDuration) * bucketDuration
            let boundary = Date(timeIntervalSinceReferenceDate: absoluteBucket + bucketDuration)
            let next = min(end, boundary)
            let duration = next.timeIntervalSince(cursor)
            let day = calendar.startOfDay(for: cursor)
            let bucket = Int(cursor.timeIntervalSince(day) / bucketDuration)
            result.append(IntervalContribution(
                slot: AggregationSlot(typeIndex: typeIndex, day: day, bucket: bucket),
                day: day,
                duration: duration,
                fraction: duration / totalDuration
            ))
            cursor = next
        }
        return cursor == end ? result : []
    }
}

private struct HealthAggregationPlan {
    let typeIndices: [String: Int]
    let sourceIndices: [AppleHealthSource: Int]
    let selectedSourceBySlot: [AggregationSlot: Int]

    func contributions(for record: AppleHealthRecord) -> [(IntervalContribution, Int)]? {
        guard let typeIndex = typeIndices[record.identifier], let sourceIndex = sourceIndices[record.source], let start = record.startDate else { return nil }
        let end = record.endDate ?? start
        let contributions = IntervalGrid.contributions(for: start, end: end, typeIndex: typeIndex)
        return contributions.isEmpty ? nil : contributions.map { ($0, sourceIndex) }
    }

    func isSelected(_ contribution: IntervalContribution, sourceIndex: Int) -> Bool {
        selectedSourceBySlot[contribution.slot] == sourceIndex
    }
}

private final class AppleHealthAggregationPlanner: NSObject, XMLParserDelegate {
    private var seenRecords: Set<RecordFingerprint> = []
    private var typeIndices: [String: Int] = [:]
    private var sources: [AppleHealthSource: Int] = [:]
    private var sourcesByIndex: [AppleHealthSource] = []
    private var coverage: [SourceAggregationSlot: TimeInterval] = [:]

    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String: String] = [:]) {
        guard elementName == "Record" else { return }
        let record = AppleHealthRecord(elementName: elementName, attributes: attributeDict)
        let shouldPlan = record.rule == .cumulativeInterval || (record.rule == .sleepInterval && record.isAsleep)
        guard shouldPlan, seenRecords.insert(record.fingerprint).inserted, let start = record.startDate else { return }

        let typeIndex = typeIndices[record.identifier, default: typeIndices.count]
        typeIndices[record.identifier] = typeIndex
        let sourceIndex: Int
        if let existing = sources[record.source] {
            sourceIndex = existing
        } else {
            sourceIndex = sourcesByIndex.count
            sources[record.source] = sourceIndex
            sourcesByIndex.append(record.source)
        }
        let end = record.endDate ?? start
        for contribution in IntervalGrid.contributions(for: start, end: end, typeIndex: typeIndex) {
            let key = SourceAggregationSlot(slot: contribution.slot, sourceIndex: sourceIndex)
            let previous = coverage[key] ?? 0
            coverage[key] = min(IntervalGrid.bucketDuration, previous + contribution.duration)
        }
    }

    func makePlan() -> HealthAggregationPlan {
        var selections: [AggregationSlot: (sourceIndex: Int, coverage: TimeInterval)] = [:]
        for (key, duration) in coverage {
            if let current = selections[key.slot] {
                let currentName = sourcesByIndex[current.sourceIndex].stableName
                let candidateName = sourcesByIndex[key.sourceIndex].stableName
                if duration > current.coverage || (duration == current.coverage && candidateName < currentName) {
                    selections[key.slot] = (key.sourceIndex, duration)
                }
            } else {
                selections[key.slot] = (key.sourceIndex, duration)
            }
        }
        return HealthAggregationPlan(
            typeIndices: typeIndices,
            sourceIndices: sources,
            selectedSourceBySlot: selections.mapValues(\.sourceIndex)
        )
    }
}

private final class AppleHealthXMLDelegate: NSObject, XMLParserDelegate {
    private(set) var recordCount = 0
    private let plan: HealthAggregationPlan
    private var accumulators: [String: HealthDataTypeAccumulator] = [:]

    init(plan: HealthAggregationPlan) {
        self.plan = plan
    }

    var dataTypes: [HealthDataTypeSummary] {
        accumulators.values.map(\.summary).sorted {
            $0.recordCount == $1.recordCount ? $0.displayName < $1.displayName : $0.recordCount > $1.recordCount
        }
    }

    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String: String] = [:]) {
        let supportedElements: Set<String> = ["Record", "Correlation", "Workout", "ActivitySummary", "ClinicalRecord", "Audiogram", "VisionPrescription"]
        guard supportedElements.contains(elementName) else { return }
        let record = AppleHealthRecord(elementName: elementName, attributes: attributeDict)
        var accumulator = accumulators[record.identifier] ?? HealthDataTypeAccumulator(identifier: record.identifier)
        let accepted = accumulator.append(record: record, plan: plan)
        accumulators[record.identifier] = accumulator
        if elementName == "Record", accepted { recordCount += 1 }
    }
}

private struct HealthDataTypeAccumulator {
    let identifier: String
    var recordCount = 0
    var sum = 0.0
    var numericCount = 0
    var unit: String?
    private var seenRecords: Set<RecordFingerprint> = []
    private var dailyTotals: [Date: (sum: Double, count: Int)] = [:]
    private var acceptedSleepBySlot: [AggregationSlot: TimeInterval] = [:]

    init(identifier: String) {
        self.identifier = identifier
    }

    mutating func append(record: AppleHealthRecord, plan: HealthAggregationPlan) -> Bool {
        guard seenRecords.insert(record.fingerprint).inserted else { return false }
        switch record.rule {
        case .cumulativeInterval:
            return appendCumulative(record: record, plan: plan)
        case .sleepInterval where record.isAsleep:
            return appendSleep(record: record, plan: plan)
        default:
            appendSample(record: record)
            return true
        }
    }

    private mutating func appendSample(record: AppleHealthRecord) {
        recordCount += 1
        guard let value = record.numericValue else { return }
        sum += value
        numericCount += 1
        if unit == nil { unit = record.unit }
        if let date = record.startDate {
            appendDaily(value: value, on: date)
        }
    }

    private mutating func appendCumulative(record: AppleHealthRecord, plan: HealthAggregationPlan) -> Bool {
        guard let value = record.numericValue, let contributions = plan.contributions(for: record) else {
            appendSample(record: record)
            return true
        }
        var acceptedValue = 0.0
        for (contribution, sourceIndex) in contributions where plan.isSelected(contribution, sourceIndex: sourceIndex) {
            let partialValue = value * contribution.fraction
            acceptedValue += partialValue
            appendDaily(value: partialValue, on: contribution.day)
        }
        guard acceptedValue > 0 else { return false }
        recordCount += 1
        sum += acceptedValue
        numericCount += 1
        if unit == nil { unit = record.unit }
        return true
    }

    private mutating func appendSleep(record: AppleHealthRecord, plan: HealthAggregationPlan) -> Bool {
        guard let contributions = plan.contributions(for: record) else {
            recordCount += 1
            return true
        }
        var acceptedDuration: TimeInterval = 0
        for (contribution, sourceIndex) in contributions where plan.isSelected(contribution, sourceIndex: sourceIndex) {
            let alreadyAccepted = acceptedSleepBySlot[contribution.slot] ?? 0
            let permitted = max(0, IntervalGrid.bucketDuration - alreadyAccepted)
            let accepted = min(contribution.duration, permitted)
            guard accepted > 0 else { continue }
            acceptedSleepBySlot[contribution.slot] = alreadyAccepted + accepted
            let hours = accepted / 3600
            acceptedDuration += accepted
            appendDaily(value: hours, on: contribution.day)
        }
        guard acceptedDuration > 0 else { return false }
        recordCount += 1
        sum += acceptedDuration / 3600
        numericCount += 1
        if unit == nil { unit = "h" }
        return true
    }

    private mutating func appendDaily(value: Double, on date: Date) {
        let day = Calendar.current.startOfDay(for: date)
        let previous = dailyTotals[day] ?? (0, 0)
        dailyTotals[day] = (previous.sum + value, previous.count + 1)
    }

    var summary: HealthDataTypeSummary {
        HealthDataTypeSummary(
            identifier: identifier,
            displayName: HealthDataTypeName.displayName(for: identifier),
            recordCount: recordCount,
            sum: sum,
            average: numericCount == 0 ? nil : sum / Double(numericCount),
            unit: unit,
            dailyValues: dailyTotals.map { day, totals in
                HealthDailyValue(date: day, sum: totals.sum, average: totals.sum / Double(totals.count))
            }.sorted { $0.date < $1.date }
        )
    }
}

private enum AppleHealthDateParser {
    private static let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss Z"
        return formatter
    }()

    static func date(from value: String?) -> Date? {
        guard let value else { return nil }
        return formatter.date(from: value) ?? ISO8601DateFormatter().date(from: value)
    }
}

enum HealthDataTypeName {
    static func displayName(for identifier: String, language: AppLanguage = .current) -> String {
        let english: [String: String] = [
            "HKQuantityTypeIdentifierStepCount": "Steps", "HKQuantityTypeIdentifierHeartRate": "Heart Rate",
            "HKCategoryTypeIdentifierSleepAnalysis": "Sleep Analysis", "HKQuantityTypeIdentifierActiveEnergyBurned": "Active Energy",
            "HKQuantityTypeIdentifierBasalEnergyBurned": "Resting Energy", "HKQuantityTypeIdentifierDistanceWalkingRunning": "Walking + Running Distance",
            "HKQuantityTypeIdentifierBodyMass": "Body Mass", "HKQuantityTypeIdentifierBodyMassIndex": "Body Mass Index",
            "HKQuantityTypeIdentifierBodyFatPercentage": "Body Fat Percentage", "HKQuantityTypeIdentifierFlightsClimbed": "Flights Climbed",
            "HKQuantityTypeIdentifierDietaryWater": "Dietary Water", "HKQuantityTypeIdentifierBloodPressureSystolic": "Blood Pressure Systolic",
            "HKQuantityTypeIdentifierBloodPressureDiastolic": "Blood Pressure Diastolic", "Workout": "Workouts",
            "ActivitySummary": "Activity Summaries", "ClinicalRecord": "Clinical Records"
        ]
        let german: [String: String] = [
            "HKQuantityTypeIdentifierStepCount": "Schritte", "HKQuantityTypeIdentifierHeartRate": "Herzfrequenz",
            "HKCategoryTypeIdentifierSleepAnalysis": "Schlafanalyse", "HKQuantityTypeIdentifierActiveEnergyBurned": "Aktive Energie",
            "HKQuantityTypeIdentifierBasalEnergyBurned": "Ruheenergie", "HKQuantityTypeIdentifierDistanceWalkingRunning": "Geh- und Laufdistanz",
            "HKQuantityTypeIdentifierBodyMass": "Körpergewicht", "HKQuantityTypeIdentifierBodyMassIndex": "Body-Mass-Index",
            "HKQuantityTypeIdentifierBodyFatPercentage": "Körperfettanteil", "HKQuantityTypeIdentifierFlightsClimbed": "Gestiegene Stockwerke",
            "HKQuantityTypeIdentifierDietaryWater": "Getrunkenes Wasser", "HKQuantityTypeIdentifierBloodPressureSystolic": "Blutdruck systolisch",
            "HKQuantityTypeIdentifierBloodPressureDiastolic": "Blutdruck diastolisch", "Workout": "Trainings",
            "ActivitySummary": "Aktivitätsübersichten", "ClinicalRecord": "Klinische Datensätze"
        ]
        if let name = (language == .german ? german : english)[identifier] { return name }
        let stem = identifier
            .replacingOccurrences(of: "HKQuantityTypeIdentifier", with: "")
            .replacingOccurrences(of: "HKCategoryTypeIdentifier", with: "")
            .replacingOccurrences(of: "HKCorrelationTypeIdentifier", with: "")
            .replacingOccurrences(of: "HKDataTypeIdentifier", with: "")
            .replacingOccurrences(of: "HKDataType", with: "")
        return stem.replacingOccurrences(of: "([a-z])([A-Z])", with: "$1 $2", options: .regularExpression)
    }
}
