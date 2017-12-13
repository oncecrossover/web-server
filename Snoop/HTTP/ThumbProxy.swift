//
//  ThumbProxy.swift
//  Snoop
//
//  Created by Bingo Zhou on 12/19/17.
//  Copyright © 2017 Vinsider, Inc. All rights reserved.
//

import Foundation

class ThumbProxy {
  fileprivate var generics = Generics()
  fileprivate var RESORUCE_URI: String

  init() {
    RESORUCE_URI = self.generics.HTTPHOST + "thumbs"
  }

  func createUserThumb(_ uid: String, quandaId: String, upped: String, downed: String, completion: @escaping (String) ->()) {
    let jsonData : [String: AnyObject] = ["uid" : uid as AnyObject, "quandaId": quandaId as AnyObject,
                                          "upped": upped as AnyObject, "downed": downed as AnyObject]
    generics.createObject(RESORUCE_URI, jsonData: jsonData) {
      completion($0)
    }
  }
}
