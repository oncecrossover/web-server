//
//  Question.swift
//  Peeq
//
//  Created by Bowen Zhang on 7/3/16.
//  Copyright © 2016 Bowen Zhang. All rights reserved.
//

import Foundation

class Question {
  fileprivate var QUESTIONURI : String
  fileprivate var SNOOPURI : String
  fileprivate var QUANDAURI: String
  fileprivate var ANSWERURI: String
  fileprivate var BULKDATAURI: String
  fileprivate var generics = Generics()
  init () {
    SNOOPURI = generics.HTTPHOST + "snoops"
    QUESTIONURI = generics.HTTPHOST + "questions"
    QUANDAURI = generics.HTTPHOST + "quandas"
    ANSWERURI = generics.HTTPHOST + "answers"
    BULKDATAURI = generics.HTTPHOST + "bulkdata"
  }

  func createQuestion(_ asker: String, question: String, responder: String,
    status: String, completion: @escaping (String) -> () ){
      let jsonData = ["asker": asker, "question": question,
        "responder": responder, "status": "PENDING"]
      generics.createObject(QUESTIONURI, jsonData: jsonData as [String : AnyObject]) {
        completion($0)
      }
  }

  func updateQuestion(_ id: String!, answerAudio: Data!, completion: @escaping (String) -> ()) {
      let myUrl = URL(string: QUANDAURI + "/" + "\(id)")
      let audioString = answerAudio?.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0))
      let jsonData: [String: AnyObject] = ["answerAudio": audioString! as AnyObject, "status" : "ANSWERED" as AnyObject]
      generics.updateObject(myUrl!, jsonData: jsonData) {
        completion($0)
      }
  }

  func submitAnswer(_ id: String, answerVideo: Data, coverPhoto: Data, duration: Int, completion: @escaping (String)->()) {
    let myUrl = URL(string: QUANDAURI + "/" + "\(id)")
    let videoString = answerVideo.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0))
    let photoString = coverPhoto.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0))
    let jsonData: [String: AnyObject] = ["answerMedia" : videoString as AnyObject, "answerCover" : photoString as AnyObject, "status" : "ANSWERED" as AnyObject, "duration" : duration as AnyObject]
    generics.updateObject(myUrl!, jsonData: jsonData) {
      completion($0)
    }
  }

  func getActivities(_ filterString: String, selectedIndex: Int!, completion: @escaping (NSArray) -> ()) {
    var myUrl: URL!
    if (selectedIndex == 0) {
      myUrl = URL(string: QUESTIONURI + "?" + filterString)!
    }
    else if (selectedIndex == 1) {
      myUrl = URL(string: ANSWERURI + "?" + filterString)!
    }
    else {
      myUrl = URL(string:  SNOOPURI + "?" + filterString)!
    }

    generics.getFilteredObjects(myUrl) {
      completion($0)
    }
  }

  func getQuestionMedia(_ id: String, completion: @escaping (String) -> ()){
    let myUrl = URL(string: QUANDAURI + "/" + "\(id)")
    generics.getObjectById(myUrl!) { convertedJsonIntoDict in
      if let storedAudio = convertedJsonIntoDict["answerMedia"] as? String {
        completion(storedAudio)
      }
      else {
        completion("")
      }
    }
  }

  func getQuestionById(_ id: String, completion: @escaping (NSDictionary) -> ()){
    let myUrl = URL(string: QUESTIONURI + "/" + "\(id)")
    generics.getObjectById(myUrl!) {
      completion($0)
    }
  }

  func getQuestionDatas(_ url: String, completion: @escaping (NSDictionary) -> ()) {
    let myUrl = URL(string: BULKDATAURI + "?" + url)
    generics.getObjectById(myUrl!) {
      completion($0)
    }
  }

  func createSnoop(_ id: String, completion: @escaping (String) -> ()) {
    let uid = UserDefaults.standard.string(forKey: "email")!
    let jsonData:[String:AnyObject] = ["uid": uid as AnyObject, "quandaId": id as AnyObject]
    generics.createObject(SNOOPURI, jsonData: jsonData) {
      completion($0)
    }
  }
}
