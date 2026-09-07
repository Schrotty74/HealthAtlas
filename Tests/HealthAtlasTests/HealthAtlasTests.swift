import Foundation
import Testing
@testable import HealthAtlasApp

struct HealthAtlasTests {
    @Test func syntheticDemoCoversEveryCurrentAppleRecordIdentifier() throws {
        let projectRoot = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
        let demoURL = projectRoot.appendingPathComponent("Demo/AppleHealthDemo/Export.xml")
        let summary = AppleHealthImporter.importXML(at: demoURL, fileName: "Export.xml")

        #expect(summary?.recordCount == 518)
        #expect(summary?.dataTypes.count == 193)
        #expect(summary?.dataTypes.first(where: { $0.identifier == "HKQuantityTypeIdentifierBasalEnergyBurned" })?.dailyValues.count == 30)
    }

    @Test func appleHealthParserListsEveryRecognisedRecordType() {
        let xml = """
        <?xml version="1.0" encoding="UTF-8"?>
        <HealthData>
          <Record type="HKQuantityTypeIdentifierStepCount" unit="count" value="42" startDate="2026-07-10 09:00:00 +0200" />
          <Record type="HKQuantityTypeIdentifierHeartRate" unit="count/min" value="60" startDate="2026-07-10 09:00:00 +0200" />
          <Record type="HKQuantityTypeIdentifierHeartRate" unit="count/min" value="70" startDate="2026-07-11 09:00:00 +0200" />
          <Record type="HKCategoryTypeIdentifierSleepAnalysis" />
        </HealthData>
        """

        let summary = AppleHealthImporter.importXML(data: Data(xml.utf8), fileName: "sample.xml")
        #expect(summary?.recordCount == 4)
        #expect(summary?.dataTypes.count == 3)
        #expect(summary?.dataTypes.first(where: { $0.identifier == "HKQuantityTypeIdentifierStepCount" })?.valueText.hasPrefix("42") == true)
        #expect(summary?.dataTypes.first(where: { $0.identifier == "HKQuantityTypeIdentifierHeartRate" })?.valueText.hasPrefix("65") == true)
        #expect(summary?.dataTypes.first(where: { $0.identifier == "HKQuantityTypeIdentifierHeartRate" })?.dailyValues.count == 2)
    }

    @Test func exactDuplicateRecordsFromTheSameSourceAreCountedOnce() {
        let record = "<Record type=\"HKQuantityTypeIdentifierStepCount\" sourceName=\"iPhone\" sourceVersion=\"18.0\" device=\"iPhone\" unit=\"count\" value=\"100\" startDate=\"2026-07-10 09:00:00 +0200\" endDate=\"2026-07-10 09:15:00 +0200\" creationDate=\"2026-07-10 09:16:00 +0200\"/>"
        let summary = importSummary(records: record + record)

        let steps = metric("HKQuantityTypeIdentifierStepCount", in: summary)
        #expect(steps?.recordCount == 1)
        #expect(steps?.sum == 100)
        #expect(summary?.recordCount == 1)
    }

    @Test func overlappingCumulativeSourcesUseOneDeterministicSourcePerInterval() {
        let summary = importSummary(records: """
        <Record type="HKQuantityTypeIdentifierStepCount" sourceName="Alpha Phone" unit="count" value="100" startDate="2026-07-10 09:00:00 +0200" endDate="2026-07-10 09:15:00 +0200"/>
        <Record type="HKQuantityTypeIdentifierStepCount" sourceName="Zeta Watch" unit="count" value="120" startDate="2026-07-10 09:00:00 +0200" endDate="2026-07-10 09:15:00 +0200"/>
        """)

        let steps = metric("HKQuantityTypeIdentifierStepCount", in: summary)
        #expect(steps?.sum == 100)
        #expect(steps?.recordCount == 1)
    }

    @Test func nonOverlappingCumulativeSourcesAreBothIncluded() {
        let summary = importSummary(records: """
        <Record type="HKQuantityTypeIdentifierDistanceWalkingRunning" sourceName="Alpha Phone" unit="km" value="1.2" startDate="2026-07-10 09:00:00 +0200" endDate="2026-07-10 09:15:00 +0200"/>
        <Record type="HKQuantityTypeIdentifierDistanceWalkingRunning" sourceName="Tracker App" unit="km" value="0.8" startDate="2026-07-10 09:15:00 +0200" endDate="2026-07-10 09:30:00 +0200"/>
        """)

        #expect(metric("HKQuantityTypeIdentifierDistanceWalkingRunning", in: summary)?.sum == 2)
    }

