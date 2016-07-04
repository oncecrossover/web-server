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

        // You can print out response object
        print("response = \(response)")

        // Print out response body
        let responseString = NSString(data: data!, encoding: NSUTF8StringEncoding)
        print("responseString = \(responseString)")
        completion("")
        
      }
      task.resume()
  }
}
