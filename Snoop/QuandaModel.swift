//
//  QuandaModel.swift
//  Snoop
//
//  Created by Bowen Zhang on 9/3/16.
//  Copyright © 2016 Bowen Zhang. All rights reserved.
//

import Foundation
class QuandaModel: AbstractModel {
  var id: Int!
  var question: String!
  var status: String!
  var isPlaying: Bool!
  var hoursToExpire: Int!
  var rate: Double!

  init(_name: String!, _title: String!, _avatarImage: NSData!, _id: Int!, _question: String!, _status: String!) {
    super.init(_name: _name, _title: _title, _avatarImage: _avatarImage)
    id = _id
    question = _question
    status = _status
    isPlaying = false
    hoursToExpire = 0
    rate = 0.0
  }
}
