//
//  FeedsModel.swift
//  Snoop
//
//  Created by Bowen Zhang on 9/5/16.
//  Copyright © 2016 Bowen Zhang. All rights reserved.
//

import Foundation
class FeedsModel {
  var name: String
  var title: String
  var id: Int
  var question: String
  var status: String
  var snoops: Int
  var responderId: Int
  var updatedTime: Double
  var duration: Int
  var responderAvatarUrl: String?
  var askerAvatarUrl: String?
  var coverUrl: String?
  var answerUrl: String
  var rate: Int
  init(_name: String, _title: String, _id: Int, _question: String, _status: String, _responderId: Int, _snoops: Int, _updatedTime: Double,  _duration: Int, _responderAvatarUrl: String?, _askerAvatarUrl: String?, _coverUrl: String?, _answerUrl: String, _rate: Int) {
    name = _name
    title = _title
    id = _id
    question = _question
    status = _status
    responderId = _responderId
    snoops = _snoops
    updatedTime = _updatedTime
    duration = _duration
    responderAvatarUrl = _responderAvatarUrl
    askerAvatarUrl = _askerAvatarUrl
    coverUrl = _coverUrl
    answerUrl = _answerUrl
    rate = _rate
  }
}
