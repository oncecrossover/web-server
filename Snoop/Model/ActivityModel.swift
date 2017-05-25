//
//  ActivityModel.swift
//  Snoop
//
//  Created by Bowen Zhang on 12/27/16.
//  Copyright © 2016 Bowen Zhang. All rights reserved.
//

import Foundation
class ActivityModel {
  var id: Int
  var question: String
  var status: String
  var rate: Int
  var duration: Int
  var askerName: String
  var responderName: String
  var responderTitle: String
  var answerCoverUrl: String?
  var askerAvatarUrl: String?
  var responderAvatarUrl: String?
  var answerUrl: String?
  var lastSeenTime: Double
  var hoursToExpire: Int

  init(_id: Int, _question: String, _status: String, _rate: Int, _duration: Int, _askerName: String, _responderName: String, _responderTitle: String, _answerCoverUrl: String?, _askerAvatarUrl: String?, _responderAvatarUrl: String?, _answerUrl : String?, _lastSeenTime: Double, _hoursToExpire: Int) {
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
    hoursToExpire = _hoursToExpire
  }

  convenience init(_ questionInfo: [String:AnyObject], isSnoop: Bool){
    var questionId = questionInfo["id"] as! Int
    var hoursToExpire = 0
    if (isSnoop) {
    questionId = questionInfo["quandaId"] as! Int
    }
    else {
    hoursToExpire = questionInfo["hoursToExpire"] as! Int
    }
    let question = questionInfo["question"] as! String
    let status = questionInfo["status"] as! String
    var rate = 0
    if (questionInfo["rate"] != nil) {
    rate = questionInfo["rate"] as! Int
    }

    let responderAvatarUrl = questionInfo["responderAvatarUrl"] as? String
    let responderName = questionInfo["responderName"] as! String
    let responderTitle = questionInfo["responderTitle"] as! String
    let askerAvatarUrl = questionInfo["askerAvatarUrl"] as? String
    let answerCoverUrl = questionInfo["answerCoverUrl"] as? String
    let answerUrl = questionInfo["answerUrl"] as? String
    let askerName = questionInfo["askerName"] as! String
    let duration = questionInfo["duration"] as! Int
    let createdTime = questionInfo["createdTime"] as! Double

    self.init(_id: questionId, _question: question, _status: status, _rate: rate, _duration: duration, _askerName: askerName, _responderName: responderName, _responderTitle: responderTitle, _answerCoverUrl: answerCoverUrl, _askerAvatarUrl: askerAvatarUrl, _responderAvatarUrl: responderAvatarUrl, _answerUrl: answerUrl, _lastSeenTime: createdTime, _hoursToExpire: hoursToExpire)
  }
}
