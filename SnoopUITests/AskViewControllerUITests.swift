//
//  AskViewControllerUITests.swift
//  Snoop
//
//  Created by Bowen Zhang on 9/7/16.
//  Copyright © 2016 Bowen Zhang. All rights reserved.
//

import XCTest

class AskViewControllerUITests: XCTestCase {

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

  func testAskQuestionFromDiscover() {
    //Make sure the user bowenzhangusa@gmail.com has a credit card on file before running this test

    let app = XCUIApplication()
    //First log in
    let emailTextField = app.textFields["Email:"]
    emailTextField.tap()
    emailTextField.typeText("bowenzhangusa@gmail.com")

    let passwordSecureTextField = app.secureTextFields["Password:"]
    passwordSecureTextField.tap()
    passwordSecureTextField.typeText("asdfgh")

    app.childrenMatchingType(.Window).elementBoundByIndex(0).childrenMatchingType(.Other).element.childrenMatchingType(.Other).element.tap()
    app.buttons["Log In"].tap()

    // Go to Tyson' profile from discover
    let tabBarsQuery = app.tabBars
    tabBarsQuery.buttons["Discover"].tap()

    let tablesQuery = app.tables
    tablesQuery.staticTexts["Mike Tyson"].tap()

    // ASk a question
    let textView = app.scrollViews.childrenMatchingType(.TextView).element
    textView.tap()
    textView.typeText("What do you think about Floyd talking about greater than Ali?")
    app.buttons["Return"].tap()

    app.buttons["Ask Him"].tap()

    // Wait for the payment method to load and tap on "pay now"
    let predicate = NSPredicate(format: "enabled == 1")
    let query = XCUIApplication().buttons["Pay Now"]
    expectationForPredicate(predicate, evaluatedWithObject: query, handler: nil)
    waitForExpectationsWithTimeout(5, handler: nil)
    app.buttons["Pay Now"].tap()

    app.buttons["done"].tap()
    app.navigationBars["Snoop.AskView"].buttons["Discover"].tap()
    tabBarsQuery.buttons["Activity"].tap()
    // Verify the question is there
    tablesQuery.staticTexts["What do you think about Floyd talking about greater than Ali?"].tap()
    tabBarsQuery.buttons["Me"].tap()
    app.buttons["Log Out"].tap()
  }

}
