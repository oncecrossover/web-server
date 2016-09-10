//
//  DiscoverViewControllerUITests.swift
//  Snoop
//
//  Created by Bowen Zhang on 9/3/16.
//  Copyright © 2016 Bowen Zhang. All rights reserved.
//

import XCTest

class DiscoverViewControllerUITests: XCTestCase {

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

  func testDiscover() {
    // Before you run the test, make sure you have users named "Steph Curry", "Ray Robinson", and "Nathan Downer" in your database
    // And the user "bzhang@test.com" is signed out
    let app = XCUIApplication()
    let emailTextField = app.textFields["Email:"]
    emailTextField.tap()
    emailTextField.typeText("bzhang@test.com")

    let passwordSecureTextField = app.secureTextFields["Password:"]
    passwordSecureTextField.tap()
    passwordSecureTextField.typeText("1234")
    app.childrenMatchingType(.Window).elementBoundByIndex(0).childrenMatchingType(.Other).element.childrenMatchingType(.Other).element.tap()
    app.buttons["Log In"].tap()

    let tabBarsQuery = app.tabBars
    tabBarsQuery.buttons["Discover"].tap()

    let tablesQuery = app.tables
    tablesQuery.staticTexts["Steph Curry"].tap()

    let discoverButton = app.navigationBars["Snoop.AskView"].buttons["Discover"]
    discoverButton.tap()
    tablesQuery.staticTexts["Nathan Downer"].tap()
    discoverButton.tap()
    tablesQuery.staticTexts["Ray Robinson"].tap()
    discoverButton.tap()
    tabBarsQuery.buttons["Me"].tap()
    app.buttons["Log Out"].tap()
  }

  func testDiscoverToProfile() {
    let app = XCUIApplication()
    let emailTextField = app.textFields["Email:"]
    emailTextField.tap()
    emailTextField.typeText("bzhang@test.com")

    let passwordSecureTextField = app.secureTextFields["Password:"]
    passwordSecureTextField.tap()
    passwordSecureTextField.typeText("1234")

    app.childrenMatchingType(.Window).elementBoundByIndex(0).childrenMatchingType(.Other).element.childrenMatchingType(.Other).element.tap()
    app.buttons["Log In"].tap()

    let tabBarsQuery = app.tabBars
    tabBarsQuery.buttons["Discover"].tap()
    app.tables.staticTexts["Ray Robinson"].tap()

    let textView = app.scrollViews.childrenMatchingType(.TextView).element
    textView.tap()
    textView.typeText("How are you?")
    app.scrollViews.containingType(.StaticText, identifier:"Ray Robinson").element.tap()
    app.buttons["Ask Him"].tap()
    app.navigationBars["Snoop.ChargeView"].childrenMatchingType(.Button).matchingIdentifier("Back").elementBoundByIndex(0).tap()
    app.navigationBars["Snoop.AskView"].buttons["Discover"].tap()
    tabBarsQuery.buttons["Me"].tap()
    app.buttons["Log Out"].tap()
  }

  func testDiscoverWithSearch() {
    let app = XCUIApplication()
    let emailTextField = app.textFields["Email:"]
    emailTextField.tap()
    emailTextField.typeText("bzhang@test.com")

    let passwordSecureTextField = app.secureTextFields["Password:"]
    passwordSecureTextField.tap()
    passwordSecureTextField.typeText("1234")

    let element = app.childrenMatchingType(.Window).elementBoundByIndex(0).childrenMatchingType(.Other).element.childrenMatchingType(.Other).element
    element.tap()
    app.buttons["Log In"].tap()

    let tabBarsQuery = app.tabBars
    tabBarsQuery.buttons["Discover"].tap()
    app.tables.searchFields["Search"].tap()
    app.searchFields["Search"].typeText("Ra")

    //For some reasons, the cell when search is active is not hittable. So
    //we need to instantiate a coordinate to tap
    let cell = app.tables.cells.elementBoundByIndex(0)
    let coordinate: XCUICoordinate = cell.coordinateWithNormalizedOffset(CGVectorMake(0.0, 0.0))
    coordinate.tap()


    app.navigationBars["Snoop.AskView"].buttons["Discover"].tap()
    app.buttons["Cancel"].tap()
    tabBarsQuery.buttons["Me"].tap()
    app.buttons["Log Out"].tap()
  }

}
