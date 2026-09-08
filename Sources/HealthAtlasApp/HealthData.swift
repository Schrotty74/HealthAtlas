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
    case cancelled
    case rejected(String)
}

final class ImportCancellationToken: @unchecked Sendable {
    private let lock = NSLock()
    private var cancelled = false

    func cancel() {
        lock.lock()
        cancelled = true
        lock.unlock()
    }

    var isCancelled: Bool {
        lock.lock()
        defer { lock.unlock() }
        return cancelled
    }
}

enum LocalImportValidator {
    private static let supportedExtensions: Set<String> = ["xml", "zip"]
    /// HealthAtlas supports local XML exports up to 5 GiB. The limit keeps
    /// import work bounded without claiming an Apple Health or macOS limit.
    static let maximumBytes = 5 * 1024 * 1024 * 1024

    static func supportsXMLByteCount(_ byteCount: Int) -> Bool {
        byteCount > 0 && byteCount <= maximumBytes
    }

    static func validate(url: URL, cancellationToken: ImportCancellationToken? = nil) -> LocalImportResult {
        if cancellationToken?.isCancelled == true { return .cancelled }
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
                return .rejected(AppLanguage.current.text(english: "HealthAtlas supports local Apple Health ZIP archives up to 5 GB. This is an app safety limit.", german: "HealthAtlas unterstützt lokale Apple-Health-ZIP-Archive bis 5 GB. Das ist eine Sicherheitsgrenze der App."))
            }
            return AppleHealthImporter.importArchive(at: url, fileSize: byteCount, cancellationToken: cancellationToken)
        }
        guard supportsXMLByteCount(byteCount) else {
            return .rejected(AppLanguage.current.text(english: "HealthAtlas supports local Apple Health XML files up to 5 GB. This is an app safety limit.", german: "HealthAtlas unterstützt lokale Apple-Health-XML-Dateien bis 5 GB. Das ist eine Sicherheitsgrenze der App."))
        }
        guard isReadableTextExport(at: url) else {
            return .rejected(AppLanguage.current.text(english: "The selected file is not a readable text export.", german: "Die ausgewählte Datei ist kein lesbarer Textexport."))
        }
        if extensionName == "xml", let summary = AppleHealthImporter.importXML(at: url, fileName: url.lastPathComponent, cancellationToken: cancellationToken) {
            return .imported(summary)
        }
        if cancellationToken?.isCancelled == true { return .cancelled }
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
    static let maximumArchiveBytes = 5 * 1024 * 1024 * 1024
    private static let maximumXMLBytes = LocalImportValidator.maximumBytes
    private static let maximumZIPListingBytes = 2 * 1024 * 1024
    private static let maximumZIPEntryInfoBytes = 64 * 1024

    static func supportsArchiveByteCount(_ byteCount: Int) -> Bool {
        byteCount > 0 && byteCount <= maximumArchiveBytes
    }

    static func importArchive(at url: URL, fileSize: Int, cancellationToken: ImportCancellationToken? = nil) -> LocalImportResult {
        if cancellationToken?.isCancelled == true { return .cancelled }
        guard supportsArchiveByteCount(fileSize) else {
            return .rejected(AppLanguage.current.text(english: "HealthAtlas supports local Apple Health ZIP archives up to 5 GB. This is an app safety limit.", german: "HealthAtlas unterstützt lokale Apple-Health-ZIP-Archive bis 5 GB. Das ist eine Sicherheitsgrenze der App."))
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
            return .rejected(AppLanguage.current.text(english: "HealthAtlas supports an Export.xml up to 5 GB after decompression. This archive was not imported.", german: "HealthAtlas unterstützt eine Export.xml bis 5 GB nach dem Entpacken. Dieses Archiv wurde nicht importiert."))
        }
        guard let temporaryXMLURL = extractExportXML(entry: exportEntry, from: url, cancellationToken: cancellationToken) else {
            if cancellationToken?.isCancelled == true { return .cancelled }
            return .rejected(AppLanguage.current.text(english: "Apple Health data could not be read safely from this ZIP.", german: "Die Apple-Health-Daten konnten nicht sicher aus diesem ZIP gelesen werden."))
        }
        defer { try? FileManager.default.removeItem(at: temporaryXMLURL) }
        guard let summary = importXML(at: temporaryXMLURL, fileName: url.lastPathComponent, cancellationToken: cancellationToken) else {
            if cancellationToken?.isCancelled == true { return .cancelled }
            return .rejected(AppLanguage.current.text(english: "The ZIP does not contain readable Apple Health data.", german: "Das ZIP enthält keine lesbaren Apple-Health-Daten."))
        }
        return .imported(summary)
    }

    static func importXML(at url: URL, fileName: String, cancellationToken: ImportCancellationToken? = nil) -> ImportedHealthSummary? {
        if cancellationToken?.isCancelled == true { return nil }
        guard let byteCount = try? url.resourceValues(forKeys: [.fileSizeKey]).fileSize,
              byteCount > 0, byteCount <= maximumXMLBytes else { return nil }
        return importXMLFromFile(at: url, fileName: fileName, cancellationToken: cancellationToken)
    }

    static func importXML(data: Data, fileName: String, cancellationToken: ImportCancellationToken? = nil) -> ImportedHealthSummary? {
        if cancellationToken?.isCancelled == true { return nil }
        guard data.count <= maximumXMLBytes else { return nil }
        return importXML(fileName: fileName, cancellationToken: cancellationToken) { XMLParser(data: data) }
    }

    private static func importXML(fileName: String, cancellationToken: ImportCancellationToken?, makeParser: () -> XMLParser?) -> ImportedHealthSummary? {
        let spoolURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("HealthAtlas-Relevant-Records-\(UUID().uuidString)")
            .appendingPathExtension("xml")
        defer { try? FileManager.default.removeItem(at: spoolURL) }
        guard FileManager.default.createFile(atPath: spoolURL.path, contents: nil),
              let spool = try? FileHandle(forWritingTo: spoolURL),
              let firstParser = makeParser() else { return nil }

        let firstPass = AppleHealthFirstPassDelegate(spool: spool, cancellationToken: cancellationToken)
        defer { firstPass.closeIfNeeded() }
        firstParser.delegate = firstPass
        guard firstParser.parse(), cancellationToken?.isCancelled != true, firstPass.finish() else { return nil }

        guard let relevantStream = InputStream(url: spoolURL) else { return nil }
        let relevantParser = XMLParser(stream: relevantStream)
        let relevantDelegate = AppleHealthXMLDelegate(
            plan: firstPass.plan,
            cancellationToken: cancellationToken,
            recordsAreAlreadyDeduplicated: true
        )
        relevantParser.delegate = relevantDelegate
        guard relevantParser.parse(), cancellationToken?.isCancelled != true else { return nil }

        var accumulators = firstPass.directAccumulators
        for (identifier, relevantAccumulator) in relevantDelegate.accumulators {
            let accumulator = accumulators[identifier] ?? HealthDataTypeAccumulator(identifier: identifier)
            accumulator.merge(relevantAccumulator)
            accumulators[identifier] = accumulator
        }
        let summaries: [HealthDataTypeSummary] = accumulators.values.map { $0.summary }
        let dataTypes = summaries.sorted { lhs, rhs in
            lhs.recordCount == rhs.recordCount ? lhs.displayName < rhs.displayName : lhs.recordCount > rhs.recordCount
        }
        let recordCount = firstPass.recordCount + relevantDelegate.recordCount
        guard recordCount > 0 else { return nil }
        return ImportedHealthSummary(fileName: fileName, recordCount: recordCount, dataTypes: dataTypes)
    }

    private static func importXMLFromFile(at url: URL, fileName: String, cancellationToken: ImportCancellationToken?) -> ImportedHealthSummary? {
        let spoolURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("HealthAtlas-Relevant-Records-\(UUID().uuidString)")
            .appendingPathExtension("xml")
        defer { try? FileManager.default.removeItem(at: spoolURL) }
        guard FileManager.default.createFile(atPath: spoolURL.path, contents: nil),
              let spool = try? FileHandle(forWritingTo: spoolURL) else { return nil }

        let firstPass = AppleHealthFirstPassDelegate(spool: spool, cancellationToken: cancellationToken)
        defer { firstPass.closeIfNeeded() }
        guard AppleHealthTagStream.parse(at: url, consumer: firstPass),
              cancellationToken?.isCancelled != true,
              firstPass.finish() else { return nil }

        let relevantDelegate = AppleHealthXMLDelegate(
            plan: firstPass.plan,
            cancellationToken: cancellationToken,
            recordsAreAlreadyDeduplicated: true
        )
        guard AppleHealthTagStream.parse(at: spoolURL, consumer: relevantDelegate),
              cancellationToken?.isCancelled != true else { return nil }

        var accumulators = firstPass.directAccumulators
        for (identifier, relevantAccumulator) in relevantDelegate.accumulators {
            let accumulator = accumulators[identifier] ?? HealthDataTypeAccumulator(identifier: identifier)
            accumulator.merge(relevantAccumulator)
            accumulators[identifier] = accumulator
        }
        let summaries: [HealthDataTypeSummary] = accumulators.values.map { $0.summary }
        let dataTypes = summaries.sorted { lhs, rhs in
            lhs.recordCount == rhs.recordCount ? lhs.displayName < rhs.displayName : lhs.recordCount > rhs.recordCount
        }
        let recordCount = firstPass.recordCount + relevantDelegate.recordCount
        guard recordCount > 0 else { return nil }
        return ImportedHealthSummary(fileName: fileName, recordCount: recordCount, dataTypes: dataTypes)
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

    private static func extractExportXML(entry: String, from archive: URL, cancellationToken: ImportCancellationToken?) -> URL? {
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
                if cancellationToken?.isCancelled == true {
                    process.terminate()
                    process.waitUntilExit()
                    try? destination.close()
                    try? FileManager.default.removeItem(at: temporaryURL)
                    return nil
                }
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

private enum AppleHealthTagStream {
    private enum Tag {
        case opening(name: String, attributes: [String: String], isSelfClosing: Bool)
        case closing(name: String)
        case ignored
    }

    static func parse(at url: URL, consumer: AppleHealthElementConsumer) -> Bool {
        guard let handle = try? FileHandle(forReadingFrom: url) else { return false }
        defer { try? handle.close() }

        var buffer = Data()
        var elementStack: [String] = []
        var sawHealthData = false
        var closedHealthData = false

        while let chunk = try? handle.read(upToCount: 128 * 1024), !chunk.isEmpty {
            buffer.append(chunk)
            var cursor = buffer.startIndex
            while true {
                guard let start = buffer[cursor...].firstIndex(of: 60) else {
                    guard sawHealthData, !closedHealthData || buffer[cursor...].allSatisfy({ $0 == 9 || $0 == 10 || $0 == 13 || $0 == 32 }) else { return false }
                    cursor = buffer.endIndex
                    break
                }
                guard sawHealthData || buffer[cursor..<start].allSatisfy({ $0 == 9 || $0 == 10 || $0 == 13 || $0 == 32 }) else { return false }
                guard let end = tagEnd(in: buffer, after: start) else { break }
                let tagData = buffer[(start + 1)..<end]
                guard let tag = parseTag(Data(tagData)) else { return false }
                switch tag {
                case .ignored:
                    break
                case .closing(let name):
                    guard elementStack.last == name else { return false }
                    elementStack.removeLast()
                    if name == "HealthData" { closedHealthData = true }
                case .opening(let name, let attributes, let isSelfClosing):
                    if name == "HealthData" {
                        guard !sawHealthData, elementStack.isEmpty else { return false }
                        sawHealthData = true
                    } else {
                        guard sawHealthData, !closedHealthData, !elementStack.isEmpty else { return false }
                    }
                    if !isSelfClosing { elementStack.append(name) }
                    if !consumer.consume(elementName: name, attributes: attributes, rawTag: Data(buffer[start...end])) { return false }
                }
                cursor = end + 1
            }
            if cursor > buffer.startIndex {
                buffer = Data(buffer[cursor...])
            }
            guard buffer.count <= 2 * 1024 * 1024 else { return false }
        }
        return sawHealthData && closedHealthData && elementStack.isEmpty && buffer.allSatisfy { $0 == 9 || $0 == 10 || $0 == 13 || $0 == 32 }
    }

    private static func tagEnd(in data: Data, after start: Int) -> Int? {
        var quote: UInt8?
        var index = start + 1
        while index < data.endIndex {
            let byte = data[index]
            if let activeQuote = quote {
                if byte == activeQuote { quote = nil }
            } else if byte == 34 || byte == 39 { // " or '
                quote = byte
            } else if byte == 62 { // >
                return index
            }
            index += 1
        }
        return nil
    }

    private static func parseTag(_ data: Data) -> Tag? {
        var bytes = Array(data)
        while bytes.last == 9 || bytes.last == 10 || bytes.last == 13 || bytes.last == 32 { bytes.removeLast() }
        while bytes.first == 9 || bytes.first == 10 || bytes.first == 13 || bytes.first == 32 { bytes.removeFirst() }
        guard let first = bytes.first else { return nil }
        if first == 63 || first == 33 { return .ignored } // processing instruction or declaration/comment
        if first == 47 {
            let nameBytes = bytes.dropFirst().prefix { !isWhitespace($0) }
            guard let name = String(bytes: nameBytes, encoding: .utf8), !name.isEmpty else { return nil }
            return .closing(name: name)
        }

        let isSelfClosing = bytes.last == 47
        var index = 0
        let nameStart = index
        while index < bytes.count, !isWhitespace(bytes[index]), bytes[index] != 47 { index += 1 }
        guard let name = String(bytes: bytes[nameStart..<index], encoding: .utf8), !name.isEmpty else { return nil }
        var attributes: [String: String] = [:]
        while index < bytes.count {
            while index < bytes.count, isWhitespace(bytes[index]) { index += 1 }
            if index >= bytes.count || bytes[index] == 47 { break }
            let keyStart = index
            while index < bytes.count, !isWhitespace(bytes[index]), bytes[index] != 61 { index += 1 }
            guard keyStart < index,
                  let key = String(bytes: bytes[keyStart..<index], encoding: .utf8) else { return nil }
            while index < bytes.count, isWhitespace(bytes[index]) { index += 1 }
            guard index < bytes.count, bytes[index] == 61 else { return nil }
            index += 1
            while index < bytes.count, isWhitespace(bytes[index]) { index += 1 }
            guard index < bytes.count, bytes[index] == 34 || bytes[index] == 39 else { return nil }
            let quote = bytes[index]
            index += 1
            let valueStart = index
            while index < bytes.count, bytes[index] != quote { index += 1 }
            guard index < bytes.count,
                  let rawValue = String(bytes: bytes[valueStart..<index], encoding: .utf8) else { return nil }
            attributes[key] = xmlUnescaped(rawValue)
            index += 1
        }
        return .opening(name: name, attributes: attributes, isSelfClosing: isSelfClosing)
    }

    private static func isWhitespace(_ byte: UInt8) -> Bool {
        byte == 9 || byte == 10 || byte == 13 || byte == 32
    }

    private static func xmlUnescaped(_ value: String) -> String {
        // Apple Health attributes virtually never need entity decoding. Avoid
        // allocating five replacement strings for every attribute in a large
        // export; retain full decoding when an entity is actually present.
        guard value.contains("&") else { return value }
        return value
            .replacingOccurrences(of: "&quot;", with: "\"")
            .replacingOccurrences(of: "&apos;", with: "'")
            .replacingOccurrences(of: "&lt;", with: "<")
            .replacingOccurrences(of: "&gt;", with: ">")
            .replacingOccurrences(of: "&amp;", with: "&")
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
        var first = UInt64(0xcbf29ce484222325)
        var second = UInt64(0x84222325cbf29ce4)
        func append(_ string: String) {
            for byte in string.utf8 {
                first = (first ^ UInt64(byte)) &* 0x100000001b3
                second = (second ^ UInt64(byte)) &* 0x100000001b3
            }
            first = (first ^ 0x1e) &* 0x100000001b3
            second = (second ^ 0x1e) &* 0x100000001b3
        }
        append(elementName)
        for (key, value) in attributes.sorted(by: { $0.key < $1.key }) {
            append(key)
            append(value)
        }
        self.first = first
        self.second = second
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

    static let empty = HealthAggregationPlan(typeIndices: [:], sourceIndices: [:], selectedSourceBySlot: [:])
}

private let supportedAppleHealthElementNames: Set<String> = ["Record", "Correlation", "Workout", "ActivitySummary", "ClinicalRecord", "Audiogram", "VisionPrescription"]

private protocol AppleHealthElementConsumer: AnyObject {
    func consume(elementName: String, attributes: [String: String], rawTag: Data?) -> Bool
}

private final class AppleHealthAggregationPlanner: NSObject, XMLParserDelegate {
    private let cancellationToken: ImportCancellationToken?
    private var seenRecords: Set<RecordFingerprint> = []
    private var typeIndices: [String: Int] = [:]
    private var sources: [AppleHealthSource: Int] = [:]
    private var sourcesByIndex: [AppleHealthSource] = []
    private var coverage: [SourceAggregationSlot: TimeInterval] = [:]

    init(cancellationToken: ImportCancellationToken?) {
        self.cancellationToken = cancellationToken
        super.init()
    }

    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String: String] = [:]) {
        if cancellationToken?.isCancelled == true {
            parser.abortParsing()
            return
        }
        append(attributes: attributeDict, elementName: elementName)
    }

    /// Returns false only for an exact duplicate. Every other relevant record
    /// belongs in the compact second-pass spool, including malformed dates that
    /// retain the existing fallback-to-sample behaviour.
    @discardableResult
    func append(attributes attributeDict: [String: String], elementName: String = "Record") -> Bool {
        guard elementName == "Record" else { return false }
        let identifier = attributeDict["type"] ?? elementName
        let rule = HealthDataAggregationRule.rule(for: identifier)
        guard rule == .cumulativeInterval || (rule == .sleepInterval && (attributeDict["value"] ?? "").localizedCaseInsensitiveContains("asleep")) else { return false }
        let record = AppleHealthRecord(elementName: elementName, attributes: attributeDict)
        guard seenRecords.insert(record.fingerprint).inserted else { return false }
        guard let start = record.startDate else { return true }

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
        return true
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

private final class AppleHealthFirstPassDelegate: NSObject, XMLParserDelegate, AppleHealthElementConsumer {
    private let cancellationToken: ImportCancellationToken?
    private let planner: AppleHealthAggregationPlanner
    private let spool: FileHandle
    private var spoolBuffer = Data()
    private var didFinish = false
    private(set) var directAccumulators: [String: HealthDataTypeAccumulator] = [:]
    private(set) var recordCount = 0

    init(spool: FileHandle, cancellationToken: ImportCancellationToken?) {
        self.spool = spool
        self.cancellationToken = cancellationToken
        self.planner = AppleHealthAggregationPlanner(cancellationToken: cancellationToken)
        super.init()
        try? spool.write(contentsOf: Data("<?xml version=\"1.0\" encoding=\"UTF-8\"?><HealthData>\n".utf8))
    }

    var plan: HealthAggregationPlan { planner.makePlan() }

    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String: String] = [:]) {
        guard consume(elementName: elementName, attributes: attributeDict, rawTag: nil) else {
            parser.abortParsing()
            return
        }
    }

    func consume(elementName: String, attributes attributeDict: [String: String], rawTag: Data?) -> Bool {
        if cancellationToken?.isCancelled == true {
            return false
        }
        guard supportedAppleHealthElementNames.contains(elementName) else { return true }

        if elementName == "Record" {
            let identifier = attributeDict["type"] ?? elementName
            let rule = HealthDataAggregationRule.rule(for: identifier)
            let isAsleep = (attributeDict["value"] ?? "").localizedCaseInsensitiveContains("asleep")
            if rule == .cumulativeInterval || (rule == .sleepInterval && isAsleep) {
                guard planner.append(attributes: attributeDict) else { return true }
                return appendToSpool(rawTag: rawTag, attributes: attributeDict)
            }
        }

        let record = AppleHealthRecord(elementName: elementName, attributes: attributeDict)
        let accumulator = directAccumulators[record.identifier] ?? HealthDataTypeAccumulator(identifier: record.identifier)
        let accepted = accumulator.append(record: record, plan: .empty)
        directAccumulators[record.identifier] = accumulator
        if elementName == "Record", accepted { recordCount += 1 }
        return true
    }

    func finish() -> Bool {
        guard !didFinish else { return true }
        do {
            try flushSpoolBuffer()
            try spool.write(contentsOf: Data("</HealthData>\n".utf8))
            try spool.close()
            didFinish = true
            return true
        } catch {
            return false
        }
    }

    func closeIfNeeded() {
        guard !didFinish else { return }
        try? spool.close()
        didFinish = true
    }

    private func appendToSpool(rawTag: Data?, attributes: [String: String]) -> Bool {
        if let rawTag {
            spoolBuffer.append(rawTag)
            spoolBuffer.append(10)
            if spoolBuffer.count < 1_048_576 { return true }
            do { try flushSpoolBuffer(); return true } catch { return false }
        }
        let attributesText = attributes.sorted { $0.key < $1.key }.map { key, value in
            " \(key)=\"\(xmlEscaped(value))\""
        }.joined()
        spoolBuffer.append(Data("<Record\(attributesText)/>\n".utf8))
        guard spoolBuffer.count >= 1_048_576 else { return true }
        do {
            try flushSpoolBuffer()
            return true
        } catch {
            return false
        }
    }

    private func flushSpoolBuffer() throws {
        guard !spoolBuffer.isEmpty else { return }
        try spool.write(contentsOf: spoolBuffer)
        spoolBuffer.removeAll(keepingCapacity: true)
    }

    private func xmlEscaped(_ value: String) -> String {
        value
            .replacingOccurrences(of: "&", with: "&amp;")
            .replacingOccurrences(of: "\"", with: "&quot;")
            .replacingOccurrences(of: "<", with: "&lt;")
            .replacingOccurrences(of: ">", with: "&gt;")
    }
}

private final class AppleHealthXMLDelegate: NSObject, XMLParserDelegate, AppleHealthElementConsumer {
    private(set) var recordCount = 0
    private let plan: HealthAggregationPlan
    private let cancellationToken: ImportCancellationToken?
    private let recordsAreAlreadyDeduplicated: Bool
    private(set) var accumulators: [String: HealthDataTypeAccumulator] = [:]

    init(plan: HealthAggregationPlan, cancellationToken: ImportCancellationToken?, recordsAreAlreadyDeduplicated: Bool = false) {
        self.plan = plan
        self.cancellationToken = cancellationToken
        self.recordsAreAlreadyDeduplicated = recordsAreAlreadyDeduplicated
    }

    var dataTypes: [HealthDataTypeSummary] {
        accumulators.values.map(\.summary).sorted {
            $0.recordCount == $1.recordCount ? $0.displayName < $1.displayName : $0.recordCount > $1.recordCount
        }
    }

    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String: String] = [:]) {
        guard consume(elementName: elementName, attributes: attributeDict, rawTag: nil) else {
            parser.abortParsing()
            return
        }
    }

    func consume(elementName: String, attributes attributeDict: [String: String], rawTag: Data?) -> Bool {
        if cancellationToken?.isCancelled == true {
            return false
        }
        guard supportedAppleHealthElementNames.contains(elementName) else { return true }
        let record = AppleHealthRecord(elementName: elementName, attributes: attributeDict)
        let accumulator = accumulators[record.identifier] ?? HealthDataTypeAccumulator(identifier: record.identifier)
        let accepted = recordsAreAlreadyDeduplicated
            ? accumulator.appendKnownUnique(record: record, plan: plan)
            : accumulator.append(record: record, plan: plan)
        accumulators[record.identifier] = accumulator
        if elementName == "Record", accepted { recordCount += 1 }
        return true
    }
}