    @Test func partiallyOverlappingCumulativeSourcesUseTheSelectedPortionOnly() {
        let summary = importSummary(records: """
        <Record type="HKQuantityTypeIdentifierActiveEnergyBurned" sourceName="Alpha Phone" unit="kcal" value="100" startDate="2026-07-10 09:00:00 +0200" endDate="2026-07-10 09:30:00 +0200"/>
        <Record type="HKQuantityTypeIdentifierActiveEnergyBurned" sourceName="Zeta Watch" unit="kcal" value="80" startDate="2026-07-10 09:15:00 +0200" endDate="2026-07-10 09:45:00 +0200"/>
        """)

        #expect(metric("HKQuantityTypeIdentifierActiveEnergyBurned", in: summary)?.sum == 140)
    }

    @Test func discreteMeasurementsKeepDistinctSourcesButRemoveExactDuplicates() {
        let summary = importSummary(records: """
        <Record type="HKQuantityTypeIdentifierHeartRate" sourceName="Apple Watch" sourceVersion="1" unit="count/min" value="60" startDate="2026-07-10 09:00:00 +0200" endDate="2026-07-10 09:01:00 +0200"/>
        <Record type="HKQuantityTypeIdentifierHeartRate" sourceName="Tracker App" sourceVersion="2" unit="count/min" value="80" startDate="2026-07-10 09:00:00 +0200" endDate="2026-07-10 09:01:00 +0200"/>
        <Record type="HKQuantityTypeIdentifierBodyMass" sourceName="Scale" unit="kg" value="70" startDate="2026-07-10 10:00:00 +0200" endDate="2026-07-10 10:00:00 +0200"/>
        <Record type="HKQuantityTypeIdentifierBodyMass" sourceName="Scale" unit="kg" value="72" startDate="2026-07-10 18:00:00 +0200" endDate="2026-07-10 18:00:00 +0200"/>
        """)

        let heartRate = metric("HKQuantityTypeIdentifierHeartRate", in: summary)
        let bodyMass = metric("HKQuantityTypeIdentifierBodyMass", in: summary)
        #expect(heartRate?.recordCount == 2)
        #expect(heartRate?.average == 70)
        #expect(bodyMass?.recordCount == 2)
        #expect(bodyMass?.dailyValues.first?.average == 71)
    }

    @Test func overlappingSleepIntervalsAreBoundedToOneSourceAndWorkoutsOnlyDeduplicateExactly() {
        let summary = importSummary(records: """
        <Record type="HKCategoryTypeIdentifierSleepAnalysis" sourceName="Alpha Phone" value="HKCategoryValueSleepAnalysisAsleepCore" startDate="2026-07-10 23:00:00 +0200" endDate="2026-07-11 07:00:00 +0200"/>
        <Record type="HKCategoryTypeIdentifierSleepAnalysis" sourceName="Zeta Watch" value="HKCategoryValueSleepAnalysisAsleepCore" startDate="2026-07-10 23:00:00 +0200" endDate="2026-07-11 07:00:00 +0200"/>
        <Workout sourceName="Apple Watch" workoutActivityType="HKWorkoutActivityTypeRunning" duration="1800" startDate="2026-07-10 18:00:00 +0200" endDate="2026-07-10 18:30:00 +0200"/>
        <Workout sourceName="Apple Watch" workoutActivityType="HKWorkoutActivityTypeRunning" duration="1800" startDate="2026-07-10 18:00:00 +0200" endDate="2026-07-10 18:30:00 +0200"/>
        """)

        #expect(metric("HKCategoryTypeIdentifierSleepAnalysis", in: summary)?.sum == 8)
        #expect(metric("HKCategoryTypeIdentifierSleepAnalysis", in: summary)?.unit == "h")
        #expect(metric("Workout", in: summary)?.recordCount == 1)
    }

