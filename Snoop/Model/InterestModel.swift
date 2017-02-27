//
//  InterestModel.swift
//  Snoop
//
//  Created by Bowen Zhang on 2/27/17.
//  Copyright © 2017 Bowen Zhang. All rights reserved.
//

import Foundation
class InterestModel: Hashable {
  var id: Int?
  var catId: Int
  init(_id: Int?, _catId: Int) {
    id = _id
    catId = _catId
  }

  convenience init(_catId: Int) {
    self.init(_id: nil, _catId: _catId)
  }

  var hashValue: Int {
    return catId
  }
}

typealias ExpertiseModel = InterestModel
func ==(lhs: InterestModel, rhs: InterestModel) -> Bool {
  return lhs.catId == rhs.catId
}
