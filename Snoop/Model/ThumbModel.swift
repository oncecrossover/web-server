//
//  ThumbModel.swift
//  Snoop
//
//  Created by Bingo Zhou on 12/19/17.
//  Copyright © 2017 Vinsider, Inc. All rights reserved.
//

import Foundation

class ThumbModel {
  var id: String
  var uid: String
  var quandaId: String
  var upped: String
  var downed: String

  init(_id: String, _uid: String, _quandaId: String, _upped: String, _downed: String) {
    id = _id
    uid = _uid
    quandaId = _quandaId
    upped = _upped
    downed = _downed
  }

  convenience init(_ thumbModelInfo: [String:AnyObject]) {
    let id = thumbModelInfo["id"] as! String
    let uid = thumbModelInfo["uid"] as! String
    let quandaId = thumbModelInfo["quandaId"] as! String
    let upped = thumbModelInfo["upped"] as! String
    let downed = thumbModelInfo["downed"] as! String

    self.init(_id: id, _uid: uid, _quandaId: quandaId, _upped: upped, _downed: downed)
  }
}
