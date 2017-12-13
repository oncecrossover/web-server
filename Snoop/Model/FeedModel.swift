//
//  FeedModel
//  Snoop
//
//  Created by Bowen Zhang on 9/5/16.
//  Copyright © 2016 Bowen Zhang. All rights reserved.
//

import Foundation
class FeedModel {
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

  convenience init(_ feedEntry: [String:AnyObject]){
    let questionId = feedEntry["id"] as! String
    let question = feedEntry["question"] as! String
    let responderId = feedEntry["responderId"] as! String
    let numberOfSnoops = feedEntry["snoops"] as! Int
    let responderName = feedEntry["responderName"] as! String
    let askerName = feedEntry["askerName"] as! String
    let updatedTime = feedEntry["updatedTime"] as! Double

    var responderTitle = ""
    if let title = feedEntry["responderTitle"] as? String {
      responderTitle = title
    }

    let responderAvatarUrl = feedEntry["responderAvatarUrl"] as? String
    let askerAvatarUrl = feedEntry["askerAvatarUrl"] as? String
    let coverUrl = feedEntry["answerCoverUrl"] as? String
    let answerUrl = feedEntry["answerUrl"] as? String

    let duration = feedEntry["duration"] as! Int
    let isAskerAnonymous = (feedEntry["isAskerAnonymous"] as! String).toBool();
    let rate = feedEntry["rate"] as! Int
    let freeForHours = feedEntry["freeForHours"] as! Int
    self.init(_responderName: responderName, _responderTitle: responderTitle, _id: questionId, _question: question, _status: "ANSWERED", _responderId: responderId, _snoops: numberOfSnoops, _updatedTime: updatedTime,  _duration: duration, _isAskerAnonymous: isAskerAnonymous, _responderAvatarUrl: responderAvatarUrl, _askerAvatarUrl: askerAvatarUrl, _askerName: askerName, _coverUrl: coverUrl, _answerUrl: answerUrl!, _rate: rate, _freeForHours: freeForHours)
  }
}
