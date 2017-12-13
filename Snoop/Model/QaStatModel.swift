//
//  QaStatModel.swift
//  Snoop
//
//  Created by Bingo Zhou on 12/19/17.
//  Copyright © 2017 Vinsider, Inc. All rights reserved.
//

import Foundation

class QaStatModel {
  var id: String
  var snoops: Int
  var thumbups: Int
  var thumbdowns: Int
  var thumbupped: String
  var thumbdowned: String

  init(_id: String, _snoops: Int, _thumbups: Int, _thumbdowns: Int,
       _thumbupped: String, _thumbdowned: String) {
    id = _id
    snoops = _snoops
    thumbups = _thumbups
    thumbdowns = _thumbdowns
    thumbupped = _thumbupped
    thumbdowned = _thumbdowned
  }

  convenience init(_ qaStatModelInfo: [String:AnyObject]) {
    let id = qaStatModelInfo["id"] as! String
    let snoops = qaStatModelInfo["snoops"] as! Int
    let thumbups = qaStatModelInfo["thumbups"] as! Int
    let thumbdowns = qaStatModelInfo["thumbdowns"] as! Int
    let thumbupped = qaStatModelInfo["thumbupped"] as! String
    let thumbdowned = qaStatModelInfo["thumbdowned"] as! String

    self.init(_id: id, _snoops: snoops, _thumbups: thumbups, _thumbdowns: thumbdowns,
              _thumbupped: thumbupped, _thumbdowned: thumbdowned)
  }
}
