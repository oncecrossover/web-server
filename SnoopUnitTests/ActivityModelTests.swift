//
//  SnoopUnitTests.swift
//  SnoopUnitTests
//
//  Created by Bowen Zhang on 5/26/17.
//  Copyright © 2017 Bowen Zhang. All rights reserved.
//

import XCTest
@testable import Snoop
class ActivityModelTests: XCTestCase {

  override func setUp() {
    super.setUp()
    // Put setup code here. This method is called before the invocation of each test method in the class.
  }

  override func tearDown() {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    super.tearDown()
  }

  func testExample() {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
    let questionInfo: [String: AnyObject] = ["id": "0" as AnyObject, "hoursToExpire": 10 as AnyObject, "question" : "How are you?" as AnyObject, "status": "PENDING" as AnyObject, "rate": 0 as AnyObject, "responderName": "Bingo" as AnyObject, "responderTitle" : "Dad" as AnyObject, "askerName": "Jason" as AnyObject, "duration" : 40 as AnyObject, "createdTime" : 100.0 as AnyObject]

    _ = ActivityModel(questionInfo, isSnoop: false)
  }

}
