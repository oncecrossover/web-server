//
//  CategoryModel.swift
//  Snoop
//
//  Created by Bowen Zhang on 2/27/17.
//  Copyright © 2017 Bowen Zhang. All rights reserved.
//

import Foundation
class CategoryModel: Hashable {
  var id: String
  var name: String
  var url: String

  var hashValue: Int {
    return name.hashValue
  }

  init(_id: String, _name: String, _url: String) {
    id = _id
    name = _name
    url = _url
  }
}

func ==(lhs: CategoryModel, rhs: CategoryModel) -> Bool {
  return lhs.id == rhs.id && lhs.name == rhs.name
}