    @Test func manualSourceOverlapFixtureMatchesEveryDocumentedExpectedValue() {
        let fixtureURL = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .appendingPathComponent("Fixtures/SourceOverlapValidation.xml")
        let summary = AppleHealthImporter.importXML(at: fixtureURL, fileName: fixtureURL.lastPathComponent)

        guard let summary else {
            Issue.record("Expected the synthetic source-overlap fixture to import successfully.")
            return
        }

        #expect(summary.recordCount == 21, "Expected 21 accepted Record elements; received \(summary.recordCount).")

        assertMetric("HKQuantityTypeIdentifierStepCount", in: summary, expectedRecordCount: 11, expectedSum: 515, expectedAverage: 515 / 11)
        assertMetric("HKQuantityTypeIdentifierDistanceWalkingRunning", in: summary, expectedRecordCount: 2, expectedSum: 2.5, expectedAverage: 1.25)
        assertMetric("HKQuantityTypeIdentifierActiveEnergyBurned", in: summary, expectedRecordCount: 2, expectedSum: 160, expectedAverage: 80)
        assertMetric("HKQuantityTypeIdentifierHeartRate", in: summary, expectedRecordCount: 2, expectedSum: 150, expectedAverage: 75)
        assertMetric("HKQuantityTypeIdentifierBodyMass", in: summary, expectedRecordCount: 2, expectedSum: 142, expectedAverage: 71)
        assertMetric("HKCategoryTypeIdentifierSleepAnalysis", in: summary, expectedRecordCount: 2, expectedSum: 3, expectedAverage: 1.5)

        let sleepDailyValues = metric("HKCategoryTypeIdentifierSleepAnalysis", in: summary)?.dailyValues.map(\.sum).sorted() ?? []
        #expect(sleepDailyValues == [1, 2], "Expected sleep split [1, 2] hours by local day; received \(sleepDailyValues).")

        let workouts = metric("Workout", in: summary)
        #expect(workouts?.recordCount == 2, "Expected two non-duplicate workouts; received \(workouts?.recordCount ?? -1).")
    }

    @Test func sourceAggregationStreamsManyRecordsWithoutRetainingTheXML() throws {
        let directory = try makeTemporaryDirectory()
        defer { try? FileManager.default.removeItem(at: directory) }
        let xmlURL = directory.appendingPathComponent("ManyRecords.xml")
        try writeManySourceRecords(to: xmlURL, count: 25_000)

        let summary = AppleHealthImporter.importXML(at: xmlURL, fileName: "ManyRecords.xml")
        #expect(metric("HKQuantityTypeIdentifierStepCount", in: summary)?.recordCount == 25_000)
        #expect(metric("HKQuantityTypeIdentifierStepCount", in: summary)?.sum == 25_000)
    }

    @Test func appleHealthParserImportsExportXMLFromZIPArchive() throws {
        let directory = FileManager.default.temporaryDirectory
            .appendingPathComponent("HealthAtlasTests-\(UUID().uuidString)", isDirectory: true)
        let xmlURL = directory.appendingPathComponent("Export.xml")
        let archiveURL = directory.appendingPathComponent("Export.zip")
        defer { try? FileManager.default.removeItem(at: directory) }

        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        let xml = """
        <?xml version="1.0" encoding="UTF-8"?>
        <HealthData>
          <Record type="HKQuantityTypeIdentifierStepCount" unit="count" value="42" startDate="2026-07-10 09:00:00 +0200" />
        </HealthData>
        """
        try Data(xml.utf8).write(to: xmlURL)

        let archive = Process()
        archive.executableURL = URL(fileURLWithPath: "/usr/bin/zip")
        archive.currentDirectoryURL = directory
        archive.arguments = ["-q", archiveURL.path, xmlURL.lastPathComponent]
        try archive.run()
        archive.waitUntilExit()
        #expect(archive.terminationStatus == 0)

        let fileSize = try archiveURL.resourceValues(forKeys: [.fileSizeKey]).fileSize ?? 0
        let result = AppleHealthImporter.importArchive(at: archiveURL, fileSize: fileSize)
        guard case let .imported(summary) = result else {
            Issue.record("Expected ZIP import to return Apple Health data.")
            return
        }
        #expect(summary.recordCount == 1)
        #expect(summary.dataTypes.first?.identifier == "HKQuantityTypeIdentifierStepCount")
    }

