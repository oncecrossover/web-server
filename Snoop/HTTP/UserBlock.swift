//
//  UserBlock.swift
//  Snoop
//
//  Created by Bingo Zhou on 9/15/17.
//  Copyright © 2017 Snoop Technologies Inc. All rights reserved.
//

import Foundation

class UserBlock {
  fileprivate var generics = Generics()
  fileprivate var BLOCK_URI: String

  init() {
    BLOCK_URI = self.generics.HTTPHOST + "blocks"
  }

  func createUserBlock(_ uid: String, blockeeId: String, blocked: String, completion: @escaping (String) ->()) {
    let jsonData : [String: AnyObject] = ["uid" : uid as AnyObject, "blockeeId": blockeeId as AnyObject, "blocked": blocked as AnyObject]
    generics.createObject(BLOCK_URI, jsonData: jsonData) {
      completion($0)
    }
  }

  func getUserBlocks(_ filterString: String, completion: @escaping (NSArray) -> ()) {
    let myUrl: URL! = URL(string: BLOCK_URI + "?" + filterString)
    generics.getFilteredObjects(myUrl) {
      completion($0)
    }
  }
}
