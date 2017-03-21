//
//  ProfileViewControllerUITests.swift
//  Snoop
//
//  Created by Bowen Zhang on 9/3/16.
//  Copyright © 2016 Bowen Zhang. All rights reserved.
//

import XCTest

class ProfileViewControllerUITests: XCTestCase {

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

  func testProfileEdit() {
    let app = XCUIApplication()
    let emailTextField = app.textFields["Email:"]
    emailTextField.tap()
    emailTextField.typeText("bzhang@test.com")

    let passwordSecureTextField = app.secureTextFields["Password:"]
    passwordSecureTextField.tap()
    passwordSecureTextField.typeText("1234")

    app.buttons["Log In"].tap()
    app.tabBars.buttons["Me"].tap()
    app.buttons["edit"].tap()

    let textField = app.scrollViews.children(matching: .textField).element(boundBy: 1)
    textField.tap()

    textField.clearAndEnterText("digital CEO")
    app.buttons["Return"].tap()
    app.buttons["Save"].tap()

    let newTitle = app.staticTexts["digital CEO"]
    XCTAssertFalse(newTitle.exists)

    let exists = NSPredicate(format: "exists == true")
    expectation(for: exists, evaluatedWith: newTitle, handler: nil)
    waitForExpectations(timeout: 5, handler: nil)
    XCTAssert(newTitle.exists)

    newTitle.tap()
    app.buttons["Log Out"].tap()
  }

}

extension XCUIElement {
  /**
   Removes any current text in the field before typing in the new value
   - Parameter text: the text to enter into the field
   */
  func clearAndEnterText(_ text: String) -> Void {
    guard let stringValue = self.value as? String else {
      XCTFail("Tried to clear and enter text into a non string value")
      return
    }

    self.tap()

    var deleteString: String = ""
    for _ in stringValue.characters {
      deleteString += "\u{8}"
    }
    self.typeText(deleteString)

    self.typeText(text)
  }
}
