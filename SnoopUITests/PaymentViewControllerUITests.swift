//
//  PaymentViewControllerUITests.swift
//  Snoop
//
//  Created by Bowen Zhang on 8/20/16.
//  Copyright © 2016 Bowen Zhang. All rights reserved.
//

import XCTest

class PaymentViewControllerUITests: XCTestCase {
        
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
    
    func testManagementPayment() {
      // Before teset starts, make sure bzhang@test.com is signed out and he has no payment methods at all
      let app = XCUIApplication()
      let emailTextField = app.textFields["Email:"]
      emailTextField.tap()
      emailTextField.typeText("bzhang@test.com")
      
      let passwordSecureTextField = app.secureTextFields["Password:"]
      passwordSecureTextField.tap()
      passwordSecureTextField.typeText("1234")
      app.childrenMatchingType(.Window).elementBoundByIndex(0).childrenMatchingType(.Other).element.childrenMatchingType(.Other).element.tap()
      app.buttons["Log In"].tap()
      app.tabBars.buttons["Me"].tap()
      app.buttons["Manage Payment"].tap()
      app.buttons["Add Card"].tap()
      
      let textField = app.textFields["1234567812345678"]
      textField.tap()
      textField.typeText("5555555555554444")
      
      let app2 = app
      app2.textFields["MM/YY"].typeText("1217")
      app2.textFields["CVC"].typeText("123")
      app.buttons["Save Card"].tap()
      app.alerts["OK"].collectionViews.buttons["OK"].tap()
      app.navigationBars["Add A Card"].childrenMatchingType(.Button).matchingIdentifier("Back").elementBoundByIndex(0).tap()
      XCTAssertEqual(app.tables.count, 1)

      app2.tables.staticTexts["ending in 4444  MasterCard"].tap()
      app.navigationBars["Payment Cards"].buttons["Profile"].tap()
      app.buttons["Log Out"].tap()
    }
    
}