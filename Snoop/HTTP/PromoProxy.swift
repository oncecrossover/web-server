//
//  PromoProxy.swift
//  Snoop
//
//  Created by Bingo Zhou on 1/8/18.
//  Copyright © 2018 Vinsider, Inc. All rights reserved.
//

import Foundation

class PromoProxy {
  fileprivate var generics = Generics()
  fileprivate var RESORUCE_URI: String

  init() {
    RESORUCE_URI = self.generics.HTTPHOST + "promos"
  }

  func getPromo(_ filterString: String, completion: @escaping (NSArray) -> ()) {
    let myUrl: URL! = URL(string: RESORUCE_URI + "?" + filterString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)
    generics.getFilteredObjects(myUrl) {
      completion($0)
    }
  }
}
