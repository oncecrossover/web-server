//
//  AnswerModel.swift
//  Snoop
//
//  Created by Bowen Zhang on 9/4/16.
//  Copyright © 2016 Bowen Zhang. All rights reserved.
//

import Foundation
class AnswerModel : QuandaModel {
  init(_name: String!, _title: String!, _avatarImage: NSData!, _id: Int!, _question: String!, _status: String!, _hoursToExpire: Int!,_rate: Double!) {
    super.init(_name: _name, _title: _title, _avatarImage: _avatarImage, _id: _id, _question: _question, _status: _status)
    hoursToExpire = _hoursToExpire
    rate = _rate
  }
}
