//
//  Tests_iOS.swift
//  Tests iOS
//
//  Created by Vladimir Babin on 21.02.2021.
//

import XCTest

@MainActor
class Tests_iOS: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    func testExample() throws {
        let app = XCUIApplication()
        app.launch()
    }

    func testLaunchPerformance() throws {
        measure(metrics: [XCTApplicationLaunchMetric()]) {
            XCUIApplication().launch()
        }
    }
}
