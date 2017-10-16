//
//  ActivityModel.swift
//  Snoop
//
//  Created by Bowen Zhang on 12/27/16.
//  Copyright © 2016 Bowen Zhang. All rights reserved.
//

import Foundation
class ActivityModel {
  var id: String
  var question: String
  var status: String
  var rate: Int
  var duration: Int
  var isAskerAnonymous: Bool
  var askerName: String
  var responderId: String?
  var responderName: String
  var responderTitle: String
  var answerCoverUrl: String?
  var askerAvatarUrl: String?
  var responderAvatarUrl: String?
  var answerUrl: String?
  var lastSeenTime: Double
  var hoursToExpire: Int
  var snoops: Int

  init(_id: String, _question: String, _status: String, _rate: Int, _duration: Int, _isAskerAnonymous: Bool, _askerName: String, _responderId: String?, _responderName: String, _responderTitle: String, _answerCoverUrl: String?, _askerAvatarUrl: String?, _responderAvatarUrl: String?, _answerUrl : String?, _lastSeenTime: Double, _hoursToExpire: Int, _snoops: Int) {
    id = _id
    question = _question
    status = _status
    rate = _rate
    duration = _duration
    isAskerAnonymous = _isAskerAnonymous
    askerName = _askerName
    responderId = _responderId
    responderName = _responderName
    responderTitle = _responderTitle
    answerCoverUrl = _answerCoverUrl
    askerAvatarUrl = _askerAvatarUrl
    responderAvatarUrl = _responderAvatarUrl
    answerUrl = _answerUrl
    lastSeenTime = _lastSeenTime
    hoursToExpire = _hoursToExpire
    snoops = _snoops
  }

  convenience init(_ questionInfo: [String:AnyObject], isSnoop: Bool){
    var questionId = questionInfo["id"] as! String
    var hoursToExpire = 0
    if (isSnoop) {
    questionId = questionInfo["quandaId"] as! String
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
    let responderId = questionInfo["responderId"] as? String
    let responderName = questionInfo["responderName"] as! String
    let responderTitle = questionInfo["responderTitle"] as! String
    let askerAvatarUrl = questionInfo["askerAvatarUrl"] as? String
    let answerCoverUrl = questionInfo["answerCoverUrl"] as? String
    let answerUrl = questionInfo["answerUrl"] as? String
    let askerName = questionInfo["askerName"] as! String
    let duration = questionInfo["duration"] as! Int
    let isAskerAnonymous = (questionInfo["isAskerAnonymous"] as! String).toBool()
    let createdTime = questionInfo["createdTime"] as! Double
    let snoops = questionInfo["snoops"] as! Int

    self.init(_id: questionId, _question: question, _status: status, _rate: rate, _duration: duration, _isAskerAnonymous: isAskerAnonymous, _askerName: askerName, _responderId: responderId, _responderName: responderName, _responderTitle: responderTitle, _answerCoverUrl: answerCoverUrl, _askerAvatarUrl: askerAvatarUrl, _responderAvatarUrl: responderAvatarUrl, _answerUrl: answerUrl, _lastSeenTime: createdTime, _hoursToExpire: hoursToExpire, _snoops: snoops)
  }
}
