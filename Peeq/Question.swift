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
  private var generics = Generics()
  init () {
    SNOOPURI = "http://localhost:8080/snoops"
    QUESTIONURI = "http://localhost:8080/quandas"
  }

  func createQuestion(asker: String, question: String, responder: String,
    status: String, completion: (String) -> () ){
      let jsonData = ["asker": asker, "question": question,
        "responder": responder, "status": "PENDING"]
      generics.createObject(QUESTIONURI, jsonData: jsonData) { result in
        completion(result)
      }
  }

  func updateQuestion(id: Int!, askerId: String!, content: String!, responderId: String!,
    answerAudio: NSData!, completion: (String) -> ()) {
      let myUrl = NSURL(string: QUESTIONURI + "/" + "\(id)")
//      let request = NSMutableURLRequest(URL: myUrl!)
//      request.HTTPMethod = "PUT"
      let audioString = answerAudio?.base64EncodedStringWithOptions(NSDataBase64EncodingOptions(rawValue: 0))
      let jsonData: [String: AnyObject] = ["asker": askerId, "question" : content, "responder":responderId,
                  "answerAudio": audioString!, "status" : "ANSWERED"]
//
//      do {
//        request.HTTPBody =  try NSJSONSerialization.dataWithJSONObject(jsonData, options: [])
//      }
//      catch {
//        print("error=\(error)")
//        completion("an error occurs when uploading audio: \(error)")
//      }
//      let task = NSURLSession.sharedSession().dataTaskWithRequest(request) {
//        data, response, error in
//        if (error != nil)
//        {
//          print("error=\(error)")
//          return
//        }
//
//        completion("")
//
//      }
//      task.resume()

      generics.updateObject(myUrl!, jsonData: jsonData) { result in
        completion(result)
      }
  }

  func getQuestions(filterString: String, completion: (NSArray) -> ()) {
    let myUrl = NSURL(string: QUESTIONURI + "?filter=" + filterString)
    let request = NSMutableURLRequest(URL: myUrl!)
    request.HTTPMethod = "GET"
    let task = NSURLSession.sharedSession().dataTaskWithRequest(request){
      data, response, error in
      if error != nil {
        print ("error: \(error)")
        return
      }

      do {
        if let jsonArray = try NSJSONSerialization.JSONObjectWithData(data!, options: []) as? NSArray {
          completion(jsonArray)
        }
      } catch let error as NSError {
        print(error.localizedDescription)
      }
    }
    task.resume()
    
  }

  func getQuestionAudio(id: Int, completion: (String) -> ()){
    let myUrl = NSURL(string: QUESTIONURI + "/" + "\(id)")
    let request = NSMutableURLRequest(URL: myUrl!)
    request.HTTPMethod = "GET"
    let task = NSURLSession.sharedSession().dataTaskWithRequest(request) {
      data, response, error in
      if error != nil {
        print ("error: \(error)")
        return
      }

      do {
        if let convertedJsonIntoDict = try NSJSONSerialization.JSONObjectWithData(data!, options: []) as? NSDictionary {

          if let storedAudio = convertedJsonIntoDict["answerAudio"] as? String {
            completion(storedAudio)
          }
          else {
            completion("")
          }
        }
      } catch let error as NSError {
        print(error.localizedDescription)
      }
      
    }
    task.resume()
  }

  func getQuestionById(id: Int, completion: (String, String) -> ()){
    let myUrl = NSURL(string: QUESTIONURI + "/" + "\(id)")
    let request = NSMutableURLRequest(URL: myUrl!)
    request.HTTPMethod = "GET"
    let task = NSURLSession.sharedSession().dataTaskWithRequest(request) {
      data, response, error in
      if error != nil {
        print ("error: \(error)")
        return
      }

      do {
        if let convertedJsonIntoDict = try NSJSONSerialization.JSONObjectWithData(data!, options: []) as? NSDictionary {

          let responderId = convertedJsonIntoDict["responder"] as! String
          let quesiton = convertedJsonIntoDict["question"] as! String
          completion(responderId, quesiton)
        }
      } catch let error as NSError {
        print(error.localizedDescription)
      }

    }
    task.resume()
  }

  func createSnoop(id: Int, completion: (String) -> ()) {
    let uid = NSUserDefaults.standardUserDefaults().stringForKey("email")!
    let jsonData:[String:AnyObject] = ["uid": uid, "quandaId": id]
    generics.createObject(SNOOPURI, jsonData: jsonData) { result in
      completion(result)
    }
  }

  func getSnoops(uid: String, completion: (NSArray) -> ()) {
    let myUrl = NSURL(string: SNOOPURI + "?filter=uid=" + uid)
    let request = NSMutableURLRequest(URL: myUrl!)
    request.HTTPMethod = "GET"

    let task = NSURLSession.sharedSession().dataTaskWithRequest(request){
      data, response, error in
      if error != nil {
        print ("error: \(error)")
        return
      }

      do {
        if let jsonArray = try NSJSONSerialization.JSONObjectWithData(data!, options: []) as? NSArray {
          completion(jsonArray)
        }
      } catch let error as NSError {
        print(error.localizedDescription)
      }
    }
    task.resume()
  }
}
