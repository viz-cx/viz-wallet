//
//  viz_walletUITests.swift
//  viz-walletUITests
//
//  Created by Vladimir Babin on 30.03.2021.
//

import XCTest

class viz_walletUITests: XCTestCase {
    
    private var app: XCUIApplication!
    
    override class func setUp() {
        let app = XCUIApplication()
        setupSnapshot(app)
        app.launch()
    }
    
    override func tearDownWithError() throws {
        app = nil
    }
    
    func testExample() throws {
        snapshot("01Login")
        let app = XCUIApplication()
        let login = app.textFields["login"]
        if login.exists {
            login.tap()
            login.typeText("tester")
            let privateRegularKeyTextField = app.textFields["regular"]
            privateRegularKeyTextField.tap()
            waitForElementToAppear(element: app.keyboards.element, timeout: 5)
            privateRegularKeyTextField.typeText("5JZz2oob5VzKegg8dr3BC8q2M2u1qrFhA7WLF6VWvp1c8yiTc6Z")
            app.buttons["signin"].tap()
        }
        
        let tabBar = app.tabBars
        waitForElementToAppear(element: tabBar.element, timeout: 90)
        
        tabBar.buttons.element(boundBy: 0).tap()
        snapshot("02Award")
        
        tabBar.buttons.element(boundBy: 1).tap()
        let privateActiveKeyTextField = XCUIApplication().scrollViews.otherElements.textFields["active"]
        if privateActiveKeyTextField.exists {
            privateActiveKeyTextField.tap()
            privateActiveKeyTextField.typeText("5JZz2oob5VzKegg8dr3BC8q2M2u1qrFhA7WLF6VWvp1c8yiTc6Z")
            XCUIApplication().scrollViews.otherElements.buttons["save"].tap()
        }
        snapshot("03Transfer")
        
        tabBar.buttons.element(boundBy: 2).tap()
        snapshot("04Receive")
        
        tabBar.buttons.element(boundBy: 3).tap()
        waitForElementToAppear(element: app.tables.element(boundBy: 0).cells.element(boundBy: 2), timeout: 30)
        snapshot("05News")
        
        tabBar.buttons.element(boundBy: 4).tap()
        snapshot("06Settings")
        
        let englishLogout = app.tables.staticTexts["Logout"]
        if englishLogout.exists {
            englishLogout.tap()
        } else {
            app.tables.staticTexts["Выйти"].tap()
        }
        snapshot("01Login")
    }
    
    func waitForElementToAppear(element: XCUIElement, timeout: TimeInterval = 5) {
        let existsPredicate = NSPredicate(format: "exists == true")
        
        expectation(for: existsPredicate,
                    evaluatedWith: element, handler: nil)
        
        waitForExpectations(timeout: timeout) { (error) -> Void in
            if (error != nil) {
                let message = "Failed to find \(element) after \(timeout) seconds."
                self.record(XCTIssue(type: .assertionFailure, compactDescription: message))
            }
        }
    }
}
