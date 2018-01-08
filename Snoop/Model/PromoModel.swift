//
//  PromoModel.swift
//  Snoop
//
//  Created by Bingo Zhou on 1/8/18.
//  Copyright © 2018 Vinsider, Inc. All rights reserved.
//

import Foundation

class PromoModel {
  var id: String
  var uid: String
  var code: String
  var amount: Int

  init(_id: String, _uid: String, _code: String, _amount: Int) {
    id = _id
    uid = _uid
    code = _code
    amount = _amount
  }

  convenience init(_ modelInfo: [String:AnyObject]) {
    let id = modelInfo["id"] as! String
    let uid = modelInfo["uid"] as! String
    let code = modelInfo["code"] as! String
    let amount = modelInfo["amount"] as! Int

    self.init(_id: id, _uid: uid, _code: code, _amount: amount)
  }
}
