//
//  Question.swift
//  Peeq
//
//  Created by Bowen Zhang on 7/3/16.
//  Copyright © 2016 Bowen Zhang. All rights reserved.
//

import Foundation

class Question {
  private var QUESTIONURI : String
  private var SNOOPURI : String
  private var QUANDAURI: String
  private var ANSWERURI: String
  private var BULKDATAURI: String
  private var generics = Generics()
  init () {
    SNOOPURI = generics.HTTPHOST + "snoops"
    QUESTIONURI = generics.HTTPHOST + "questions"
    QUANDAURI = generics.HTTPHOST + "quandas"
    ANSWERURI = generics.HTTPHOST + "answers"
    BULKDATAURI = generics.HTTPHOST + "bulkdata"
  }

  func createQuestion(asker: String, question: String, responder: String,
    status: String, completion: (String) -> () ){
      let jsonData = ["asker": asker, "question": question,
        "responder": responder, "status": "PENDING"]
      generics.createObject(QUESTIONURI, jsonData: jsonData) { result in
        completion(result)
      }
  }

  func updateQuestion(id: Int!, answerAudio: NSData!, completion: (String) -> ()) {
      let myUrl = NSURL(string: QUANDAURI + "/" + "\(id)")
      let audioString = answerAudio?.base64EncodedStringWithOptions(NSDataBase64EncodingOptions(rawValue: 0))
      let jsonData: [String: AnyObject] = ["answerAudio": audioString!, "status" : "ANSWERED"]
      generics.updateObject(myUrl!, jsonData: jsonData) { result in
        completion(result)
      }
  }

  func submitAnswer(id: Int!, answerVideo: NSData!, coverPhoto: NSData!, duration: Int!, completion: (String)->()) {
    let myUrl = NSURL(string: QUANDAURI + "/" + "\(id)")
    let videoString = answerVideo?.base64EncodedStringWithOptions(NSDataBase64EncodingOptions(rawValue: 0))
    let photoString = coverPhoto?.base64EncodedStringWithOptions(NSDataBase64EncodingOptions(rawValue: 0))
    let jsonData: [String: AnyObject] = ["answerMedia" : videoString!, "answerCover" : photoString!, "status" : "ANSWERED", "duration" : duration]
    generics.updateObject(myUrl!, jsonData: jsonData) { result in
      completion(result)
    }
  }

  func getActivities(filterString: String, selectedIndex: Int!, completion: (NSArray) -> ()) {
    var myUrl = NSURL()
    if (selectedIndex == 0) {
      myUrl = NSURL(string: QUESTIONURI + "?" + filterString)!
    }
    else if (selectedIndex == 1) {
      myUrl = NSURL(string: ANSWERURI + "?" + filterString)!
    }
    else {
      myUrl = NSURL(string:  SNOOPURI + "?" + filterString)!
    }

    generics.getFilteredObjects(myUrl) { result in
      completion(result)
    }
  }

  func getQuestionMedia(id: Int, completion: (String) -> ()){
    let myUrl = NSURL(string: QUANDAURI + "/" + "\(id)")
    generics.getObjectById(myUrl!) { convertedJsonIntoDict in
      if let storedAudio = convertedJsonIntoDict["answerMedia"] as? String {
        completion(storedAudio)
      }
      else {
        completion("")
      }
    }
  }

  func getQuestionById(id: Int, completion: (NSDictionary) -> ()){
    let myUrl = NSURL(string: QUESTIONURI + "/" + "\(id)")
    generics.getObjectById(myUrl!) { convertedJsonIntoDict in
      completion(convertedJsonIntoDict)
    }
  }

  func getQuestionDatas(url: String, completion: (NSDictionary) -> ()) {
    let myUrl = NSURL(string: BULKDATAURI + "?" + url)
    generics.getObjectById(myUrl!) { convertedJsonIntoDict in
      completion(convertedJsonIntoDict)
    }
  }

  func createSnoop(id: Int, completion: (String) -> ()) {
    let uid = NSUserDefaults.standardUserDefaults().stringForKey("email")!
    let jsonData:[String:AnyObject] = ["uid": uid, "quandaId": id]
    generics.createObject(SNOOPURI, jsonData: jsonData) { result in
      completion(result)
    }
  }
}
