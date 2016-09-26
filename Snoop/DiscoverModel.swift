//
//  DiscoverModel.swift
//  Snoop
//
//  Created by Bowen Zhang on 8/30/16.
//  Copyright © 2016 Bowen Zhang. All rights reserved.
//

import Foundation
class DiscoverModel : AbstractModel {
  var uid: String!
  var about: String!
  var rate: Double!
  var updatedTime: Double!

  init(_name: String!, _title: String!, _avatarImage: NSData!, _uid: String!, _about: String!, _rate: Double!, _updatedTime: Double!) {
    super.init(_name: _name, _title: _title, _avatarImage: _avatarImage)
    self.uid = _uid
    self.about = _about
    self.rate = _rate
    self.updatedTime = _updatedTime
  }
}