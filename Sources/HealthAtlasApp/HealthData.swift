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
    static let maximumBytes = 100 * 1024 * 1024

    static func validate(url: URL) -> LocalImportResult {
        let extensionName = url.pathExtension.lowercased()
        guard supportedExtensions.contains(extensionName) else {
            return .rejected(AppLanguage.current.text(english: "Select an Apple Health ZIP archive or Export.xml file.", german: "Wähle ein Apple-Health-ZIP-Archiv oder eine Export.xml-Datei aus."))
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
              let exportEntry = String(data: entries, encoding: .utf8)?.split(whereSeparator: \.isNewline).first(where: { entry in
                  entry.split(separator: "/").last?.lowercased() == "export.xml"
              }) else {
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
        let identifier = attributeDict["type"] ?? elementName
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