    @Test func importSizeLimitsSupportLargeLocalExports() {
        #expect(LocalImportValidator.supportsXMLByteCount(126 * 1024 * 1024))
        #expect(LocalImportValidator.supportsXMLByteCount(LocalImportValidator.maximumBytes))
        #expect(!LocalImportValidator.supportsXMLByteCount(LocalImportValidator.maximumBytes + 1))
        #expect(AppleHealthImporter.supportsArchiveByteCount(126 * 1024 * 1024))
        #expect(AppleHealthImporter.supportsArchiveByteCount(AppleHealthImporter.maximumArchiveBytes))
        #expect(!AppleHealthImporter.supportsArchiveByteCount(AppleHealthImporter.maximumArchiveBytes + 1))
    }

    @Test func streamingImportHandles126MiBXMLAndZIPArchive() throws {
        let directory = try makeTemporaryDirectory()
        defer { try? FileManager.default.removeItem(at: directory) }
        let xmlURL = directory.appendingPathComponent("Export.xml")
        let archiveURL = directory.appendingPathComponent("Export.zip")
        try writeSyntheticXML(to: xmlURL, byteCount: 126 * 1024 * 1024)

        guard case let .imported(xmlSummary) = LocalImportValidator.validate(url: xmlURL) else {
            Issue.record("Expected the 126 MiB XML export to import.")
            return
        }
        #expect(xmlSummary.recordCount == 1)

        try createZIP(at: archiveURL, containing: xmlURL, in: directory)
        guard case let .imported(zipSummary) = LocalImportValidator.validate(url: archiveURL) else {
            Issue.record("Expected the ZIP with a 126 MiB Export.xml to import.")
            return
        }
        #expect(zipSummary.recordCount == 1)
    }

    @Test func optionalFullScaleStreamingImportHandles500MiBXML() throws {
        guard ProcessInfo.processInfo.environment["HEALTHATLAS_RUN_LARGE_IMPORT_TESTS"] == "1" else { return }
        let directory = try makeTemporaryDirectory()
        defer { try? FileManager.default.removeItem(at: directory) }
        let xmlURL = directory.appendingPathComponent("Export.xml")
        let archiveURL = directory.appendingPathComponent("Export.zip")
        try writeSyntheticXML(to: xmlURL, byteCount: LocalImportValidator.maximumBytes)

        guard case let .imported(summary) = LocalImportValidator.validate(url: xmlURL) else {
            Issue.record("Expected the 500 MiB XML export to import.")
            return
        }
        #expect(summary.recordCount == 1)

        try createZIP(at: archiveURL, containing: xmlURL, in: directory)
        guard case let .imported(zipSummary) = LocalImportValidator.validate(url: archiveURL) else {
            Issue.record("Expected the ZIP with a 500 MiB Export.xml to import.")
            return
        }
        #expect(zipSummary.recordCount == 1)

        let oversizedXML = directory.appendingPathComponent("Oversized.xml")
        let oversizedArchive = directory.appendingPathComponent("Oversized.zip")
        try writeSparseFile(to: oversizedXML, byteCount: LocalImportValidator.maximumBytes + 1)
        try createZIP(at: oversizedArchive, containing: oversizedXML, in: directory)
        if case .rejected = LocalImportValidator.validate(url: oversizedArchive) {
            // The compressed archive is deliberately small; the contained XML is over the limit.
        } else {
            Issue.record("Expected a ZIP with an oversized uncompressed XML entry to be rejected.")
        }
    }

