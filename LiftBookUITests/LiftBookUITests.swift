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
    func testSettingsCanSwitchWeightUnitPreference() throws {
        app.launch()

        XCTAssertTrue(app.buttons["Settings"].waitForExistence(timeout: 4))
        app.buttons["Settings"].tap()

        XCTAssertTrue(app.navigationBars["Settings"].waitForExistence(timeout: 4))
        XCTAssertTrue(app.staticTexts["Preferences"].waitForExistence(timeout: 4))

        let poundButton = app.buttons["lb"].firstMatch
        XCTAssertTrue(poundButton.waitForExistence(timeout: 4))
        poundButton.tap()
        XCTAssertTrue(poundButton.isSelected)

        let restTimerNotificationsToggle = app.switches["restTimerNotificationsSettingsToggle"]
            .firstMatch
        XCTAssertTrue(restTimerNotificationsToggle.waitForExistence(timeout: 4))
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

    @MainActor
    func testExerciseSelectionCanShowExerciseDetails() throws {
        app.launch()

        XCTAssertTrue(app.buttons["Create Routine"].waitForExistence(timeout: 4))
        app.buttons["Create Routine"].tap()

        XCTAssertTrue(app.buttons["Add Exercise"].waitForExistence(timeout: 4))
        app.buttons["Add Exercise"].tap()

        let searchField = app.searchFields.firstMatch
        XCTAssertTrue(searchField.waitForExistence(timeout: 4))
        searchField.tap()
        searchField.typeText("Close-Grip Bench Press")

        let detailButton = app.buttons["Show details for Close-Grip Bench Press"]
        XCTAssertTrue(detailButton.waitForExistence(timeout: 4))
        detailButton.tap()

        XCTAssertTrue(app.navigationBars["Exercise"].waitForExistence(timeout: 4))
        XCTAssertTrue(app.staticTexts["Close-Grip Bench Press"].waitForExistence(timeout: 4))
        XCTAssertVisibleElement(named: "Muscles")
        XCTAssertVisibleElement(named: "Equipment")
        XCTAssertVisibleElement(named: "Description")
        XCTAssertVisibleElement(named: "Instructions")
        XCTAssertVisibleElement(named: "Video URL")
        XCTAssertVisibleElement(named: "https://www.youtube.com/watch?v=XEnAUu6WtSw")
    }

    @MainActor
    func testSettingsExerciseLibraryCanShowExerciseDetails() throws {
        app.launch()

        XCTAssertTrue(app.buttons["Settings"].waitForExistence(timeout: 4))
        app.buttons["Settings"].tap()

        XCTAssertTrue(app.navigationBars["Settings"].waitForExistence(timeout: 4))
        let exerciseLibraryRow = app.buttons["exerciseLibrarySettingsRow"]
        XCTAssertTrue(exerciseLibraryRow.waitForExistence(timeout: 4))
        exerciseLibraryRow.tap()

        XCTAssertTrue(app.navigationBars["Exercise Library"].waitForExistence(timeout: 4))

        let searchField = app.searchFields.firstMatch
        XCTAssertTrue(searchField.waitForExistence(timeout: 4))
        searchField.tap()
        searchField.typeText("Close-Grip Bench Press")

        let exerciseRow = app.buttons["exerciseLibraryRow-close-grip-bench-press"].firstMatch
        XCTAssertTrue(exerciseRow.waitForExistence(timeout: 4))
        exerciseRow.tap()

        XCTAssertTrue(app.navigationBars["Exercise"].waitForExistence(timeout: 4))
        XCTAssertTrue(app.staticTexts["Close-Grip Bench Press"].waitForExistence(timeout: 4))
        XCTAssertVisibleElement(named: "Muscles")
        XCTAssertVisibleElement(named: "Equipment")
        XCTAssertVisibleElement(named: "Description")
        XCTAssertVisibleElement(named: "Instructions")
        XCTAssertVisibleElement(named: "Video URL")
        XCTAssertVisibleElement(named: "https://www.youtube.com/watch?v=XEnAUu6WtSw")
    }

    private func XCTAssertVisibleElement(
        named label: String,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        let matchingElements = [
            app.staticTexts[label].firstMatch,
            app.links[label].firstMatch,
            app.buttons[label].firstMatch
        ]

        if matchingElements.contains(where: { $0.waitForExistence(timeout: 1) }) {
            return
        }

        let scrollView = app.scrollViews.firstMatch
        for _ in 0..<5 where !matchingElements.contains(where: \.exists) {
            scrollView.swipeUp()
        }

        XCTAssertTrue(
            matchingElements.contains(where: \.exists),
            "Expected to find element named: \(label)",
            file: file,
            line: line
        )
    }
}
