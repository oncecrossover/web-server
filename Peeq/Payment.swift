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

  init(){
    PAYMENTURI = "http://localhost:8080/payments"
  }

  func createPayment(type: String!, lastFour: String!, token: String!, completion: (String) ->()) {
    let uid = NSUserDefaults.standardUserDefaults().stringForKey("email")
    let url = NSURL(string: PAYMENTURI + "/")
    let request = NSMutableURLRequest(URL: url!)
    request.HTTPMethod = "POST"

    let jsonData = ["uid" : uid, "type" : type, "lastFour" : lastFour, "token" : token]

    do {
      request.HTTPBody =  try NSJSONSerialization.dataWithJSONObject(jsonData, options: [])
    }
    catch {
      print("error=\(error)")
      completion("an error occurs when creating payment: \(error)")
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
