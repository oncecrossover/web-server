//
//  AbstractModel.swift
//  Snoop
//
//  Created by Bowen Zhang on 8/30/16.
//  Copyright © 2016 Bowen Zhang. All rights reserved.
//

import Foundation
class AbstractModel {
  var name: String!
  var title: String!
  var avatarImage: NSData!

  init(_name: String!, _title: String!, _avatarImage: NSData!) {
    self.name = _name
    self.title = _title
    self.avatarImage = _avatarImage
  }
}
