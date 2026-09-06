import XCTest

final class HealthAtlasUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @MainActor
    func testDesignStudioKeepsControlsAnchoredWhenChangingLanguageAndTheme() throws {
        let app = XCUIApplication()
        app.launchArguments = [
            "--ui-testing",
            "--ui-testing-reset",
            "-AppleLanguages", "(en)",
            "-AppleLocale", "en_US"
        ]
        app.launch()

        let designStudio = app.buttons["Design Studio"]
        XCTAssertTrue(designStudio.waitForExistence(timeout: 5))
        designStudio.click()

        let appearanceHeading = app.staticTexts["design-studio-heading"]
        XCTAssertTrue(appearanceHeading.waitForExistence(timeout: 3))
        let originalY = appearanceHeading.frame.minY

        let languagePicker = app.popUpButtons["design-studio-language"]
        XCTAssertTrue(languagePicker.waitForExistence(timeout: 3))
        languagePicker.click()
        app.menuItems["Deutsch"].click()

        let germanHeading = app.staticTexts["design-studio-heading"]
        XCTAssertTrue(germanHeading.waitForExistence(timeout: 3))
        XCTAssertEqual(germanHeading.frame.minY, originalY, accuracy: 2)

        let auroraTheme = app.buttons["Aurora"]
        XCTAssertTrue(auroraTheme.waitForExistence(timeout: 3))
        auroraTheme.click()

        XCTAssertEqual(germanHeading.frame.minY, originalY, accuracy: 2)
    }
}
