//
//  CategoryModel.swift
//  Snoop
//
//  Created by Bowen Zhang on 2/27/17.
//  Copyright © 2017 Bowen Zhang. All rights reserved.
//

import Foundation
class CategoryModel: Hashable {
  var id: Int
  var name: String

  var hashValue: Int {
    return "\(id), \(name)".hashValue
  }

  init(_id: Int, _name: String) {
    id = _id
    name = _name
  }
}

func ==(lhs: CategoryModel, rhs: CategoryModel) -> Bool {
  return lhs.id == rhs.id && lhs.name == rhs.name
}