    @Test func importValidationRejectsInvalidAndEmptyInputs() throws {
        let directory = try makeTemporaryDirectory()
        defer { try? FileManager.default.removeItem(at: directory) }
        let emptyXML = directory.appendingPathComponent("Empty.xml")
        let malformedXML = directory.appendingPathComponent("Broken.xml")
        let unsupportedFile = directory.appendingPathComponent("Export.txt")
        let invalidZIP = directory.appendingPathComponent("Broken.zip")
        let nonHealthZIP = directory.appendingPathComponent("NoExport.zip")
        let textFile = directory.appendingPathComponent("Other.txt")
        let oversizedXML = directory.appendingPathComponent("Oversized.xml")

        try Data().write(to: emptyXML)
        try Data("<HealthData><Record".utf8).write(to: malformedXML)
        try Data("not an export".utf8).write(to: unsupportedFile)
        try Data("not a zip archive".utf8).write(to: invalidZIP)
        try Data("unrelated".utf8).write(to: textFile)
        try writeSparseFile(to: oversizedXML, byteCount: LocalImportValidator.maximumBytes + 1)
        try createZIP(at: nonHealthZIP, containing: textFile, in: directory)

        [emptyXML, malformedXML, unsupportedFile, invalidZIP, nonHealthZIP, oversizedXML].forEach { url in
            if case .rejected = LocalImportValidator.validate(url: url) {
                return
            }
            Issue.record("Expected \(url.lastPathComponent) to be rejected.")
        }
    }

