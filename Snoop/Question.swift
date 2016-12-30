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
  private var generics = Generics()
  init () {
    SNOOPURI = generics.HTTPHOST + "snoops"
    QUESTIONURI = generics.HTTPHOST + "questions"
    QUANDAURI = generics.HTTPHOST + "quandas"
    ANSWERURI = generics.HTTPHOST + "answers"
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
    let jsonData: [String: AnyObject] = ["answerAudio" : videoString!, "answerCover" : photoString!, "status" : "ANSWERED", "duration" : duration]
    generics.updateObject(myUrl!, jsonData: jsonData) { result in
      completion(result)
    }
  }
  func getQuestions(filterString: String, isQuestion: Bool!, completion: (NSArray) -> ()) {
    var myUrl = NSURL(string: QUESTIONURI + "?" + filterString)
    if (!isQuestion) {
      myUrl = NSURL(string: ANSWERURI + "?" + filterString)
    }
    generics.getFilteredObjects(myUrl!) { result in
      completion(result)
    }

  }

  func getQuestionAudio(id: Int, completion: (String) -> ()){
    let myUrl = NSURL(string: QUANDAURI + "/" + "\(id)")
    generics.getObjectById(myUrl!) { convertedJsonIntoDict in
      if let storedAudio = convertedJsonIntoDict["answerAudio"] as? String {
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

  func createSnoop(id: Int, completion: (String) -> ()) {
    let uid = NSUserDefaults.standardUserDefaults().stringForKey("email")!
    let jsonData:[String:AnyObject] = ["uid": uid, "quandaId": id]
    generics.createObject(SNOOPURI, jsonData: jsonData) { result in
      completion(result)
    }
  }

  func getSnoops(uid: String, completion: (NSArray) -> ()) {
    let myUrl = NSURL(string: SNOOPURI + "?uid='" + uid + "'")
    generics.getFilteredObjects(myUrl!) { result in
      completion(result)
    }
  }
}
