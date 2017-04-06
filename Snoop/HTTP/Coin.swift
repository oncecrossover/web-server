//
//  Coin.swift
//  Snoop
//
//  Created by Bowen Zhang on 3/6/17.
//  Copyright © 2017 Bowen Zhang. All rights reserved.
//

import Foundation
class Coin {
  fileprivate var generics = Generics()
  fileprivate var COINSURI: String

  init() {
    COINSURI = self.generics.HTTPHOST + "coins"
  }

  func getCoinsCount(_ completion: @escaping (NSDictionary) -> ()) {
    let uid = UserDefaults.standard.integer(forKey: "uid")
    generics.getObjectById(URL(string: COINSURI + "/\(uid)")!) {
      completion($0)
    }
  }

  func addCoins(_ uid: Int, count: Int, completion: @escaping (String) ->()) {
    let jsonData : [String: AnyObject] = ["uid" : uid as AnyObject, "amount": count as AnyObject]
    generics.createObject(COINSURI, jsonData: jsonData) {
      completion($0)
    }
  }
}
