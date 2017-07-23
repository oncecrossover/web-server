//
//  InterestModel.swift
//  Snoop
//
//  Created by Bowen Zhang on 2/27/17.
//  Copyright © 2017 Bowen Zhang. All rights reserved.
//

import Foundation
class InterestModel: Hashable {
  var id: String?
  var catId: String
  var name: String
  init(_id: String?, _catId: String, _name: String) {
    id = _id
    catId = _catId
    name = _name
  }

  convenience init(_catId: String, _name: String) {
    self.init(_id: nil, _catId: _catId, _name: _name)
  }

  var hashValue: Int {
    return name.hashValue
  }
}

typealias ExpertiseModel = InterestModel
func ==(lhs: InterestModel, rhs: InterestModel) -> Bool {
  return lhs.catId == rhs.catId
}
