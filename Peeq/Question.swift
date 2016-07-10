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
  init () {
    QUESTIONURI = "http://localhost:8080/quandas"
  }

  func createQuestion(asker: String, question: String, responder: String,
    status: String, completion: (String) -> () ){
      let myUrl = NSURL(string: QUESTIONURI);
      let request = NSMutableURLRequest(URL:myUrl!);
      request.HTTPMethod = "POST";
      let jsonData = ["asker": asker, "question": question,
        "responder": responder, "status": "PENDING"]

      do {
        request.HTTPBody =  try NSJSONSerialization.dataWithJSONObject(jsonData, options: [])
      }
      catch {
        print("error=\(error)")
        completion("an error occurs when creating user: \(error)")
      }
      let task = NSURLSession.sharedSession().dataTaskWithRequest(request) {
        data, response, error in
        if (error != nil)
        {
          print("error=\(error)")
          return
        }

        completion("")
        
      }
      task.resume()
  }

  func updateQuestion(id: Int!, askerId: String!, content: String!, responderId: String!,
    answerAudio: NSData!, completion: (String) -> ()) {
      let myUrl = NSURL(string: QUESTIONURI + "/" + "\(id)")
      let request = NSMutableURLRequest(URL: myUrl!)
      request.HTTPMethod = "PUT"
      let audioString = answerAudio?.base64EncodedStringWithOptions(NSDataBase64EncodingOptions(rawValue: 0))

      do {
        let jsonData: [String: AnyObject] = ["asker": askerId, "question" : content, "responder":responderId,
          "answerAudio": audioString!, "status" : "ANSWERED"]

        request.HTTPBody =  try NSJSONSerialization.dataWithJSONObject(jsonData, options: [])
      }
      catch {
        print("error=\(error)")
        completion("an error occurs when uploading audio: \(error)")
      }
      let task = NSURLSession.sharedSession().dataTaskWithRequest(request) {
        data, response, error in
        if (error != nil)
        {
          print("error=\(error)")
          return
        }

        completion("")

      }
      task.resume()
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
        if data!.length == 1 {
          let emptyResult: [[String:AnyObject]] = []
          completion(emptyResult)
        }
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
}
