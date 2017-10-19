//
//  FeedsModel.swift
//  Snoop
//
//  Created by Bowen Zhang on 9/5/16.
//  Copyright © 2016 Bowen Zhang. All rights reserved.
//

import Foundation
class FeedsModel {
  var responderName: String
  var responderTitle: String
  var id: String
  var question: String
  var status: String
  var snoops: Int
  var responderId: String
  var updatedTime: Double
  var duration: Int
  var isAskerAnonymous: Bool
  var responderAvatarUrl: String?
  var askerAvatarUrl: String?
  var askerName: String
  var coverUrl: String?
  var answerUrl: String
  var rate: Int
  var freeForHours: Int
  init(_responderName: String, _responderTitle: String, _id: String, _question: String, _status: String, _responderId: String, _snoops: Int, _updatedTime: Double,  _duration: Int, _isAskerAnonymous: Bool, _responderAvatarUrl: String?, _askerAvatarUrl: String?, _askerName: String, _coverUrl: String?, _answerUrl: String, _rate: Int, _freeForHours: Int) {
    responderName = _responderName
    responderTitle = _responderTitle
    id = _id
    question = _question
    status = _status
    responderId = _responderId
    snoops = _snoops
    updatedTime = _updatedTime
    duration = _duration
    isAskerAnonymous = _isAskerAnonymous
    responderAvatarUrl = _responderAvatarUrl
    askerAvatarUrl = _askerAvatarUrl
    askerName = _askerName
    coverUrl = _coverUrl
    answerUrl = _answerUrl
    rate = _rate
    freeForHours = _freeForHours
  }
}
