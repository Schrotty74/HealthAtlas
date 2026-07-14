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
}
