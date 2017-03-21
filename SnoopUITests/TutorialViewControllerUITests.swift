//
//  TutorialViewControllerUITests.swift
//  Snoop
//
//  Created by Bowen Zhang on 9/9/16.
//  Copyright © 2016 Bowen Zhang. All rights reserved.
//

import XCTest

class TutorialViewControllerUITests: XCTestCase {

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

  func testTutorialPageAfterSignup() {
    //Make sure there is no user with uid david@test.com
    let app = XCUIApplication()
    app.buttons["Sign Up"].tap()

    let nameTextField = app.textFields["Name:"]
    nameTextField.tap()
    nameTextField.typeText("David Silva")

    let emailTextField = app.textFields["Email:"]
    emailTextField.tap()
    emailTextField.typeText("david@test.com")

    let passwordSecureTextField = app.secureTextFields["Password:"]
    passwordSecureTextField.tap()
    passwordSecureTextField.typeText("asdfgh")

    let window = app.children(matching: .window).element(boundBy: 0)
    window.children(matching: .other).element(boundBy: 1).children(matching: .other).element.tap()
    app.buttons["Join Now"].tap()

    let okButton = app.alerts["OK"].collectionViews.buttons["Ok"]
    okButton.tap()

    let element = window.children(matching: .other).element(boundBy: 2).children(matching: .other).element
    element.tap()
    element.tap()
    element.tap()
    element.tap()
    element.tap()
    app.navigationBars["Tutorial"].buttons["Skip"].tap()
    emailTextField.tap()
    window.children(matching: .other).element.children(matching: .other).element.tap()
  }

}
