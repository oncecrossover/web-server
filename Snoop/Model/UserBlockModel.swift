//
//  UserBlockModel.swift
//  Snoop
//
//  Created by Bingo Zhou on 9/15/17.
//  Copyright © 2017 Snoop Technologies Inc. All rights reserved.
//

import Foundation

class UserBlockModel {

  var id: String
  var uid: String
  var blockeeId: String
  var blocked: String

  init(_id: String, _uid: String, _blockeeId: String, _blocked: String) {
    id = _id
    uid = _uid
    blockeeId = _blockeeId
    blocked = _blocked
  }

  convenience init(_ userBlockInfo: [String:AnyObject]){
    let id = userBlockInfo["id"] as! String
    let uid = userBlockInfo["uid"] as! String
    let blockeeId = userBlockInfo["blockeeId"] as! String
    let blocked = userBlockInfo["blocked"] as! String

    self.init(_id: id, _uid: uid, _blockeeId: blockeeId, _blocked: blocked)
  }
}
