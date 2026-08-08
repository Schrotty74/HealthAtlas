import Foundation
import Testing
@testable import HealthAtlasApp

struct HealthAtlasTests {
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
}
