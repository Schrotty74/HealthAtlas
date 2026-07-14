import Foundation

struct HealthMetric {
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
        if identifier == "HKQuantityTypeIdentifierStepCount" || identifier.contains("Energy") || identifier.contains("Distance") || identifier.contains("FlightsClimbed") {
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
        identifier == "HKQuantityTypeIdentifierStepCount" || identifier.contains("Energy") || identifier.contains("Distance") || identifier.contains("FlightsClimbed")
            ? dailyValue.sum : dailyValue.average
    }

    func formattedValue(_ value: Double) -> String {
        let formatted = value.formatted(.number.precision(.fractionLength(0...1)))
        return unit.map { "\(formatted) \(localizedUnit($0))" } ?? formatted
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
    private static let supportedExtensions: Set<String> = ["json", "xml", "csv", "zip"]
    static let maximumBytes = 100 * 1024 * 1024

    static func validate(url: URL) -> LocalImportResult {
        let extensionName = url.pathExtension.lowercased()
        guard supportedExtensions.contains(extensionName) else {
            return .rejected(AppLanguage.current.text(english: "Only Apple Health ZIP/XML, JSON and CSV files can be checked.", german: "Es können nur Apple-Health-ZIP/XML-, JSON- und CSV-Dateien geprüft werden."))
        }
        guard let values = try? url.resourceValues(forKeys: [.fileSizeKey, .isRegularFileKey]), values.isRegularFile == true else {
            return .rejected(AppLanguage.current.text(english: "Please select a regular local file.", german: "Bitte wähle eine normale lokale Datei aus."))
        }
        let byteCount = values.fileSize ?? 0
        guard byteCount > 0, byteCount <= maximumBytes else {
            return .rejected(AppLanguage.current.text(english: "The file must be between 1 byte and 100 MB.", german: "Die Datei muss zwischen 1 Byte und 100 MB groß sein."))
        }
        if extensionName == "zip" {
            return AppleHealthImporter.importArchive(at: url, fileSize: byteCount)
        }
        guard let data = try? Data(contentsOf: url, options: [.mappedIfSafe]), !data.prefix(512).contains(0) else {
            return .rejected(AppLanguage.current.text(english: "The selected file is not a readable text export.", german: "Die ausgewählte Datei ist kein lesbarer Textexport."))
        }
        if extensionName == "xml", let summary = AppleHealthImporter.importXML(data: data, fileName: url.lastPathComponent) {
            return .imported(summary)
        }
        return .ready(LocalImportSummary(fileName: url.lastPathComponent, format: extensionName.uppercased(), byteCount: byteCount))
    }
}

enum AppleHealthImporter {
    private static let maximumXMLBytes = 100 * 1024 * 1024

    static func importArchive(at url: URL, fileSize: Int) -> LocalImportResult {
        guard fileSize <= LocalImportValidator.maximumBytes else {
            return .rejected(AppLanguage.current.text(english: "The archive is too large to import safely.", german: "Das Archiv ist für einen sicheren Import zu groß."))
        }
        guard let entries = unzip(arguments: ["-Z1", url.path]),
              let exportEntry = String(data: entries, encoding: .utf8)?.split(whereSeparator: \.isNewline).first(where: { $0.lowercased().hasSuffix("/export.xml") || $0.lowercased() == "export.xml" }) else {
            return .rejected(AppLanguage.current.text(english: "This ZIP does not contain the required Export.xml data file.", german: "Dieses ZIP enthält nicht die erforderliche Datendatei Export.xml."))
        }
        guard let xml = unzip(arguments: ["-p", url.path, String(exportEntry)]), xml.count <= maximumXMLBytes else {
            return .rejected(AppLanguage.current.text(english: "Apple Health data could not be read safely from this ZIP.", german: "Die Apple-Health-Daten konnten nicht sicher aus diesem ZIP gelesen werden."))
        }
        guard let summary = importXML(data: xml, fileName: url.lastPathComponent) else {
            return .rejected(AppLanguage.current.text(english: "The ZIP does not contain readable Apple Health data.", german: "Das ZIP enthält keine lesbaren Apple-Health-Daten."))
        }
        return .imported(summary)
    }

    static func importXML(data: Data, fileName: String) -> ImportedHealthSummary? {
        guard data.count <= maximumXMLBytes else { return nil }
        let parserDelegate = AppleHealthXMLDelegate()
        let parser = XMLParser(data: data)
        parser.delegate = parserDelegate
        guard parser.parse(), parserDelegate.recordCount > 0 else { return nil }
        return ImportedHealthSummary(
            fileName: fileName,
            recordCount: parserDelegate.recordCount,
            dataTypes: parserDelegate.dataTypes
        )
    }

    private static func unzip(arguments: [String]) -> Data? {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/unzip")
        process.arguments = arguments
        let output = Pipe()
        process.standardOutput = output
        process.standardError = FileHandle.nullDevice
        do {
            try process.run()
            let data = output.fileHandleForReading.readDataToEndOfFile()
            process.waitUntilExit()
            return process.terminationStatus == 0 ? data : nil
        } catch {
            return nil
        }
    }
}

private final class AppleHealthXMLDelegate: NSObject, XMLParserDelegate {
    var recordCount = 0
    private var accumulators: [String: HealthDataTypeAccumulator] = [:]

    var dataTypes: [HealthDataTypeSummary] {
        accumulators.values.map(\.summary).sorted {
            $0.recordCount == $1.recordCount ? $0.displayName < $1.displayName : $0.recordCount > $1.recordCount
        }
    }

    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String: String] = [:]) {
        let supportedElements: Set<String> = ["Record", "Correlation", "Workout", "ActivitySummary", "ClinicalRecord", "Audiogram", "VisionPrescription"]
        guard supportedElements.contains(elementName) else { return }
        let identifier = elementName == "Record" ? attributeDict["type"] : elementName
        guard let identifier else { return }
        if elementName == "Record" { recordCount += 1 }
        var accumulator = accumulators[identifier] ?? HealthDataTypeAccumulator(identifier: identifier)
        accumulator.append(
            value: Double(attributeDict["value"] ?? ""),
            unit: attributeDict["unit"],
            date: AppleHealthDateParser.date(from: attributeDict["startDate"])
        )
        accumulators[identifier] = accumulator
    }
}

private struct HealthDataTypeAccumulator {
    let identifier: String
    var recordCount = 0
    var sum = 0.0
    var numericCount = 0
    var unit: String?
    private var dailyTotals: [Date: (sum: Double, count: Int)] = [:]

    init(identifier: String) {
        self.identifier = identifier
    }

    mutating func append(value: Double?, unit: String?, date: Date?) {
        recordCount += 1
        if let value {
            sum += value
            numericCount += 1
        }
        if self.unit == nil { self.unit = unit }
        if let value, let date {
            let day = Calendar.current.startOfDay(for: date)
            let previous = dailyTotals[day] ?? (0, 0)
            dailyTotals[day] = (previous.sum + value, previous.count + 1)
        }
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
