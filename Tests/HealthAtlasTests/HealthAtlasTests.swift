import Testing
@testable import HealthAtlasApp

struct HealthAtlasTests {
    @Test func demoDataIsDeterministicAndNonEmpty() {
        #expect(HealthDataStore.demoMetrics.count == 4)
        #expect(HealthDataStore.demoMetrics.allSatisfy { !$0.title.isEmpty && !$0.value.isEmpty })
    }
}
