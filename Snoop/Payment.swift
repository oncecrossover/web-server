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
    PAYMENTURI = generics.HTTPHOST + "pcentries"
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
    generics.getFilteredObjects(url!) { result in
      completion(result)
    }
  }

  func deletePayment(id: Int, completion: (String) -> ()) {
    let url = NSURL(string: PAYMENTURI + "/" + "\(id)")
    let request = NSMutableURLRequest(URL: url!)
    request.HTTPMethod = "DELETE"
    let session = generics.getURLSession()
    let task = session.dataTaskWithRequest(request) {
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
