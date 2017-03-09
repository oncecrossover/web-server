//
//  ActivityModel.swift
//  Snoop
//
//  Created by Bowen Zhang on 12/27/16.
//  Copyright © 2016 Bowen Zhang. All rights reserved.
//

import Foundation
class ActivityModel {
  var id: Int!
  var question: String!
  var status: String!
  var rate: Int!
  var duration: Int!
  var askerName: String!
  var responderName: String!
  var responderTitle: String!
  var answerCoverUrl: String?
  var askerAvatarUrl: String?
  var responderAvatarUrl: String?
  var answerUrl: String?
  var lastSeenTime: Double!

  init(_id: Int!, _question: String!, _status: String!, _rate: Int!, _duration: Int!, _askerName: String!, _responderName: String!, _responderTitle: String!, _answerCoverUrl: String?, _askerAvatarUrl: String?, _responderAvatarUrl: String?, _answerUrl : String?, _lastSeenTime: Double!) {
    id = _id
    question = _question
    status = _status
    rate = _rate
    duration = _duration
    askerName = _askerName
    responderName = _responderName
    responderTitle = _responderTitle
    answerCoverUrl = _answerCoverUrl
    askerAvatarUrl = _askerAvatarUrl
    responderAvatarUrl = _responderAvatarUrl
    answerUrl = _answerUrl
    lastSeenTime = _lastSeenTime
  }

}
