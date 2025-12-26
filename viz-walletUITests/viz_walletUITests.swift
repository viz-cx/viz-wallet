//
//  viz_walletUITests.swift
//  viz-walletUITests
//
//  Created by Vladimir Babin on 30.03.2021.
//

import XCTest

@MainActor
final class viz_walletUITests: XCTestCase {
    
    nonisolated(unsafe)
    private var app: XCUIApplication!
    
    // MARK: - Lifecycle
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        
        self.app = MainActor.assumeIsolated {
            let app = XCUIApplication()
            
            app.launchArguments += ["-ui-testing"]
            
            setupSnapshot(app)
            app.launch()
            return app
        }
    }

    // MARK: - Tests
    
    func testExample() async throws {
        snapshot("01Login")
        
        let loginField = app.textFields["login"]
        if loginField.waitForExistence(timeout: 5) {
            loginField.tap()
            loginField.typeText("tester")
            
            let regularKeyField = app.textFields["regular"]
            regularKeyField.tap()
            regularKeyField.typeText("5JZz2oob5VzKegg8dr3BC8q2M2u1qrFhA7WLF6VWvp1c8yiTc6Z")
            
            app.buttons["signin"].tap()
        }
        
        let tabBar = app.tabBars.element
        XCTAssertTrue(
            tabBar.waitForExistence(timeout: 10),
            "Tab bar did not appear"
        )
        
        app.tabBars.buttons.element(boundBy: 0).tap()
        snapshot("02Award")
        
        app.tabBars.buttons.element(boundBy: 1).tap()
        let activeKeyField = app.scrollViews.otherElements.textFields["active"]
        
        if activeKeyField.waitForExistence(timeout: 5) {
            activeKeyField.tap()
            activeKeyField.typeText("5JZz2oob5VzKegg8dr3BC8q2M2u1qrFhA7WLF6VWvp1c8yiTc6Z")
            app.scrollViews.otherElements.buttons["save"].tap()
        }
        
        snapshot("03Transfer")
        
        app.tabBars.buttons.element(boundBy: 2).tap()
        snapshot("04Receive")
        
        app.tabBars.buttons.element(boundBy: 3).tap()
        snapshot("05Settings")
        
        let logoutButton =
        app.tables.staticTexts["Logout"].exists
        ? app.tables.staticTexts["Logout"]
        : app.tables.staticTexts["Выйти"]
        
        XCTAssertTrue(logoutButton.waitForExistence(timeout: 5))
        logoutButton.tap()
        
        snapshot("01Login")
    }
}
