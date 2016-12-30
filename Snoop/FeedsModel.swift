//
//  FeedsModel.swift
//  Snoop
//
//  Created by Bowen Zhang on 9/5/16.
//  Copyright © 2016 Bowen Zhang. All rights reserved.
//

import Foundation
class FeedsModel: QuandaModel {
  var snoops: Int!
  var responderId: String!
  var updatedTime: Double!
  var coverImage: NSData!
  var duration: Int!
  init(_name: String!, _title: String!, _avatarImage: NSData!, _id: Int!, _question: String!, _status: String!, _responderId: String!, _snoops: Int!, _updatedTime: Double!, _coverImage: NSData!, _duration: Int!) {
    super.init(_name: _name, _title: _title, _avatarImage: _avatarImage, _id: _id, _question: _question, _status: _status)
    responderId = _responderId
    snoops = _snoops
    updatedTime = _updatedTime
    coverImage = _coverImage
    duration = _duration
  }
}
