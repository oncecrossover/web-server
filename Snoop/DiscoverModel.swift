//
//  DiscoverModel.swift
//  Snoop
//
//  Created by Bowen Zhang on 8/30/16.
//  Copyright © 2016 Bowen Zhang. All rights reserved.
//

import Foundation
class DiscoverModel {
  var name: String!
  var title: String!
  var avatarImage: NSData?
  var uid: String!
  var about: String!
  var rate: Double!
  var updatedTime: Double!
  var avatarUrl: String?

  init(_name: String!, _title: String!, _avatarImage: NSData?, _uid: String!, _about: String!, _rate: Double!, _updatedTime: Double!, _avatarUrl : String?) {
    name = _name
    title = _title
    uid = _uid
    about = _about
    rate = _rate
    updatedTime = _updatedTime
    avatarUrl = _avatarUrl
    avatarImage = _avatarImage
  }
}
