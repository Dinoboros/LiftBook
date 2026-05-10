//
//  LiftBookUITests.swift
//  LiftBookUITests
//
//  Created by Méryl VALIER on 24/04/2026.
//

import XCTest

final class LiftBookUITests: XCTestCase {
    private var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = [
            "-uiTestingSkipSplash",
            "-uiTestingSkipOnboarding",
            "-uiTestingResetData"
        ]
    }

    override func tearDownWithError() throws {
        app = nil
    }

    @MainActor
    func testFinishedEmptyWorkoutAppearsInHistoryWithSource() throws {
        app.launch()

        XCTAssertTrue(app.buttons["Start Empty Workout"].waitForExistence(timeout: 4))
        app.buttons["Start Empty Workout"].tap()

        XCTAssertTrue(app.buttons["Workout options"].waitForExistence(timeout: 4))
        app.buttons["Workout options"].tap()
        app.buttons["Finish Workout"].tap()

        XCTAssertTrue(app.staticTexts["Empty workout"].waitForExistence(timeout: 4))
    }
}
