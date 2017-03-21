//
//  ViewControllerUITests.swift
//  Snoop
//
//  Created by Bowen Zhang on 8/17/16.
//  Copyright © 2016 Bowen Zhang. All rights reserved.
//

import XCTest

class ViewControllerUITests: XCTestCase {
        
    override func setUp() {
        super.setUp()
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        XCUIApplication().launch()

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
  func testSignIn() {
    
    let app = XCUIApplication()
    XCTAssertEqual(app.textFields.count, 1)
    XCTAssertEqual(app.secureTextFields.count, 1)
    let emailTextField = app.textFields["Email:"]
    emailTextField.tap()
    emailTextField.typeText("bzhang@test.com")
    
    let passwordSecureTextField = app.secureTextFields["Password:"]
    passwordSecureTextField.tap()

    passwordSecureTextField.typeText("1234")
    app.children(matching: .window).element(boundBy: 0).children(matching: .other).element.children(matching: .other).element.tap()
    app.buttons["Log In"].tap()
    XCTAssertEqual(app.tables.count, 1)
    app.tabBars.buttons["Me"].tap()
    app.buttons["Log Out"].tap()

  }
    
}
