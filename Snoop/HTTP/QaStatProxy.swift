//
//  QaStatProxy
//  Snoop
//
//  Created by Bingo Zhou on 12/19/17.
//  Copyright © 2017 Vinsider, Inc. All rights reserved.
//

import Foundation

class QaStatProxy {
  fileprivate var generics = Generics()
  fileprivate var RESORUCE_URI: String

  init() {
    RESORUCE_URI = self.generics.HTTPHOST + "qastats"
  }

  func getQaStats(_ filterString: String, completion: @escaping (NSArray) -> ()) {
    let myUrl: URL! = URL(string: RESORUCE_URI + "?" + filterString)
    generics.getFilteredObjects(myUrl) {
      completion($0)
    }
  }
}
