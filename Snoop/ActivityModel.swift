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
  var rate: Double!
  var answerCover: NSData?
  var duration: Int!
  var askerName: String!
  var askerImage: NSData?
  var responderName: String!
  var responderTitle: String!
  var responderImage: NSData?
  var answerCoverUrl: String?
  var askerAvatarUrl: String?
  var responderAvatarUrl: String?
  var answerUrl: String?

  init(_id: Int!, _question: String!, _status: String!, _rate: Double!, _duration: Int!, _askerName: String!, _responderName: String!, _responderTitle: String!, _answerCoverUrl: String?, _askerAvatarUrl: String?, _responderAvatarUrl: String?, _answerURl : String?) {
    id = _id
    question = _question
    status = _status
    rate = _rate
    answerCover = nil
    duration = _duration
    askerName = _askerName
    askerImage = nil
    responderName = _responderName
    responderTitle = _responderTitle
    responderImage = nil
    answerCoverUrl = _answerCoverUrl
    askerAvatarUrl = _askerAvatarUrl
    responderAvatarUrl = _responderAvatarUrl
    answerUrl = _answerURl
  }

}
