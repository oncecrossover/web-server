//
//  SignupViewControllerUITests.swift
//  Snoop
//
//  Created by Bowen Zhang on 8/21/16.
//  Copyright © 2016 Bowen Zhang. All rights reserved.
//

import XCTest

class SignupViewControllerUITests: XCTestCase {
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

  func testSignupWithInvalidEmail() {
    let app = XCUIApplication()
    app.buttons["Sign Up"].tap()

    let nameTextField = app.textFields["Name:"]
    nameTextField.tap()
    nameTextField.typeText("Bowen Zhang")

    let emailTextField = app.textFields["Email:"]
    emailTextField.tap()
    emailTextField.typeText("bzhang")

    let passwordSecureTextField = app.secureTextFields["Password:"]
    passwordSecureTextField.tap()
    passwordSecureTextField.typeText("123456")

    app.childrenMatchingType(.Window).elementBoundByIndex(0).childrenMatchingType(.Other).elementBoundByIndex(1).childrenMatchingType(.Other).element.tap()
    app.buttons["Join Now"].tap()

    //We should see an Alert popup since the email address is invalid
    app.alerts["Alert"].collectionViews.buttons["OK"].tap()
  }

  func testSignupWithInvalidEmail2() {
    let app = XCUIApplication()
    app.buttons["Sign Up"].tap()

    let nameTextField = app.textFields["Name:"]
    nameTextField.tap()
    nameTextField.typeText("Bowen Zhang")

    let emailTextField = app.textFields["Email:"]
    emailTextField.tap()
    emailTextField.typeText("bzhang@test")

    let passwordSecureTextField = app.secureTextFields["Password:"]
    passwordSecureTextField.tap()
    passwordSecureTextField.typeText("123456")
    app.childrenMatchingType(.Window).elementBoundByIndex(0).childrenMatchingType(.Other).elementBoundByIndex(1).childrenMatchingType(.Other).element.tap()

    app.buttons["Join Now"].tap()
    //We should see a popup here since the email lacks of ".com" at the end
    app.alerts["Alert"].collectionViews.buttons["OK"].tap()

  }

  func testSignupWithExistingEmail() {
    let app = XCUIApplication()
    app.buttons["Sign Up"].tap()
    
    let nameTextField = app.textFields["Name:"]
    nameTextField.tap()
    nameTextField.typeText("Bowen")
    
    let emailTextField = app.textFields["Email:"]
    emailTextField.tap()
    emailTextField.typeText("bzhang@test.com")
    
    let passwordSecureTextField = app.secureTextFields["Password:"]
    passwordSecureTextField.tap()
    passwordSecureTextField.typeText("123456")

    app.childrenMatchingType(.Window).elementBoundByIndex(0).childrenMatchingType(.Other).elementBoundByIndex(1).childrenMatchingType(.Other).element.tap()
    app.buttons["Join Now"].tap()

    //We should see a popup indicating user exists already
    let okButton = app.alerts["Alert"].collectionViews.buttons["OK"]
    okButton.tap()
  }

  func testSignupWithUnqualifiedPassword() {
    let app = XCUIApplication()
    app.buttons["Sign Up"].tap()

    let nameTextField = app.textFields["Name:"]
    nameTextField.tap()
    nameTextField.typeText("Irvin")

    let emailTextField = app.textFields["Email:"]
    emailTextField.tap()
    emailTextField.typeText("irvin@test.com")

    let passwordSecureTextField = app.secureTextFields["Password:"]
    passwordSecureTextField.tap()
    passwordSecureTextField.typeText("1234")

    app.childrenMatchingType(.Window).elementBoundByIndex(0).childrenMatchingType(.Other).elementBoundByIndex(1).childrenMatchingType(.Other).element.tap()
    app.buttons["Join Now"].tap()

    //We should see a popup indicating password is not long enough
    let okButton = app.alerts["Alert"].collectionViews.buttons["OK"]
    okButton.tap()
  }
}
