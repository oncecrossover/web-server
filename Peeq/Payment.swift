//
//  Payment.swift
//  Peeq
//
//  Created by Bowen Zhang on 7/23/16.
//  Copyright © 2016 Bowen Zhang. All rights reserved.
//

import Foundation

class Payment {

  private var PAYMENTURI: String
  private var generics = Generics()

  init(){
    PAYMENTURI = "http://localhost:8080/pcentries"
  }

  func createPayment(token: String!, completion: (String) ->()) {
    let uid = NSUserDefaults.standardUserDefaults().stringForKey("email")

    let jsonData = ["uid" : uid, "token" : token]
    generics.createObject(PAYMENTURI, jsonData: jsonData) { result in
      completion(result)
    }
  }

  func getPayments(filterString: String!, completion: (NSArray) -> ()) {
    let url = NSURL(string: PAYMENTURI + "?filter=" + filterString)
    let request = NSMutableURLRequest(URL: url!)
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

  func deletePayment(id: Int, completion: (String) -> ()) {
    let url = NSURL(string: PAYMENTURI + "/" + "\(id)")
    let request = NSMutableURLRequest(URL: url!)
    request.HTTPMethod = "DELETE"

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
