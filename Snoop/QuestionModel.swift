//
//  QuestionModel.swift
//  Snoop
//
//  Created by Bowen Zhang on 9/4/16.
//  Copyright © 2016 Bowen Zhang. All rights reserved.
//

import Foundation
class QuestionModel: QuandaModel {
  init(_name: String!, _title: String!, _avatarImage: NSData!, _id: Int!, _question: String!, _status: String!, _isPlaying: Bool!, _rate: Double!, _hoursToExpire: Int!) {
    super.init(_name: _name, _title: _title, _avatarImage: _avatarImage, _id: _id, _question: _question, _status: _status)
    isPlaying = _isPlaying
    rate = _rate
    hoursToExpire = _hoursToExpire
  }
}
