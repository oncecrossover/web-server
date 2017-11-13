//
//  UserFollowModel.swift
//  Snoop
//
//  Created by Bingo Zhou on 11/13/17.
//  Copyright © 2017 Vinsider Inc. All rights reserved.
//

import Foundation

class UserFollowModel {

  var id: String
  var uid: String
  var followeeId: String
  var followed: String

  init(_id: String, _uid: String, _followeeId: String, _followed: String) {
    id = _id
    uid = _uid
    followeeId = _followeeId
    followed = _followed
  }

  convenience init(_ userFollowInfo: [String:AnyObject]) {
    let id = userFollowInfo["id"] as! String
    let uid = userFollowInfo["uid"] as! String
    let followeeId = userFollowInfo["followeeId"] as! String
    let followed = userFollowInfo["followed"] as! String

    self.init(_id: id, _uid: uid, _followeeId: followeeId, _followed: followed)
  }
}

