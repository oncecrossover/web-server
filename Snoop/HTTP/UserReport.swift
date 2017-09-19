//
//  UserReport.swift
//  Snoop
//
//  Created by Bingo Zhou on 9/12/17.
//  Copyright © 2017 Snoop Technologies Inc. All rights reserved.
//

import Foundation

class UserReport {
  fileprivate var generics = Generics()
  fileprivate var REPORT_URI: String

  init() {
    REPORT_URI = self.generics.HTTPHOST + "reports"
  }

  func createReport(_ uid: String, quandaId: String, completion: @escaping (String) ->()) {
    let jsonData : [String: AnyObject] = ["uid" : uid as AnyObject, "quandaId": quandaId as AnyObject]
    generics.createObject(REPORT_URI, jsonData: jsonData) {
      completion($0)
    }
  }
}
