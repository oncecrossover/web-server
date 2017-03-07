//
//  Coin.swift
//  Snoop
//
//  Created by Bowen Zhang on 3/6/17.
//  Copyright © 2017 Bowen Zhang. All rights reserved.
//

import Foundation
class Coin {
  private var generics = Generics()
  private var COINSURI: String

  init() {
    COINSURI = self.generics.HTTPHOST + "coins"
  }

  func getCoinsCount(completion: (NSDictionary) -> ()) {
    let uid = NSUserDefaults.standardUserDefaults().stringForKey("email")!
    generics.getObjectById(NSURL(string: COINSURI + "/" + uid)!) { result in
      completion(result)
    }
  }

  func addCoins(uid: String, count: Int, completion: (String) ->()) {
    let jsonData : [String: AnyObject] = ["uid" : uid, "amount": count]
    generics.createObject(COINSURI, jsonData: jsonData) { result in
      completion(result)
    }
  }
}
