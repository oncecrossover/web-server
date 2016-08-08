//
//  Generics.swift
//  Peeq
//
//  Created by Bowen Zhang on 8/8/16.
//  Copyright © 2016 Bowen Zhang. All rights reserved.
//

import Foundation
class Generics {
  init() {
  }

  func createObject(URI: String, jsonData: [String:AnyObject], completion: (String) -> ()) {
    let myUrl = NSURL(string: URI);
    let request = NSMutableURLRequest(URL:myUrl!);
    request.HTTPMethod = "POST";

    do {
      request.HTTPBody =  try NSJSONSerialization.dataWithJSONObject(jsonData, options: [])
    }
    catch {
      print("error=\(error)")
      completion("an error occurs when creating object: \(error)")
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

}
