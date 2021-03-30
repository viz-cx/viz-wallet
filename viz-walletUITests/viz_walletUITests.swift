//
//  viz_walletUITests.swift
//  viz-walletUITests
//
//  Created by Vladimir Babin on 30.03.2021.
//

import XCTest

class viz_walletUITests: XCTestCase {
    
    override class func setUp() {
        let app = XCUIApplication()
        setupSnapshot(app)
        app.launch()
    }

    func testExample() throws {
        snapshot("01LoginScreen")
        
        let app = XCUIApplication()
        let login = app.textFields["Login"]
        login.tap()
        login.typeText("tester5")
        
        let privateRegularKeyTextField = app.textFields["Private regular key"]
        privateRegularKeyTextField.tap()
        privateRegularKeyTextField.typeText("5K6wUi4eL2j8LV4R6UVqyaww1zQFjMLmKxrr7B45WLa1QeD6i9x")
        app.buttons["Sign In"].tap()
        
        sleep(10)
        
        snapshot("02MainScreen")
    }
}