    private func makeTemporaryDirectory() throws -> URL {
        let directory = FileManager.default.temporaryDirectory
            .appendingPathComponent("HealthAtlasTests-\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        return directory
    }

    private func importSummary(records: String) -> ImportedHealthSummary? {
        let xml = "<?xml version=\"1.0\" encoding=\"UTF-8\"?><HealthData>\(records)</HealthData>"
        return AppleHealthImporter.importXML(data: Data(xml.utf8), fileName: "sources.xml")
    }

    private func metric(_ identifier: String, in summary: ImportedHealthSummary?) -> HealthDataTypeSummary? {
        summary?.dataTypes.first { $0.identifier == identifier }
    }

    private func assertMetric(
        _ identifier: String,
        in summary: ImportedHealthSummary,
        expectedRecordCount: Int,
        expectedSum: Double,
        expectedAverage: Double
    ) {
        guard let actual = metric(identifier, in: summary) else {
            Issue.record("Expected metric \(identifier) to be present.")
            return
        }
        #expect(actual.recordCount == expectedRecordCount, "\(identifier) expected \(expectedRecordCount) accepted records; received \(actual.recordCount).")
        #expect(actual.sum == expectedSum, "\(identifier) expected total \(expectedSum); received \(actual.sum).")
        #expect(actual.average == expectedAverage, "\(identifier) expected average \(expectedAverage); received \(actual.average).")
    }

    private func writeSyntheticXML(to url: URL, byteCount: Int) throws {
        let opening = Data("<?xml version=\"1.0\" encoding=\"UTF-8\"?><HealthData><Record type=\"HKQuantityTypeIdentifierStepCount\" unit=\"count\" value=\"42\" startDate=\"2026-07-10 09:00:00 +0200\"/>".utf8)
        let closing = Data("</HealthData>".utf8)
        precondition(byteCount > opening.count + closing.count)
        FileManager.default.createFile(atPath: url.path, contents: nil)
        let handle = try FileHandle(forWritingTo: url)
        defer { try? handle.close() }
        try handle.write(contentsOf: opening)

        var remaining = byteCount - opening.count - closing.count
        let whitespace = Data(repeating: 0x20, count: min(1 * 1024 * 1024, remaining))
        while remaining > 0 {
            let count = min(remaining, whitespace.count)
            try handle.write(contentsOf: whitespace.prefix(count))
            remaining -= count
        }
        try handle.write(contentsOf: closing)
    }

    private func writeManySourceRecords(to url: URL, count: Int) throws {
        FileManager.default.createFile(atPath: url.path, contents: nil)
        let handle = try FileHandle(forWritingTo: url)
        defer { try? handle.close() }
        try handle.write(contentsOf: Data("<?xml version=\"1.0\" encoding=\"UTF-8\"?><HealthData>".utf8))
        for index in 0..<count {
            let hour = index / 3600
            let minute = (index / 60) % 60
            let second = index % 60
            let timestamp = String(format: "2026-07-01 %02d:%02d:%02d +0200", hour, minute, second)
            let record = "<Record type=\"HKQuantityTypeIdentifierStepCount\" sourceName=\"Synthetic Watch\" unit=\"count\" value=\"1\" startDate=\"\(timestamp)\" endDate=\"\(timestamp)\"/>"
            try handle.write(contentsOf: Data(record.utf8))
        }
        try handle.write(contentsOf: Data("</HealthData>".utf8))
    }

    private func createZIP(at archiveURL: URL, containing fileURL: URL, in directory: URL) throws {
        let archive = Process()
        archive.executableURL = URL(fileURLWithPath: "/usr/bin/zip")
        archive.currentDirectoryURL = directory
        archive.arguments = ["-q", archiveURL.path, fileURL.lastPathComponent]
        try archive.run()
        archive.waitUntilExit()
        #expect(archive.terminationStatus == 0)
    }

    private func writeSparseFile(to url: URL, byteCount: Int) throws {
        FileManager.default.createFile(atPath: url.path, contents: nil)
        let handle = try FileHandle(forWritingTo: url)
        defer { try? handle.close() }
        try handle.truncate(atOffset: UInt64(byteCount))
    }

    @Test func firstLaunchAIServiceURLsUseTheThreeSelectedServices() {
        let urls = Dictionary(uniqueKeysWithValues: FirstLaunchAIService.allCases.map {
            ($0.title, $0.websiteURL.absoluteString)
        })

        #expect(urls == [
            "ChatGPT": "https://chatgpt.com/",
            "Gemini": "https://gemini.google.com/",
            "Claude": "https://claude.ai/"
        ])
    }

    @Test func firstLaunchHelpUsesTheLanguageSpecificPublicHandbook() {
        let german = FirstLaunchHelpContent(language: .german)
        let english = FirstLaunchHelpContent(language: .english)

        #expect(german.handbookURL.absoluteString == "https://github.com/Schrotty74/HealthAtlas/blob/main/output/pdf/HealthAtlas-Handbuch-DE.pdf")
        #expect(english.handbookURL.absoluteString == "https://github.com/Schrotty74/HealthAtlas/blob/main/output/pdf/HealthAtlas-Manual-EN.pdf")
        #expect(german.prompt.contains(german.handbookURL.absoluteString))
        #expect(english.prompt.contains(english.handbookURL.absoluteString))
    }

    @Test func AIHelpAsksForAnExplanationOfThePublicManual() {
        let german = FirstLaunchHelpContent(language: .german)
        let english = FirstLaunchHelpContent(language: .english)

        #expect(german.prompt.contains("Handbuch"))
        #expect(english.prompt.localizedCaseInsensitiveContains("manual"))
        #expect(german.manualExplanationDescription.contains("Handbuch"))
        #expect(english.manualExplanationDescription.localizedCaseInsensitiveContains("manual"))
    }

    @Test func firstLaunchPromptContainsNoLocalOrImportedData() {
        for language in [AppLanguage.german, .english] {
            let prompt = FirstLaunchHelpContent(language: language).prompt
            let localUserPathPrefix = "/" + "Users/"
            let forbiddenFragments = [localUserPathPrefix, "file://", "Export.xml", "HKQuantity", "token", "password", "license"]

            #expect(forbiddenFragments.allSatisfy { !prompt.localizedCaseInsensitiveContains($0) })
            #expect(prompt.components(separatedBy: "https://").count == 2)
        }
    }

    @Test func healthDataCategoriesCoverCommonAppleHealthTypes() {
        #expect(HealthDataCategory.category(for: "HKQuantityTypeIdentifierHeartRate") == .heart)
        #expect(HealthDataCategory.category(for: "HKCategoryTypeIdentifierSleepAnalysis") == .sleep)
        #expect(HealthDataCategory.category(for: "HKQuantityTypeIdentifierStepCount") == .activity)
        #expect(HealthDataCategory.category(for: "HKQuantityTypeIdentifierBodyMass") == .body)
        #expect(HealthDataCategory.category(for: "HKQuantityTypeIdentifierDietaryProtein") == .nutrition)
        #expect(HealthDataCategory.category(for: "HKQuantityTypeIdentifierWalkingSpeed") == .mobility)
        #expect(HealthDataCategory.category(for: "HKCategoryTypeIdentifierHeadache") == .symptoms)
    }

    @Test func chartStylesMatchTheLocalDataType() {
        let steps = HealthDataTypeSummary(identifier: "HKQuantityTypeIdentifierStepCount", displayName: "Steps", recordCount: 1, sum: 1, average: 1, unit: "count", dailyValues: [])
        let energy = HealthDataTypeSummary(identifier: "HKQuantityTypeIdentifierActiveEnergyBurned", displayName: "Active Energy", recordCount: 1, sum: 1, average: 1, unit: "kcal", dailyValues: [])
        let sleep = HealthDataTypeSummary(identifier: "HKCategoryTypeIdentifierSleepAnalysis", displayName: "Sleep", recordCount: 1, sum: 1, average: 1, unit: nil, dailyValues: [])
        let heart = HealthDataTypeSummary(identifier: "HKQuantityTypeIdentifierHeartRate", displayName: "Heart Rate", recordCount: 1, sum: 1, average: 1, unit: "count/min", dailyValues: [])

        #expect(steps.preferredChartStyle == .bar)
        #expect(energy.preferredChartStyle == .bar)
        #expect(sleep.preferredChartStyle == .area)
        #expect(heart.preferredChartStyle == .line)
    }

    @Test func localDataCoverageReportsMissingDatesAndSparseTypes() {
        let calendar = Calendar(identifier: .gregorian)
        let first = Date(timeIntervalSince1970: 0)
        let second = calendar.date(byAdding: .day, value: 6, to: first)!
        let metric = HealthDataTypeSummary(
            identifier: "HKQuantityTypeIdentifierHeartRate", displayName: "Heart Rate", recordCount: 2, sum: 140, average: 70, unit: "count/min",
            dailyValues: [HealthDailyValue(date: first, sum: 60, average: 60), HealthDailyValue(date: second, sum: 80, average: 80)]
        )
        let coverage = LocalDataCoverage.make(metrics: [metric], days: 7, calendar: calendar)

        #expect(coverage.observedDays == 2)
        #expect(coverage.missingDays == 5)
        #expect(coverage.sparseTypes.count == 1)
    }

    @Test func periodComparisonUsesAdjacentLocalPeriods() {
        let metric = HealthDataTypeSummary(
            identifier: "HKQuantityTypeIdentifierHeartRate",
            displayName: "Heart Rate",
            recordCount: 4,
            sum: 280,
            average: 70,
            unit: "count/min",
            dailyValues: [
                HealthDailyValue(date: Date(timeIntervalSince1970: 0), sum: 60, average: 60),
                HealthDailyValue(date: Date(timeIntervalSince1970: 86_400), sum: 70, average: 70),
                HealthDailyValue(date: Date(timeIntervalSince1970: 172_800), sum: 80, average: 80),
                HealthDailyValue(date: Date(timeIntervalSince1970: 259_200), sum: 90, average: 90)
            ]
        )
        let comparison = HealthPeriodComparison.make(values: metric.dailyValues, metric: metric, days: 2)
        #expect(comparison?.current == 85)
        #expect(comparison?.previous == 65)
        #expect(comparison?.difference == 20)
    }

    @Test func appUpdateVersionsOrderFinalAfterBeta() {
        #expect(AppReleaseVersion("v0.1.0-beta.10")! > AppReleaseVersion("v0.1.0-beta.9")!)
        #expect(AppReleaseVersion("v0.1.0")! > AppReleaseVersion("v0.1.0-beta.10")!)
        #expect(AppReleaseVersion("v0.2.0-beta.1")! > AppReleaseVersion("v0.1.0")!)
    }

    @Test func appUpdateUsesTheMatchingReleaseChannel() {
        let releases = [
            GitHubRelease(tagName: "v0.1.0-beta.9", htmlURL: URL(string: "https://example.com/beta")!, isPrerelease: true, isDraft: false),
            GitHubRelease(tagName: "v0.1.0", htmlURL: URL(string: "https://example.com/final")!, isPrerelease: false, isDraft: false),
            GitHubRelease(tagName: "v0.2.0-beta.1", htmlURL: URL(string: "https://example.com/draft")!, isPrerelease: true, isDraft: true)
        ]

        #expect(AppUpdateService.latestRelease(from: releases, for: .beta)?.versionText == "v0.1.0")
        #expect(AppUpdateService.latestRelease(from: releases, for: .final)?.versionText == "v0.1.0")
    }
}
