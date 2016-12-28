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
  var answerCover: NSData!
  var askerName: String!
  var askerImage: NSData!
  var responderName: String!
  var responderTitle: String!
  var responderImage: NSData!
  init(_id: Int!, _question: String!, _status: String!, _rate: Double!, _answerCover: NSData!, _askerName: String!, _askerImage: NSData!, _responderName: String!, _responderTitle: String!, _responderImage: NSData!) {
    id = _id
    question = _question
    status = _status
    rate = _rate
    answerCover = _answerCover
    askerName = _askerName
    askerImage = _askerImage
    responderName = _responderName
    responderTitle = _responderTitle
    responderImage = _responderImage
  }

}
