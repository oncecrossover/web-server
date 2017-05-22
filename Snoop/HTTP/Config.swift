//
//  Config.swift
//  Snoop
//
//  Created by Bowen Zhang on 5/22/17.
//  Copyright © 2017 Bowen Zhang. All rights reserved.
//

import Foundation
class Config {
  fileprivate var CONFIGURI: String
  fileprivate var generics = Generics()
  init() {
    CONFIGURI = generics.HTTPHOST + "configurations"
  }

  func getConfigByKey(_ key: String, completion: @escaping (NSDictionary) -> ()) {
    let url = URL(string: CONFIGURI + "?ckey='\(key)'")!
    generics.getFilteredObjects(url) { results in
      let result = results[0] as! NSDictionary
      completion(result)
    }
  }
}