private final class HealthDataTypeAccumulator {
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

    func append(record: AppleHealthRecord, plan: HealthAggregationPlan) -> Bool {
        guard seenRecords.insert(record.fingerprint).inserted else { return false }
        return appendKnownUnique(record: record, plan: plan)
    }

    func appendKnownUnique(record: AppleHealthRecord, plan: HealthAggregationPlan) -> Bool {
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

    func merge(_ other: HealthDataTypeAccumulator) {
        guard identifier == other.identifier else { return }
        recordCount += other.recordCount
        sum += other.sum
        numericCount += other.numericCount
        if unit == nil { unit = other.unit }
        for (day, totals) in other.dailyTotals {
            let previous = dailyTotals[day] ?? (0, 0)
            dailyTotals[day] = (previous.sum + totals.sum, previous.count + totals.count)
        }
    }

    private func appendSample(record: AppleHealthRecord) {
        recordCount += 1
        guard let value = record.numericValue else { return }
        sum += value
        numericCount += 1
        if unit == nil { unit = record.unit }
        if let date = record.startDate {
            appendDaily(value: value, on: date)
        }
    }

    private func appendCumulative(record: AppleHealthRecord, plan: HealthAggregationPlan) -> Bool {
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

    private func appendSleep(record: AppleHealthRecord, plan: HealthAggregationPlan) -> Bool {
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

    private func appendDaily(value: Double, on date: Date) {
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
        return fixedWidthDate(from: value) ?? formatter.date(from: value) ?? ISO8601DateFormatter().date(from: value)
    }

    /// Apple Health normally writes dates as `yyyy-MM-dd HH:mm:ss +HHMM`.
    /// Parsing that fixed representation directly avoids millions of expensive
    /// formatter calls for large local exports. Other valid representations keep
    /// the Foundation fallbacks above.
    private static func fixedWidthDate(from value: String) -> Date? {
        let bytes = Array(value.utf8)
        guard bytes.count >= 25,
              bytes[4] == 45, bytes[7] == 45, bytes[10] == 32,
              bytes[13] == 58, bytes[16] == 58,
              bytes[19] == 32, (bytes[20] == 43 || bytes[20] == 45),
              let year = number(bytes, 0, 4), let month = number(bytes, 5, 2),
              let day = number(bytes, 8, 2), let hour = number(bytes, 11, 2),
              let minute = number(bytes, 14, 2), let second = number(bytes, 17, 2),
              let offsetHour = number(bytes, 21, 2), let offsetMinute = number(bytes, 23, 2),
              (1...12).contains(month), (1...31).contains(day), hour < 24, minute < 60, second < 60,
              offsetHour <= 23, offsetMinute < 60 else { return nil }

        let adjustedYear = year - (month <= 2 ? 1 : 0)
        let era = adjustedYear >= 0 ? adjustedYear / 400 : (adjustedYear - 399) / 400
        let yearOfEra = adjustedYear - era * 400
        let adjustedMonth = month + (month > 2 ? -3 : 9)
        let dayOfYear = (153 * adjustedMonth + 2) / 5 + day - 1
        let dayOfEra = yearOfEra * 365 + yearOfEra / 4 - yearOfEra / 100 + dayOfYear
        let daysSinceUnixEpoch = era * 146_097 + dayOfEra - 719_468
        let localSeconds = TimeInterval(daysSinceUnixEpoch * 86_400 + hour * 3_600 + minute * 60 + second)
        let offsetSeconds = TimeInterval((offsetHour * 3_600 + offsetMinute * 60) * (bytes[20] == 43 ? 1 : -1))
        return Date(timeIntervalSince1970: localSeconds - offsetSeconds)
    }

    private static func number(_ bytes: [UInt8], _ start: Int, _ length: Int) -> Int? {
        var result = 0
        for index in start..<(start + length) {
            let digit = bytes[index]
            guard (48...57).contains(digit) else { return nil }
            result = result * 10 + Int(digit - 48)
        }
        return result
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
